-- Social Vote
-- Admin Center AC8.4: report decision foundation with mandatory review note.
--
-- This migration only records the moderation decision. Content actions
-- (hide/restore/escalation handling), full audit and concurrent-work hardening
-- remain separate AC8.5/AC8.6 steps.

begin;

alter table public.reports
  add column if not exists moderation_decision text,
  add column if not exists review_note text,
  add column if not exists reviewed_by uuid,
  add column if not exists reviewed_at timestamptz;

do $$
begin
  if not exists (
    select 1
    from pg_catalog.pg_constraint c
    where c.conrelid = 'public.reports'::regclass
      and c.conname = 'reports_moderation_decision_valid_check'
  ) then
    alter table public.reports
      add constraint reports_moderation_decision_valid_check
      check (
        moderation_decision is null
        or moderation_decision in (
          'no_violation',
          'violation_confirmed',
          'escalate_to_admin'
        )
      );
  end if;

  if not exists (
    select 1
    from pg_catalog.pg_constraint c
    where c.conrelid = 'public.reports'::regclass
      and c.conname = 'reports_review_note_length_check'
  ) then
    alter table public.reports
      add constraint reports_review_note_length_check
      check (
        review_note is null
        or (
          nullif(btrim(review_note), '') is not null
          and char_length(review_note) <= 2000
        )
      );
  end if;

  if not exists (
    select 1
    from pg_catalog.pg_constraint c
    where c.conrelid = 'public.reports'::regclass
      and c.conname = 'reports_review_metadata_shape_check'
  ) then
    alter table public.reports
      add constraint reports_review_metadata_shape_check
      check (
        (
          moderation_decision is null
          and review_note is null
          and reviewed_by is null
          and reviewed_at is null
        )
        or
        (
          moderation_decision is not null
          and review_note is not null
          and reviewed_by is not null
          and reviewed_at is not null
        )
      );
  end if;
end;
$$;

create index if not exists reports_moderation_decision_created_idx
on public.reports (moderation_decision, created_at desc, id desc)
where moderation_decision is not null;

comment on column public.reports.moderation_decision is
  'Staff moderation decision: no_violation, violation_confirmed, or escalate_to_admin.';

comment on column public.reports.review_note is
  'Mandatory staff note recorded together with a moderation decision.';

comment on column public.reports.reviewed_by is
  'Staff user id captured without a foreign key so moderation history survives later account deletion.';

comment on column public.reports.reviewed_at is
  'Timestamp of the recorded moderation decision.';

