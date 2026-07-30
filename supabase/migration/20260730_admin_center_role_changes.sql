-- Social Vote
-- Admin Center: retry-safe system-role change coordination.
--
-- Security and consistency rules:
-- - only the service-role backend can call these RPCs;
-- - both RPCs independently verify the actor's synchronized admin role;
-- - one operation id always identifies one actor/target/role/reason request;
-- - only one role change may be in progress for a target;
-- - retries return the recorded state instead of starting a second change;
-- - the permanent append-only audit records the request and final outcome;
-- - no email, display name, token, document or secret is stored.

begin;

create table if not exists app_private.admin_system_role_change_operations (
  id uuid primary key,
  actor_user_id uuid not null,
  target_user_id uuid not null,
  requested_role text not null,
  reason text not null,
  previous_auth_role text,
  previous_mirror_role text,
  status text not null,
  result text,
  error_code text,
  auth_role_updated boolean not null default false,
  mirror_role_updated boolean not null default false,
  sessions_revoked boolean not null default false,
  revoked_session_count integer not null default 0,
  rollback_succeeded boolean,
  request_audit_id uuid not null unique,
  completion_audit_id uuid not null unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  completed_at timestamptz,
  constraint admin_system_role_change_requested_role_check
    check (requested_role in ('user', 'moderator', 'admin')),
  constraint admin_system_role_change_previous_auth_role_check
    check (
      previous_auth_role is null
      or previous_auth_role in ('user', 'moderator', 'admin')
    ),
  constraint admin_system_role_change_previous_mirror_role_check
    check (
      previous_mirror_role is null
      or previous_mirror_role in ('user', 'moderator', 'admin')
    ),
  constraint admin_system_role_change_reason_check
    check (
      nullif(btrim(reason), '') is not null
      and char_length(reason) <= 1000
    ),
  constraint admin_system_role_change_status_check
    check (status in ('started', 'completed', 'failed')),
  constraint admin_system_role_change_result_check
    check (
      result is null
      or result in ('success', 'failure', 'denied', 'noop')
    ),
  constraint admin_system_role_change_error_code_check
    check (
      error_code is null
      or (
        char_length(error_code) between 1 and 100
        and error_code = lower(error_code)
        and error_code ~ '^[a-z0-9_]+$'
      )
    ),
  constraint admin_system_role_change_revoked_count_check
    check (revoked_session_count >= 0),
  constraint admin_system_role_change_state_shape_check
    check (
      (
        status = 'started'
        and result is null
        and error_code is null
        and completed_at is null
      )
      or (
        status = 'completed'
        and result in ('success', 'noop')
        and error_code is null
        and completed_at is not null
      )
      or (
        status = 'failed'
        and result in ('failure', 'denied')
        and error_code is not null
        and completed_at is not null
      )
    )
);

comment on table app_private.admin_system_role_change_operations is
  'Private retry coordination for Admin Center system-role changes; permanent history remains in admin_audit_logs.';

alter table app_private.admin_system_role_change_operations
  enable row level security;

alter table app_private.admin_system_role_change_operations
  force row level security;

revoke all
on table app_private.admin_system_role_change_operations
from public, anon, authenticated;

grant select, insert, update
on table app_private.admin_system_role_change_operations
to service_role;

create unique index if not exists
  admin_system_role_change_one_started_per_target_idx
on app_private.admin_system_role_change_operations (target_user_id)
where status = 'started';

create index if not exists
  admin_system_role_change_actor_created_idx
on app_private.admin_system_role_change_operations (
  actor_user_id,
  created_at desc
);

create index if not exists
  admin_system_role_change_status_updated_idx
on app_private.admin_system_role_change_operations (
  status,
  updated_at desc
);

