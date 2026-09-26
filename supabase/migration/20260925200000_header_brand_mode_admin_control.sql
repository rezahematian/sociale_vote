-- Social Vote global header brand mode.
-- Public read; client writes forbidden; admin changes via audited RPC.

begin;

alter table public.social_vote_world_surface_settings
  add column if not exists header_brand_mode text
  not null default 'normal';

alter table public.social_vote_world_surface_settings
  alter column header_brand_mode set default 'normal';

alter table public.social_vote_world_surface_settings
  alter column header_brand_mode set not null;

alter table public.social_vote_world_surface_settings
  drop constraint if exists
  social_vote_world_surface_settings_header_brand_mode_check;

alter table public.social_vote_world_surface_settings
  add constraint
  social_vote_world_surface_settings_header_brand_mode_check
  check (header_brand_mode in ('normal', 'flicker'));

create or replace function public.admin_set_header_brand_mode(
  p_mode text,
  p_reason text default
    'Admin Center Social Vote header brand mode control'
)
returns table (
  header_brand_mode text,
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
      using errcode = '42501',
            message = 'Admin access is required.';
  end if;

  if v_mode not in ('normal', 'flicker') then
    raise exception
      using errcode = '22023',
            message = 'Header brand mode must be normal or flicker.';
  end if;

  if v_reason is null then
    v_reason :=
      'Admin Center Social Vote header brand mode control';
  end if;

  select s.header_brand_mode
  into v_previous
  from public.social_vote_world_surface_settings s
  where s.id = 'global'
  for update;

  if v_previous is null then
    raise exception
      using errcode = 'P0002',
            message = 'Global settings row is missing.';
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
      'set_header_brand_mode',
      'runtime_policy',
      'global',
      jsonb_build_object(
        'headerBrandMode', v_previous
      ),
      jsonb_build_object(
        'headerBrandMode', v_mode
      ),
      v_reason,
      'noop'
    );

    return query select v_mode, v_updated_at;
    return;
  end if;

  update public.social_vote_world_surface_settings s
  set header_brand_mode = v_mode,
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
    'set_header_brand_mode',
    'runtime_policy',
    'global',
    jsonb_build_object(
      'headerBrandMode', v_previous
    ),
    jsonb_build_object(
      'headerBrandMode', v_mode
    ),
    v_reason,
    'success'
  );

  return query select v_mode, v_updated_at;
end;
$$;

revoke all on function
  public.admin_set_header_brand_mode(text, text)
from public, anon;

grant execute on function
  public.admin_set_header_brand_mode(text, text)
to authenticated;

commit;