-- Backend-only decision write path. The Edge Function must still validate the
-- caller session, but this RPC independently checks the authoritative Auth role
-- and the public.users mirror before changing a report.
create or replace function public.admin_record_report_decision(
  p_report_id uuid,
  p_actor_user_id uuid,
  p_actor_role text,
  p_decision text,
  p_review_note text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor_role text := lower(btrim(coalesce(p_actor_role, '')));
  v_auth_role text;
  v_mirror_role text;
  v_decision text := lower(btrim(coalesce(p_decision, '')));
  v_review_note text := btrim(coalesce(p_review_note, ''));
  v_previous_status text;
  v_new_status text;
  v_existing_decision text;
begin
  if coalesce((select auth.role()), '') <> 'service_role' then
    raise exception
      using
        errcode = '42501',
        message = 'Service role access is required.';
  end if;

  if p_report_id is null or p_actor_user_id is null then
    raise exception
      using
        errcode = '22004',
        message = 'Report and staff user identifiers are required.';
  end if;

  if v_actor_role not in ('moderator', 'admin') then
    raise exception
      using
        errcode = '42501',
        message = 'Moderator or administrator access is required.';
  end if;

  if v_decision not in (
    'no_violation',
    'violation_confirmed',
    'escalate_to_admin'
  ) then
    raise exception
      using
        errcode = '22023',
        message = 'Unsupported moderation decision.';
  end if;

  if char_length(v_review_note) < 3 or char_length(v_review_note) > 2000 then
    raise exception
      using
        errcode = '22023',
        message = 'Review note must contain between 3 and 2000 characters.';
  end if;

  select
    lower(coalesce(au.raw_app_meta_data ->> 'role', 'user')),
    lower(coalesce(pu.role, 'user'))
  into
    v_auth_role,
    v_mirror_role
  from auth.users au
  left join public.users pu
    on pu.id = au.id
  where au.id = p_actor_user_id;

  if v_auth_role is null or v_mirror_role is null then
    raise exception
      using
        errcode = '42501',
        message = 'Staff account could not be verified.';
  end if;

  if v_auth_role <> v_actor_role or v_mirror_role <> v_actor_role then
    raise exception
      using
        errcode = '42501',
        message = 'Staff role is not synchronized.';
  end if;

  select
    r.status,
    r.moderation_decision
  into
    v_previous_status,
    v_existing_decision
  from public.reports r
  where r.id = p_report_id
  for update;

  if not found then
    raise exception
      using
        errcode = 'P0002',
        message = 'Report was not found.';
  end if;

  if v_previous_status not in ('open', 'in_review') then
    raise exception
      using
        errcode = '55000',
        message = 'Report is no longer pending.';
  end if;

  if v_existing_decision is not null then
    raise exception
      using
        errcode = '55000',
        message = 'A moderation decision has already been recorded.';
  end if;

  v_new_status := case
    when v_decision = 'no_violation' then 'dismissed'
    else 'in_review'
  end;

  update public.reports
  set
    moderation_decision = v_decision,
    review_note = v_review_note,
    reviewed_by = p_actor_user_id,
    reviewed_at = now(),
    status = v_new_status
  where id = p_report_id;

  return jsonb_build_object(
    'success', true,
    'reportId', p_report_id,
    'previousStatus', v_previous_status,
    'status', v_new_status,
    'decision', v_decision,
    'reviewedBy', p_actor_user_id,
    'reviewedAt', now()
  );
end;
$$;

comment on function public.admin_record_report_decision(
  uuid,
  uuid,
  text,
  text,
  text
) is
  'Backend-only report decision write path with mandatory note and synchronized staff-role validation.';

revoke all
on function public.admin_record_report_decision(
  uuid,
  uuid,
  text,
  text,
  text
)
from public, anon, authenticated;

grant execute
on function public.admin_record_report_decision(
  uuid,
  uuid,
  text,
  text,
  text
)
to service_role;

-- Extend the protected report queue with the recorded review context.
drop function if exists public.admin_get_report_queue(
  text,
  text,
  integer,
  integer
);

create function public.admin_get_report_queue(
  p_status text default null,
  p_target_type text default null,
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
  reason text,
  status text,
  moderation_decision text,
  review_note text,
  reviewed_by text,
  reviewed_at timestamptz,
  created_at timestamptz,
  total_count bigint
)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_status text := nullif(lower(btrim(p_status)), '');
  v_target_type text := nullif(lower(btrim(p_target_type)), '');
begin
  if coalesce((select auth.role()), '') <> 'service_role' then
    raise exception
      using
        errcode = '42501',
        message = 'Service role access is required.';
  end if;

  if v_status is not null
    and v_status not in ('open', 'in_review', 'resolved', 'dismissed')
  then
    raise exception
      using
        errcode = '22023',
        message = 'Invalid report status filter.';
  end if;

  if v_target_type is not null
    and v_target_type not in ('poll', 'post', 'news')
  then
    raise exception
      using
        errcode = '22023',
        message = 'Invalid report target type filter.';
  end if;

  if p_limit is null or p_limit < 1 or p_limit > 100 then
    raise exception
      using
        errcode = '22023',
        message = 'Report queue limit must be between 1 and 100.';
  end if;

  if p_offset is null or p_offset < 0 or p_offset > 1000000 then
    raise exception
      using
        errcode = '22023',
        message = 'Report queue offset must be between 0 and 1000000.';
  end if;

  return query
  with normalized_reports as (
    select
      r.id,
      lower(btrim(r.target_type::text)) as normalized_target_type,
      btrim(r.target_id::text) as normalized_target_id,
      r.user_id,
      r.reason,
      r.status,
      r.moderation_decision,
      r.review_note,
      r.reviewed_by,
      r.reviewed_at,
      r.created_at
    from public.reports r
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
      case
        when r.normalized_target_type = 'poll'
          then poll_target.title
        when r.normalized_target_type = 'post'
          then post_target.title
        else null
      end as target_title,
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
    where
      r.normalized_target_type in ('poll', 'post', 'news')
      and (
        (v_status is null and r.status in ('open', 'in_review'))
        or r.status = v_status
      )
      and (
        v_target_type is null
        or r.normalized_target_type = v_target_type
      )
  )
  select
    rt.report_id,
    rt.target_type,
    rt.target_id,
    rt.reporter_user_id,
    rt.reported_user_id,
    coalesce(profile.display_name, user_mirror.display_name)::text
      as reported_display_name,
    profile.username::text as reported_username,
    profile.avatar_url::text as reported_avatar_url,
    profile.actor_type::text as reported_actor_type,
    profile.verification_level::text as reported_verification_level,
    rt.target_title::text,
    rt.reason,
    rt.status,
    rt.moderation_decision,
    rt.review_note,
    rt.reviewed_by::text,
    rt.reviewed_at,
    rt.created_at,
    count(*) over () as total_count
  from report_targets rt
  left join public.user_profiles profile
    on profile.id::text = rt.reported_user_id
  left join public.users user_mirror
    on user_mirror.id::text = rt.reported_user_id
  order by
    rt.created_at desc,
    rt.report_id desc
  limit p_limit
  offset p_offset;
end;
$$;

comment on function public.admin_get_report_queue(
  text,
  text,
  integer,
  integer
) is
  'Backend-only paginated report queue with target/profile context and moderation review metadata.';

revoke all
on function public.admin_get_report_queue(
  text,
  text,
  integer,
  integer
)
from public, anon, authenticated;

grant execute
on function public.admin_get_report_queue(
  text,
  text,
  integer,
  integer
)
to service_role;

notify pgrst, 'reload schema';

commit;
