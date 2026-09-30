-- Social Vote presentation controls V2.
-- Adds header flicker tuning and independent Globe cloud coverage/motion.
-- Public read remains inherited from the existing singleton settings table.
-- Client writes remain forbidden; Admin changes are RPC-only and audited.

begin;

alter table public.social_vote_world_surface_settings
  add column if not exists header_flicker_intensity smallint not null default 100,
  add column if not exists header_flicker_speed smallint not null default 100,
  add column if not exists globe_cloud_density smallint not null default 42,
  add column if not exists globe_cloud_speed smallint not null default 22,
  add column if not exists globe_cloud_direction smallint not null default 1;

alter table public.social_vote_world_surface_settings
  drop constraint if exists social_vote_world_surface_settings_header_flicker_intensity_check,
  drop constraint if exists social_vote_world_surface_settings_header_flicker_speed_check,
  drop constraint if exists social_vote_world_surface_settings_globe_cloud_density_check,
  drop constraint if exists social_vote_world_surface_settings_globe_cloud_speed_check,
  drop constraint if exists social_vote_world_surface_settings_globe_cloud_direction_check;

alter table public.social_vote_world_surface_settings
  add constraint social_vote_world_surface_settings_header_flicker_intensity_check
    check (header_flicker_intensity between 20 and 100),
  add constraint social_vote_world_surface_settings_header_flicker_speed_check
    check (header_flicker_speed between 50 and 200),
  add constraint social_vote_world_surface_settings_globe_cloud_density_check
    check (globe_cloud_density between 0 and 100),
  add constraint social_vote_world_surface_settings_globe_cloud_speed_check
    check (globe_cloud_speed between 0 and 100),
  add constraint social_vote_world_surface_settings_globe_cloud_direction_check
    check (globe_cloud_direction in (-1, 1));

