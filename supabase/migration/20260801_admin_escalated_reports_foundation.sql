-- Social Vote — AC8.5 / AC9
-- Escalation to administrator: backend state and dedicated pending queue.
--
-- This migration:
-- 1. makes escalate_to_admin a pending administrative state, not a final result;
-- 2. reopens existing escalated reports that have no administrator resolution;
-- 3. stores the future final administrator resolution separately;
-- 4. exposes a service-role-only read model for the administrator queue.
--
-- The Flutter UI and Edge Function wiring are subsequent micro-steps.

begin;

alter table public.reports
  add column if not exists admin_resolution text,
  add column if not exists admin_resolution_note text,
  add column if not exists admin_resolved_by uuid,
  add column if not exists admin_resolved_at timestamptz;

comment on column public.reports.admin_resolution is
  'Final administrator outcome for a report previously escalated_to_admin.';

comment on column public.reports.admin_resolution_note is
  'Mandatory administrator note explaining the final escalation outcome.';

comment on column public.reports.admin_resolved_by is
  'Administrator user id that completed the escalated report.';

comment on column public.reports.admin_resolved_at is
  'Timestamp at which the administrator completed the escalated report.';

do $$
begin
  if not exists (
    select 1
    from pg_catalog.pg_constraint
    where conrelid = 'public.reports'::regclass
      and conname = 'reports_admin_resolution_value_check'
  ) then
    alter table public.reports
      add constraint reports_admin_resolution_value_check
      check (
        admin_resolution is null
        or admin_resolution in (
          'no_account_action',
          'account_suspended',
          'logout_forced',
          'account_deleted'
        )
      );
  end if;

  if not exists (
    select 1
    from pg_catalog.pg_constraint
    where conrelid = 'public.reports'::regclass
      and conname = 'reports_admin_resolution_shape_check'
  ) then
    alter table public.reports
      add constraint reports_admin_resolution_shape_check
      check (
        (
          admin_resolution is null
          and admin_resolution_note is null
          and admin_resolved_by is null
          and admin_resolved_at is null
        )
        or
        (
          admin_resolution is not null
          and admin_resolution_note is not null
          and char_length(btrim(admin_resolution_note)) between 3 and 2000
          and admin_resolved_by is not null
          and admin_resolved_at is not null
        )
      );
  end if;

  if not exists (
    select 1
    from pg_catalog.pg_constraint
    where conrelid = 'public.reports'::regclass
      and conname = 'reports_admin_resolution_requires_escalation_check'
  ) then
    alter table public.reports
      add constraint reports_admin_resolution_requires_escalation_check
      check (
        admin_resolution is null
        or lower(btrim(coalesce(moderation_decision, ''))) =
            'escalate_to_admin'
      );
  end if;
end;
$$;

create or replace function app_private.enforce_report_escalation_state()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if lower(btrim(coalesce(new.moderation_decision, ''))) =
      'escalate_to_admin'
  then
    if new.admin_resolution is null then
      -- Escalation is pending until an administrator records a final outcome.
      new.status := 'in_review';
    else
      new.status := 'resolved';
    end if;
  elsif new.admin_resolution is not null then
    raise exception
      using
        errcode = '23514',
        message =
          'An administrator resolution requires an escalated report.';
  end if;

  return new;
end;
$$;

revoke all
on function app_private.enforce_report_escalation_state()
from public, anon, authenticated;

drop trigger if exists
  social_vote_enforce_report_escalation_state
on public.reports;

create trigger social_vote_enforce_report_escalation_state
before insert or update of
  moderation_decision,
  status,
  admin_resolution,
  admin_resolution_note,
  admin_resolved_by,
  admin_resolved_at
on public.reports
for each row
execute function app_private.enforce_report_escalation_state();

-- Repair the current test report and any earlier escalations incorrectly closed
-- before an administrator actually completed them.
update public.reports
set status = 'in_review'
where lower(btrim(coalesce(moderation_decision, ''))) =
      'escalate_to_admin'
  and admin_resolution is null
  and status <> 'in_review';

create index if not exists
  reports_pending_admin_escalation_idx
on public.reports (
  reviewed_at desc,
  created_at desc
)
where
  lower(btrim(coalesce(moderation_decision, ''))) =
    'escalate_to_admin'
  and admin_resolution is null
  and status = 'in_review';

drop function if exists public.admin_get_escalated_report_queue(
  integer,
  integer
);

