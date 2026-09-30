do $$
declare
  v_failures text[] := array[]::text[];
  v_header_intensity integer;
  v_header_speed integer;
  v_cloud_density integer;
  v_cloud_speed integer;
  v_cloud_direction integer;
begin
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'social_vote_world_surface_settings'
      and column_name = 'header_flicker_intensity'
      and is_nullable = 'NO'
  ) then
    v_failures := array_append(v_failures, 'header_flicker_intensity missing/nullable');
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'social_vote_world_surface_settings'
      and column_name = 'header_flicker_speed'
      and is_nullable = 'NO'
  ) then
    v_failures := array_append(v_failures, 'header_flicker_speed missing/nullable');
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'social_vote_world_surface_settings'
      and column_name = 'globe_cloud_density'
      and is_nullable = 'NO'
  ) then
    v_failures := array_append(v_failures, 'globe_cloud_density missing/nullable');
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'social_vote_world_surface_settings'
      and column_name = 'globe_cloud_speed'
      and is_nullable = 'NO'
  ) then
    v_failures := array_append(v_failures, 'globe_cloud_speed missing/nullable');
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'social_vote_world_surface_settings'
      and column_name = 'globe_cloud_direction'
      and is_nullable = 'NO'
  ) then
    v_failures := array_append(v_failures, 'globe_cloud_direction missing/nullable');
  end if;

  select
    s.header_flicker_intensity,
    s.header_flicker_speed,
    s.globe_cloud_density,
    s.globe_cloud_speed,
    s.globe_cloud_direction
  into
    v_header_intensity,
    v_header_speed,
    v_cloud_density,
    v_cloud_speed,
    v_cloud_direction
  from public.social_vote_world_surface_settings s
  where s.id = 'global';

  if v_header_intensity not between 20 and 100 then
    v_failures := array_append(v_failures, 'header_flicker_intensity invalid');
  end if;
  if v_header_speed not between 50 and 200 then
    v_failures := array_append(v_failures, 'header_flicker_speed invalid');
  end if;
  if v_cloud_density not between 0 and 100 then
    v_failures := array_append(v_failures, 'globe_cloud_density invalid');
  end if;
  if v_cloud_speed not between 0 and 100 then
    v_failures := array_append(v_failures, 'globe_cloud_speed invalid');
  end if;
  if v_cloud_direction not in (-1, 1) then
    v_failures := array_append(v_failures, 'globe_cloud_direction invalid');
  end if;

  if to_regprocedure('public.admin_set_header_flicker_profile(integer,integer,text)') is null then
    v_failures := array_append(v_failures, 'header flicker profile RPC missing');
  end if;
  if to_regprocedure('public.admin_set_globe_cloud_profile(integer,integer,integer,text)') is null then
    v_failures := array_append(v_failures, 'globe cloud profile RPC missing');
  end if;

  if has_function_privilege(
    'anon',
    'public.admin_set_header_flicker_profile(integer,integer,text)',
    'EXECUTE'
  ) then
    v_failures := array_append(v_failures, 'anon can execute header profile RPC');
  end if;

  if has_function_privilege(
    'anon',
    'public.admin_set_globe_cloud_profile(integer,integer,integer,text)',
    'EXECUTE'
  ) then
    v_failures := array_append(v_failures, 'anon can execute cloud profile RPC');
  end if;

  if has_table_privilege('authenticated', 'public.social_vote_world_surface_settings', 'UPDATE')
     or has_table_privilege('anon', 'public.social_vote_world_surface_settings', 'UPDATE') then
    v_failures := array_append(v_failures, 'client role can update settings table');
  end if;

  if coalesce(array_length(v_failures, 1), 0) > 0 then
    raise exception 'PRESENTATION MOTION CONTROLS V2 VERIFY FAIL: %',
      array_to_string(v_failures, '; ');
  end if;

  raise notice
    'PRESENTATION MOTION CONTROLS V2 VERIFY PASS: header=%/% cloud=%/%/%',
    v_header_intensity, v_header_speed,
    v_cloud_density, v_cloud_speed, v_cloud_direction;
end;
$$;
