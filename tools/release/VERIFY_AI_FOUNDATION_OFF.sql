-- Social Vote - read-only verification for AI foundation.
-- Expected immediately after migration: both features exist and are DISABLED,
-- no AI cron jobs exist, backend tables have RLS enabled/forced.

select
  feature,
  enabled,
  model,
  prompt_version,
  max_calls_per_day,
  max_items_per_call
from public.ai_runtime_config
order by feature;

select
  c.relname as table_name,
  c.relrowsecurity as rls_enabled,
  c.relforcerowsecurity as rls_forced
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public'
  and c.relname in (
    'ai_runtime_config',
    'ai_usage_daily',
    'news_ai_enrichments'
  )
order by c.relname;

select
  routine_name,
  security_type
from information_schema.routines
where routine_schema = 'public'
  and routine_name in (
    'reserve_ai_call_slot',
    'record_ai_token_usage',
    'record_admin_ai_advisory_audit'
  )
order by routine_name;

-- Must return ZERO rows for the OFF foundation.
select jobid, jobname, schedule, active
from cron.job
where lower(jobname) like '%ai%';

-- Must return both rows with enabled = false.
select
  count(*) filter (where enabled = false) as disabled_features,
  count(*) as configured_features
from public.ai_runtime_config
where feature in ('news_enrichment', 'admin_assistant');
