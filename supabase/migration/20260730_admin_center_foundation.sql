-- Social Vote
-- Admin Center foundation: private account controls and append-only staff audit.
--
-- Security rules:
-- - account suspension state is kept outside the exposed public schema;
-- - authenticated clients can never write staff audit rows;
-- - only an active admin with synchronized Auth/mirror roles can read the audit;
-- - audit actor/target identifiers intentionally have no foreign keys, so the
--   record survives later account or content deletion;
-- - tokens, document data, secrets, email addresses and display names must
--   never be written to previous_value or new_value.

begin;

create schema if not exists app_private;

revoke all on schema app_private from public;
revoke all on schema app_private from anon;
revoke all on schema app_private from authenticated;

-- ============================================================
-- PRIVATE ACCOUNT CONTROL STATE
-- ============================================================

create table if not exists app_private.account_controls (
  user_id uuid primary key,
  status text not null default 'active',
  suspended_at timestamptz,
  suspended_until timestamptz,
  suspended_by uuid,
  suspension_reason text,
  updated_at timestamptz not null default now(),
  constraint account_controls_status_check
    check (status in ('active', 'suspended', 'deleted')),
  constraint account_controls_suspension_shape_check
    check (
      (
        status = 'active'
        and suspended_at is null
        and suspended_until is null
        and suspended_by is null
        and suspension_reason is null
      )
      or
      (
        status = 'suspended'
        and suspended_at is not null
        and suspended_until is not null
        and suspended_until > suspended_at
        and suspended_by is not null
        and suspension_reason is not null
        and nullif(btrim(suspension_reason), '') is not null
        and char_length(suspension_reason) <= 1000
      )
      or
      (
        status = 'deleted'
        and suspended_at is null
        and suspended_until is null
        and suspended_by is null
        and suspension_reason is null
      )
    )
);

comment on table app_private.account_controls is
  'Private application-level account state used for suspension and deletion enforcement.';

comment on column app_private.account_controls.suspended_by is
  'Staff user id captured without a foreign key so the record survives later staff deletion.';

alter table app_private.account_controls enable row level security;
alter table app_private.account_controls force row level security;

revoke all
on table app_private.account_controls
from public, anon, authenticated;

create index if not exists account_controls_status_idx
on app_private.account_controls (status);

create index if not exists account_controls_suspended_until_idx
on app_private.account_controls (suspended_until)
where status = 'suspended';

create index if not exists account_controls_suspended_by_idx
on app_private.account_controls (suspended_by)
where suspended_by is not null;

-- Existing Auth users start active. An existing state is never overwritten.
insert into app_private.account_controls (
  user_id,
  status
)
select
  au.id,
  'active'
from auth.users au
on conflict (user_id) do nothing;

-- Historical public users without a corresponding Auth account are deleted.
insert into app_private.account_controls (
  user_id,
  status
)
select
  pu.id,
  'deleted'
from public.users pu
where not exists (
  select 1
  from auth.users au
  where au.id = pu.id
)
on conflict (user_id) do update
set
  status = 'deleted',
  suspended_at = null,
  suspended_until = null,
  suspended_by = null,
  suspension_reason = null,
  updated_at = now();

-- Keep account control creation aligned with the existing latest-session
-- registry. A suspended/deleted state is never reactivated by a new session.
create or replace function app_private.capture_latest_auth_session()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into app_private.account_controls (
    user_id,
    status
  )
  values (
    new.user_id,
    'active'
  )
  on conflict (user_id) do nothing;

  insert into app_private.active_user_sessions (
    user_id,
    session_id,
    activated_at
  )
  values (
    new.user_id,
    new.id,
    coalesce(new.created_at, now())
  )
  on conflict (user_id) do update
  set
    session_id = excluded.session_id,
    activated_at = excluded.activated_at;

  return new;
end;
$$;

revoke all
on function app_private.capture_latest_auth_session()
from public, anon, authenticated;

-- An authenticated action is valid only when:
-- - the Auth user still exists;
-- - the account is active, or its temporary suspension has expired;
-- - the JWT session is the latest registered session and still exists.
create or replace function public.is_current_auth_user_active()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select
    (select auth.uid()) is not null
    and exists (
      select 1
      from auth.users au
      where au.id = (select auth.uid())
    )
    and exists (
      select 1
      from app_private.account_controls ac
      where ac.user_id = (select auth.uid())
        and (
          ac.status = 'active'
          or (
            ac.status = 'suspended'
            and ac.suspended_until <= now()
          )
        )
    )
    and exists (
      select 1
      from app_private.active_user_sessions aus
      join auth.sessions s
        on s.id = aus.session_id
       and s.user_id = aus.user_id
      where aus.user_id = (select auth.uid())
        and aus.session_id =
          nullif(
            (select auth.jwt() ->> 'session_id'),
            ''
          )::uuid
    );
$$;

revoke all
on function public.is_current_auth_user_active()
from public, anon;

grant execute
on function public.is_current_auth_user_active()
to authenticated;

-- Preserve the private state when an Auth account is deleted. The public user
-- mirror remains available for historical foreign keys, as in the existing
-- account-deletion hardening migration.
create or replace function app_private.prepare_deleted_auth_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.users
  set
    email = null,
    display_name = null,
    role = 'user'
  where id = old.id;

  insert into app_private.account_controls (
    user_id,
    status,
    updated_at
  )
  values (
    old.id,
    'deleted',
    now()
  )
  on conflict (user_id) do update
  set
    status = 'deleted',
    suspended_at = null,
    suspended_until = null,
    suspended_by = null,
    suspension_reason = null,
    updated_at = now();

  delete from app_private.active_user_sessions
  where user_id = old.id;

  return old;
end;
$$;

revoke all
on function app_private.prepare_deleted_auth_user()
from public, anon, authenticated;

