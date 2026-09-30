do $$
declare
  v_failures text[] := array[]::text[];
  v_enabled boolean;
begin
  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'social_vote_world_surface_settings'
      and column_name = 'globe_clouds_enabled'
      and is_nullable = 'NO'
  ) then
    v_failures := array_append(
      v_failures,
      'globe_clouds_enabled column missing/nullable'
    );
  end if;

  select s.globe_clouds_enabled
  into v_enabled
  from public.social_vote_world_surface_settings s
  where s.id = 'global';

  if v_enabled is null then
    v_failures := array_append(
      v_failures,
      'global globe_clouds_enabled is null'
    );
  end if;

  if to_regprocedure(
    'public.admin_set_globe_clouds_enabled(boolean,text)'
  ) is null then
    v_failures := array_append(
      v_failures,
      'admin_set_globe_clouds_enabled RPC missing'
    );
  end if;

  if has_function_privilege(
    'anon',
    'public.admin_set_globe_clouds_enabled(boolean,text)',
    'EXECUTE'
  ) then
    v_failures := array_append(
      v_failures,
      'anon can execute Globe clouds admin RPC'
    );
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
    v_failures := array_append(
      v_failures,
      'client role can update settings table'
    );
  end if;

  if coalesce(array_length(v_failures, 1), 0) > 0 then
    raise exception
      'GLOBE CLOUDS V1 VERIFY FAIL: %',
      array_to_string(v_failures, '; ');
  end if;

  raise notice
    'GLOBE CLOUDS V1 VERIFY PASS: enabled=%',
    v_enabled;
end;
$$;
