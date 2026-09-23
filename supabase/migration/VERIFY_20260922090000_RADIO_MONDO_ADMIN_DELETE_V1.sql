-- VERIFY — RADIO MONDO ADMIN DELETE V1
-- Read-only checks. Does not delete any Radio Mondo row.

select
  to_regprocedure('public.admin_radio_mondo_delete_v1(uuid,text)') is not null
    as delete_rpc_exists,
  has_function_privilege(
    'authenticated',
    'public.admin_radio_mondo_delete_v1(uuid,text)',
    'EXECUTE'
  ) as authenticated_can_execute,
  not has_function_privilege(
    'anon',
    'public.admin_radio_mondo_delete_v1(uuid,text)',
    'EXECUTE'
  ) as anon_cannot_execute;

select
  count(*) filter (where is_default) <= 1 as at_most_one_default,
  count(*) as track_count
from public.radio_mondo_tracks;