create function public.admin_get_escalated_report_queue(
  p_limit integer default 25,
  p_offset integer default 0
)
returns table (
  report_id text,
  target_type text,
  target_id text,
  reporter_user_id text,
  reported_user_id text,
  reported_display_name text,
  reported_username text,
  reported_avatar_url text,
  reported_actor_type text,
  reported_verification_level text,
  target_title text,
  target_url text,
  reason text,
  status text,
  moderation_decision text,
  review_note text,
  reviewed_by text,
  reviewed_at timestamptz,
  content_is_hidden boolean,
  content_visibility_updated_at timestamptz,
  content_visibility_version bigint,
  created_at timestamptz,
  total_count bigint
)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if coalesce((select auth.role()), '') <> 'service_role' then
    raise exception
      using
        errcode = '42501',
        message = 'Service role access is required.';
  end if;

  if p_limit is null or p_limit < 1 or p_limit > 100 then
    raise exception
      using
        errcode = '22023',
        message = 'Escalated report queue limit must be between 1 and 100.';
  end if;

  if p_offset is null or p_offset < 0 or p_offset > 1000000 then
    raise exception
      using
        errcode = '22023',
        message = 'Escalated report queue offset must be between 0 and 1000000.';
  end if;

  return query
  with normalized_reports as (
    select
      r.id,
      lower(btrim(r.target_type::text)) as normalized_target_type,
      btrim(r.target_id::text) as normalized_target_id,
      nullif(btrim(r.target_title), '') as stored_target_title,
      nullif(btrim(r.target_url), '') as stored_target_url,
      r.user_id,
      r.reason,
      r.status,
      r.moderation_decision,
      r.review_note,
      r.reviewed_by,
      r.reviewed_at,
      r.created_at
    from public.reports r
    where lower(btrim(coalesce(r.moderation_decision, ''))) =
          'escalate_to_admin'
      and r.admin_resolution is null
      and r.status = 'in_review'
  ),
  report_targets as (
    select
      r.id::text as report_id,
      r.normalized_target_type as target_type,
      r.normalized_target_id as target_id,
      r.user_id::text as reporter_user_id,
      case
        when r.normalized_target_type = 'poll'
          then poll_target.author_id::text
        when r.normalized_target_type = 'post'
          then post_target.author_id::text
        else null
      end as reported_user_id,
      coalesce(
        r.stored_target_title,
        case
          when r.normalized_target_type = 'poll'
            then poll_target.title
          when r.normalized_target_type = 'post'
            then post_target.title
          else null
        end
      ) as target_title,
      r.stored_target_url as target_url,
      r.reason,
      r.status,
      r.moderation_decision,
      r.review_note,
      r.reviewed_by,
      r.reviewed_at,
      r.created_at
    from normalized_reports r
    left join public.polls poll_target
      on r.normalized_target_type = 'poll'
      and poll_target.id::text = r.normalized_target_id
    left join public.posts post_target
      on r.normalized_target_type = 'post'
      and post_target.id::text = r.normalized_target_id
    where r.normalized_target_type in ('poll', 'post', 'news')
  )
  select
    rt.report_id,
    rt.target_type,
    rt.target_id,
    rt.reporter_user_id,
    rt.reported_user_id,
    coalesce(profile.display_name, user_mirror.display_name)::text,
    profile.username::text,
    profile.avatar_url::text,
    profile.actor_type::text,
    profile.verification_level::text,
    rt.target_title::text,
    rt.target_url::text,
    rt.reason::text,
    rt.status::text,
    rt.moderation_decision::text,
    rt.review_note::text,
    rt.reviewed_by::text,
    rt.reviewed_at,
    coalesce(visibility.is_hidden, false),
    visibility.updated_at,
    visibility.version,
    rt.created_at,
    count(*) over ()
  from report_targets rt
  left join public.user_profiles profile
    on profile.id::text = rt.reported_user_id
  left join public.users user_mirror
    on user_mirror.id::text = rt.reported_user_id
  left join app_private.admin_content_visibility visibility
    on visibility.target_type = rt.target_type
    and visibility.target_id = rt.target_id
  order by
    rt.reviewed_at desc nulls last,
    rt.created_at desc,
    rt.report_id desc
  limit p_limit
  offset p_offset;
end;
$$;

comment on function public.admin_get_escalated_report_queue(
  integer,
  integer
) is
  'Backend-only queue of reports awaiting a final administrator decision.';

revoke all
on function public.admin_get_escalated_report_queue(
  integer,
  integer
)
from public, anon, authenticated;

grant execute
on function public.admin_get_escalated_report_queue(
  integer,
  integer
)
to service_role;

notify pgrst, 'reload schema';

commit;
