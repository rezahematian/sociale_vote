-- Social Vote
-- Admin Center: protected and idempotent administrative account deletion.
--
-- This migration coordinates an external Edge Function operation that must
-- remove Storage objects before deleting the Auth user.
--
-- Security and consistency rules:
-- - only the service-role backend can call these RPCs;
-- - the database independently verifies the actor's synchronized admin role;
-- - self-deletion and deletion of an admin account are denied;
-- - confirmation requires both DELETE and the exact target user id;
-- - a private mutable operation record makes retries safe;
-- - permanent append-only audit records the accepted request and final result;
-- - no email, display name, token, document or secret is stored here;
-- - the existing Auth deletion trigger owns public-user anonymization and
--   account_controls transition to deleted.

begin;

create table if not exists app_private.admin_account_deletion_operations (
  id uuid primary key,
  actor_user_id uuid not null,
  target_user_id uuid not null,
  reason text not null,
  status text not null default 'started',
  error_code text,
  avatar_cleanup_completed boolean not null default false,
  auth_user_deleted boolean not null default false,
  request_audit_id uuid not null unique,
  completion_audit_id uuid not null unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  completed_at timestamptz,
  constraint admin_account_deletion_reason_check
    check (
      nullif(btrim(reason), '') is not null
      and char_length(reason) <= 1000
    ),
  constraint admin_account_deletion_status_check
    check (status in ('started', 'completed', 'failed')),
  constraint admin_account_deletion_error_code_check
    check (
      error_code is null
      or (
        char_length(error_code) between 1 and 100
        and error_code = lower(error_code)
        and error_code ~ '^[a-z0-9_]+$'
      )
    ),
  constraint admin_account_deletion_state_shape_check
    check (
      (
        status = 'started'
        and completed_at is null
        and error_code is null
        and auth_user_deleted = false
      )
      or (
        status = 'completed'
        and completed_at is not null
        and error_code is null
        and auth_user_deleted = true
      )
      or (
        status = 'failed'
        and completed_at is not null
        and error_code is not null
      )
    )
);

comment on table app_private.admin_account_deletion_operations is
  'Private retry coordination for Admin Center account deletion; permanent history remains in admin_audit_logs.';

alter table app_private.admin_account_deletion_operations
  enable row level security;

alter table app_private.admin_account_deletion_operations
  force row level security;

revoke all
on table app_private.admin_account_deletion_operations
from public, anon, authenticated;

grant select, insert, update
on table app_private.admin_account_deletion_operations
to service_role;

create unique index if not exists
  admin_account_deletion_one_started_per_target_idx
on app_private.admin_account_deletion_operations (target_user_id)
where status = 'started';

create index if not exists
  admin_account_deletion_actor_created_idx
on app_private.admin_account_deletion_operations (
  actor_user_id,
  created_at desc
);

create index if not exists
  admin_account_deletion_status_updated_idx
on app_private.admin_account_deletion_operations (
  status,
  updated_at desc
);

