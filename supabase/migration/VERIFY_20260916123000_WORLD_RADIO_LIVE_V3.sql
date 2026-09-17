select
  exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='radio_mondo_tracks' and column_name='source_type'
  ) as source_type_present,
  exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='radio_mondo_tracks' and column_name='channel_type'
  ) as channel_type_present,
  exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='radio_mondo_tracks' and column_name='language_code'
  ) as language_code_present,
  exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='radio_mondo_tracks' and column_name='world_brief_id'
  ) as world_brief_id_present,
  exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='radio_mondo_tracks' and column_name='is_default'
  ) as is_default_present,
  exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='radio_mondo_tracks' and column_name='is_live'
  ) as is_live_present,
  to_regprocedure('public.admin_radio_mondo_upsert_v3(uuid,text,text,integer,boolean,text,text,text,text,text,text,boolean,boolean,boolean,text)') is not null
    as admin_upsert_v3_present,
  to_regprocedure('public.radio_mondo_public_catalog()') is not null
    as public_catalog_present,
  exists (
    select 1 from pg_catalog.pg_constraint
    where conrelid='public.radio_mondo_tracks'::regclass
      and conname='radio_mondo_tracks_world_brief_fk'
  ) as world_brief_fk_present,
  exists (
    select 1 from pg_catalog.pg_indexes
    where schemaname='public' and tablename='radio_mondo_tracks'
      and indexname='radio_mondo_tracks_single_default_idx'
  ) as single_default_index_present;

select id, title, source_type, channel_type, language_code, world_brief_id,
       is_default, is_live, is_enabled, sort_order
from public.radio_mondo_tracks
order by is_live desc, is_default desc, sort_order asc, created_at asc;
