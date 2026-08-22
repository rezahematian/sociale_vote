-- Social Vote Organizations + Sessions — REMOTE STATE PRECHECK (READ ONLY)
-- Run first in Supabase SQL Editor when it is uncertain whether 20260821 pilot SQL was already applied.

with required_tables(table_name) as (
  values
    ('organization_entities'),('organization_memberships'),('organization_workspaces'),
    ('live_sessions'),('live_questions'),('live_options'),('live_access_tokens'),
    ('live_participant_credentials'),('live_token_question_uses'),('live_open_question_uses'),
    ('live_ballots'),('organization_session_audit'),('live_verified_reports')
), present as (
  select count(*)::integer as table_count
  from required_tables r
  where to_regclass('public.' || r.table_name) is not null
), funcs as (
  select count(*)::integer as function_count
  from (values
    ('public.organization_get_mine()'),
    ('public.organization_bootstrap_from_verified_profile()'),
    ('public.session_create(text,text,text,text,integer)'),
    ('public.session_public_join(text,text)'),
    ('public.session_public_vote(text,text,uuid,uuid[])'),
    ('public.session_close(uuid)'),
    ('public.session_verified_report(uuid)'),
    ('public.sessions_retention_cleanup()')
  ) f(signature)
  where to_regprocedure(f.signature) is not null
)
select
  p.table_count,
  f.function_count,
  case
    when p.table_count = 13 and f.function_count = 8 then 'BASE_PRESENT'
    when p.table_count = 0 and f.function_count = 0 then 'BASE_ABSENT'
    else 'PARTIAL_STOP'
  end as remote_state,
  case
    when p.table_count = 13 and f.function_count = 8
      then 'Do NOT reapply 20260821. Apply only 20260822 hardening, then VERIFY.'
    when p.table_count = 0 and f.function_count = 0
      then 'Apply 20260821 base once, then 20260822 hardening, then VERIFY.'
    else 'Partial schema detected: STOP and inspect before any write.'
  end as next_action
from present p cross join funcs f;
