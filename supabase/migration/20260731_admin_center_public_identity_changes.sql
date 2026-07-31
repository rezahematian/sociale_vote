-- Social Vote
-- Admin Center: protected public identity and verification changes.
--
-- Security rules:
-- - only the service-role backend can execute this function;
-- - the Edge Function must authenticate the caller before invoking it;
-- - the database independently verifies the actor's synchronized admin role;
-- - Persona may use none/level1/level2, while every other public identity
--   must use verification level none;
-- - any pending verification request is closed when an admin overrides the
--   public identity state;
-- - the change and its audit entry are committed together;
-- - p_operation_id makes network retries idempotent;
-- - no email, token, document or other sensitive value is written to audit.

begin;

create or replace function public.admin_set_public_identity(
  p_operation_id uuid,
  p_actor_user_id uuid,
  p_target_user_id uuid,
  p_actor_type text,
  p_verification_level text,
  p_reason text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor_type text := lower(btrim(coalesce(p_actor_type, '')));
  v_verification_level text := lower(
    btrim(coalesce(p_verification_level, ''))
  );
  v_reason text := btrim(coalesce(p_reason, ''));
  v_actor_auth_role text;
  v_actor_mirror_role text;
  v_target_account_status text;
  v_previous_actor_type text;
  v_previous_account_type text;
  v_previous_verification_level text;
  v_previous_verification_status text;
  v_previous_is_verified boolean;
  v_new_is_verified boolean;
  v_profile_changed boolean := false;
  v_pending_request_count integer := 0;
  v_cancelled_request_count integer := 0;
  v_changed boolean := false;
  v_result text;
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

  if v_actor_type not in (
    'citizen',
    'public_official',
    'institution',
    'organization'
  ) then
    raise exception
      using
        errcode = '22023',
        message = 'Invalid public identity type.';
  end if;

  if v_verification_level not in ('none', 'level1', 'level2') then
    raise exception
      using
        errcode = '22023',
        message = 'Invalid verification level.';
  end if;

  if
    v_actor_type <> 'citizen'
    and v_verification_level <> 'none'
  then
    raise exception
      using
        errcode = '22023',
        message = 'Verification levels apply only to Persona accounts.';
  end if;

  if v_reason = '' or char_length(v_reason) > 1000 then
    raise exception
      using
        errcode = '22023',
        message = 'A reason between 1 and 1000 characters is required.';
  end if;

  v_new_is_verified :=
    v_actor_type <> 'citizen'
    or v_verification_level <> 'none';

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
      or v_existing_audit.action <> 'set_public_identity'
      or v_existing_audit.target_type <> 'user'
      or v_existing_audit.target_id is distinct from p_target_user_id::text
      or v_existing_audit.reason <> v_reason
      or v_existing_audit.new_value ->> 'actorType'
        is distinct from v_actor_type
      or v_existing_audit.new_value ->> 'verificationLevel'
        is distinct from v_verification_level
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
      'actorType',
      v_existing_audit.new_value ->> 'actorType',
      'verificationLevel',
      v_existing_audit.new_value ->> 'verificationLevel',
      'cancelledPendingRequestCount',
      coalesce(
        (
          v_existing_audit.new_value
          ->> 'cancelledPendingRequestCount'
        )::integer,
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

  perform 1
  from auth.users au
  where au.id = p_target_user_id;

  if not found then
    v_new_value := jsonb_build_object(
      'actorType', v_actor_type,
      'verificationLevel', v_verification_level,
      'changed', false,
      'cancelledPendingRequestCount', 0
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
      'set_public_identity',
      'user',
      p_target_user_id::text,
      '{}'::jsonb,
      v_new_value,
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
      'actorType', v_actor_type,
      'verificationLevel', v_verification_level,
      'cancelledPendingRequestCount', 0,
      'auditRecorded', true
    );
  end if;

  select coalesce(ac.status, 'active')
  into v_target_account_status
  from app_private.account_controls ac
  where ac.user_id = p_target_user_id;

  if coalesce(v_target_account_status, 'active') = 'deleted' then
    v_new_value := jsonb_build_object(
      'actorType', v_actor_type,
      'verificationLevel', v_verification_level,
      'changed', false,
      'cancelledPendingRequestCount', 0
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
      'set_public_identity',
      'user',
      p_target_user_id::text,
      '{}'::jsonb,
      v_new_value,
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
      'actorType', v_actor_type,
      'verificationLevel', v_verification_level,
      'cancelledPendingRequestCount', 0,
      'auditRecorded', true
    );
  end if;

  select
    case
      when lower(coalesce(up.actor_type, '')) in (
        'citizen',
        'public_official',
        'institution',
        'organization'
      )
        then lower(up.actor_type)
      when lower(coalesce(up.actor_type, '')) = 'verified_organization'
        then 'organization'
      else 'citizen'
    end,
    case
      when lower(coalesce(up.verification_level, '')) in (
        'none',
        'level1',
        'level2'
      )
        then lower(up.verification_level)
      else 'none'
    end,
    case
      when lower(coalesce(up.verification_status, '')) in (
        'none',
        'pending',
        'rejected'
      )
        then lower(up.verification_status)
      else 'none'
    end,
    case
      when lower(coalesce(up.account_type, '')) in (
        'citizen',
        'public_official',
        'institution',
        'organization'
      )
        then lower(up.account_type)
      when lower(coalesce(up.account_type, '')) = 'verified_organization'
        then 'organization'
      else 'citizen'
    end,
    coalesce(up.is_verified, false)
  into
    v_previous_actor_type,
    v_previous_verification_level,
    v_previous_verification_status,
    v_previous_account_type,
    v_previous_is_verified
  from public.user_profiles up
  where up.id = p_target_user_id
  for update;

  if not found then
    v_new_value := jsonb_build_object(
      'actorType', v_actor_type,
      'verificationLevel', v_verification_level,
      'changed', false,
      'cancelledPendingRequestCount', 0
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
      'set_public_identity',
      'user',
      p_target_user_id::text,
      '{}'::jsonb,
      v_new_value,
      v_reason,
      'failure',
      'target_profile_missing'
    );

    return jsonb_build_object(
      'success', false,
      'replayed', false,
      'changed', false,
      'result', 'failure',
      'errorCode', 'target_profile_missing',
      'actorType', v_actor_type,
      'verificationLevel', v_verification_level,
      'cancelledPendingRequestCount', 0,
      'auditRecorded', true
    );
  end if;

  select count(*)::integer
  into v_pending_request_count
  from public.verification_requests vr
  where vr.user_id = p_target_user_id
    and vr.status = 'pending';

  v_profile_changed :=
    v_previous_actor_type <> v_actor_type
    or v_previous_account_type <> v_actor_type
    or v_previous_verification_level <> v_verification_level
    or v_previous_verification_status <> 'none'
    or v_previous_is_verified <> v_new_is_verified;

  v_previous_value := jsonb_build_object(
    'actorType', v_previous_actor_type,
    'accountType', v_previous_account_type,
    'verificationLevel', v_previous_verification_level,
    'verificationStatus', v_previous_verification_status,
    'isVerified', v_previous_is_verified,
    'pendingRequestCount', v_pending_request_count
  );

  if v_profile_changed then
    update public.user_profiles
    set
      actor_type = v_actor_type,
      account_type = v_actor_type,
      verification_level = v_verification_level,
      verification_status = 'none',
      verification_requested_at = null,
      verified_at = case
        when v_new_is_verified then now()
        else null
      end,
      institution_level = case
        when v_actor_type = 'institution' then institution_level
        else null
      end,
      official_title = case
        when v_actor_type = 'public_official' then official_title
        else null
      end,
      institution_name = case
        when v_actor_type = 'institution' then institution_name
        else null
      end,
      organization_name = case
        when v_actor_type = 'organization' then organization_name
        else null
      end,
      is_verified = v_new_is_verified,
      updated_at = now()
    where id = p_target_user_id;
  end if;

  if v_pending_request_count > 0 then
    update public.verification_requests
    set
      status = 'cancelled',
      reviewed_by = p_actor_user_id,
      reviewed_at = now(),
      review_note = 'Closed by administrator after direct identity update.',
      updated_at = now()
    where user_id = p_target_user_id
      and status = 'pending';

    get diagnostics v_cancelled_request_count = row_count;
  end if;

  v_changed := v_profile_changed or v_cancelled_request_count > 0;
  v_result := case when v_changed then 'success' else 'noop' end;

  v_new_value := jsonb_build_object(
    'actorType', v_actor_type,
    'verificationLevel', v_verification_level,
    'verificationStatus', 'none',
    'isVerified', v_new_is_verified,
    'changed', v_changed,
    'cancelledPendingRequestCount', v_cancelled_request_count
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
    'set_public_identity',
    'user',
    p_target_user_id::text,
    v_previous_value,
    v_new_value,
    v_reason,
    v_result,
    null
  );

  return jsonb_build_object(
    'success', true,
    'replayed', false,
    'changed', v_changed,
    'result', v_result,
    'errorCode', null,
    'actorType', v_actor_type,
    'verificationLevel', v_verification_level,
    'cancelledPendingRequestCount', v_cancelled_request_count,
    'auditRecorded', true
  );
end;
$$;

comment on function public.admin_set_public_identity(
  uuid,
  uuid,
  uuid,
  text,
  text,
  text
) is
  'Backend-only audited Admin Center update of public identity and verification state.';

revoke all
on function public.admin_set_public_identity(
  uuid,
  uuid,
  uuid,
  text,
  text,
  text
)
from public, anon, authenticated;

grant execute
on function public.admin_set_public_identity(
  uuid,
  uuid,
  uuid,
  text,
  text,
  text
)
to service_role;

commit;
