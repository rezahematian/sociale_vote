-- Social Vote — Workspace Entitlement + Team Management + Admin Control V1
-- 2026-08-29
-- Verification is identity. Workspace entitlement is commercial access.
-- Existing pilot workspaces remain pilot. New verified entities bootstrap with no entitlement.
-- Team management operates only on existing Social Vote accounts and is fully server-side/audited.

begin;

alter table public.organization_workspaces
  add column if not exists entitlement_status text,
  add column if not exists entitlement_started_at timestamptz,
  add column if not exists entitlement_expires_at timestamptz;

update public.organization_workspaces
set entitlement_status = case
  when entitlement_status is not null then entitlement_status
  when plan_key = 'pilot' or commercial_mode = 'pilot_free' then 'pilot'
  when commercial_mode = 'paid' then 'active'
  else 'active'
end
where entitlement_status is null;

alter table public.organization_workspaces
  alter column entitlement_status set default 'none',
  alter column entitlement_status set not null;

alter table public.organization_workspaces
  drop constraint if exists organization_workspaces_entitlement_status_check;

alter table public.organization_workspaces
  add constraint organization_workspaces_entitlement_status_check
  check (entitlement_status in ('none','pilot','active','suspended','expired'));

create or replace function public.organization_workspace_effective_active(
  p_workspace public.organization_workspaces
)
returns boolean
language sql
stable
set search_path = pg_catalog, public
as $$
  select
    p_workspace.entitlement_status in ('pilot','active')
    and (
      p_workspace.entitlement_expires_at is null
      or p_workspace.entitlement_expires_at > pg_catalog.now()
    )
    and p_workspace.status = 'active';
$$;

revoke all on function public.organization_workspace_effective_active(public.organization_workspaces)
from public, anon;
grant execute on function public.organization_workspace_effective_active(public.organization_workspaces)
to authenticated;

-- ------------------------------------------------------------
-- TEAM
-- ------------------------------------------------------------

create or replace function public.organization_team_list()
returns table (
  user_id uuid,
  username text,
  display_name text,
  email text,
  membership_role text,
  membership_status text,
  created_at timestamptz
)
language plpgsql
security definer
set search_path = pg_catalog, public, auth
as $$
declare
  v_user_id uuid := auth.uid();
  v_org_id uuid;
begin
  if v_user_id is null or not public.is_current_auth_user_active() then
    raise exception using errcode='42501', message='Active authentication required.';
  end if;

  select om.organization_id into v_org_id
  from public.organization_memberships om
  where om.user_id = v_user_id and om.status = 'active'
  order by (om.membership_role='owner') desc, om.created_at asc
  limit 1;

  if v_org_id is null then
    return;
  end if;

  return query
  select
    om.user_id,
    nullif(btrim(up.username),'')::text,
    nullif(btrim(up.display_name),'')::text,
    nullif(btrim(au.email),'')::text,
    om.membership_role,
    om.status,
    om.created_at
  from public.organization_memberships om
  left join public.user_profiles up on up.id = om.user_id
  left join auth.users au on au.id = om.user_id
  where om.organization_id = v_org_id
  order by
    case om.membership_role when 'owner' then 0 when 'manager' then 1 when 'operator' then 2 else 3 end,
    om.created_at asc;
end;
$$;

revoke all on function public.organization_team_list() from public, anon;
grant execute on function public.organization_team_list() to authenticated;

create or replace function public.organization_team_add_existing_user(
  p_identifier text,
  p_role text
)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public, auth
as $$
declare
  v_actor uuid := auth.uid();
  v_org_id uuid;
  v_actor_role text;
  v_target uuid;
  v_identifier text := lower(btrim(coalesce(p_identifier,'')));
  v_role text := lower(btrim(coalesce(p_role,'')));
  v_workspace public.organization_workspaces%rowtype;
