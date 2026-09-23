-- SOCIAL VOTE — RADIO MONDO ADMIN DELETE V1
-- Local/additive admin deletion with audit. Default station is protected.

begin;

do $$
begin
  if to_regclass('public.radio_mondo_tracks') is null then
    raise exception 'radio_mondo_tracks is missing.';
  end if;
  if to_regclass('public.admin_audit_logs') is null then
    raise exception 'admin_audit_logs is missing.';
  end if;
end;
$$;

create or replace function public.admin_radio_mondo_delete_v1(
  p_track_id uuid,
  p_reason text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := (select auth.uid());
  v_reason text := btrim(coalesce(p_reason, ''));
  v_track public.radio_mondo_tracks%rowtype;
begin
  if v_actor is null or not (select public.is_current_auth_user_admin()) then
    raise exception using errcode = '42501', message = 'Admin required.';
  end if;

  if p_track_id is null then
    raise exception using errcode = '22023', message = 'Track is required.';
  end if;

  if char_length(v_reason) not between 1 and 1000 then
    raise exception using errcode = '22023', message = 'Audit reason is required.';
  end if;

  select * into v_track
  from public.radio_mondo_tracks t
  where t.id = p_track_id
  for update;

  if not found then
    raise exception using errcode = 'P0002', message = 'Radio track not found.';
  end if;

  if v_track.is_default then
    raise exception using errcode = '22023',
      message = 'Default Radio Mondo station cannot be deleted. Set another default station first.';
  end if;

  delete from public.radio_mondo_tracks t
  where t.id = p_track_id;

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
  ) values (
    v_actor,
    'admin',
    'radio_item_delete_v1',
    'radio_track',
    v_track.id::text,
    jsonb_build_object(
      'title', v_track.title,
      'audio_url', v_track.audio_url,
      'sort_order', v_track.sort_order,
      'is_enabled', v_track.is_enabled,
      'attribution', v_track.attribution,
      'license_url', v_track.license_url,
      'source_type', v_track.source_type,
      'channel_type', v_track.channel_type,
      'language_code', v_track.language_code,
      'world_brief_id', v_track.world_brief_id,
      'is_default', v_track.is_default,
      'is_live', v_track.is_live
    ),
    '{}'::jsonb,
    v_reason,
    'success'
  );

  return jsonb_build_object(
    'id', v_track.id,
    'title', v_track.title,
    'audio_url', v_track.audio_url,
    'deleted', true
  );
end;
$$;

revoke all on function public.admin_radio_mondo_delete_v1(uuid, text)
from public, anon, authenticated;

grant execute on function public.admin_radio_mondo_delete_v1(uuid, text)
to authenticated;

commit;
