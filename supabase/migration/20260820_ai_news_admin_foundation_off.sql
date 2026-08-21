-- Social Vote - AI News + Admin advisory foundation (OFF by default)
--
-- Safety properties of this migration:
-- - additive only: it does not alter Poll/Post/News/Admin behavior;
-- - both AI features are inserted with enabled = false;
-- - no pg_cron job is created here;
-- - no OpenAI secret is stored in Postgres;
-- - tables are backend-only (anon/authenticated receive no access);
-- - AI Admin remains advisory-only and cannot execute moderation/account actions.

begin;

create table if not exists public.ai_runtime_config (
  feature text primary key,
  enabled boolean not null default false,
  model text not null,
  prompt_version integer not null default 1,
  max_calls_per_day integer not null default 1,
  max_items_per_call integer not null default 1,
  updated_at timestamptz not null default clock_timestamp(),

  constraint ai_runtime_config_feature_check
    check (feature in ('news_enrichment', 'admin_assistant')),
  constraint ai_runtime_config_model_check
    check (
      nullif(btrim(model), '') is not null
      and char_length(model) <= 160
    ),
  constraint ai_runtime_config_prompt_version_check
    check (prompt_version between 1 and 1000000),
  constraint ai_runtime_config_max_calls_check
    check (max_calls_per_day between 1 and 10000),
  constraint ai_runtime_config_max_items_check
    check (max_items_per_call between 1 and 50)
);

comment on table public.ai_runtime_config is
  'Backend-only Social Vote AI feature flags/model/cost guards. Features are installed disabled.';

alter table public.ai_runtime_config enable row level security;
alter table public.ai_runtime_config force row level security;

revoke all on table public.ai_runtime_config
from public, anon, authenticated;

grant select, insert, update on table public.ai_runtime_config
to service_role;

-- Never turn an already configured feature on/off during an idempotent re-run.
insert into public.ai_runtime_config (
  feature,
  enabled,
  model,
  prompt_version,
  max_calls_per_day,
  max_items_per_call
)
values
  ('news_enrichment', false, 'gpt-5.6-luna', 1, 12, 8),
  ('admin_assistant', false, 'gpt-5.6-terra', 1, 20, 1)
on conflict (feature) do update
set
  model = excluded.model,
  prompt_version = greatest(public.ai_runtime_config.prompt_version, excluded.prompt_version),
  max_calls_per_day = excluded.max_calls_per_day,
  max_items_per_call = excluded.max_items_per_call,
  updated_at = clock_timestamp();

create table if not exists public.ai_usage_daily (
  feature text not null,
  usage_date date not null default current_date,
  calls integer not null default 0,
  input_tokens bigint not null default 0,
  cached_input_tokens bigint not null default 0,
  output_tokens bigint not null default 0,
  last_call_at timestamptz,
  updated_at timestamptz not null default clock_timestamp(),
  primary key (feature, usage_date),

  constraint ai_usage_daily_feature_check
    check (feature in ('news_enrichment', 'admin_assistant')),
  constraint ai_usage_daily_calls_check
    check (calls >= 0),
  constraint ai_usage_daily_input_tokens_check
    check (input_tokens >= 0),
  constraint ai_usage_daily_cached_tokens_check
    check (cached_input_tokens >= 0),
  constraint ai_usage_daily_output_tokens_check
    check (output_tokens >= 0)
);

comment on table public.ai_usage_daily is
  'Backend-only aggregate AI usage counters. Contains no prompts, UGC, user IDs, names, email, phone or report text.';

alter table public.ai_usage_daily enable row level security;
alter table public.ai_usage_daily force row level security;

revoke all on table public.ai_usage_daily
from public, anon, authenticated;

grant select, insert, update on table public.ai_usage_daily
to service_role;

