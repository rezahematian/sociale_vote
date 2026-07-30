-- Social Vote
-- Admin Center: transactional account suspension, reactivation and logout.
--
-- Security rules:
-- - only the service-role backend can execute this function;
-- - the Edge Function must authenticate the caller before invoking it;
-- - the database independently verifies the actor's synchronized admin role;
-- - self-actions and actions against an admin are denied and audited;
-- - account state, session revocation and the success audit are committed
--   together;
-- - p_operation_id makes network retries idempotent;
-- - no email, token, document or other sensitive value is written to audit.

begin;

create or replace function public.admin_apply_account_action(
  p_operation_id uuid,
  p_actor_user_id uuid,
  p_target_user_id uuid,
  p_action text,
  p_reason text,
  p_suspended_until timestamptz
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_action text := lower(btrim(coalesce(p_action, '')));
  v_reason text := btrim(coalesce(p_reason, ''));
  v_audit_action text;
  v_actor_auth_role text;
  v_actor_mirror_role text;
  v_target_auth_role text;
  v_target_mirror_role text;
  v_previous_status text;
  v_previous_suspended_until timestamptz;
  v_previous_suspension_reason text;
  v_new_status text;
  v_new_suspended_until timestamptz;
  v_changed boolean := false;
  v_had_authorized_session boolean := false;
  v_revoked_session_count integer := 0;
  v_audit_result text;
  v_existing_audit public.admin_audit_logs%rowtype;
  v_previous_value jsonb := '{}'::jsonb;
  v_new_value jsonb := '{}'::jsonb;
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

  if v_action not in ('suspend', 'reactivate', 'force_logout') then
    raise exception
      using
        errcode = '22023',
        message = 'Action must be suspend, reactivate, or force_logout.';
  end if;

  if v_reason = '' or char_length(v_reason) > 1000 then
    raise exception
      using
        errcode = '22023',
        message = 'A reason between 1 and 1000 characters is required.';
  end if;

  if v_action = 'suspend' then
    if
      p_suspended_until is null
      or not isfinite(p_suspended_until)
      or p_suspended_until <= now()
    then
      raise exception
        using
          errcode = '22023',
          message = 'Suspension end time must be a finite future timestamp.';
    end if;
  elsif p_suspended_until is not null then
    raise exception
      using
        errcode = '22023',
        message = 'Suspension end time is valid only for suspend.';
  end if;

  v_audit_action := case v_action
    when 'suspend' then 'suspend_account'
    when 'reactivate' then 'reactivate_account'
    else 'force_account_logout'
  end;

  -- Serialize retries using the same operation id before checking the audit.
  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(p_operation_id::text, 0)
  );

  select *
  into v_existing_audit
  from public.admin_audit_logs aal
  where aal.id = p_operation_id;

  if found then
    if
      v_existing_audit.actor_user_id <> p_actor_user_id
      or v_existing_audit.action <> v_audit_action
      or v_existing_audit.target_type <> 'user'
      or v_existing_audit.target_id is distinct from p_target_user_id::text
      or v_existing_audit.reason <> v_reason
      or (
        v_action = 'suspend'
        and (
          v_existing_audit.new_value ->> 'suspendedUntil'
        )::timestamptz is distinct from p_suspended_until
      )
    then
      raise exception
        using
          errcode = '23505',
          message = 'Operation id has already been used for another action.';
    end if;

    return jsonb_build_object(
      'success',
      v_existing_audit.result in ('success', 'noop'),
      'replayed',
      true,
      'changed',
      coalesce(
        (v_existing_audit.new_value ->> 'changed')::boolean,
        false
      ),
      'result',
      v_existing_audit.result,
      'errorCode',
      v_existing_audit.error_code,
      'accountStatus',
      v_existing_audit.new_value ->> 'accountStatus',
      'suspendedUntil',
      v_existing_audit.new_value ->> 'suspendedUntil',
      'revokedSessionCount',
      coalesce(
        (v_existing_audit.new_value ->> 'revokedSessionCount')::integer,
        0
      ),
      'auditRecorded',
      true
    );
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
      when lower(coalesce(pu.role, '')) in ('user', 'moderator', 'admin')
        then lower(pu.role)
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

  if p_actor_user_id = p_target_user_id then
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
      v_audit_action,
      'user',
      p_target_user_id::text,
      '{}'::jsonb,
      jsonb_build_object(
        'changed', false,
        'revokedSessionCount', 0
      ),
      v_reason,
      'denied',
      'self_account_action_not_allowed'
    );

    return jsonb_build_object(
      'success', false,
      'replayed', false,
      'changed', false,
      'result', 'denied',
      'errorCode', 'self_account_action_not_allowed',
      'revokedSessionCount', 0,
      'auditRecorded', true
    );
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
  into v_target_auth_role
  from auth.users au
  where au.id = p_target_user_id;

  if not found then
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
      v_audit_action,
      'user',
      p_target_user_id::text,
      '{}'::jsonb,
      jsonb_build_object(
        'changed', false,
        'revokedSessionCount', 0
      ),
      v_reason,
      'failure',
      'target_user_not_found'
    );

    return jsonb_build_object(
      'success', false,
      'replayed', false,
      'changed', false,
      'result', 'failure',
      'errorCode', 'target_user_not_found',
      'revokedSessionCount', 0,
      'auditRecorded', true
    );
  end if;

  select
    case
      when lower(coalesce(pu.role, '')) in ('user', 'moderator', 'admin')
        then lower(pu.role)
      else 'user'
    end
  into v_target_mirror_role
  from public.users pu
  where pu.id = p_target_user_id;

  if not found then
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
      v_audit_action,
      'user',
      p_target_user_id::text,
      jsonb_build_object(
        'authRole', v_target_auth_role
      ),
      jsonb_build_object(
        'changed', false,
        'revokedSessionCount', 0
      ),
      v_reason,
      'failure',
      'target_mirror_missing'
    );

    return jsonb_build_object(
      'success', false,
      'replayed', false,
      'changed', false,
      'result', 'failure',
      'errorCode', 'target_mirror_missing',
      'revokedSessionCount', 0,
      'auditRecorded', true
    );
  end if;

  if v_target_auth_role <> v_target_mirror_role then
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
      v_audit_action,
      'user',
      p_target_user_id::text,
      jsonb_build_object(
        'authRole', v_target_auth_role,
        'mirrorRole', v_target_mirror_role
      ),
      jsonb_build_object(
        'changed', false,
        'revokedSessionCount', 0
      ),
      v_reason,
      'denied',
      'target_role_not_synchronized'
    );

    return jsonb_build_object(
      'success', false,
      'replayed', false,
      'changed', false,
      'result', 'denied',
      'errorCode', 'target_role_not_synchronized',
      'revokedSessionCount', 0,
      'auditRecorded', true
    );
  end if;

  if v_target_auth_role = 'admin' then
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
      v_audit_action,
      'user',
      p_target_user_id::text,
      jsonb_build_object(
        'role', 'admin'
      ),
      jsonb_build_object(
        'changed', false,
        'revokedSessionCount', 0
      ),
      v_reason,
      'denied',
      'target_admin_action_not_allowed'
    );

    return jsonb_build_object(
      'success', false,
      'replayed', false,
      'changed', false,
      'result', 'denied',
      'errorCode', 'target_admin_action_not_allowed',
      'revokedSessionCount', 0,
      'auditRecorded', true
    );
  end if;

  insert into app_private.account_controls (
    user_id,
    status
  )
  values (
    p_target_user_id,
    'active'
  )
  on conflict (user_id) do nothing;

  select
    ac.status,
    ac.suspended_until,
    ac.suspension_reason
  into
    v_previous_status,
    v_previous_suspended_until,
    v_previous_suspension_reason
  from app_private.account_controls ac
  where ac.user_id = p_target_user_id
  for update;

  if v_previous_status = 'deleted' then
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
      v_audit_action,
      'user',
      p_target_user_id::text,
      jsonb_build_object(
        'accountStatus', 'deleted'
      ),
      jsonb_build_object(
        'accountStatus', 'deleted',
        'changed', false,
        'revokedSessionCount', 0
      ),
      v_reason,
      'denied',
      'target_account_deleted'
    );

    return jsonb_build_object(
      'success', false,
      'replayed', false,
      'changed', false,
      'result', 'denied',
      'errorCode', 'target_account_deleted',
      'accountStatus', 'deleted',
      'revokedSessionCount', 0,
      'auditRecorded', true
    );
  end if;

  v_previous_value := jsonb_build_object(
    'accountStatus', v_previous_status,
    'suspendedUntil', v_previous_suspended_until
  );

  v_had_authorized_session :=
    exists (
      select 1
      from app_private.active_user_sessions aus
      where aus.user_id = p_target_user_id
    )
    or exists (
      select 1
      from auth.sessions s
      where s.user_id = p_target_user_id
    );

  if v_action = 'suspend' then
    v_changed :=
      v_previous_status <> 'suspended'
      or v_previous_suspended_until is distinct from p_suspended_until
      or v_previous_suspension_reason is distinct from v_reason;

    if v_changed then
      update app_private.account_controls
      set
        status = 'suspended',
        suspended_at = now(),
        suspended_until = p_suspended_until,
        suspended_by = p_actor_user_id,
        suspension_reason = v_reason,
        updated_at = now()
      where user_id = p_target_user_id;
    end if;

    select public.admin_revoke_user_sessions(p_target_user_id)
    into v_revoked_session_count;

    v_new_status := 'suspended';
    v_new_suspended_until := p_suspended_until;
  elsif v_action = 'reactivate' then
    v_changed := v_previous_status <> 'active';

    if v_changed then
      update app_private.account_controls
      set
        status = 'active',
        suspended_at = null,
        suspended_until = null,
        suspended_by = null,
        suspension_reason = null,
        updated_at = now()
      where user_id = p_target_user_id;
    end if;

    v_new_status := 'active';
    v_new_suspended_until := null;
  else
    select public.admin_revoke_user_sessions(p_target_user_id)
    into v_revoked_session_count;

    v_changed := v_had_authorized_session;
    v_new_status := case
      when
        v_previous_status = 'suspended'
        and v_previous_suspended_until <= now()
        then 'active'
      else v_previous_status
    end;
    v_new_suspended_until := case
      when v_new_status = 'suspended' then v_previous_suspended_until
      else null
    end;
  end if;

  if v_action = 'reactivate' then
    v_audit_result := case
      when v_changed then 'success'
      else 'noop'
    end;
  else
    v_audit_result := case
      when v_changed or v_revoked_session_count > 0 then 'success'
      else 'noop'
    end;
  end if;

  v_new_value := jsonb_build_object(
    'accountStatus', v_new_status,
    'suspendedUntil', v_new_suspended_until,
    'changed', v_changed,
    'revokedSessionCount', v_revoked_session_count
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
    result
  )
  values (
    p_operation_id,
    p_actor_user_id,
    'admin',
    v_audit_action,
    'user',
    p_target_user_id::text,
    v_previous_value,
    v_new_value,
    v_reason,
    v_audit_result
  );

  return jsonb_build_object(
    'success', true,
    'replayed', false,
    'changed', v_changed,
    'result', v_audit_result,
    'errorCode', null,
    'accountStatus', v_new_status,
    'suspendedUntil', v_new_suspended_until,
    'revokedSessionCount', v_revoked_session_count,
    'auditRecorded', true
  );
end;
$$;

comment on function public.admin_apply_account_action(
  uuid,
  uuid,
  uuid,
  text,
  text,
  timestamptz
) is
  'Backend-only idempotent account suspension, reactivation and logout with transactional audit.';

revoke all
on function public.admin_apply_account_action(
  uuid,
  uuid,
  uuid,
  text,
  text,
  timestamptz
)
from public, anon, authenticated;

grant execute
on function public.admin_apply_account_action(
  uuid,
  uuid,
  uuid,
  text,
  text,
  timestamptz
)
to service_role;

commit;
