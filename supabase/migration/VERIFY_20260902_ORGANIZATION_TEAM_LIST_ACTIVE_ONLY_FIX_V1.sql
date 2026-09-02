-- VERIFY Social Vote — Team List Active Only Fix V1
select
  to_regprocedure('public.organization_team_list()') is not null
    as team_list_rpc_present,

  coalesce((
    select p.prosecdef
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname='public'
      and p.proname='organization_team_list'
      and pg_get_function_identity_arguments(p.oid)=''
    limit 1
  ), false) as security_definer,

  coalesce((
    select array_to_string(p.proconfig, ',') like '%search_path=pg_catalog, public, auth%'
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname='public'
      and p.proname='organization_team_list'
      and pg_get_function_identity_arguments(p.oid)=''
    limit 1
  ), false) as locked_search_path,

  has_function_privilege(
    'authenticated',
    'public.organization_team_list()',
    'EXECUTE'
  ) as authenticated_can_execute,

  not has_function_privilege(
    'anon',
    'public.organization_team_list()',
    'EXECUTE'
  ) as anon_cannot_execute,

  coalesce((
    select
      pg_get_functiondef(p.oid) like '%and om.status = ''active''%'
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname='public'
      and p.proname='organization_team_list'
      and pg_get_function_identity_arguments(p.oid)=''
    limit 1
  ), false) as active_only_filter_present;