create table if not exists public.news_ai_enrichments (
  news_id uuid not null,
  language text not null,
  source_fingerprint text not null,
  summary text not null,
  topic text not null,
  importance smallint not null,
  confidence double precision not null,
  translation_applied boolean not null default false,
  model text not null,
  prompt_version integer not null,
  generated_at timestamptz not null default clock_timestamp(),
  updated_at timestamptz not null default clock_timestamp(),
  primary key (news_id, language),

  constraint news_ai_enrichments_news_fk
    foreign key (news_id)
    references public.news_articles(id)
    on delete cascade,
  constraint news_ai_enrichments_language_check
    check (language ~ '^[a-z]{2,3}$'),
  constraint news_ai_enrichments_fingerprint_check
    check (source_fingerprint ~ '^[0-9a-f]{64}$'),
  constraint news_ai_enrichments_summary_check
    check (char_length(btrim(summary)) between 20 and 1200),
  constraint news_ai_enrichments_topic_check
    check (topic in (
      'civics', 'economy', 'society', 'environment', 'health',
      'science_technology', 'security', 'conflict', 'transport',
      'culture', 'sport', 'other'
    )),
  constraint news_ai_enrichments_importance_check
    check (importance between 1 and 5),
  constraint news_ai_enrichments_confidence_check
    check (confidence between 0 and 1),
  constraint news_ai_enrichments_model_check
    check (
      nullif(btrim(model), '') is not null
      and char_length(model) <= 160
    ),
  constraint news_ai_enrichments_prompt_version_check
    check (prompt_version between 1 and 1000000)
);

comment on table public.news_ai_enrichments is
  'Backend-only cached AI summaries/classification derived strictly from provider text. This table never controls News geographic location.';

alter table public.news_ai_enrichments enable row level security;
alter table public.news_ai_enrichments force row level security;

revoke all on table public.news_ai_enrichments
from public, anon, authenticated;

grant select, insert, update, delete on table public.news_ai_enrichments
to service_role;

create index if not exists news_ai_enrichments_generated_idx
on public.news_ai_enrichments (generated_at desc);

