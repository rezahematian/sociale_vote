-- Social Vote World marker density: backend-authoritative visual policy.
-- 0 = no Home Globe markers; 100 = maximum safe Home visual budget.
-- This setting never changes geographic coordinates, content ranking, RLS or GeoScope.

begin;

create table if not exists public.social_vote_world_surface_settings (
  id text primary key,
  marker_density smallint not null default 30,
  updated_at timestamptz not null default now(),
  constraint social_vote_world_surface_settings_singleton_check
    check (id = 'global'),
  constraint social_vote_world_surface_settings_marker_density_check
    check (marker_density between 0 and 100)
);

comment on table public.social_vote_world_surface_settings is
  'Public read-only World presentation policy. Client writes are forbidden; admin changes use audited RPC.';

insert into public.social_vote_world_surface_settings (
  id,
  marker_density
)
values ('global', 30)
on conflict (id) do nothing;

alter table public.social_vote_world_surface_settings enable row level security;
alter table public.social_vote_world_surface_settings force row level security;

revoke all on table public.social_vote_world_surface_settings from public;
grant select on table public.social_vote_world_surface_settings to anon, authenticated;

-- The setting is intentionally public because every client needs the same Home
-- Globe presentation policy. No account/private data is stored in this table.
drop policy if exists social_vote_world_surface_settings_public_read
on public.social_vote_world_surface_settings;

create policy social_vote_world_surface_settings_public_read
on public.social_vote_world_surface_settings
for select
to anon, authenticated
using (id = 'global');

create or replace function public.admin_set_world_marker_density(
  p_density integer,
  p_reason text default 'Admin Center World marker density control'
)
returns table (
  marker_density integer,
  updated_at timestamptz
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := (select auth.uid());
  v_previous integer;
  v_updated_at timestamptz;
  v_reason text := nullif(btrim(coalesce(p_reason, '')), '');
begin
  if not (select public.is_current_auth_user_admin()) then
    raise exception
      using errcode = '42501', message = 'Admin access is required.';
  end if;

  if p_density is null or p_density < 0 or p_density > 100 then
    raise exception
      using errcode = '22023', message = 'Marker density must be between 0 and 100.';
  end if;

  if v_reason is null then
    v_reason := 'Admin Center World marker density control';
  end if;

  select s.marker_density
  into v_previous
  from public.social_vote_world_surface_settings s
  where s.id = 'global'
  for update;

  if v_previous is null then
    raise exception
      using errcode = 'P0002', message = 'World surface settings row is missing.';
  end if;

  if v_previous = p_density then
    select s.updated_at
    into v_updated_at
    from public.social_vote_world_surface_settings s
    where s.id = 'global';

    insert into public.admin_audit_logs (
      actor_user_id,
      actor_role,
      action,
      target_type,
      target_id,
      previous_value,
      new_value,
      reason,
      result
    )
    values (
      v_actor,
      'admin',
      'set_world_marker_density',
      'world_surface',
      'global',
      jsonb_build_object('markerDensity', v_previous),
      jsonb_build_object('markerDensity', p_density),
      v_reason,
      'noop'
    );

    return query select p_density, v_updated_at;
    return;
  end if;

  update public.social_vote_world_surface_settings s
  set marker_density = p_density,
      updated_at = now()
  where s.id = 'global'
  returning s.updated_at into v_updated_at;

  insert into public.admin_audit_logs (
    actor_user_id,
    actor_role,
    action,
    target_type,
    target_id,
    previous_value,
    new_value,
    reason,
    result
  )
  values (
    v_actor,
    'admin',
    'set_world_marker_density',
    'world_surface',
    'global',
    jsonb_build_object('markerDensity', v_previous),
    jsonb_build_object('markerDensity', p_density),
    v_reason,
    'success'
  );

  return query select p_density, v_updated_at;
end;
$$;

revoke all on function public.admin_set_world_marker_density(integer, text)
from public, anon;
grant execute on function public.admin_set_world_marker_density(integer, text)
to authenticated;

commit;