-- Start or replay a protected deletion request.
--
-- Expected validation failures are stored as final failed/denied operations,
-- making a repeated request with the same operation id deterministic.
create or replace function public.admin_begin_account_deletion(
  p_operation_id uuid,
  p_actor_user_id uuid,
  p_target_user_id uuid,
  p_reason text,
  p_confirmation text,
  p_account_identifier text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_reason text := btrim(coalesce(p_reason, ''));
  v_actor_auth_role text;
  v_actor_mirror_role text;
  v_target_auth_role text;
  v_target_mirror_role text;
  v_target_account_status text;
  v_existing_operation
    app_private.admin_account_deletion_operations%rowtype;
  v_existing_audit public.admin_audit_logs%rowtype;
  v_other_operation_id uuid;
  v_completion_audit_id uuid := gen_random_uuid();
  v_error_code text;
  v_result text;
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

  if v_reason = '' or char_length(v_reason) > 1000 then
    raise exception
      using
        errcode = '22023',
        message = 'A reason between 1 and 1000 characters is required.';
  end if;

  if p_confirmation is distinct from 'DELETE' then
    raise exception
      using
        errcode = '22023',
        message = 'The DELETE confirmation is required.';
  end if;

  if
    lower(btrim(coalesce(p_account_identifier, '')))
      <> lower(p_target_user_id::text)
  then
    raise exception
      using
        errcode = '22023',
        message = 'The account identifier does not match the target user.';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(
      'admin-account-deletion-operation:' || p_operation_id::text,
      0
    )
  );

  select *
  into v_existing_operation
  from app_private.admin_account_deletion_operations ado
  where ado.id = p_operation_id;

  if found then
    if
      v_existing_operation.actor_user_id <> p_actor_user_id
      or v_existing_operation.target_user_id <> p_target_user_id
      or v_existing_operation.reason <> v_reason
    then
      raise exception
        using
          errcode = '23505',
          message = 'Operation id has already been used for another action.';
    end if;

    return jsonb_build_object(
      'success', v_existing_operation.status in ('started', 'completed'),
      'allowed', v_existing_operation.status = 'started',
      'replayed', true,
      'operationStatus', v_existing_operation.status,
      'errorCode', v_existing_operation.error_code,
      'avatarCleanupCompleted',
        v_existing_operation.avatar_cleanup_completed,
      'authUserDeleted', v_existing_operation.auth_user_deleted,
      'requestAuditRecorded', true,
      'completionAuditRecorded',
        v_existing_operation.status in ('completed', 'failed')
        and exists (
          select 1
          from public.admin_audit_logs aal
          where aal.id = v_existing_operation.completion_audit_id
        )
    );
  end if;

  select *
  into v_existing_audit
  from public.admin_audit_logs aal
  where aal.id = p_operation_id;

  if found then
    raise exception
      using
        errcode = '23505',
        message = 'Operation id conflicts with an existing audit record.';
  end if;

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

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(
      'admin-account-deletion-target:' || p_target_user_id::text,
      0
    )
  );

  select ado.id
  into v_other_operation_id
  from app_private.admin_account_deletion_operations ado
  where ado.target_user_id = p_target_user_id
    and ado.status = 'started'
  limit 1;

  if found then
    insert into app_private.admin_account_deletion_operations (
      id,
      actor_user_id,
      target_user_id,
      reason,
      status,
      error_code,
      request_audit_id,
      completion_audit_id,
      completed_at
    )
    values (
      p_operation_id,
      p_actor_user_id,
      p_target_user_id,
      v_reason,
      'failed',
      'target_deletion_in_progress',
      p_operation_id,
      v_completion_audit_id,
      now()
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
      'delete_account',
      'user',
      p_target_user_id::text,
      '{}'::jsonb,
      jsonb_build_object(
        'operationStatus', 'failed',
        'changed', false
      ),
      v_reason,
      'failure',
      'target_deletion_in_progress'
    );

    return jsonb_build_object(
      'success', false,
      'allowed', false,
      'replayed', false,
      'operationStatus', 'failed',
      'errorCode', 'target_deletion_in_progress',
      'avatarCleanupCompleted', false,
      'authUserDeleted', false,
      'requestAuditRecorded', true,
      'completionAuditRecorded', false
    );
  end if;

  insert into app_private.admin_account_deletion_operations (
    id,
    actor_user_id,
    target_user_id,
    reason,
    status,
    request_audit_id,
    completion_audit_id
  )
  values (
    p_operation_id,
    p_actor_user_id,
    p_target_user_id,
    v_reason,
    'started',
    p_operation_id,
    v_completion_audit_id
  );

  if p_actor_user_id = p_target_user_id then
    v_error_code := 'self_account_deletion_not_allowed';
    v_result := 'denied';
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
      v_error_code := 'target_user_not_found';
      v_result := 'failure';
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
        v_error_code := 'target_mirror_missing';
        v_result := 'failure';
      elsif
        v_target_auth_role = 'admin'
        or v_target_mirror_role = 'admin'
      then
        v_error_code := 'target_admin_deletion_not_allowed';
        v_result := 'denied';
      elsif v_target_auth_role <> v_target_mirror_role then
        v_error_code := 'target_role_not_synchronized';
        v_result := 'failure';
      else
        select ac.status
        into v_target_account_status
        from app_private.account_controls ac
        where ac.user_id = p_target_user_id;

        if not found then
          v_error_code := 'target_account_state_missing';
          v_result := 'failure';
        elsif v_target_account_status = 'deleted' then
          v_error_code := 'target_account_already_deleted';
          v_result := 'failure';
        end if;
      end if;
    end if;
  end if;

  if v_error_code is not null then
    update app_private.admin_account_deletion_operations
    set
      status = 'failed',
      error_code = v_error_code,
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
      p_operation_id,
      p_actor_user_id,
      'admin',
      'delete_account',
      'user',
      p_target_user_id::text,
      jsonb_build_object(
        'authRole', v_target_auth_role,
        'mirrorRole', v_target_mirror_role,
        'accountStatus', v_target_account_status
      ),
      jsonb_build_object(
        'operationStatus', 'failed',
        'changed', false
      ),
      v_reason,
      v_result,
      v_error_code
    );

    return jsonb_build_object(
      'success', false,
      'allowed', false,
      'replayed', false,
      'operationStatus', 'failed',
      'errorCode', v_error_code,
      'avatarCleanupCompleted', false,
      'authUserDeleted', false,
      'requestAuditRecorded', true,
      'completionAuditRecorded', false
    );
  end if;

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
    'delete_account_requested',
    'user',
    p_target_user_id::text,
    jsonb_build_object(
      'authRole', v_target_auth_role,
      'mirrorRole', v_target_mirror_role,
      'accountStatus', v_target_account_status
    ),
    jsonb_build_object(
      'operationStatus', 'started',
      'changed', false
    ),
    v_reason,
    'success',
    null
  );

  return jsonb_build_object(
    'success', true,
    'allowed', true,
    'replayed', false,
    'operationStatus', 'started',
    'errorCode', null,
    'avatarCleanupCompleted', false,
    'authUserDeleted', false,
    'requestAuditRecorded', true,
    'completionAuditRecorded', false
  );
