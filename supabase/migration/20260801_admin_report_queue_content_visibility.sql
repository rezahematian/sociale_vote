-- Social Vote
-- Admin Center AC8.5.2: expose moderated content visibility in the report queue.
--
-- This migration extends the protected report read model with:
-- - content_is_hidden
-- - content_visibility_updated_at
-- - content_visibility_version
--
-- The Flutter client still reads the data only through the admin-read
-- Edge Function. Direct client execution remains revoked.

begin;

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
    coalesce(visibility.is_hidden, false) as content_is_hidden,
    visibility.updated_at as content_visibility_updated_at,
    visibility.version as content_visibility_version,
    rt.created_at,
    count(*) over () as total_count
  from report_targets rt
  left join public.user_profiles profile
    on profile.id::text = rt.reported_user_id
  left join public.users user_mirror
    on user_mirror.id::text = rt.reported_user_id
  left join app_private.admin_content_visibility visibility
    on visibility.target_type = rt.target_type
    and visibility.target_id = rt.target_id
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
  'Backend-only paginated report queue with target/profile context, review metadata and moderated content visibility state.';

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
