-- SOCIAL VOTE — RADIO MONDO CATEGORIES / PLAYLISTS V1
-- Additive category layer for coherent per-category playback.
-- Preserves channel_type, World Brief links, default station, rights checks and audit.

begin;

do $$
begin
  if to_regclass('public.radio_mondo_tracks') is null then
    raise exception 'radio_mondo_tracks is missing.';
  end if;
end;
$$;

alter table public.radio_mondo_tracks
  add column if not exists category_key text not null default 'world_music';

alter table public.radio_mondo_tracks
  drop constraint if exists radio_mondo_tracks_category_key_check;
alter table public.radio_mondo_tracks
  add constraint radio_mondo_tracks_category_key_check
  check (category_key in (
    'reggae',
    'classical',
    'house',
    'jazz_soul',
    'world_music',
    'sounds_atmospheres'
  ));

-- Safe backfill for the CURRENT catalog. Existing World Live content starts in
-- World music; Nature/Special items (including the current nature/space audio)
-- start in Sounds & Atmospheres. Admin can reassign any item afterwards.
update public.radio_mondo_tracks
set category_key = case
  when channel_type in ('nature', 'special') then 'sounds_atmospheres'
  else 'world_music'
end;

comment on column public.radio_mondo_tracks.category_key is
  'Listener music category: reggae, classical, house, jazz_soul, world_music, sounds_atmospheres.';

create index if not exists radio_mondo_tracks_category_sort_idx
on public.radio_mondo_tracks(category_key, sort_order, created_at)
where is_enabled = true;

create or replace function public.radio_mondo_public_catalog()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id', t.id,
        'title', t.title,
        'audio_url', t.audio_url,
        'sort_order', t.sort_order,
        'attribution', t.attribution,
        'license_url', t.license_url,
        'source_type', t.source_type,
        'channel_type', t.channel_type,
        'category_key', t.category_key,
        'language_code', t.language_code,
        'world_brief_id', t.world_brief_id,
        'is_default', t.is_default,
        'is_live', t.is_live
      )
      order by t.is_live desc, t.is_default desc, t.sort_order asc, t.created_at asc
    ),
    '[]'::jsonb
  )
  from public.radio_mondo_tracks t
  where t.is_enabled = true;
$$;

create or replace function public.admin_radio_mondo_list()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := (select auth.uid());
  v_tracks jsonb;
begin
  if v_actor is null or not (select public.is_current_auth_user_admin()) then
    raise exception using errcode = '42501', message = 'Admin required.';
  end if;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id', t.id,
        'title', t.title,
        'audio_url', t.audio_url,
        'sort_order', t.sort_order,
        'is_enabled', t.is_enabled,
        'attribution', t.attribution,
        'license_url', t.license_url,
        'source_type', t.source_type,
        'channel_type', t.channel_type,
        'category_key', t.category_key,
        'language_code', t.language_code,
        'world_brief_id', t.world_brief_id,
        'is_default', t.is_default,
        'is_live', t.is_live,
        'created_at', t.created_at,
        'updated_at', t.updated_at
      )
      order by t.category_key asc, t.sort_order asc, t.created_at asc
    ),
    '[]'::jsonb
  )
  into v_tracks
  from public.radio_mondo_tracks t;

  return v_tracks;
end;
$$;

