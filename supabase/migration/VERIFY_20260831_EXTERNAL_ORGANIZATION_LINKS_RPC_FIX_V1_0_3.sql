with fn as (
  select
    p.oid,
    p.prosecdef,
    p.provolatile,
    p.proconfig,
    p.prosrc,
    pg_get_functiondef(p.oid) as definition
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public'
    and p.oid = to_regprocedure(
      'public.organization_external_links_replace(jsonb)'
    )
)
select
  exists (select 1 from fn) as replace_rpc_present,
  coalesce((
    select f.definition ilike '%#variable_conflict use_column%'
    from fn f
  ), false) as ambiguity_directive_present,
  coalesce((select f.prosecdef from fn f), false)
    as security_definer,
  coalesce((select f.provolatile = 'v' from fn f), false)
    as volatile,
  coalesce((
    select position('set search_path' in lower(f.definition)) > 0
    from fn f
  ), false) as locked_search_path,
  not has_function_privilege(
    'anon',
    'public.organization_external_links_replace(jsonb)',
    'EXECUTE'
  )
    and has_function_privilege(
      'authenticated',
      'public.organization_external_links_replace(jsonb)',
      'EXECUTE'
    ) as grants_valid,
  coalesce((
    select f.prosrc ilike '%v_role not in (''owner'', ''manager'')%'
      and f.prosrc ilike '%is_current_auth_user_active%'
    from fn f
  ), false) as manager_gate_present,
  coalesce((
    select f.prosrc ilike '%on conflict (organization_id, provider)%'
    from fn f
  ), false) as conflict_target_present,
  to_regclass('public.external_account_links') is not null
    as links_table_present,
  coalesce((
    select count(*) = 1
    from pg_indexes i
    where i.schemaname = 'public'
      and i.indexname = 'external_account_links_organization_provider_uidx'
  ), false) as organization_provider_index_present;
