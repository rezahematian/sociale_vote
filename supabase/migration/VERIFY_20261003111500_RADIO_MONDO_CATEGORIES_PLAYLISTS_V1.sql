select
  exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='radio_mondo_tracks' and column_name='category_key'
  ) as category_key_present,
  exists (
    select 1 from pg_catalog.pg_constraint
    where conrelid='public.radio_mondo_tracks'::regclass
      and conname='radio_mondo_tracks_category_key_check'
  ) as category_check_present,
  exists (
    select 1 from pg_catalog.pg_indexes
    where schemaname='public' and tablename='radio_mondo_tracks'
      and indexname='radio_mondo_tracks_category_sort_idx'
  ) as category_sort_index_present,
  to_regprocedure('public.admin_radio_mondo_upsert_v4(uuid,text,text,integer,boolean,text,text,text,text,text,text,text,boolean,boolean,boolean,text)') is not null
    as admin_upsert_v4_present,
  position('category_key' in pg_get_functiondef('public.radio_mondo_public_catalog()'::regprocedure)) > 0
    as public_catalog_category_present,
  position('category_key' in pg_get_functiondef('public.admin_radio_mondo_list()'::regprocedure)) > 0
    as admin_list_category_present;

select category_key, count(*) as track_count
from public.radio_mondo_tracks
group by category_key
order by category_key;

select id, title, category_key, channel_type, source_type, is_default, is_enabled, sort_order
from public.radio_mondo_tracks
order by category_key, sort_order, created_at;