-- Reserve or replay a role-change operation before the Edge Function updates
-- Auth metadata. Expected validation failures are recorded immediately.
create or replace function public.admin_begin_system_role_change(
  p_operation_id uuid,
  p_actor_user_id uuid,
  p_target_user_id uuid,
  p_requested_role text,
  p_reason text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_requested_role text :=
    lower(btrim(coalesce(p_requested_role, '')));
  v_reason text := btrim(coalesce(p_reason, ''));
  v_actor_auth_role text;
  v_actor_mirror_role text;
  v_target_auth_role text;
  v_target_mirror_role text;
  v_existing_operation
    app_private.admin_system_role_change_operations%rowtype;
  v_other_operation_id uuid;
  v_completion_audit_id uuid := gen_random_uuid();
  v_status text := 'started';
  v_result text;
  v_error_code text;
begin
  if coalesce((select auth.role()), '') <> 'service_role' then
    raise exception
      using
        errcode = '42501',
        message = 'Service role access is required.';
  end if;

  if p_operation_id is null then
    raise exception
      using
        errcode = '22004',
        message = 'An operation id is required.';
  end if;

  if p_actor_user_id is null or p_target_user_id is null then
    raise exception
      using
        errcode = '22004',
        message = 'Actor and target user ids are required.';
  end if;

  if v_requested_role not in ('user', 'moderator', 'admin') then
    raise exception
      using
        errcode = '22023',
        message = 'Role must be user, moderator, or admin.';
  end if;

  if v_reason = '' or char_length(v_reason) > 1000 then
    raise exception
      using
        errcode = '22023',
        message = 'A reason between 1 and 1000 characters is required.';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(
      'admin-system-role-operation:' || p_operation_id::text,
      0
    )
  );

  select
    case
      when lower(coalesce(au.raw_app_meta_data ->> 'role', '')) in (
        'user',
        'moderator',
        'admin'
      )
        then lower(au.raw_app_meta_data ->> 'role')
      else 'user'
    end
  into v_actor_auth_role
  from auth.users au
  where au.id = p_actor_user_id;

  if not found then
    raise exception
      using
        errcode = 'P0002',
        message = 'Actor user was not found.';
  end if;

  select
    case
      when lower(coalesce(pu.role::text, '')) in (
        'user',
        'moderator',
        'admin'
      )
        then lower(pu.role::text)
      else 'user'
    end
  into v_actor_mirror_role
  from public.users pu
  where pu.id = p_actor_user_id;

  if
    not found
    or v_actor_auth_role <> 'admin'
    or v_actor_mirror_role <> 'admin'
  then
    raise exception
      using
        errcode = '42501',
        message = 'A synchronized administrator role is required.';
  end if;

  select *
  into v_existing_operation
  from app_private.admin_system_role_change_operations asro
  where asro.id = p_operation_id;

  if found then
    if
      v_existing_operation.actor_user_id <> p_actor_user_id
      or v_existing_operation.target_user_id <> p_target_user_id
      or v_existing_operation.requested_role <> v_requested_role
      or v_existing_operation.reason <> v_reason
    then
      raise exception
        using
          errcode = '23505',
          message = 'Operation id has already been used for another action.';
    end if;

    return jsonb_build_object(
      'success',
        v_existing_operation.status = 'started'
        or (
          v_existing_operation.status = 'completed'
          and v_existing_operation.result in ('success', 'noop')
        ),
      'allowed', v_existing_operation.status = 'started',
      'replayed', true,
      'operationStatus', v_existing_operation.status,
      'result', v_existing_operation.result,
      'errorCode', v_existing_operation.error_code,
      'previousAuthRole', v_existing_operation.previous_auth_role,
      'previousMirrorRole', v_existing_operation.previous_mirror_role,
      'requestedRole', v_existing_operation.requested_role,
      'changed', v_existing_operation.result = 'success',
      'authRoleUpdated', v_existing_operation.auth_role_updated,
      'mirrorRoleUpdated', v_existing_operation.mirror_role_updated,
      'sessionsRevoked', v_existing_operation.sessions_revoked,
      'revokedSessionCount', v_existing_operation.revoked_session_count,
      'rollbackSucceeded', v_existing_operation.rollback_succeeded,
      'requestAuditRecorded',
        exists (
          select 1
          from public.admin_audit_logs aal
          where aal.id = v_existing_operation.request_audit_id
        ),
      'completionAuditRecorded',
        v_existing_operation.status in ('completed', 'failed')
        and exists (
          select 1
          from public.admin_audit_logs aal
          where aal.id = v_existing_operation.completion_audit_id
        )
    );
  end if;

  if exists (
    select 1
    from public.admin_audit_logs aal
    where aal.id = p_operation_id
  ) then
    raise exception
      using
        errcode = '23505',
        message = 'Operation id conflicts with an existing audit record.';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(
      'admin-system-role-target:' || p_target_user_id::text,
      0
    )
  );

  select asro.id
  into v_other_operation_id
  from app_private.admin_system_role_change_operations asro
  where asro.target_user_id = p_target_user_id
    and asro.status = 'started'
  limit 1;

  if found then
    v_status := 'failed';
    v_result := 'failure';
    v_error_code := 'target_role_change_in_progress';
  elsif p_actor_user_id = p_target_user_id then
    v_status := 'failed';
    v_result := 'denied';
    v_error_code := 'self_role_change_not_allowed';
  else
    select
      case
        when lower(coalesce(au.raw_app_meta_data ->> 'role', '')) in (
          'user',
          'moderator',
          'admin'
        )
          then lower(au.raw_app_meta_data ->> 'role')
        else 'user'
      end
    into v_target_auth_role
    from auth.users au
    where au.id = p_target_user_id;

    if not found then
      v_status := 'failed';
      v_result := 'failure';
      v_error_code := 'target_user_not_found';
    else
      select
        case
          when lower(coalesce(pu.role::text, '')) in (
            'user',
            'moderator',
            'admin'
          )
            then lower(pu.role::text)
          else 'user'
        end
      into v_target_mirror_role
      from public.users pu
      where pu.id = p_target_user_id;

      if not found then
        v_status := 'failed';
        v_result := 'failure';
        v_error_code := 'target_mirror_missing';
      elsif v_target_auth_role <> v_target_mirror_role then
        v_status := 'failed';
        v_result := 'denied';
        v_error_code := 'target_role_not_synchronized';
      elsif v_target_auth_role = v_requested_role then
        v_status := 'completed';
        v_result := 'noop';
      end if;
    end if;
  end if;

  insert into app_private.admin_system_role_change_operations (
    id,
    actor_user_id,
    target_user_id,
    requested_role,
    reason,
    previous_auth_role,
    previous_mirror_role,
    status,
    result,
    error_code,
    request_audit_id,
    completion_audit_id,
    completed_at
  )
  values (
    p_operation_id,
    p_actor_user_id,
    p_target_user_id,
    v_requested_role,
    v_reason,
    v_target_auth_role,
    v_target_mirror_role,
    v_status,
    v_result,
    v_error_code,
    p_operation_id,
    v_completion_audit_id,
    case when v_status = 'started' then null else now() end
  );

  insert into public.admin_audit_logs (
    id,
    actor_user_id,
    actor_role,
    action,
    target_type,
    target_id,
    previous_value,
    new_value,
    reason,
    result,
    error_code
  )
  values (
    p_operation_id,
    p_actor_user_id,
    'admin',
    'set_system_role_requested',
    'user',
    p_target_user_id::text,
    jsonb_build_object(
      'authRole', v_target_auth_role,
      'mirrorRole', v_target_mirror_role
    ),
    jsonb_build_object(
      'requestedRole', v_requested_role,
      'operationStatus', 'started',
      'changed', false
    ),
    v_reason,
    'success',
    null
  );

  if v_status <> 'started' then
    insert into public.admin_audit_logs (
      id,
      actor_user_id,
      actor_role,
      action,
      target_type,
      target_id,
      previous_value,
      new_value,
      reason,
      result,
      error_code
    )
    values (
      v_completion_audit_id,
      p_actor_user_id,
      'admin',
      'set_system_role',
      'user',
      p_target_user_id::text,
      jsonb_build_object(
        'authRole', v_target_auth_role,
        'mirrorRole', v_target_mirror_role
      ),
      jsonb_build_object(
        'requestedRole', v_requested_role,
        'operationStatus', v_status,
        'changed', false,
        'authRoleUpdated', false,
        'mirrorRoleUpdated', false,
        'sessionsRevoked', false,
        'revokedSessionCount', 0
      ),
      v_reason,
      v_result,
      v_error_code
    );
  end if;

  return jsonb_build_object(
    'success', v_status in ('started', 'completed'),
    'allowed', v_status = 'started',
    'replayed', false,
    'operationStatus', v_status,
    'result', v_result,
    'errorCode', v_error_code,
    'previousAuthRole', v_target_auth_role,
    'previousMirrorRole', v_target_mirror_role,
    'requestedRole', v_requested_role,
    'changed', false,
    'authRoleUpdated', false,
    'mirrorRoleUpdated', false,
    'sessionsRevoked', false,
    'revokedSessionCount', 0,
    'rollbackSucceeded', null,
    'requestAuditRecorded', true,
    'completionAuditRecorded', v_status <> 'started'
  );