-- Conservative global daily call reservation. A slot is consumed before the
-- provider request, so provider/network failures cannot create retry storms.
create or replace function public.reserve_ai_call_slot(
  p_feature text
)
returns table (
  allowed boolean,
  calls_used integer,
  max_calls integer
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_feature text := lower(btrim(coalesce(p_feature, '')));
  v_enabled boolean;
  v_max_calls integer;
  v_calls integer;
begin
  if coalesce((select auth.role()), '') <> 'service_role' then
    raise exception using
      errcode = '42501',
      message = 'Service role access is required.';
  end if;

  select c.enabled, c.max_calls_per_day
  into v_enabled, v_max_calls
  from public.ai_runtime_config c
  where c.feature = v_feature
  for update;

  if not found then
    raise exception using
      errcode = '22023',
      message = 'Unknown AI feature.';
  end if;

  if v_enabled is not true then
    return query select false, 0, v_max_calls;
    return;
  end if;

  insert into public.ai_usage_daily (
    feature,
    usage_date,
    calls,
    last_call_at,
    updated_at
  )
  values (
    v_feature,
    current_date,
    0,
    null,
    clock_timestamp()
  )
  on conflict (feature, usage_date) do nothing;

  select u.calls
  into v_calls
  from public.ai_usage_daily u
  where u.feature = v_feature
    and u.usage_date = current_date
  for update;

  if v_calls >= v_max_calls then
    return query select false, v_calls, v_max_calls;
    return;
  end if;

  update public.ai_usage_daily u
  set
    calls = u.calls + 1,
    last_call_at = clock_timestamp(),
    updated_at = clock_timestamp()
  where u.feature = v_feature
    and u.usage_date = current_date
  returning u.calls into v_calls;

  return query select true, v_calls, v_max_calls;
end;
$$;

revoke all on function public.reserve_ai_call_slot(text)
from public, anon, authenticated;

grant execute on function public.reserve_ai_call_slot(text)
to service_role;

create or replace function public.record_ai_token_usage(
  p_feature text,
  p_input_tokens bigint,
  p_cached_input_tokens bigint,
  p_output_tokens bigint
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_feature text := lower(btrim(coalesce(p_feature, '')));
  v_input bigint := greatest(coalesce(p_input_tokens, 0), 0);
  v_cached bigint := greatest(coalesce(p_cached_input_tokens, 0), 0);
  v_output bigint := greatest(coalesce(p_output_tokens, 0), 0);
begin
  if coalesce((select auth.role()), '') <> 'service_role' then
    raise exception using
      errcode = '42501',
      message = 'Service role access is required.';
  end if;

  if v_feature not in ('news_enrichment', 'admin_assistant') then
    raise exception using
      errcode = '22023',
      message = 'Unknown AI feature.';
  end if;

  insert into public.ai_usage_daily (
    feature,
    usage_date,
    calls,
    input_tokens,
    cached_input_tokens,
    output_tokens,
    updated_at
  ) values (
    v_feature,
    current_date,
    0,
    v_input,
    v_cached,
    v_output,
    clock_timestamp()
  )
  on conflict (feature, usage_date) do update
  set
    input_tokens = public.ai_usage_daily.input_tokens + excluded.input_tokens,
    cached_input_tokens = public.ai_usage_daily.cached_input_tokens + excluded.cached_input_tokens,
    output_tokens = public.ai_usage_daily.output_tokens + excluded.output_tokens,
    updated_at = clock_timestamp();
end;
$$;

revoke all on function public.record_ai_token_usage(text, bigint, bigint, bigint)
from public, anon, authenticated;

grant execute on function public.record_ai_token_usage(text, bigint, bigint, bigint)
to service_role;

-- Minimal AI-advisory audit metadata only. No prompt, target content, UGC or
-- personal data is written into the audit entry.
create or replace function public.record_admin_ai_advisory_audit(
  p_actor_user_id uuid,
  p_actor_role text,
  p_action text,
  p_target_type text,
  p_target_id text,
  p_model text,
  p_prompt_version integer,
  p_confidence double precision,
  p_suggestion text,
  p_result text,
  p_error_code text default null
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor_role text := lower(btrim(coalesce(p_actor_role, '')));
  v_action text := lower(btrim(coalesce(p_action, '')));
  v_target_type text := lower(btrim(coalesce(p_target_type, '')));
  v_result text := lower(btrim(coalesce(p_result, '')));
  v_suggestion text := lower(btrim(coalesce(p_suggestion, '')));
begin
  if coalesce((select auth.role()), '') <> 'service_role' then
    raise exception using
      errcode = '42501',
      message = 'Service role access is required.';
  end if;

  if p_actor_user_id is null or v_actor_role not in ('moderator', 'admin') then
    raise exception using
      errcode = '22023',
      message = 'Invalid AI audit actor.';
  end if;

  if v_action not in ('ai_admin_brief', 'ai_report_triage') then
    raise exception using
      errcode = '22023',
      message = 'Invalid AI audit action.';
  end if;

  if v_target_type not in ('admin_center', 'report') then
    raise exception using
      errcode = '22023',
      message = 'Invalid AI audit target type.';
  end if;

  if v_result not in ('success', 'failure', 'denied', 'noop') then
    raise exception using
      errcode = '22023',
      message = 'Invalid AI audit result.';
  end if;

  insert into public.admin_audit_logs (
    actor_user_id,
    actor_role,
    action,
    target_type,
    target_id,
    previous_value,
    new_value,
    reason,
    result,
    error_code
  ) values (
    p_actor_user_id,
    v_actor_role,
    v_action,
    v_target_type,
    nullif(btrim(coalesce(p_target_id, '')), ''),
    '{}'::jsonb,
    jsonb_strip_nulls(jsonb_build_object(
      'model', nullif(btrim(coalesce(p_model, '')), ''),
      'prompt_version', p_prompt_version,
      'confidence', p_confidence,
      'suggestion', nullif(v_suggestion, '')
    )),
    'AI advisory generated; no moderation, account, role, verification, visibility, or deletion action was executed by AI.',
    v_result,
    nullif(lower(btrim(coalesce(p_error_code, ''))), '')
  );
end;
$$;

revoke all on function public.record_admin_ai_advisory_audit(
  uuid, text, text, text, text, text, integer, double precision, text, text, text
)
from public, anon, authenticated;

grant execute on function public.record_admin_ai_advisory_audit(
  uuid, text, text, text, text, text, integer, double precision, text, text, text
)
to service_role;

commit;