-- ============================================================
-- CENTRAL ADMIN AUTHORIZATION HELPER
-- ============================================================

create or replace function public.is_current_auth_user_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select
    coalesce(
      (select auth.jwt() -> 'app_metadata' ->> 'role'),
      ''
    ) = 'admin'
    and exists (
      select 1
      from public.users pu
      where pu.id = (select auth.uid())
        and pu.role = 'admin'
    )
    and (select public.is_current_auth_user_active());
$$;

revoke all
on function public.is_current_auth_user_admin()
from public, anon;

grant execute
on function public.is_current_auth_user_admin()
to authenticated;

-- ============================================================
-- BACKEND-ONLY SESSION INVALIDATION
-- ============================================================

-- Role changes and account actions must immediately block the target's
-- existing JWT at the application RLS layer and revoke its Auth sessions.
-- This RPC is intentionally unavailable to every client role; Edge Functions
-- call it only with the service-role client after completing their own
-- authorization checks.
create or replace function public.admin_revoke_user_sessions(
  p_target_user_id uuid
)
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  revoked_session_count integer := 0;
begin
  if p_target_user_id is null then
    raise exception
      using
        errcode = '22004',
        message = 'A target user id is required.';
  end if;

  if coalesce((select auth.role()), '') <> 'service_role' then
    raise exception
      using
        errcode = '42501',
        message = 'Service role access is required.';
  end if;

  delete from auth.sessions
  where user_id = p_target_user_id;

  get diagnostics revoked_session_count = row_count;

  delete from app_private.active_user_sessions
  where user_id = p_target_user_id;

  return revoked_session_count;
end;
$$;

revoke all
on function public.admin_revoke_user_sessions(uuid)
from public, anon, authenticated;

grant execute
on function public.admin_revoke_user_sessions(uuid)
to service_role;

-- ============================================================
-- APPEND-ONLY STAFF AUDIT
-- ============================================================

create table if not exists public.admin_audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_user_id uuid not null,
  actor_role text not null,
  action text not null,
  target_type text not null,
  target_id text,
  previous_value jsonb not null default '{}'::jsonb,
  new_value jsonb not null default '{}'::jsonb,
  reason text not null,
  result text not null,
  error_code text,
  created_at timestamptz not null default now(),
  constraint admin_audit_logs_actor_role_check
    check (actor_role in ('moderator', 'admin')),
  constraint admin_audit_logs_action_check
    check (
      char_length(action) between 1 and 80
      and action = lower(action)
      and action ~ '^[a-z0-9_]+$'
    ),
  constraint admin_audit_logs_target_type_check
    check (
      char_length(target_type) between 1 and 50
      and target_type = lower(target_type)
      and target_type ~ '^[a-z0-9_]+$'
    ),
  constraint admin_audit_logs_previous_value_check
    check (jsonb_typeof(previous_value) = 'object'),
  constraint admin_audit_logs_new_value_check
    check (jsonb_typeof(new_value) = 'object'),
  constraint admin_audit_logs_reason_check
    check (
      nullif(btrim(reason), '') is not null
      and char_length(reason) <= 1000
    ),
  constraint admin_audit_logs_result_check
    check (result in ('success', 'failure', 'denied', 'noop')),
  constraint admin_audit_logs_error_code_check
    check (
      error_code is null
      or (
        char_length(error_code) between 1 and 100
        and error_code = lower(error_code)
        and error_code ~ '^[a-z0-9_]+$'
      )
    )
);

comment on table public.admin_audit_logs is
  'Permanent append-only audit of sensitive Social Vote staff actions.';

comment on column public.admin_audit_logs.actor_user_id is
  'Staff user id without a foreign key so the audit survives account deletion.';

comment on column public.admin_audit_logs.target_id is
  'Generic target identifier without a foreign key so the audit survives target deletion.';

comment on column public.admin_audit_logs.previous_value is
  'Minimal non-sensitive previous state; never store tokens, documents, secrets, email or display name.';

comment on column public.admin_audit_logs.new_value is
  'Minimal non-sensitive new state; never store tokens, documents, secrets, email or display name.';

alter table public.admin_audit_logs enable row level security;
alter table public.admin_audit_logs force row level security;

revoke all
on table public.admin_audit_logs
from public, anon, authenticated, service_role;

grant select
on table public.admin_audit_logs
to authenticated;

grant select, insert
on table public.admin_audit_logs
to service_role;

drop policy if exists
  admin_audit_logs_select_admin
on public.admin_audit_logs;

create policy admin_audit_logs_select_admin
on public.admin_audit_logs
for select
to authenticated
using (
  (select public.is_current_auth_user_admin())
);

create index if not exists admin_audit_logs_actor_created_idx
on public.admin_audit_logs (actor_user_id, created_at desc);

create index if not exists admin_audit_logs_target_created_idx
on public.admin_audit_logs (target_type, target_id, created_at desc);

create index if not exists admin_audit_logs_action_created_idx
on public.admin_audit_logs (action, created_at desc);

create index if not exists admin_audit_logs_result_created_idx
on public.admin_audit_logs (result, created_at desc);

create index if not exists admin_audit_logs_created_at_idx
on public.admin_audit_logs (created_at desc);

create or replace function app_private.prevent_admin_audit_mutation()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  raise exception
    using
      errcode = '42501',
      message = 'Admin audit records are append-only.';
end;
$$;

revoke all
on function app_private.prevent_admin_audit_mutation()
from public, anon, authenticated;

drop trigger if exists
  social_vote_prevent_admin_audit_mutation
on public.admin_audit_logs;

create trigger social_vote_prevent_admin_audit_mutation
before update or delete on public.admin_audit_logs
for each row
execute function app_private.prevent_admin_audit_mutation();

commit;
