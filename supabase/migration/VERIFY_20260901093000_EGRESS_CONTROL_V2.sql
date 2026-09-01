-- Run only after 20260901093000_egress_control_v2.sql.
-- Read-only verification: it never changes the configured egress mode.

do $$
declare
  v_failures text[] := array[]::text[];
  v_mode text;
begin
  if to_regclass('public.social_vote_world_surface_settings') is null then
    v_failures := array_append(v_failures, 'settings table missing');
  end if;

  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'social_vote_world_surface_settings'
      and column_name = 'egress_mode'
      and is_nullable = 'NO'
  ) then
    v_failures := array_append(v_failures, 'egress_mode column missing/nullable');
  end if;

  select s.egress_mode
  into v_mode
  from public.social_vote_world_surface_settings s
  where s.id = 'global';

  if v_mode is null or v_mode not in ('normal', 'conservative', 'emergency') then
    v_failures := array_append(v_failures, 'global egress_mode invalid');
  end if;

  if to_regprocedure('public.admin_set_egress_mode(text,text)') is null then
    v_failures := array_append(v_failures, 'admin_set_egress_mode RPC missing');
  end if;

  if not exists (
    select 1
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname = 'admin_set_egress_mode'
      and p.prosecdef
  ) then
    v_failures := array_append(v_failures, 'RPC is not SECURITY DEFINER');
  end if;

  if not has_function_privilege(
    'authenticated',
    'public.admin_set_egress_mode(text,text)',
    'EXECUTE'
  ) then
    v_failures := array_append(v_failures, 'authenticated RPC execute missing');
  end if;

  if has_function_privilege(
    'anon',
    'public.admin_set_egress_mode(text,text)',
    'EXECUTE'
  ) then
    v_failures := array_append(v_failures, 'anon can execute admin RPC');
  end if;

  if has_table_privilege(
    'authenticated',
    'public.social_vote_world_surface_settings',
    'UPDATE'
  ) or has_table_privilege(
    'anon',
    'public.social_vote_world_surface_settings',
    'UPDATE'
  ) then
    v_failures := array_append(v_failures, 'client role can update settings table');
  end if;

  if coalesce(array_length(v_failures, 1), 0) > 0 then
    raise exception 'EGRESS CONTROL V2 VERIFY FAIL: %', array_to_string(v_failures, '; ');
  end if;

  raise notice 'EGRESS CONTROL V2 VERIFY PASS: mode=%', v_mode;
end;
$$;
