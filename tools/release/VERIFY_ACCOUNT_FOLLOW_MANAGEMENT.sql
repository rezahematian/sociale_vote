-- SOCIAL VOTE
-- Account follow management structural verification
-- Expected result: ACCOUNT FOLLOW MANAGEMENT PASS / all booleans true.

select
  'ACCOUNT FOLLOW MANAGEMENT PASS' as result,
  to_regclass('public.account_follows') is not null
    as account_follows_table,
  coalesce(
    (
      select c.relrowsecurity
      from pg_catalog.pg_class c
      join pg_catalog.pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public'
        and c.relname = 'account_follows'
    ),
    false
  ) as graph_rls_enabled,
  to_regprocedure(
    'public.list_my_account_connections(text,integer,integer)'
  ) is not null as connection_list_ready,
  coalesce(
    (
      select p.prosecdef
      from pg_catalog.pg_proc p
      join pg_catalog.pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public'
        and p.proname = 'list_my_account_connections'
        and pg_catalog.pg_get_function_identity_arguments(p.oid) =
          'p_direction text, p_limit integer, p_offset integer'
    ),
    false
  ) as security_definer,
  has_function_privilege(
    'authenticated',
    'public.list_my_account_connections(text,integer,integer)',
    'EXECUTE'
  ) as authenticated_execute,
  not has_function_privilege(
    'anon',
    'public.list_my_account_connections(text,integer,integer)',
    'EXECUTE'
  ) as anon_blocked;
