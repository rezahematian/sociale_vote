-- Social Vote — Workspace entitlement runtime fix V1
-- 2026-08-30
--
-- Fixes the real Admin runtime failure when applying entitlement=active.
-- Billing remains hard OFF: entitlement and commercial plan stay separate.

begin;

do $$
begin
  if to_regclass('public.organization_workspaces') is null then
    raise exception using
      errcode = '55000',
      message = 'organization_workspaces is missing.';
  end if;

  if to_regprocedure(
    'public.admin_set_workspace_entitlement(uuid,text,timestamptz,text)'
  ) is null then
    raise exception using
      errcode = '55000',
      message = 'admin_set_workspace_entitlement foundation is missing.';
  end if;

  if not exists (
    select 1
    from pg_catalog.pg_constraint c
    join pg_catalog.pg_class t on t.oid = c.conrelid
    join pg_catalog.pg_namespace n on n.oid = t.relnamespace
    where n.nspname = 'public'
      and t.relname = 'organization_workspaces'
      and c.conname = 'organization_workspaces_pilot_billing_hard_off'
      and c.convalidated
  ) then
    raise exception using
      errcode = '55000',
      message = 'Pilot billing hard-off constraint is missing or not validated.';
  end if;

  if exists (
    select 1
    from public.organization_workspaces
    where plan_key <> 'pilot'
       or commercial_mode <> 'pilot_free'
       or billing_enabled
  ) then
    raise exception using
      errcode = '55000',
      message = 'Unexpected commercial Workspace state; runtime fix stopped.';
  end if;
end;
$$;

create or replace function public.admin_set_workspace_entitlement(
  p_target_user_id uuid,
  p_entitlement_status text,
  p_expires_at timestamptz,
  p_reason text
)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  v_actor uuid := auth.uid();
  v_entitlement text := lower(btrim(coalesce(p_entitlement_status,'')));
  v_reason text := btrim(coalesce(p_reason,''));
  v_org_id uuid;
  v_workspace public.organization_workspaces%rowtype;
  v_new_status text;
  v_new_plan text;
  v_new_mode text;
begin
  if v_actor is null or not public.is_current_auth_user_admin() then
    raise exception using errcode='42501', message='Admin required.';
  end if;
  if v_entitlement not in ('none','pilot','active','suspended','expired') then
    raise exception using errcode='22023', message='Invalid entitlement status.';
  end if;
  if v_reason='' or char_length(v_reason)>1000 then
    raise exception using errcode='22023', message='Reason required.';
  end if;

  select om.organization_id into v_org_id
  from public.organization_memberships om
  where om.user_id=p_target_user_id and om.status='active'
  order by (om.membership_role='owner') desc,om.created_at asc
  limit 1;

  if v_org_id is null then
    raise exception using errcode='P0002', message='No organization membership for target user.';
  end if;

  select * into v_workspace
  from public.organization_workspaces
  where organization_id=v_org_id
  for update;

  if not found then
    raise exception using errcode='P0002', message='Workspace not found.';
  end if;

  v_new_status := case
    when v_entitlement in ('pilot','active') then 'active'
    when v_entitlement='suspended' then 'suspended'
    else 'restricted'
  end;

  -- Entitlement is independent from billing. Until billing is deliberately
  -- implemented, every Workspace must continue to satisfy the pilot hard-off
  -- invariant. In particular, entitlement=active must not invent pro/paid.
  v_new_plan := 'pilot';
  v_new_mode := 'pilot_free';

  update public.organization_workspaces
  set entitlement_status=v_entitlement,
      entitlement_started_at=case
        when v_entitlement in ('pilot','active')
          then coalesce(entitlement_started_at,pg_catalog.now())
        else entitlement_started_at
      end,
      entitlement_expires_at=p_expires_at,
      status=v_new_status,
      plan_key=v_new_plan,
      commercial_mode=v_new_mode,
      billing_enabled=false,
      updated_at=pg_catalog.now()
  where id=v_workspace.id;

  insert into public.admin_audit_logs(
    actor_user_id,actor_role,action,target_type,target_id,
    previous_value,new_value,reason,result
  ) values (
    v_actor,'admin','workspace_entitlement_change','organization_workspace',v_workspace.id::text,
    jsonb_build_object(
      'entitlement_status',v_workspace.entitlement_status,
      'status',v_workspace.status,
      'plan_key',v_workspace.plan_key,
      'commercial_mode',v_workspace.commercial_mode,
      'expires_at',v_workspace.entitlement_expires_at
    ),
    jsonb_build_object(
      'entitlement_status',v_entitlement,
      'status',v_new_status,
      'plan_key',v_new_plan,
      'commercial_mode',v_new_mode,
      'expires_at',p_expires_at
    ),
    v_reason,'success'
  );

  return public.admin_get_workspace_entitlement(p_target_user_id);
end;
$$;

revoke all on function public.admin_set_workspace_entitlement(
  uuid,text,timestamptz,text
) from public, anon, authenticated;
grant execute on function public.admin_set_workspace_entitlement(
  uuid,text,timestamptz,text
) to authenticated;

do $$
declare
  v_definition text;
begin
  select pg_catalog.pg_get_functiondef(
    'public.admin_set_workspace_entitlement(uuid,text,timestamptz,text)'::regprocedure
  ) into v_definition;

  if position('v_new_plan := ''pilot''' in v_definition) = 0
     or position('v_new_mode := ''pilot_free''' in v_definition) = 0
     or position('billing_enabled=false' in v_definition) = 0 then
    raise exception using
      errcode = '55000',
      message = 'Workspace entitlement runtime fix verification failed.';
  end if;

  if position('v_new_plan := case' in v_definition) > 0
     or position('v_new_mode := case' in v_definition) > 0 then
    raise exception using
      errcode = '55000',
      message = 'Old pro/paid entitlement coupling is still present.';
  end if;
end;
$$;

commit;
