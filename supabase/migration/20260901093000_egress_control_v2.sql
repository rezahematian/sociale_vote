-- Social Vote automatic egress control V2.
-- This migration adds one small public runtime policy to the existing global
-- settings row. Client writes remain forbidden; Admin changes use an audited
-- SECURITY DEFINER RPC. No service_role credential is exposed to Flutter.

begin;

alter table public.social_vote_world_surface_settings
  add column if not exists egress_mode text not null default 'conservative';

alter table public.social_vote_world_surface_settings
  alter column egress_mode set default 'conservative';

alter table public.social_vote_world_surface_settings
  alter column egress_mode set not null;

alter table public.social_vote_world_surface_settings
  drop constraint if exists social_vote_world_surface_settings_egress_mode_check;

alter table public.social_vote_world_surface_settings
  add constraint social_vote_world_surface_settings_egress_mode_check
  check (egress_mode in ('normal', 'conservative', 'emergency'));

comment on column public.social_vote_world_surface_settings.egress_mode is
  'Public automatic-read policy: normal, conservative or emergency. It never bypasses RLS or backend enforcement.';

create or replace function public.admin_set_egress_mode(
  p_mode text,
  p_reason text default 'Admin Center automatic egress control'
)
returns table (
  egress_mode text,
  updated_at timestamptz
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := (select auth.uid());
  v_mode text := lower(btrim(coalesce(p_mode, '')));
  v_previous text;
  v_updated_at timestamptz;
  v_reason text := nullif(btrim(coalesce(p_reason, '')), '');
begin
  if not (select public.is_current_auth_user_admin()) then
    raise exception
      using errcode = '42501', message = 'Admin access is required.';
  end if;

  if v_mode not in ('normal', 'conservative', 'emergency') then
    raise exception
      using errcode = '22023',
            message = 'Egress mode must be normal, conservative or emergency.';
  end if;

  if v_reason is null then
    v_reason := 'Admin Center automatic egress control';
  end if;

  select s.egress_mode
  into v_previous
  from public.social_vote_world_surface_settings s
  where s.id = 'global'
  for update;

  if v_previous is null then
    raise exception
      using errcode = 'P0002', message = 'Global settings row is missing.';
  end if;

  if v_previous = v_mode then
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
      'set_egress_mode',
      'runtime_policy',
      'global',
      jsonb_build_object('egressMode', v_previous),
      jsonb_build_object('egressMode', v_mode),
      v_reason,
      'noop'
    );

    return query select v_mode, v_updated_at;
    return;
  end if;

  update public.social_vote_world_surface_settings s
  set egress_mode = v_mode,
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
    'set_egress_mode',
    'runtime_policy',
    'global',
    jsonb_build_object('egressMode', v_previous),
    jsonb_build_object('egressMode', v_mode),
    v_reason,
    'success'
  );

  return query select v_mode, v_updated_at;
end;
$$;

revoke all on function public.admin_set_egress_mode(text, text)
from public, anon;
grant execute on function public.admin_set_egress_mode(text, text)
to authenticated;

commit;
