-- SOCIAL VOTE — RADIO JAHAN CONTINUOUS PLAYLIST V1
-- Additive cross-category continuous listening mode.
-- Existing per-category playlists, default station, streams, LIVE flag and playback remain preserved.

begin;

do $$
begin
  if to_regclass('public.radio_mondo_tracks') is null then
    raise exception 'radio_mondo_tracks is missing.';
  end if;
end;
$$;

alter table public.radio_mondo_tracks
  add column if not exists jahan_enabled boolean not null default false;

alter table public.radio_mondo_tracks
  add column if not exists jahan_order integer not null default 1000;

alter table public.radio_mondo_tracks
  drop constraint if exists radio_mondo_tracks_jahan_order_check;
alter table public.radio_mondo_tracks
  add constraint radio_mondo_tracks_jahan_order_check
  check (jahan_order between 0 and 10000);

-- Initial safe playlist: published finite music tracks only.
-- Sounds & Atmospheres starts excluded, matching the requested Radio Jahan baseline.
with ranked as (
  select
    t.id,
    row_number() over (
      order by
        case t.category_key
          when 'reggae' then 10
          when 'classical' then 20
          when 'house' then 30
          when 'jazz_soul' then 40
          when 'world_music' then 50
          else 60
        end,
        t.sort_order,
        t.created_at,
        t.id
    ) * 10 as jahan_order
  from public.radio_mondo_tracks t
  where t.is_enabled = true
    and t.source_type = 'audio'
    and t.is_live = false
    and t.category_key <> 'sounds_atmospheres'
)
update public.radio_mondo_tracks t
set jahan_enabled = true,
    jahan_order = ranked.jahan_order::integer
from ranked
where ranked.id = t.id;

comment on column public.radio_mondo_tracks.jahan_enabled is
  'Whether this finite audio track participates in the Radio Jahan continuous playlist.';
comment on column public.radio_mondo_tracks.jahan_order is
  'Global Radio Jahan playlist order; independent from per-category sort_order.';

create index if not exists radio_mondo_tracks_jahan_order_idx
on public.radio_mondo_tracks(jahan_order, created_at)
where is_enabled = true
  and jahan_enabled = true
  and source_type = 'audio'
  and is_live = false;

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
        'is_live', t.is_live,
        'jahan_enabled', t.jahan_enabled,
        'jahan_order', t.jahan_order
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
        'jahan_enabled', t.jahan_enabled,
        'jahan_order', t.jahan_order,
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

create or replace function public.admin_radio_mondo_set_jahan_playlist_v1(
  p_items jsonb,
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
  v_item jsonb;
  v_track_id uuid;
  v_enabled boolean;
  v_order integer;
  v_source_type text;
  v_is_live boolean;
  v_previous jsonb;
  v_new jsonb;
  v_seen uuid[] := '{}'::uuid[];
begin
  if v_actor is null or not (select public.is_current_auth_user_admin()) then
    raise exception using errcode = '42501', message = 'Admin required.';
  end if;

  if char_length(v_reason) not between 1 and 1000 then
    raise exception using errcode = '22023', message = 'Audit reason is required.';
  end if;

  if p_items is null or jsonb_typeof(p_items) <> 'array' then
    raise exception using errcode = '22023', message = 'Radio Jahan items must be an array.';
  end if;

  if jsonb_array_length(p_items) > 500 then
    raise exception using errcode = '22023', message = 'Too many Radio Jahan items.';
  end if;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'track_id', t.id,
        'jahan_enabled', t.jahan_enabled,
        'jahan_order', t.jahan_order
      ) order by t.jahan_order, t.id
    ),
    '[]'::jsonb
  )
  into v_previous
  from public.radio_mondo_tracks t
  where t.jahan_enabled = true;

  update public.radio_mondo_tracks
  set jahan_enabled = false,
      updated_by = v_actor,
      updated_at = now()
  where jahan_enabled = true;

  for v_item in select value from jsonb_array_elements(p_items)
  loop
    if jsonb_typeof(v_item) <> 'object' then
      raise exception using errcode = '22023', message = 'Invalid Radio Jahan item.';
    end if;

    begin
      v_track_id := nullif(btrim(v_item->>'track_id'), '')::uuid;
    exception when invalid_text_representation then
      raise exception using errcode = '22023', message = 'Invalid Radio Jahan track ID.';
    end;

    if v_track_id is null then
      raise exception using errcode = '22023', message = 'Radio Jahan track ID is required.';
    end if;

    if v_track_id = any(v_seen) then
      raise exception using errcode = '22023', message = 'Duplicate Radio Jahan track ID.';
    end if;
    v_seen := array_append(v_seen, v_track_id);

    if jsonb_typeof(v_item->'is_enabled') is distinct from 'boolean' then
      raise exception using errcode = '22023', message = 'Radio Jahan enabled state is required.';
    end if;
    v_enabled := (v_item->>'is_enabled')::boolean;

    begin
      v_order := (v_item->>'sort_order')::integer;
    exception when invalid_text_representation then
      raise exception using errcode = '22023', message = 'Invalid Radio Jahan order.';
    end;

    if v_order is null or v_order not between 0 and 10000 then
      raise exception using errcode = '22023', message = 'Radio Jahan order must be between 0 and 10000.';
    end if;

    select t.source_type, t.is_live
    into v_source_type, v_is_live
    from public.radio_mondo_tracks t
    where t.id = v_track_id;

    if not found then
      raise exception using errcode = 'P0002', message = 'Radio Jahan track not found.';
    end if;

    if v_source_type <> 'audio' or v_is_live then
      raise exception using errcode = '22023', message = 'Radio Jahan accepts finite non-LIVE audio only.';
    end if;

    update public.radio_mondo_tracks
    set jahan_enabled = v_enabled,
        jahan_order = v_order,
        updated_by = v_actor,
        updated_at = now()
    where id = v_track_id;
  end loop;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'track_id', t.id,
        'jahan_enabled', t.jahan_enabled,
        'jahan_order', t.jahan_order
      ) order by t.jahan_order, t.id
    ),
    '[]'::jsonb
  )
  into v_new
  from public.radio_mondo_tracks t
  where t.jahan_enabled = true;

  insert into public.admin_audit_logs (
    actor_user_id, actor_role, action, target_type, target_id,
    previous_value, new_value, reason, result
  ) values (
    v_actor,
    'admin',
    'radio_jahan_playlist_update_v1',
    'radio_jahan_playlist',
    'radio_jahan',
    jsonb_build_object('items', v_previous),
    jsonb_build_object('items', v_new),
    v_reason,
    'success'
  );

  return jsonb_build_object(
    'success', true,
    'items', v_new
  );
end;
$$;

revoke all on function public.radio_mondo_public_catalog() from public, anon, authenticated;
grant execute on function public.radio_mondo_public_catalog() to anon, authenticated;

revoke all on function public.admin_radio_mondo_list() from public, anon, authenticated;
grant execute on function public.admin_radio_mondo_list() to authenticated;

revoke all on function public.admin_radio_mondo_set_jahan_playlist_v1(jsonb,text)
  from public, anon, authenticated;
grant execute on function public.admin_radio_mondo_set_jahan_playlist_v1(jsonb,text)
  to authenticated;

commit;
