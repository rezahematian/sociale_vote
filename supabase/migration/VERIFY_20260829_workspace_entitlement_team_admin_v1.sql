-- VERIFY Social Vote Workspace Entitlement + Team + Admin V1
select
  exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='organization_workspaces'
      and column_name='entitlement_status'
  ) as entitlement_column,
  to_regprocedure('public.organization_team_list()') is not null as team_list_rpc,
  to_regprocedure('public.organization_team_add_existing_user(text,text)') is not null as team_add_rpc,
  to_regprocedure('public.organization_team_set_role(uuid,text)') is not null as team_role_rpc,
  to_regprocedure('public.organization_team_revoke(uuid)') is not null as team_revoke_rpc,
  to_regprocedure('public.admin_get_workspace_entitlement(uuid)') is not null as admin_get_rpc,
  to_regprocedure('public.admin_set_workspace_entitlement(uuid,text,timestamptz,text)') is not null as admin_set_rpc,
  not has_function_privilege('anon','public.admin_set_workspace_entitlement(uuid,text,timestamptz,text)','EXECUTE') as anon_cannot_admin_set,
  has_function_privilege('authenticated','public.admin_set_workspace_entitlement(uuid,text,timestamptz,text)','EXECUTE') as authenticated_rpc_gate_present,
  not exists (
    select 1 from public.organization_workspaces
    where entitlement_status not in ('none','pilot','active','suspended','expired')
  ) as lifecycle_values_valid;
