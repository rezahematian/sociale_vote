-- Social Vote Globe Clouds V1 global presentation control.
-- Public read; client writes forbidden; admin changes via audited RPC.

begin;

alter table public.social_vote_world_surface_settings
  add column if not exists globe_clouds_enabled boolean
  not null default false;

alter table public.social_vote_world_surface_settings
  alter column globe_clouds_enabled set default false;

alter table public.social_vote_world_surface_settings
  alter column globe_clouds_enabled set not null;

create or replace function public.admin_set_globe_clouds_enabled(
  p_enabled boolean,
  p_reason text default 'Admin Center Globe clouds control'
)
returns table (
  globe_clouds_enabled boolean,
  updated_at timestamptz
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := (select auth.uid());
  v_previous boolean;
  v_updated_at timestamptz;
  v_reason text := nullif(btrim(coalesce(p_reason, '')), '');
begin
  if not (select public.is_current_auth_user_admin()) then
    raise exception
      using errcode = '42501',
            message = 'Admin access is required.';
  end if;

  if p_enabled is null then
    raise exception
      using errcode = '22023',
            message = 'Globe clouds enabled must be true or false.';
  end if;

  if v_reason is null then
    v_reason := 'Admin Center Globe clouds control';
  end if;

  select s.globe_clouds_enabled
  into v_previous
  from public.social_vote_world_surface_settings s
  where s.id = 'global'
  for update;

  if v_previous is null then
    raise exception
      using errcode = 'P0002',
            message = 'Global settings row is missing.';
  end if;

  if v_previous = p_enabled then
    select s.updated_at
    into v_updated_at
    from public.social_vote_world_surface_settings s
    where s.id = 'global';

    insert into public.admin_audit_logs (
      actor_user_id, actor_role, action, target_type, target_id,
      previous_value, new_value, reason, result
    )
    values (
      v_actor, 'admin', 'set_globe_clouds_enabled', 'runtime_policy', 'global',
      jsonb_build_object('globeCloudsEnabled', v_previous),
      jsonb_build_object('globeCloudsEnabled', p_enabled),
      v_reason, 'noop'
    );

    return query select p_enabled, v_updated_at;
    return;
  end if;

  update public.social_vote_world_surface_settings s
  set globe_clouds_enabled = p_enabled,
      updated_at = now()
  where s.id = 'global'
  returning s.updated_at into v_updated_at;

  insert into public.admin_audit_logs (
    actor_user_id, actor_role, action, target_type, target_id,
    previous_value, new_value, reason, result
  )
  values (
    v_actor, 'admin', 'set_globe_clouds_enabled', 'runtime_policy', 'global',
    jsonb_build_object('globeCloudsEnabled', v_previous),
    jsonb_build_object('globeCloudsEnabled', p_enabled),
    v_reason, 'success'
  );

  return query select p_enabled, v_updated_at;
end;
$$;

revoke all on function
  public.admin_set_globe_clouds_enabled(boolean, text)
from public, anon;

grant execute on function
  public.admin_set_globe_clouds_enabled(boolean, text)
to authenticated;

commit;
