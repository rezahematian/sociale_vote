do $$
declare
  v_failures text[] := array[]::text[];
  v_mode text;
begin
  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'social_vote_world_surface_settings'
      and column_name = 'header_brand_mode'
      and is_nullable = 'NO'
  ) then
    v_failures := array_append(
      v_failures,
      'header_brand_mode column missing/nullable'
    );
  end if;

  select s.header_brand_mode
  into v_mode
  from public.social_vote_world_surface_settings s
  where s.id = 'global';

  if v_mode is null or v_mode not in ('normal', 'flicker') then
    v_failures := array_append(
      v_failures,
      'global header_brand_mode invalid'
    );
  end if;

  if to_regprocedure(
    'public.admin_set_header_brand_mode(text,text)'
  ) is null then
    v_failures := array_append(
      v_failures,
      'admin_set_header_brand_mode RPC missing'
    );
  end if;

  if has_function_privilege(
    'anon',
    'public.admin_set_header_brand_mode(text,text)',
    'EXECUTE'
  ) then
    v_failures := array_append(
      v_failures,
      'anon can execute admin RPC'
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
      'HEADER BRAND MODE VERIFY FAIL: %',
      array_to_string(v_failures, '; ');
  end if;

  raise notice
    'HEADER BRAND MODE VERIFY PASS: mode=%',
    v_mode;
end;
$$;
