-- SOCIAL VOTE VERIFIED RESULT REPORT LANGUAGE V3 - READ ONLY VERIFY

select
  exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'live_sessions'
      and column_name = 'report_language'
  ) as report_language_column_present,
  to_regprocedure('public.session_create(text,text,text,text,integer,text)') is not null
    as session_create_v3_present,
  to_regprocedure('public.session_close(uuid)') is not null
    as session_close_present;

select
  pg_catalog.strpos(
    pg_catalog.pg_get_functiondef('public.session_close(uuid)'::regprocedure),
    '''report_language'''
  ) > 0 as close_snapshot_has_report_language,
  pg_catalog.strpos(
    pg_catalog.pg_get_functiondef('public.session_close(uuid)'::regprocedure),
    '''schema_version'', 3'
  ) > 0 as close_snapshot_schema_v3,
  pg_catalog.strpos(
    pg_catalog.pg_get_functiondef(
      'public.session_create(text,text,text,text,integer,text)'::regprocedure
    ),
    'p_report_language'
  ) > 0 as create_accepts_report_language;

select
  conname,
  pg_get_constraintdef(oid) as definition
from pg_catalog.pg_constraint
where conrelid = 'public.live_sessions'::regclass
  and conname = 'live_sessions_report_language_check';
