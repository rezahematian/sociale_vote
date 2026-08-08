-- SOCIAL VOTE
-- P10 — Admin Center operational dashboard foundation
-- 2026-08-08
--
-- Privacy / semantics:
-- - no real-time presence tracking;
-- - "recent sign-ins" means auth.users.last_sign_in_at in the period;
-- - all values are aggregate counters;
-- - no session tokens, IP addresses, device identifiers, or per-user activity
--   are exposed by this function.
--
-- The existing admin_get_dashboard_summary() is intentionally preserved.
-- The Admin Edge Function can migrate to this richer read model separately.

begin;

create or replace function public.admin_get_operational_dashboard_summary()
returns table (
  pending_verification_requests bigint,
  open_reports bigint,
  suspended_accounts bigint,
  total_users bigint,
  staff_users bigint,

  new_users_24h bigint,
  new_users_7d bigint,
  recent_sign_ins_24h bigint,
  recent_sign_ins_7d bigint,

  polls_created_24h bigint,
  polls_created_7d bigint,
  posts_created_24h bigint,
  posts_created_7d bigint,

  admin_actions_24h bigint,
  admin_actions_7d bigint,

  generated_at timestamptz
)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_now timestamptz := now();

  v_pending_verification_requests bigint := 0;
  v_open_reports bigint := 0;
  v_suspended_accounts bigint := 0;
  v_total_users bigint := 0;
  v_staff_users bigint := 0;

  v_new_users_24h bigint := 0;
  v_new_users_7d bigint := 0;
  v_recent_sign_ins_24h bigint := 0;
  v_recent_sign_ins_7d bigint := 0;

  v_polls_created_24h bigint := 0;
  v_polls_created_7d bigint := 0;
  v_posts_created_24h bigint := 0;
  v_posts_created_7d bigint := 0;

  v_admin_actions_24h bigint := 0;
  v_admin_actions_7d bigint := 0;
begin
  if coalesce((select auth.role()), '') <> 'service_role' then
    raise exception
      using
        errcode = '42501',
        message = 'Service role access is required.';
  end if;

  -- Existing Admin Center work counters.
  select count(*)
  into v_pending_verification_requests
  from public.verification_requests vr
  where vr.status = 'pending';

  select count(*)
  into v_open_reports
  from public.reports r
  where r.status in ('open', 'in_review');

  select count(*)
  into v_suspended_accounts
  from app_private.account_controls ac
  where ac.status = 'suspended'
    and ac.suspended_until is not null
    and ac.suspended_until > v_now;

  -- Users / staff + recent registrations + recent sign-ins.
  select
    count(*),
    count(*) filter (
      where lower(
        coalesce(au.raw_app_meta_data ->> 'role', 'user')
      ) in ('moderator', 'admin')
    ),
    count(*) filter (
      where au.created_at >= v_now - interval '24 hours'
    ),
    count(*) filter (
      where au.created_at >= v_now - interval '7 days'
    ),
    count(*) filter (
      where au.last_sign_in_at is not null
        and au.last_sign_in_at >= v_now - interval '24 hours'
    ),
    count(*) filter (
      where au.last_sign_in_at is not null
        and au.last_sign_in_at >= v_now - interval '7 days'
    )
  into
    v_total_users,
    v_staff_users,
    v_new_users_24h,
    v_new_users_7d,
    v_recent_sign_ins_24h,
    v_recent_sign_ins_7d
  from auth.users au;

  -- Content creation activity.
  select
    count(*) filter (
      where p.created_at >= v_now - interval '24 hours'
    ),
    count(*) filter (
      where p.created_at >= v_now - interval '7 days'
    )
  into
    v_polls_created_24h,
    v_polls_created_7d
  from public.polls p;

  select
    count(*) filter (
      where p.created_at >= v_now - interval '24 hours'
    ),
    count(*) filter (
      where p.created_at >= v_now - interval '7 days'
    )
  into
    v_posts_created_24h,
    v_posts_created_7d
  from public.posts p;

  -- Administrative activity already recorded by the existing audit system.
  select
    count(*) filter (
      where aal.created_at >= v_now - interval '24 hours'
    ),
    count(*) filter (
      where aal.created_at >= v_now - interval '7 days'
    )
  into
    v_admin_actions_24h,
    v_admin_actions_7d
  from public.admin_audit_logs aal;

  return query
  select
    v_pending_verification_requests,
    v_open_reports,
    v_suspended_accounts,
    v_total_users,
    v_staff_users,

    v_new_users_24h,
    v_new_users_7d,
    v_recent_sign_ins_24h,
    v_recent_sign_ins_7d,

    v_polls_created_24h,
    v_polls_created_7d,
    v_posts_created_24h,
    v_posts_created_7d,

    v_admin_actions_24h,
    v_admin_actions_7d,

    v_now;
end;
$$;

comment on function public.admin_get_operational_dashboard_summary() is
  'Backend-only aggregate operational counters for Admin Center. '
  'No real-time presence or per-user activity is exposed.';

revoke all
on function public.admin_get_operational_dashboard_summary()
from public, anon, authenticated;

grant execute
on function public.admin_get_operational_dashboard_summary()
to service_role;

notify pgrst, 'reload schema';

commit;