begin
  if v_actor is null or not public.is_current_auth_user_active() then
    raise exception using errcode='42501', message='Active authentication required.';
  end if;
  if v_identifier = '' then
    raise exception using errcode='22023', message='Username or email required.';
  end if;
  if v_role not in ('manager','operator','viewer') then
    raise exception using errcode='22023', message='Invalid team role.';
  end if;

  select om.organization_id, om.membership_role
  into v_org_id, v_actor_role
  from public.organization_memberships om
  where om.user_id=v_actor and om.status='active'
  order by (om.membership_role='owner') desc, om.created_at asc
  limit 1;

  if v_org_id is null or v_actor_role not in ('owner','manager') then
    raise exception using errcode='42501', message='Owner or manager required.';
  end if;

  select * into v_workspace
  from public.organization_workspaces
  where organization_id=v_org_id;

  if not found or not public.organization_workspace_effective_active(v_workspace) then
    raise exception using errcode='42501', message='Active or pilot Workspace required.';
  end if;

  select coalesce(up.id, au.id) into v_target
  from auth.users au
  left join public.user_profiles up on up.id=au.id
  where lower(coalesce(au.email,'')) = v_identifier
     or lower(coalesce(up.username,'')) = trim(leading '@' from v_identifier)
  order by (lower(coalesce(up.username,'')) = trim(leading '@' from v_identifier)) desc
  limit 1;

  if v_target is null then
    raise exception using errcode='P0002', message='Existing Social Vote account not found.';
  end if;
  if v_target = v_actor then
    raise exception using errcode='22023', message='Use role management for your own membership.';
  end if;

  insert into public.organization_memberships (
    organization_id,user_id,membership_role,status,created_at,updated_at
  ) values (
    v_org_id,v_target,v_role,'active',pg_catalog.now(),pg_catalog.now()
  )
  on conflict (organization_id,user_id) do update
  set membership_role=excluded.membership_role,
      status='active',
      updated_at=pg_catalog.now();

  insert into public.organization_session_audit(
    organization_id,actor_user_id,event_key,metadata
  ) values (
    v_org_id,v_actor,'team_member_added',
    jsonb_build_object('target_user_id',v_target,'role',v_role)
  );

  return jsonb_build_object('ok',true,'user_id',v_target,'role',v_role);
end;
$$;

revoke all on function public.organization_team_add_existing_user(text,text) from public, anon;
grant execute on function public.organization_team_add_existing_user(text,text) to authenticated;

create or replace function public.organization_team_set_role(
  p_user_id uuid,
  p_role text
)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  v_actor uuid := auth.uid();
  v_org_id uuid;
  v_actor_role text;
  v_current_role text;
  v_role text := lower(btrim(coalesce(p_role,'')));
begin
  if v_actor is null or not public.is_current_auth_user_active() then
    raise exception using errcode='42501', message='Active authentication required.';
  end if;
  if v_role not in ('manager','operator','viewer') then
    raise exception using errcode='22023', message='Invalid team role.';
  end if;

  select organization_id,membership_role into v_org_id,v_actor_role
  from public.organization_memberships
  where user_id=v_actor and status='active'
  order by (membership_role='owner') desc, created_at asc
  limit 1;

  if v_org_id is null or v_actor_role not in ('owner','manager') then
    raise exception using errcode='42501', message='Owner or manager required.';
  end if;

  select membership_role into v_current_role
  from public.organization_memberships
  where organization_id=v_org_id and user_id=p_user_id and status='active';

  if v_current_role is null then
    raise exception using errcode='P0002', message='Team member not found.';
  end if;
  if v_current_role='owner' then
    raise exception using errcode='42501', message='Owner role cannot be changed here.';
  end if;
  if v_actor_role='manager' and v_current_role='manager' and p_user_id<>v_actor then
    raise exception using errcode='42501', message='Managers cannot change another manager.';
  end if;

  update public.organization_memberships
  set membership_role=v_role,updated_at=pg_catalog.now()
  where organization_id=v_org_id and user_id=p_user_id and status='active';

  insert into public.organization_session_audit(
    organization_id,actor_user_id,event_key,metadata
  ) values (
    v_org_id,v_actor,'team_member_role_changed',
    jsonb_build_object('target_user_id',p_user_id,'previous_role',v_current_role,'new_role',v_role)
  );

  return jsonb_build_object('ok',true,'user_id',p_user_id,'role',v_role);
end;
$$;

revoke all on function public.organization_team_set_role(uuid,text) from public, anon;
grant execute on function public.organization_team_set_role(uuid,text) to authenticated;

