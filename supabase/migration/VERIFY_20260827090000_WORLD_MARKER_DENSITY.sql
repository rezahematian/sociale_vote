-- Read-only verification for World marker density admin control.
select
  to_regclass('public.social_vote_world_surface_settings') is not null as settings_table,
  exists (
    select 1
    from pg_class c
    where c.oid = 'public.social_vote_world_surface_settings'::regclass
      and c.relrowsecurity
  ) as rls_enabled,
  exists (
    select 1
    from pg_class c
    where c.oid = 'public.social_vote_world_surface_settings'::regclass
      and c.relforcerowsecurity
  ) as rls_forced,
  exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'social_vote_world_surface_settings'
      and policyname = 'social_vote_world_surface_settings_public_read'
      and cmd = 'SELECT'
  ) as public_read_policy,
  not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'social_vote_world_surface_settings'
      and cmd in ('INSERT', 'UPDATE', 'DELETE', 'ALL')
  ) as no_client_write_policy,
  has_table_privilege('anon', 'public.social_vote_world_surface_settings', 'SELECT')
    as anon_can_read,
  has_table_privilege('authenticated', 'public.social_vote_world_surface_settings', 'SELECT')
    as authenticated_can_read,
  not has_table_privilege('anon', 'public.social_vote_world_surface_settings', 'INSERT,UPDATE,DELETE')
    as anon_cannot_write,
  not has_table_privilege('authenticated', 'public.social_vote_world_surface_settings', 'INSERT,UPDATE,DELETE')
    as authenticated_cannot_write,
  to_regprocedure('public.admin_set_world_marker_density(integer,text)') is not null
    as admin_rpc,
  coalesce((
    select p.prosecdef
    from pg_proc p
    where p.oid = to_regprocedure('public.admin_set_world_marker_density(integer,text)')
  ), false) as admin_rpc_security_definer,
  has_function_privilege(
    'authenticated',
    'public.admin_set_world_marker_density(integer,text)',
    'EXECUTE'
  ) as authenticated_can_call_rpc,
  not has_function_privilege(
    'anon',
    'public.admin_set_world_marker_density(integer,text)',
    'EXECUTE'
  ) as anon_cannot_call_rpc,
  exists (
    select 1
    from public.social_vote_world_surface_settings
    where id = 'global'
      and marker_density between 0 and 100
  ) as global_row_valid;

select id, marker_density, updated_at
from public.social_vote_world_surface_settings
where id = 'global';
