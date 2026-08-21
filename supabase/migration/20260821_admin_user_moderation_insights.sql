-- Social Vote
-- Admin Center V2: richer backend-only account detail.
--
-- This does NOT create new user data and does not change any moderation rule.
-- It extends the existing protected read model with aggregate counters derived
-- from data already stored by Social Vote. Direct client execution remains
-- revoked; the Admin Center reads it only through the authorized admin-read
-- Edge Function.

begin;

drop function if exists public.admin_get_user_detail(uuid);

create function public.admin_get_user_detail(
  p_user_id uuid
)
returns table (
  user_id uuid,
  email text,
  email_confirmed_at timestamptz,
  last_sign_in_at timestamptz,
  display_name text,
  username text,
  avatar_url text,
  system_role text,
  mirror_role text,
  role_synchronized boolean,
  actor_type text,
  verification_level text,
  verification_status text,
  account_status text,
  suspended_until timestamptz,
  created_at timestamptz,
  reports_received_total bigint,
  reports_received_pending bigint,
  confirmed_violations_total bigint,
  reports_filed_total bigint,
  polls_created_total bigint,
  posts_created_total bigint,
  comments_created_total bigint,
  admin_actions_total bigint,
  last_report_received_at timestamptz
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

  if p_user_id is null then
    raise exception
      using
        errcode = '22023',
        message = 'A target user ID is required.';
  end if;

  return query
  with report_targets as (
    select
      r.id,
      r.user_id as reporter_user_id,
      lower(btrim(r.target_type::text)) as target_type,
      r.status::text as status,
      r.moderation_decision::text as moderation_decision,
      r.created_at,
      case
        when lower(btrim(r.target_type::text)) = 'poll'
          then poll_target.author_id
        when lower(btrim(r.target_type::text)) = 'post'
          then post_target.author_id
        else null::uuid
      end as reported_user_id
    from public.reports r
    left join public.polls poll_target
      on lower(btrim(r.target_type::text)) = 'poll'
      and poll_target.id::text = btrim(r.target_id::text)
    left join public.posts post_target
      on lower(btrim(r.target_type::text)) = 'post'
      and post_target.id::text = btrim(r.target_id::text)
  ),
  report_stats as (
    select
      count(*) filter (
        where rt.reported_user_id = p_user_id
      )::bigint as reports_received_total,
      count(*) filter (
        where rt.reported_user_id = p_user_id
          and lower(btrim(rt.status)) in ('open', 'in_review')
      )::bigint as reports_received_pending,
      count(*) filter (
        where rt.reported_user_id = p_user_id
          and lower(btrim(coalesce(rt.moderation_decision, ''))) =
            'violation_confirmed'
      )::bigint as confirmed_violations_total,
      count(*) filter (
        where rt.reporter_user_id = p_user_id
      )::bigint as reports_filed_total,
      max(rt.created_at) filter (
        where rt.reported_user_id = p_user_id
      ) as last_report_received_at
    from report_targets rt
  ),
  content_stats as (
    select
      (select count(*) from public.polls p where p.author_id = p_user_id)::bigint
        as polls_created_total,
      (select count(*) from public.posts p where p.author_id = p_user_id)::bigint
        as posts_created_total,
      (select count(*) from public.comments c where c.author_id = p_user_id)::bigint
        as comments_created_total
  ),
  admin_stats as (
    select count(*)::bigint as admin_actions_total
    from public.admin_audit_logs aal
    where aal.target_id = p_user_id::text
      and lower(coalesce(aal.result::text, '')) in ('success', 'noop')
  )
  select
    au.id as user_id,
    au.email::text as email,
    au.email_confirmed_at,
    au.last_sign_in_at,
    coalesce(
      nullif(btrim(up.display_name), ''),
      nullif(btrim(pu.display_name), '')
    )::text as display_name,
    nullif(btrim(up.username), '')::text as username,
    nullif(btrim(up.avatar_url), '')::text as avatar_url,
    case
      when lower(coalesce(au.raw_app_meta_data ->> 'role', '')) in (
        'user',
        'moderator',
        'admin'
      )
        then lower(au.raw_app_meta_data ->> 'role')
      else 'user'
    end::text as system_role,
    case
      when lower(coalesce(pu.role, '')) in (
        'user',
        'moderator',
        'admin'
      )
        then lower(pu.role)
      else 'user'
    end::text as mirror_role,
    (
      case
        when lower(coalesce(au.raw_app_meta_data ->> 'role', '')) in (
          'user',
          'moderator',
          'admin'
        )
          then lower(au.raw_app_meta_data ->> 'role')
        else 'user'
      end
      =
      case
        when lower(coalesce(pu.role, '')) in (
          'user',
          'moderator',
          'admin'
        )
          then lower(pu.role)
        else 'user'
      end
    ) as role_synchronized,
    coalesce(nullif(btrim(up.actor_type), ''), 'citizen')::text
      as actor_type,
    coalesce(nullif(btrim(up.verification_level), ''), 'none')::text
      as verification_level,
    coalesce(nullif(btrim(up.verification_status), ''), 'none')::text
      as verification_status,
    case
      when ac.status = 'suspended'
        and ac.suspended_until is not null
        and ac.suspended_until <= now()
        then 'active'
      else coalesce(ac.status, 'active')
    end::text as account_status,
    case
      when ac.status = 'suspended'
        and ac.suspended_until is not null
        and ac.suspended_until > now()
        then ac.suspended_until
      else null::timestamptz
    end as suspended_until,
    au.created_at,
    coalesce(rs.reports_received_total, 0)::bigint,
    coalesce(rs.reports_received_pending, 0)::bigint,
    coalesce(rs.confirmed_violations_total, 0)::bigint,
    coalesce(rs.reports_filed_total, 0)::bigint,
    coalesce(cs.polls_created_total, 0)::bigint,
    coalesce(cs.posts_created_total, 0)::bigint,
    coalesce(cs.comments_created_total, 0)::bigint,
    coalesce(ast.admin_actions_total, 0)::bigint,
    rs.last_report_received_at
  from auth.users au
  left join public.users pu
    on pu.id = au.id
  left join public.user_profiles up
    on up.id = au.id
  left join app_private.account_controls ac
    on ac.user_id = au.id
  cross join report_stats rs
  cross join content_stats cs
  cross join admin_stats ast
  where au.id = p_user_id
  limit 1;
end;
$$;

comment on function public.admin_get_user_detail(uuid) is
  'Backend-only Admin Center account detail with Auth, verification, moderation and aggregate activity context.';

revoke all
on function public.admin_get_user_detail(uuid)
from public, anon, authenticated;

grant execute
on function public.admin_get_user_detail(uuid)
to service_role;

notify pgrst, 'reload schema';

commit;
