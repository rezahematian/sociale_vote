select
  to_regclass('public.admin_finance_entries') is not null
    as finance_table,
  to_regclass('public.radio_mondo_tracks') is not null
    as radio_table,
  coalesce((
    select c.relrowsecurity and c.relforcerowsecurity
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public' and c.relname = 'admin_finance_entries'
  ), false) as finance_rls_forced,
  coalesce((
    select c.relrowsecurity and c.relforcerowsecurity
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public' and c.relname = 'radio_mondo_tracks'
  ), false) as radio_rls_forced,
  to_regprocedure('public.admin_finance_snapshot()') is not null
    as finance_snapshot_rpc,
  to_regprocedure('public.admin_finance_add_entry(date,text,bigint,text,text,text,text)') is not null
    as finance_add_rpc,
  to_regprocedure('public.admin_finance_void_entry(uuid,text)') is not null
    as finance_void_rpc,
  to_regprocedure('public.radio_mondo_public_catalog()') is not null
    as radio_public_rpc,
  to_regprocedure('public.admin_radio_mondo_list()') is not null
    as radio_admin_list_rpc,
  to_regprocedure('public.admin_radio_mondo_upsert(uuid,text,text,integer,boolean,text,text,boolean,text)') is not null
    as radio_admin_upsert_rpc,
  to_regprocedure('public.admin_radio_mondo_set_enabled(uuid,boolean,text)') is not null
    as radio_admin_enabled_rpc,
  not has_table_privilege('anon', 'public.admin_finance_entries', 'SELECT')
    and not has_table_privilege('authenticated', 'public.admin_finance_entries', 'INSERT')
    as finance_direct_access_blocked,
  not has_table_privilege('anon', 'public.radio_mondo_tracks', 'SELECT')
    and not has_table_privilege('authenticated', 'public.radio_mondo_tracks', 'INSERT')
    as radio_direct_access_blocked,
  not has_function_privilege('anon', 'public.admin_finance_snapshot()', 'EXECUTE')
    and not has_function_privilege('anon', 'public.admin_radio_mondo_list()', 'EXECUTE')
    as anon_cannot_admin_manage,
  has_function_privilege('anon', 'public.radio_mondo_public_catalog()', 'EXECUTE')
    and has_function_privilege('authenticated', 'public.radio_mondo_public_catalog()', 'EXECUTE')
    as radio_public_catalog_available,
  coalesce((
    select bool_and(p.prosrc ilike '%is_current_auth_user_admin%')
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname in (
        'admin_finance_snapshot',
        'admin_finance_add_entry',
        'admin_finance_void_entry',
        'admin_radio_mondo_list',
        'admin_radio_mondo_upsert',
        'admin_radio_mondo_set_enabled'
      )
  ), false) as admin_gate_present;
