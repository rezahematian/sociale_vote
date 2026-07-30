-- Social Vote
-- Admin Center: backend-only read models for dashboard and audit.
--
-- Security rules:
-- - both RPCs are callable only with the service role;
-- - the Edge Function must authorize the current admin before invoking them;
-- - no email, token, identity document or other sensitive payload is returned;
-- - the Flutter client must never call these RPCs directly.

begin;

-- ============================================================
-- ADMIN DASHBOARD SUMMARY
-- ============================================================

create or replace function public.admin_get_dashboard_summary()
returns table (
  pending_verification_requests bigint,
  open_reports bigint,
  suspended_accounts bigint,
  total_users bigint,
  staff_users bigint
)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_pending_verification_requests bigint := 0;
  v_open_reports bigint := 0;
  v_suspended_accounts bigint := 0;
  v_total_users bigint := 0;
  v_staff_users bigint := 0;
  v_reports_have_status boolean := false;
begin
  if coalesce((select auth.role()), '') <> 'service_role' then
    raise exception
      using
        errcode = '42501',
        message = 'Service role access is required.';
  end if;

  select count(*)
  into v_pending_verification_requests
  from public.verification_requests vr
  where vr.status = 'pending';

  -- Until the report workflow migration adds its status column, every report
  -- is unresolved and therefore belongs to the open-work count.
  select exists (
    select 1
    from pg_catalog.pg_attribute a
    join pg_catalog.pg_class c
      on c.oid = a.attrelid
    join pg_catalog.pg_namespace n
      on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relname = 'reports'
      and a.attname = 'status'
      and a.attnum > 0
      and not a.attisdropped
  )
  into v_reports_have_status;

  if v_reports_have_status then
    execute 'select count(*) from public.reports where status in (''open'', ''reviewing'')'
    into v_open_reports;
  else
    select count(*)
    into v_open_reports
    from public.reports;
  end if;

  select count(*)
  into v_suspended_accounts
  from app_private.account_controls ac
  where ac.status = 'suspended'
    and ac.suspended_until is not null
    and ac.suspended_until > now();

  select
    count(*),
    count(*) filter (
      where lower(
        coalesce(au.raw_app_meta_data ->> 'role', 'user')
      ) in ('moderator', 'admin')
    )
  into
    v_total_users,
    v_staff_users
  from auth.users au;

  return query
  select
    v_pending_verification_requests,
    v_open_reports,
    v_suspended_accounts,
    v_total_users,
    v_staff_users;
end;
$$;

comment on function public.admin_get_dashboard_summary() is
  'Backend-only aggregate counters for the Admin Center dashboard.';

revoke all
on function public.admin_get_dashboard_summary()
from public, anon, authenticated;

grant execute
on function public.admin_get_dashboard_summary()
to service_role;

-- ============================================================
-- ADMIN AUDIT READ MODEL
-- ============================================================

create or replace function public.admin_get_audit_entries(
  p_actor_user_id uuid default null,
  p_action text default null,
  p_target_id text default null,
  p_result text default null,
  p_from timestamptz default null,
  p_to timestamptz default null,
  p_limit integer default 50,
  p_offset integer default 0
)
returns table (
  id uuid,
  actor_user_id uuid,
  actor_role text,
  action text,
  target_type text,
  target_id text,
  previous_value jsonb,
  new_value jsonb,
  reason text,
  result text,
  error_code text,
  created_at timestamptz
)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_action text := nullif(lower(btrim(p_action)), '');
  v_target_id text := nullif(btrim(p_target_id), '');
  v_result text := nullif(lower(btrim(p_result)), '');
begin
  if coalesce((select auth.role()), '') <> 'service_role' then
    raise exception
      using
        errcode = '42501',
        message = 'Service role access is required.';
  end if;

  if v_action is not null
    and (
      char_length(v_action) > 80
      or v_action !~ '^[a-z0-9_]+$'
    )
  then
    raise exception
      using
        errcode = '22023',
        message = 'Invalid audit action filter.';
  end if;

  if v_target_id is not null and char_length(v_target_id) > 320 then
    raise exception
      using
        errcode = '22023',
        message = 'Audit target filter is too long.';
  end if;

  if v_result is not null
    and v_result not in ('success', 'failure', 'denied', 'noop')
  then
    raise exception
      using
        errcode = '22023',
        message = 'Invalid audit result filter.';
  end if;

  if p_from is not null and p_to is not null and p_from > p_to then
    raise exception
      using
        errcode = '22023',
        message = 'Audit date range is inverted.';
  end if;

  if p_limit is null or p_limit < 1 or p_limit > 100 then
    raise exception
      using
        errcode = '22023',
        message = 'Audit limit must be between 1 and 100.';
  end if;

  if p_offset is null or p_offset < 0 or p_offset > 1000000 then
    raise exception
      using
        errcode = '22023',
        message = 'Audit offset must be between 0 and 1000000.';
  end if;

  return query
  select
    aal.id,
    aal.actor_user_id,
    aal.actor_role,
    aal.action,
    aal.target_type,
    aal.target_id,
    aal.previous_value,
    aal.new_value,
    aal.reason,
    aal.result,
    aal.error_code,
    aal.created_at
  from public.admin_audit_logs aal
  where
    (p_actor_user_id is null or aal.actor_user_id = p_actor_user_id)
    and (v_action is null or aal.action = v_action)
    and (v_target_id is null or aal.target_id = v_target_id)
    and (v_result is null or aal.result = v_result)
    and (p_from is null or aal.created_at >= p_from)
    and (p_to is null or aal.created_at <= p_to)
  order by
    aal.created_at desc,
    aal.id desc
  limit p_limit
  offset p_offset;
end;
$$;

comment on function public.admin_get_audit_entries(
  uuid,
  text,
  text,
  text,
  timestamptz,
  timestamptz,
  integer,
  integer
) is
  'Backend-only filtered Admin Center audit read model.';

revoke all
on function public.admin_get_audit_entries(
  uuid,
  text,
  text,
  text,
  timestamptz,
  timestamptz,
  integer,
  integer
)
from public, anon, authenticated;

grant execute
on function public.admin_get_audit_entries(
  uuid,
  text,
  text,
  text,
  timestamptz,
  timestamptz,
  integer,
  integer
)
to service_role;

commit;