end;
$$;

revoke all
on function public.admin_begin_account_deletion(
  uuid,
  uuid,
  uuid,
  text,
  text,
  text
)
from public, anon, authenticated;

grant execute
on function public.admin_begin_account_deletion(
  uuid,
  uuid,
  uuid,
  text,
  text,
  text
)
to service_role;

-- Finalize or replay the result after the Edge Function has completed Storage
-- cleanup and attempted Auth deletion.
create or replace function public.admin_finish_account_deletion(
  p_operation_id uuid,
  p_actor_user_id uuid,
  p_target_user_id uuid,
  p_outcome text,
  p_error_code text,
  p_avatar_cleanup_completed boolean,
  p_auth_user_deleted boolean
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_outcome text := lower(btrim(coalesce(p_outcome, '')));
  v_error_code text := lower(btrim(coalesce(p_error_code, '')));
  v_operation
    app_private.admin_account_deletion_operations%rowtype;
  v_auth_user_exists boolean;
  v_public_user_anonymized boolean;
  v_account_marked_deleted boolean;
  v_final_status text;
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

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(
      'admin-account-deletion-operation:' || p_operation_id::text,
      0
    )
  );

  select *
  into v_operation
  from app_private.admin_account_deletion_operations ado
  where ado.id = p_operation_id
  for update;

  if not found then
    raise exception
      using
        errcode = 'P0002',
        message = 'Account deletion operation was not found.';
  end if;

  if
    v_operation.actor_user_id <> p_actor_user_id
    or v_operation.target_user_id <> p_target_user_id
  then
    raise exception
      using
        errcode = '42501',
        message = 'Operation actor or target does not match.';
  end if;

  if v_operation.status in ('completed', 'failed') then
    return jsonb_build_object(
      'success', v_operation.status = 'completed',
      'replayed', true,
      'operationStatus', v_operation.status,
      'errorCode', v_operation.error_code,
      'avatarCleanupCompleted',
        v_operation.avatar_cleanup_completed,
      'authUserDeleted', v_operation.auth_user_deleted,
      'auditRecorded',
        exists (
          select 1
          from public.admin_audit_logs aal
          where aal.id = v_operation.completion_audit_id
        )
    );
  end if;

  if v_outcome = 'completed' then
    select exists (
      select 1
      from auth.users au
      where au.id = p_target_user_id
    )
    into v_auth_user_exists;

    select exists (
      select 1
      from public.users pu
      where pu.id = p_target_user_id
        and pu.email is null
        and pu.display_name is null
        and lower(coalesce(pu.role::text, '')) = 'user'
    )
    into v_public_user_anonymized;

    select exists (
      select 1
      from app_private.account_controls ac
      where ac.user_id = p_target_user_id
        and ac.status = 'deleted'
    )
    into v_account_marked_deleted;

    if
      p_auth_user_deleted is not true
      or v_auth_user_exists
      or not v_public_user_anonymized
      or not v_account_marked_deleted
    then
      v_final_status := 'failed';
      v_final_error_code := 'deletion_state_not_confirmed';
    else
      v_final_status := 'completed';
      v_final_error_code := null;
    end if;
  else
    v_final_status := 'failed';
    v_final_error_code := v_error_code;
  end if;

  update app_private.admin_account_deletion_operations
  set
    status = v_final_status,
    error_code = v_final_error_code,
    avatar_cleanup_completed =
      coalesce(p_avatar_cleanup_completed, false),
    auth_user_deleted = coalesce(p_auth_user_deleted, false),
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
    'delete_account',
    'user',
    p_target_user_id::text,
    jsonb_build_object(
      'operationStatus', 'started'
    ),
    jsonb_build_object(
      'operationStatus', v_final_status,
      'changed', v_final_status = 'completed',
      'avatarCleanupCompleted',
        coalesce(p_avatar_cleanup_completed, false),
      'authUserDeleted', coalesce(p_auth_user_deleted, false),
      'accountStatus',
        case
          when v_final_status = 'completed' then 'deleted'
          else null
        end
    ),
    v_operation.reason,
    case
      when v_final_status = 'completed' then 'success'
      else 'failure'
    end,
    v_final_error_code
  );

  return jsonb_build_object(
    'success', v_final_status = 'completed',
    'replayed', false,
    'operationStatus', v_final_status,
    'errorCode', v_final_error_code,
    'avatarCleanupCompleted',
      coalesce(p_avatar_cleanup_completed, false),
    'authUserDeleted', coalesce(p_auth_user_deleted, false),
    'auditRecorded', true
  );
end;
$$;

revoke all
on function public.admin_finish_account_deletion(
  uuid,
  uuid,
  uuid,
  text,
  text,
  boolean,
  boolean
)
from public, anon, authenticated;

grant execute
on function public.admin_finish_account_deletion(
  uuid,
  uuid,
  uuid,
  text,
  text,
  boolean,
  boolean
)
to service_role;

commit;
