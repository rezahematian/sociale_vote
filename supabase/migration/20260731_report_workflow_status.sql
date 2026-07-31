-- Social Vote
-- Admin Center AC8.1: report workflow status foundation.

begin;

alter table public.reports
  add column if not exists status text;

update public.reports
set status = case
  when status is null or btrim(status) = '' then 'open'
  when lower(btrim(status)) = 'reviewing' then 'in_review'
  else lower(btrim(status))
end;

do $$
begin
  if exists (
    select 1
    from public.reports r
    where r.status not in ('open', 'in_review', 'resolved', 'dismissed')
  ) then
    raise exception
      using
        errcode = '23514',
        message = 'Existing reports contain an unsupported status.';
  end if;
end;
$$;

alter table public.reports
  alter column status set default 'open',
  alter column status set not null;

do $$
begin
  if not exists (
    select 1
    from pg_catalog.pg_constraint c
    where c.conrelid = 'public.reports'::regclass
      and c.conname = 'reports_status_valid_check'
  ) then
    alter table public.reports
      add constraint reports_status_valid_check
      check (status in ('open', 'in_review', 'resolved', 'dismissed'));
  end if;
end;
$$;

create index if not exists reports_status_created_idx
on public.reports (status, created_at desc, id desc);

comment on column public.reports.status is
  'Moderation workflow status: open, in_review, resolved, or dismissed.';

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

  select count(*)
  into v_open_reports
  from public.reports r
  where r.status in ('open', 'in_review');

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

commit;
