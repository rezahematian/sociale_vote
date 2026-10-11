-- SOCIAL VOTE — VERIFY RADIO JAHAN CONTINUOUS PLAYLIST V1

select
  exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'radio_mondo_tracks'
      and column_name = 'jahan_enabled'
  ) as jahan_enabled_column,
  exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'radio_mondo_tracks'
      and column_name = 'jahan_order'
  ) as jahan_order_column,
  to_regprocedure('public.admin_radio_mondo_set_jahan_playlist_v1(jsonb,text)') is not null
    as admin_jahan_rpc,
  has_function_privilege('authenticated', 'public.admin_radio_mondo_set_jahan_playlist_v1(jsonb,text)', 'EXECUTE')
    as authenticated_can_execute_admin_jahan_rpc,
  not has_function_privilege('anon', 'public.admin_radio_mondo_set_jahan_playlist_v1(jsonb,text)', 'EXECUTE')
    as anon_cannot_execute_admin_jahan_rpc;

select
  count(*) filter (
    where jahan_enabled = true
      and (source_type <> 'audio' or is_live = true)
  ) = 0 as jahan_has_only_finite_non_live_audio,
  count(*) filter (
    where jahan_enabled = true
      and category_key = 'sounds_atmospheres'
  ) = 0 as sounds_atmospheres_initially_excluded
from public.radio_mondo_tracks;

select
  id,
  title,
  category_key,
  jahan_enabled,
  jahan_order
from public.radio_mondo_tracks
order by jahan_enabled desc, jahan_order asc, title asc;