create or replace function public.organization_team_revoke(p_user_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  v_actor uuid := auth.uid();
  v_org_id uuid;
  v_actor_role text;
  v_target_role text;
begin
  if v_actor is null or not public.is_current_auth_user_active() then
    raise exception using errcode='42501', message='Active authentication required.';
  end if;

  select organization_id,membership_role into v_org_id,v_actor_role
  from public.organization_memberships
  where user_id=v_actor and status='active'
  order by (membership_role='owner') desc, created_at asc
  limit 1;

  if v_org_id is null or v_actor_role not in ('owner','manager') then
    raise exception using errcode='42501', message='Owner or manager required.';
  end if;

  select membership_role into v_target_role
  from public.organization_memberships
  where organization_id=v_org_id and user_id=p_user_id and status='active';

  if v_target_role is null then
    raise exception using errcode='P0002', message='Team member not found.';
  end if;
  if v_target_role='owner' then
    raise exception using errcode='42501', message='Owner cannot be revoked.';
  end if;
  if v_actor_role='manager' and v_target_role='manager' and p_user_id<>v_actor then
    raise exception using errcode='42501', message='Managers cannot revoke another manager.';
  end if;

  update public.organization_memberships
  set status='revoked',updated_at=pg_catalog.now()
  where organization_id=v_org_id and user_id=p_user_id and status='active';

  insert into public.organization_session_audit(
    organization_id,actor_user_id,event_key,metadata
  ) values (
    v_org_id,v_actor,'team_member_revoked',
    jsonb_build_object('target_user_id',p_user_id,'previous_role',v_target_role)
  );

  return jsonb_build_object('ok',true,'user_id',p_user_id);
end;
$$;

revoke all on function public.organization_team_revoke(uuid) from public, anon;
grant execute on function public.organization_team_revoke(uuid) to authenticated;

-- ------------------------------------------------------------
-- ADMIN WORKSPACE CONTROL
-- ------------------------------------------------------------

create or replace function public.admin_get_workspace_entitlement(p_target_user_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  v_actor uuid := auth.uid();
  v_result jsonb;
begin
  if v_actor is null or not public.is_current_auth_user_admin() then
    raise exception using errcode='42501', message='Admin required.';
  end if;

  select jsonb_build_object(
    'organization_id',oe.id,
    'organization_name',oe.public_name,
    'verification_status',oe.verification_status,
    'workspace_id',ow.id,
    'entitlement_status',ow.entitlement_status,
    'workspace_status',ow.status,
    'plan_key',ow.plan_key,
    'commercial_mode',ow.commercial_mode,
    'billing_enabled',ow.billing_enabled,
    'entitlement_started_at',ow.entitlement_started_at,
    'entitlement_expires_at',ow.entitlement_expires_at
  )
  into v_result
  from public.organization_memberships om
  join public.organization_entities oe on oe.id=om.organization_id
  join public.organization_workspaces ow on ow.organization_id=oe.id
  where om.user_id=p_target_user_id and om.status='active'
  order by (om.membership_role='owner') desc,om.created_at asc
  limit 1;

  return v_result;
end;
$$;

revoke all on function public.admin_get_workspace_entitlement(uuid) from public, anon, authenticated;
grant execute on function public.admin_get_workspace_entitlement(uuid) to authenticated;

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
  v_new_plan := case
    when v_entitlement='pilot' then 'pilot'
    when v_entitlement='active' then 'pro'
    else v_workspace.plan_key
  end;
  v_new_mode := case
    when v_entitlement='pilot' then 'pilot_free'
    when v_entitlement='active' then 'paid'
    else v_workspace.commercial_mode
  end;

  update public.organization_workspaces
  set entitlement_status=v_entitlement,
      entitlement_started_at=case when v_entitlement in ('pilot','active') then coalesce(entitlement_started_at,pg_catalog.now()) else entitlement_started_at end,
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

revoke all on function public.admin_set_workspace_entitlement(uuid,text,timestamptz,text)
from public, anon, authenticated;
grant execute on function public.admin_set_workspace_entitlement(uuid,text,timestamptz,text)
to authenticated;

-- ------------------------------------------------------------
-- BOOTSTRAP: verified identity does NOT automatically grant Workspace.
-- Organization + Public Institution create identity/membership, entitlement=none.
-- ------------------------------------------------------------

create or replace function public.organization_bootstrap_from_verified_profile()
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public, extensions
as $$
declare
  v_user_id uuid := auth.uid();
  v_profile public.user_profiles%rowtype;
  v_request public.verification_requests%rowtype;
  v_has_request boolean := false;
  v_org_id uuid;
  v_workspace_id uuid;
  v_slug_base text;
  v_slug text;
  v_legal_name text;
  v_public_name text;
  v_entity_type text;
  v_country_code text;
  v_city text;
  v_website_url text;
  v_source text;
begin
  if v_user_id is null or not public.is_current_auth_user_active() then
    raise exception using errcode='42501', message='Active authentication required.';
  end if;

  if exists (
    select 1 from public.organization_memberships
    where user_id=v_user_id and status='active'
  ) then
    return public.organization_get_mine();
  end if;

  select * into v_profile from public.user_profiles where id=v_user_id;

  if not found
    or v_profile.actor_type not in ('organization','institution')
    or v_profile.verified_at is null
    or (v_profile.actor_type='organization' and nullif(btrim(v_profile.organization_name),'') is null)
    or (v_profile.actor_type='institution' and nullif(btrim(v_profile.institution_name),'') is null)
  then
    raise exception using errcode='42501',
      message='A verified organization or public institution identity is required.';
  end if;

  if v_profile.actor_type='organization' then
    select vr.* into v_request
    from public.verification_requests vr
    where vr.user_id=v_user_id and vr.request_type='organization' and vr.status='approved'
    order by vr.reviewed_at desc nulls last,vr.created_at desc
    limit 1;
    v_has_request := found;

    v_legal_name := coalesce(
      nullif(btrim(case when v_has_request then v_request.organization_legal_name end),''),
      nullif(btrim(v_profile.organization_name),'')
    );
    v_public_name := coalesce(
      nullif(btrim(case when v_has_request then v_request.organization_public_name end),''),
      nullif(btrim(v_profile.organization_name),'')
    );
    v_entity_type := coalesce(
      nullif(btrim(case when v_has_request then v_request.organization_entity_type end),''),
      'other'
    );
    if v_entity_type not in ('association','nonprofit','company','cooperative','sports','public_body','committee','other') then
      v_entity_type := 'other';
    end if;
    v_country_code := coalesce(
      nullif(upper(btrim(case when v_has_request then v_request.organization_country_code end)),''),
      case when upper(coalesce(v_profile.country,'')) ~ '^[A-Z]{2}$' then upper(v_profile.country) else null end
    );
    v_city := coalesce(
      nullif(btrim(case when v_has_request then v_request.organization_city end),''),
      nullif(btrim(v_profile.city),'')
    );
    v_website_url := nullif(btrim(case when v_has_request then v_request.organization_website_url end),'');
    v_source := case when v_has_request then 'verification_request_v2' else 'legacy_verified_profile' end;
  else
    v_legal_name := nullif(btrim(v_profile.institution_name),'');
    v_public_name := v_legal_name;
    v_entity_type := 'public_body';
    v_country_code := case when upper(coalesce(v_profile.country,'')) ~ '^[A-Z]{2}$' then upper(v_profile.country) else null end;
    v_city := nullif(btrim(v_profile.city),'');
    v_website_url := null;
    v_source := 'verified_public_institution_profile';
  end if;

  v_slug_base := trim(both '-' from regexp_replace(lower(v_public_name),'[^a-z0-9]+','-','g'));
  if v_slug_base='' then v_slug_base:='organization'; end if;
  v_slug := v_slug_base || '-' || substr(replace(gen_random_uuid()::text,'-',''),1,7);

  insert into public.organization_entities(
    legal_name,public_name,slug,entity_type,country_code,city,website_url,
    verification_status,verification_source,verified_at,created_by
  ) values (
    v_legal_name,v_public_name,v_slug,v_entity_type,v_country_code,v_city,v_website_url,
    'verified',v_source,v_profile.verified_at,v_user_id
  ) returning id into v_org_id;

  insert into public.organization_memberships(
    organization_id,user_id,membership_role,status
  ) values(v_org_id,v_user_id,'owner','active');

  insert into public.organization_workspaces(
    organization_id,plan_key,status,commercial_mode,billing_enabled,
    entitlement_status
  ) values(
    v_org_id,'pilot','restricted','pilot_free',false,'none'
  ) returning id into v_workspace_id;

  insert into public.organization_session_audit(
    organization_id,actor_user_id,event_key,metadata
  ) values(
    v_org_id,v_user_id,'organization_bootstrapped',
    jsonb_build_object(
      'source',v_source,
      'actor_type',v_profile.actor_type,
      'entity_type',v_entity_type,
      'workspace_id',v_workspace_id,
      'entitlement_status','none'
    )
  );

  return public.organization_get_mine();
end;
$$;

revoke all on function public.organization_bootstrap_from_verified_profile() from public, anon;
grant execute on function public.organization_bootstrap_from_verified_profile() to authenticated;

commit;