create or replace function public.admin_radio_mondo_upsert_v4(
  p_track_id uuid,
  p_title text,
  p_audio_url text,
  p_sort_order integer,
  p_is_enabled boolean,
  p_attribution text,
  p_license_url text,
  p_source_type text,
  p_channel_type text,
  p_category_key text,
  p_language_code text,
  p_world_brief_id text,
  p_is_default boolean,
  p_is_live boolean,
  p_rights_confirmed boolean,
  p_reason text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := (select auth.uid());
  v_title text := btrim(coalesce(p_title, ''));
  v_audio_url text := btrim(coalesce(p_audio_url, ''));
  v_attribution text := btrim(coalesce(p_attribution, ''));
  v_license_url text := nullif(btrim(coalesce(p_license_url, '')), '');
  v_source_type text := lower(btrim(coalesce(p_source_type, 'audio')));
  v_channel_type text := lower(btrim(coalesce(p_channel_type, 'special')));
  v_category_key text := lower(btrim(coalesce(p_category_key, 'world_music')));
  v_language_code text := nullif(lower(btrim(coalesce(p_language_code, ''))), '');
  v_world_brief_id uuid;
  v_reason text := btrim(coalesce(p_reason, ''));
  v_previous public.radio_mondo_tracks%rowtype;
  v_track public.radio_mondo_tracks%rowtype;
  v_is_new boolean := p_track_id is null;
begin
  if v_actor is null or not (select public.is_current_auth_user_admin()) then
    raise exception using errcode = '42501', message = 'Admin required.';
  end if;
  if p_rights_confirmed is distinct from true then
    raise exception using errcode = '22023', message = 'Audio/stream rights confirmation is required.';
  end if;
  if char_length(v_title) not between 1 and 120 then
    raise exception using errcode = '22023', message = 'Public title is required.';
  end if;
  if char_length(v_audio_url) not between 9 and 2048 or v_audio_url !~ '^https://' then
    raise exception using errcode = '22023', message = 'A valid HTTPS audio/stream URL is required.';
  end if;
  if p_sort_order is null or p_sort_order not between 0 and 1000 then
    raise exception using errcode = '22023', message = 'Sort order must be between 0 and 1000.';
  end if;
  if p_is_enabled is null or p_is_default is null or p_is_live is null then
    raise exception using errcode = '22023', message = 'Radio state is required.';
  end if;
  if char_length(v_attribution) not between 1 and 300 then
    raise exception using errcode = '22023', message = 'Rights or attribution note is required.';
  end if;
  if v_license_url is not null and (char_length(v_license_url) > 2048 or v_license_url !~ '^https://') then
    raise exception using errcode = '22023', message = 'License URL must use HTTPS.';
  end if;
  if v_source_type not in ('audio','stream') then
    raise exception using errcode = '22023', message = 'Invalid source type.';
  end if;
  if v_channel_type not in ('world_live','nature','world_brief','live_event','special') then
    raise exception using errcode = '22023', message = 'Invalid channel type.';
  end if;
  if v_category_key not in (
    'reggae','classical','house','jazz_soul','world_music','sounds_atmospheres'
  ) then
    raise exception using errcode = '22023', message = 'Invalid Radio Mondo category.';
  end if;
  if v_language_code is not null and v_language_code not in ('ar','de','en','es','fa','fr','it','pt','ro','ru','zh') then
    raise exception using errcode = '22023', message = 'Invalid language code.';
  end if;
  if nullif(btrim(coalesce(p_world_brief_id, '')), '') is not null then
    begin
      v_world_brief_id := btrim(p_world_brief_id)::uuid;
    exception when invalid_text_representation then
      raise exception using errcode = '22023', message = 'Invalid World Brief ID.';
    end;
    if not exists (
      select 1 from public.social_vote_world_briefs b where b.id = v_world_brief_id
    ) then
      raise exception using errcode = 'P0002', message = 'World Brief not found.';
    end if;
  end if;
  if char_length(v_reason) not between 1 and 1000 then
    raise exception using errcode = '22023', message = 'Audit reason is required.';
  end if;

  if p_is_default then
    update public.radio_mondo_tracks
    set is_default = false,
        updated_by = v_actor,
        updated_at = now()
    where is_default = true
      and (p_track_id is null or id is distinct from p_track_id);
  end if;

  if v_is_new then
    insert into public.radio_mondo_tracks (
      title, audio_url, sort_order, is_enabled, attribution, license_url,
      source_type, channel_type, category_key, language_code, world_brief_id,
      is_default, is_live, created_by, updated_by
    ) values (
      v_title, v_audio_url, p_sort_order, p_is_enabled, v_attribution,
      v_license_url, v_source_type, v_channel_type, v_category_key,
      v_language_code, v_world_brief_id, p_is_default, p_is_live, v_actor, v_actor
    )
    returning * into v_track;
  else
    select * into v_previous
    from public.radio_mondo_tracks t
    where t.id = p_track_id
    for update;

    if not found then
      raise exception using errcode = 'P0002', message = 'Radio item not found.';
    end if;

    update public.radio_mondo_tracks t
    set title = v_title,
        audio_url = v_audio_url,
        sort_order = p_sort_order,
        is_enabled = p_is_enabled,
        attribution = v_attribution,
        license_url = v_license_url,
        source_type = v_source_type,
        channel_type = v_channel_type,
        category_key = v_category_key,
        language_code = v_language_code,
        world_brief_id = v_world_brief_id,
        is_default = p_is_default,
        is_live = p_is_live,
        updated_by = v_actor,
        updated_at = now()
    where t.id = p_track_id
    returning * into v_track;
  end if;

  insert into public.admin_audit_logs (
    actor_user_id, actor_role, action, target_type, target_id,
    previous_value, new_value, reason, result
  ) values (
    v_actor,
    'admin',
    case when v_is_new then 'radio_item_add_v4' else 'radio_item_update_v4' end,
    'radio_track',
    v_track.id::text,
    case when v_is_new then '{}'::jsonb else jsonb_build_object(
      'sort_order', v_previous.sort_order,
      'is_enabled', v_previous.is_enabled,
      'source_type', v_previous.source_type,
      'channel_type', v_previous.channel_type,
      'category_key', v_previous.category_key,
      'language_code', v_previous.language_code,
      'world_brief_id', v_previous.world_brief_id,
      'is_default', v_previous.is_default,
      'is_live', v_previous.is_live
    ) end,
    jsonb_build_object(
      'sort_order', v_track.sort_order,
      'is_enabled', v_track.is_enabled,
      'source_type', v_track.source_type,
      'channel_type', v_track.channel_type,
      'category_key', v_track.category_key,
      'language_code', v_track.language_code,
      'world_brief_id', v_track.world_brief_id,
      'is_default', v_track.is_default,
      'is_live', v_track.is_live
    ),
    v_reason,
    'success'
  );

  return jsonb_build_object(
    'id', v_track.id,
    'title', v_track.title,
    'audio_url', v_track.audio_url,
    'sort_order', v_track.sort_order,
    'is_enabled', v_track.is_enabled,
    'attribution', v_track.attribution,
    'license_url', v_track.license_url,
    'source_type', v_track.source_type,
    'channel_type', v_track.channel_type,
    'category_key', v_track.category_key,
    'language_code', v_track.language_code,
    'world_brief_id', v_track.world_brief_id,
    'is_default', v_track.is_default,
    'is_live', v_track.is_live,
    'created_at', v_track.created_at,
    'updated_at', v_track.updated_at
  );
end;
$$;

revoke all on function public.admin_radio_mondo_upsert_v4(
  uuid,text,text,integer,boolean,text,text,text,text,text,text,text,boolean,boolean,boolean,text
) from public, anon, authenticated;
grant execute on function public.admin_radio_mondo_upsert_v4(
  uuid,text,text,integer,boolean,text,text,text,text,text,text,text,boolean,boolean,boolean,text
) to authenticated;

revoke all on function public.radio_mondo_public_catalog() from public, anon, authenticated;
grant execute on function public.radio_mondo_public_catalog() to anon, authenticated;
revoke all on function public.admin_radio_mondo_list() from public, anon, authenticated;
grant execute on function public.admin_radio_mondo_list() to authenticated;

commit;