end;
$$;

comment on function public.admin_begin_system_role_change(
  uuid,
  uuid,
  uuid,
  text,
  text
) is
  'Backend-only reservation and replay entry point for idempotent Admin Center role changes.';

revoke all
on function public.admin_begin_system_role_change(
  uuid,
  uuid,
  uuid,
  text,
  text
)
from public, anon, authenticated;

grant execute
on function public.admin_begin_system_role_change(
  uuid,
  uuid,
  uuid,
  text,
  text
)
to service_role;

-- Finalize or replay an operation after Auth, mirror and session work has
-- completed in the Edge Function.
create or replace function public.admin_finish_system_role_change(
  p_operation_id uuid,
  p_actor_user_id uuid,
  p_target_user_id uuid,
  p_requested_role text,
  p_outcome text,
  p_error_code text,
  p_auth_role_updated boolean,
  p_mirror_role_updated boolean,
  p_sessions_revoked boolean,
  p_revoked_session_count integer,
  p_rollback_succeeded boolean
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_requested_role text :=
    lower(btrim(coalesce(p_requested_role, '')));
  v_outcome text := lower(btrim(coalesce(p_outcome, '')));
  v_error_code text := lower(btrim(coalesce(p_error_code, '')));
  v_actor_auth_role text;
  v_actor_mirror_role text;
  v_current_auth_role text;
  v_current_mirror_role text;
  v_auth_user_exists boolean := false;
  v_mirror_user_exists boolean := false;
  v_sessions_remaining boolean := false;
  v_operation
    app_private.admin_system_role_change_operations%rowtype;
  v_final_status text;
  v_final_result text;
  v_final_error_code text;
begin
  if coalesce((select auth.role()), '') <> 'service_role' then
    raise exception
      using
        errcode = '42501',
        message = 'Service role access is required.';
  end if;

  if p_operation_id is null then
    raise exception
      using
        errcode = '22004',
        message = 'An operation id is required.';
  end if;

  if p_actor_user_id is null or p_target_user_id is null then
    raise exception
      using
        errcode = '22004',
        message = 'Actor and target user ids are required.';
  end if;

  if v_requested_role not in ('user', 'moderator', 'admin') then
    raise exception
      using
        errcode = '22023',
        message = 'Role must be user, moderator, or admin.';
  end if;

  if v_outcome not in ('completed', 'failed') then
    raise exception
      using
        errcode = '22023',
        message = 'Outcome must be completed or failed.';
  end if;

  if v_outcome = 'failed' then
    if
      v_error_code = ''
      or char_length(v_error_code) > 100
      or v_error_code !~ '^[a-z0-9_]+$'
    then
      raise exception
        using
          errcode = '22023',
          message = 'A valid failure error code is required.';
    end if;
  elsif v_error_code <> '' then
    raise exception
      using
        errcode = '22023',
        message = 'Error code is valid only for a failed outcome.';
  end if;

  if
    p_revoked_session_count is null
    or p_revoked_session_count < 0
  then
    raise exception
      using
        errcode = '22023',
        message = 'Revoked session count must be zero or greater.';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(
      'admin-system-role-operation:' || p_operation_id::text,
      0
    )
  );

  select
    case
      when lower(coalesce(au.raw_app_meta_data ->> 'role', '')) in (
        'user',
        'moderator',
        'admin'
      )
        then lower(au.raw_app_meta_data ->> 'role')
      else 'user'
    end
  into v_actor_auth_role
  from auth.users au
  where au.id = p_actor_user_id;

  if not found then
    raise exception
      using
        errcode = 'P0002',
        message = 'Actor user was not found.';
  end if;

  select
    case
      when lower(coalesce(pu.role::text, '')) in (
        'user',
        'moderator',
        'admin'
      )
        then lower(pu.role::text)
      else 'user'
    end
  into v_actor_mirror_role
  from public.users pu
  where pu.id = p_actor_user_id;

  if
    not found
    or v_actor_auth_role <> 'admin'
    or v_actor_mirror_role <> 'admin'
  then
    raise exception
      using
        errcode = '42501',
        message = 'A synchronized administrator role is required.';
  end if;

  select *
  into v_operation
  from app_private.admin_system_role_change_operations asro
  where asro.id = p_operation_id
  for update;

  if not found then
    raise exception
      using
        errcode = 'P0002',
        message = 'System-role change operation was not found.';
  end if;

  if
    v_operation.actor_user_id <> p_actor_user_id
    or v_operation.target_user_id <> p_target_user_id
    or v_operation.requested_role <> v_requested_role
  then
    raise exception
      using
        errcode = '42501',
        message = 'Operation actor, target or requested role does not match.';
  end if;

  if v_operation.status in ('completed', 'failed') then
    return jsonb_build_object(
      'success',
        v_operation.status = 'completed'
        and v_operation.result in ('success', 'noop'),
      'replayed', true,
      'operationStatus', v_operation.status,
      'result', v_operation.result,
      'errorCode', v_operation.error_code,
      'changed', v_operation.result = 'success',
      'previousAuthRole', v_operation.previous_auth_role,
      'previousMirrorRole', v_operation.previous_mirror_role,
      'requestedRole', v_operation.requested_role,
      'authRoleUpdated', v_operation.auth_role_updated,
      'mirrorRoleUpdated', v_operation.mirror_role_updated,
      'sessionsRevoked', v_operation.sessions_revoked,
      'revokedSessionCount', v_operation.revoked_session_count,
      'rollbackSucceeded', v_operation.rollback_succeeded,
      'auditRecorded',
        exists (
          select 1
          from public.admin_audit_logs aal
          where aal.id = v_operation.completion_audit_id
        )
    );
  end if;

  select
    exists (
      select 1
      from auth.users au
      where au.id = p_target_user_id
    ),
    (
      select
        case
          when lower(coalesce(au.raw_app_meta_data ->> 'role', '')) in (
            'user',
            'moderator',
            'admin'
          )
            then lower(au.raw_app_meta_data ->> 'role')
          else 'user'
        end
      from auth.users au
      where au.id = p_target_user_id
    )
  into
    v_auth_user_exists,
    v_current_auth_role;

  select
    exists (
      select 1
      from public.users pu
      where pu.id = p_target_user_id
    ),
    (
      select
        case
          when lower(coalesce(pu.role::text, '')) in (
            'user',
            'moderator',
            'admin'
          )
            then lower(pu.role::text)
          else 'user'
        end
      from public.users pu
      where pu.id = p_target_user_id
    )
  into
    v_mirror_user_exists,
    v_current_mirror_role;

  select
    exists (
      select 1
      from auth.sessions s
      where s.user_id = p_target_user_id
    )
    or exists (
      select 1
      from app_private.active_user_sessions aus
      where aus.user_id = p_target_user_id
    )
  into v_sessions_remaining;

  if v_outcome = 'completed' then
    if
      p_auth_role_updated is not true
      or p_mirror_role_updated is not true
      or p_sessions_revoked is not true
      or not v_auth_user_exists
      or not v_mirror_user_exists
      or v_current_auth_role <> v_requested_role
      or v_current_mirror_role <> v_requested_role
      or v_sessions_remaining
    then
      -- Keep the operation resumable. The Edge Function must roll back the
      -- external changes and then finalize with outcome = failed.
      return jsonb_build_object(
        'success', false,
        'replayed', false,
        'operationStatus', 'started',
        'result', null,
        'errorCode', 'role_change_state_not_confirmed',
        'requiresRollback', true,
        'changed', false,
        'previousAuthRole', v_operation.previous_auth_role,
        'previousMirrorRole', v_operation.previous_mirror_role,
        'requestedRole', v_requested_role,
        'currentAuthRole', v_current_auth_role,
        'currentMirrorRole', v_current_mirror_role,
        'authRoleUpdated', coalesce(p_auth_role_updated, false),
        'mirrorRoleUpdated', coalesce(p_mirror_role_updated, false),
        'sessionsRevoked', coalesce(p_sessions_revoked, false),
        'revokedSessionCount', p_revoked_session_count,
        'rollbackSucceeded', null,
        'auditRecorded', false
      );
    end if;

    v_final_status := 'completed';
    v_final_result := 'success';
    v_final_error_code := null;
  else
    v_final_status := 'failed';
    v_final_result := 'failure';
    v_final_error_code := v_error_code;
  end if;

  update app_private.admin_system_role_change_operations
  set
    status = v_final_status,
    result = v_final_result,
    error_code = v_final_error_code,
    auth_role_updated = coalesce(p_auth_role_updated, false),
    mirror_role_updated = coalesce(p_mirror_role_updated, false),
    sessions_revoked = coalesce(p_sessions_revoked, false),
    revoked_session_count = p_revoked_session_count,
    rollback_succeeded = p_rollback_succeeded,
    updated_at = now(),
    completed_at = now()
  where id = p_operation_id;

  insert into public.admin_audit_logs (
    id,
    actor_user_id,
    actor_role,
    action,
    target_type,
    target_id,
    previous_value,
    new_value,
    reason,
    result,
    error_code
  )
  values (
    v_operation.completion_audit_id,
    p_actor_user_id,
    'admin',
    'set_system_role',
    'user',
    p_target_user_id::text,
    jsonb_build_object(
      'authRole', v_operation.previous_auth_role,
      'mirrorRole', v_operation.previous_mirror_role
    ),
    jsonb_build_object(
      'requestedRole', v_requested_role,
      'currentAuthRole', v_current_auth_role,
      'currentMirrorRole', v_current_mirror_role,
      'operationStatus', v_final_status,
      'changed', v_final_result = 'success',
      'authRoleUpdated', coalesce(p_auth_role_updated, false),
      'mirrorRoleUpdated', coalesce(p_mirror_role_updated, false),
      'sessionsRevoked', coalesce(p_sessions_revoked, false),
      'revokedSessionCount', p_revoked_session_count,
      'rollbackSucceeded', p_rollback_succeeded
    ),
    v_operation.reason,
    v_final_result,
    v_final_error_code
  );

  return jsonb_build_object(
    'success', v_final_status = 'completed',
    'replayed', false,
    'operationStatus', v_final_status,
    'result', v_final_result,
    'errorCode', v_final_error_code,
    'changed', v_final_result = 'success',
    'previousAuthRole', v_operation.previous_auth_role,
    'previousMirrorRole', v_operation.previous_mirror_role,
    'requestedRole', v_requested_role,
    'authRoleUpdated', coalesce(p_auth_role_updated, false),
    'mirrorRoleUpdated', coalesce(p_mirror_role_updated, false),
    'sessionsRevoked', coalesce(p_sessions_revoked, false),
    'revokedSessionCount', p_revoked_session_count,
    'rollbackSucceeded', p_rollback_succeeded,
    'auditRecorded', true
  );
end;
$$;

comment on function public.admin_finish_system_role_change(
  uuid,
  uuid,
  uuid,
  text,
  text,
  text,
  boolean,
  boolean,
  boolean,
  integer,
  boolean
) is
  'Backend-only finalization and replay entry point for idempotent Admin Center role changes.';

revoke all
on function public.admin_finish_system_role_change(
  uuid,
  uuid,
  uuid,
  text,
  text,
  text,
  boolean,
  boolean,
  boolean,
  integer,
  boolean
)
from public, anon, authenticated;

grant execute
on function public.admin_finish_system_role_change(
  uuid,
  uuid,
  uuid,
  text,
  text,
  text,
  boolean,
  boolean,
  boolean,
  integer,
  boolean
)
to service_role;

commit;