create or replace function public.admin_set_header_flicker_profile(
  p_intensity integer,
  p_speed integer,
  p_reason text default 'Admin Center Social Vote header flicker tuning'
)
returns table (
  header_flicker_intensity smallint,
  header_flicker_speed smallint,
  updated_at timestamptz
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := (select auth.uid());
  v_previous_intensity smallint;
  v_previous_speed smallint;
  v_updated_at timestamptz;
  v_reason text := nullif(btrim(coalesce(p_reason, '')), '');
begin
  if not (select public.is_current_auth_user_admin()) then
    raise exception using errcode = '42501', message = 'Admin access is required.';
  end if;

  if p_intensity is null or p_intensity < 20 or p_intensity > 100 then
    raise exception using errcode = '22023', message = 'Header flicker intensity must be between 20 and 100.';
  end if;

  if p_speed is null or p_speed < 50 or p_speed > 200 then
    raise exception using errcode = '22023', message = 'Header flicker speed must be between 50 and 200.';
  end if;

  if v_reason is null then
    v_reason := 'Admin Center Social Vote header flicker tuning';
  end if;

  select s.header_flicker_intensity, s.header_flicker_speed
  into v_previous_intensity, v_previous_speed
  from public.social_vote_world_surface_settings s
  where s.id = 'global'
  for update;

  if not found then
    raise exception using errcode = 'P0002', message = 'Global settings row is missing.';
  end if;

  if v_previous_intensity = p_intensity and v_previous_speed = p_speed then
    select s.updated_at into v_updated_at
    from public.social_vote_world_surface_settings s
    where s.id = 'global';

    insert into public.admin_audit_logs (
      actor_user_id, actor_role, action, target_type, target_id,
      previous_value, new_value, reason, result
    ) values (
      v_actor, 'admin', 'set_header_flicker_profile', 'runtime_policy', 'global',
      jsonb_build_object(
        'headerFlickerIntensity', v_previous_intensity,
        'headerFlickerSpeed', v_previous_speed
      ),
      jsonb_build_object(
        'headerFlickerIntensity', p_intensity,
        'headerFlickerSpeed', p_speed
      ),
      v_reason, 'noop'
    );

    return query select p_intensity::smallint, p_speed::smallint, v_updated_at;
    return;
  end if;

  update public.social_vote_world_surface_settings s
  set header_flicker_intensity = p_intensity,
      header_flicker_speed = p_speed,
      updated_at = now()
  where s.id = 'global'
  returning s.updated_at into v_updated_at;

  insert into public.admin_audit_logs (
    actor_user_id, actor_role, action, target_type, target_id,
    previous_value, new_value, reason, result
  ) values (
    v_actor, 'admin', 'set_header_flicker_profile', 'runtime_policy', 'global',
    jsonb_build_object(
      'headerFlickerIntensity', v_previous_intensity,
      'headerFlickerSpeed', v_previous_speed
    ),
    jsonb_build_object(
      'headerFlickerIntensity', p_intensity,
      'headerFlickerSpeed', p_speed
    ),
    v_reason, 'success'
  );

  return query select p_intensity::smallint, p_speed::smallint, v_updated_at;
end;
$$;

revoke all on function public.admin_set_header_flicker_profile(integer, integer, text)
from public, anon;
grant execute on function public.admin_set_header_flicker_profile(integer, integer, text)
to authenticated;

create or replace function public.admin_set_globe_cloud_profile(
  p_density integer,
  p_speed integer,
  p_direction integer,
  p_reason text default 'Admin Center Globe clouds motion control'
)
returns table (
  globe_cloud_density smallint,
  globe_cloud_speed smallint,
  globe_cloud_direction smallint,
  updated_at timestamptz
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := (select auth.uid());
  v_previous_density smallint;
  v_previous_speed smallint;
  v_previous_direction smallint;
  v_updated_at timestamptz;
  v_reason text := nullif(btrim(coalesce(p_reason, '')), '');
begin
  if not (select public.is_current_auth_user_admin()) then
    raise exception using errcode = '42501', message = 'Admin access is required.';
  end if;

  if p_density is null or p_density < 0 or p_density > 100 then
    raise exception using errcode = '22023', message = 'Globe cloud density must be between 0 and 100.';
  end if;

  if p_speed is null or p_speed < 0 or p_speed > 100 then
    raise exception using errcode = '22023', message = 'Globe cloud speed must be between 0 and 100.';
  end if;

  if p_direction is null or p_direction not in (-1, 1) then
    raise exception using errcode = '22023', message = 'Globe cloud direction must be -1 or 1.';
  end if;

  if v_reason is null then
    v_reason := 'Admin Center Globe clouds motion control';
  end if;

  select s.globe_cloud_density, s.globe_cloud_speed, s.globe_cloud_direction
  into v_previous_density, v_previous_speed, v_previous_direction
  from public.social_vote_world_surface_settings s
  where s.id = 'global'
  for update;

  if not found then
    raise exception using errcode = 'P0002', message = 'Global settings row is missing.';
  end if;

  if v_previous_density = p_density
     and v_previous_speed = p_speed
     and v_previous_direction = p_direction then
    select s.updated_at into v_updated_at
    from public.social_vote_world_surface_settings s
    where s.id = 'global';

    insert into public.admin_audit_logs (
      actor_user_id, actor_role, action, target_type, target_id,
      previous_value, new_value, reason, result
    ) values (
      v_actor, 'admin', 'set_globe_cloud_profile', 'runtime_policy', 'global',
      jsonb_build_object(
        'globeCloudDensity', v_previous_density,
        'globeCloudSpeed', v_previous_speed,
        'globeCloudDirection', v_previous_direction
      ),
      jsonb_build_object(
        'globeCloudDensity', p_density,
        'globeCloudSpeed', p_speed,
        'globeCloudDirection', p_direction
      ),
      v_reason, 'noop'
    );

    return query select p_density::smallint, p_speed::smallint,
      p_direction::smallint, v_updated_at;
    return;
  end if;

  update public.social_vote_world_surface_settings s
  set globe_cloud_density = p_density,
      globe_cloud_speed = p_speed,
      globe_cloud_direction = p_direction,
      updated_at = now()
  where s.id = 'global'
  returning s.updated_at into v_updated_at;

  insert into public.admin_audit_logs (
    actor_user_id, actor_role, action, target_type, target_id,
    previous_value, new_value, reason, result
  ) values (
    v_actor, 'admin', 'set_globe_cloud_profile', 'runtime_policy', 'global',
    jsonb_build_object(
      'globeCloudDensity', v_previous_density,
      'globeCloudSpeed', v_previous_speed,
      'globeCloudDirection', v_previous_direction
    ),
    jsonb_build_object(
      'globeCloudDensity', p_density,
      'globeCloudSpeed', p_speed,
      'globeCloudDirection', p_direction
    ),
    v_reason, 'success'
  );

  return query select p_density::smallint, p_speed::smallint,
    p_direction::smallint, v_updated_at;
end;
$$;

revoke all on function public.admin_set_globe_cloud_profile(integer, integer, integer, text)
from public, anon;
grant execute on function public.admin_set_globe_cloud_profile(integer, integer, integer, text)
to authenticated;

commit;
