-- READ-ONLY verification for Sessions UX V3 / Verified Result Certificate V2.
-- Expected: every CHECK row PASS and OVERALL = PASS / failed_checks=0.

with checks as (
  select 1 as ord,
         'organizer_detail_operational_counters'::text as check_name,
         (
           pg_get_functiondef('public._session_detail_json(uuid)'::regprocedure) like '%''participant_count''%'
           and pg_get_functiondef('public._session_detail_json(uuid)'::regprocedure) like '%''used_access_count''%'
           and pg_get_functiondef('public._session_detail_json(uuid)'::regprocedure) like '%''question_count''%'
         ) as passed,
         'participant_count + used_access_count + question_count'::text as detail
  union all
  select 2,
         'sessions_list_operational_counters',
         (
           pg_get_functiondef('public.sessions_list_mine()'::regprocedure) like '%''participant_count''%'
           and pg_get_functiondef('public.sessions_list_mine()'::regprocedure) like '%''used_access_count''%'
           and pg_get_functiondef('public.sessions_list_mine()'::regprocedure) like '%''question_count''%'
         ),
         'workspace list exposes organizer aggregate counters'
  union all
  select 3,
         'public_read_model_hides_operational_counts',
         (
           pg_get_functiondef('public._session_public_detail_json(uuid)'::regprocedure) like '%''participant_count'', 0%'
           and pg_get_functiondef('public._session_public_detail_json(uuid)'::regprocedure) like '%''used_access_count'', 0%'
         ),
         'participant/public model does not expose organizer counters'
  union all
  select 4,
         'certificate_snapshot_v2',
         (
           pg_get_functiondef('public.session_close(uuid)'::regprocedure) like '%''schema_version'', 2%'
           and pg_get_functiondef('public.session_close(uuid)'::regprocedure) like '%''certificate_number''%'
           and pg_get_functiondef('public.session_close(uuid)'::regprocedure) like '%''integrity_algorithm'', ''SHA-256''%'
         ),
         'session_close builds certificate schema v2'
  union all
  select 5,
         'organization_identity_frozen_in_certificate',
         (
           pg_get_functiondef('public.session_close(uuid)'::regprocedure) like '%''organization_legal_name''%'
           and pg_get_functiondef('public.session_close(uuid)'::regprocedure) like '%''organization_entity_type''%'
           and pg_get_functiondef('public.session_close(uuid)'::regprocedure) like '%''organization_logo_url''%'
           and pg_get_functiondef('public.session_close(uuid)'::regprocedure) like '%''organization_verified_at''%'
         ),
         'Organization identity/branding copied into immutable snapshot at close'
  union all
  select 6,
         'certificate_participation_aggregates',
         (
           pg_get_functiondef('public.session_close(uuid)'::regprocedure) like '%''participant_credentials_joined''%'
           and pg_get_functiondef('public.session_close(uuid)'::regprocedure) like '%''participants_with_recorded_vote''%'
           and pg_get_functiondef('public.session_close(uuid)'::regprocedure) like '%''ballots_total''%'
         ),
         'certificate distinguishes access/participation/ballot aggregates'
  union all
  select 7,
         'ballot_has_no_identity_token_credential_columns',
         not exists (
           select 1
           from information_schema.columns
           where table_schema = 'public'
             and table_name = 'live_ballots'
             and column_name ~* '(user|identity|token|credential|participant)'
         ),
         'live_ballots remains anonymous by schema'
  union all
  select 8,
         'access_token_remains_hash_only',
         (
           exists (
             select 1 from information_schema.columns
             where table_schema = 'public'
               and table_name = 'live_access_tokens'
               and column_name = 'token_hash'
           )
           and not exists (
             select 1 from information_schema.columns
             where table_schema = 'public'
               and table_name = 'live_access_tokens'
               and column_name in ('token','token_plaintext','plaintext_token','access_token')
           )
         ),
         'no plaintext access pass column exists'
  union all
  select 9,
         'verified_report_immutability_trigger',
         exists (
           select 1
           from pg_trigger t
           join pg_class c on c.oid = t.tgrelid
           join pg_namespace n on n.oid = c.relnamespace
           where n.nspname = 'public'
             and c.relname = 'live_verified_reports'
             and t.tgname = 'live_verified_reports_immutable'
             and t.tgenabled <> 'D'
             and not t.tgisinternal
         ),
         'immutable report trigger remains enabled'
  union all
  select 10,
         'security_definer_search_path',
         not exists (
           select 1
           from pg_proc p
           join pg_namespace n on n.oid = p.pronamespace
           where n.nspname = 'public'
             and p.proname in ('_session_detail_json','_session_public_detail_json','sessions_list_mine','session_close','session_verified_report')
             and (
               not p.prosecdef
               or coalesce(array_to_string(p.proconfig, ','), '') not like '%search_path=pg_catalog, public, extensions%'
             )
         ),
         'critical Session functions stay SECURITY DEFINER with controlled search_path'
  union all
  select 11,
         'live_token_generation_open_or_draft',
         (
           pg_get_functiondef('public.session_generate_tokens(uuid,integer)'::regprocedure) like '%in (''draft'', ''open'')%'
           or pg_get_functiondef('public.session_generate_tokens(uuid,integer)'::regprocedure) like '%IN (''draft'', ''open'')%'
         ),
         'existing Live Tokens fix remains installed'
  union all
  select 12,
         'verified_report_hash_revalidation',
         pg_get_functiondef('public.session_verified_report(uuid)'::regprocedure) like '%v_recomputed = v_report.snapshot_sha256%',
         'public report read still recomputes SHA-256'
), summary as (
  select count(*) as total,
         count(*) filter (where passed) as passed_count,
         count(*) filter (where not passed) as failed_count,
         bool_and(passed) as all_passed
  from checks
)
select ord as "#",
       check_name,
       case when passed then 'PASS' else 'FAIL' end as status,
       detail
from checks
union all
select 99,
       'OVERALL',
       case when all_passed then 'PASS' else 'FAIL' end,
       'passed=' || passed_count || '/' || total || ' failed_checks=' || failed_count
from summary
order by "#";
