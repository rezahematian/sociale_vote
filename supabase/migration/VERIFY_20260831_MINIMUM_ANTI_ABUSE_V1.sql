with funcs as (
  select
    p.proname,
    p.prosecdef,
    pg_get_functiondef(p.oid) as def,
    coalesce(array_to_string(p.proconfig, ','), '') as config
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'app_private'
    and p.proname in (
      'consume_social_vote_rate_limit',
      'enforce_social_vote_mutation_rate'
    )
), triggers as (
  select tgname
  from pg_trigger
  where not tgisinternal
), policies as (
  select action_key, burst_max, burst_window_seconds,
         sustained_max, sustained_window_seconds, enabled
  from app_private.social_vote_rate_limit_policy
)
select
  to_regclass('app_private.social_vote_rate_limit_policy') is not null
    as policy_table_present,
  to_regclass('app_private.social_vote_rate_limit_counters') is not null
    as counters_table_present,
  not has_table_privilege('anon', 'app_private.social_vote_rate_limit_policy', 'select,insert,update,delete')
    as anon_policy_table_blocked,
  not has_table_privilege('authenticated', 'app_private.social_vote_rate_limit_policy', 'select,insert,update,delete')
    as authenticated_policy_table_blocked,
  not has_table_privilege('anon', 'app_private.social_vote_rate_limit_counters', 'select,insert,update,delete')
    as anon_counters_blocked,
  not has_table_privilege('authenticated', 'app_private.social_vote_rate_limit_counters', 'select,insert,update,delete')
    as authenticated_counters_blocked,
  exists (
    select 1 from funcs
    where proname = 'consume_social_vote_rate_limit'
      and prosecdef
      and config like '%search_path=pg_catalog, app_private, public%'
  ) as consume_security_definer_locked,
  exists (
    select 1 from funcs
    where proname = 'enforce_social_vote_mutation_rate'
      and prosecdef
      and config like '%search_path=pg_catalog, app_private, public%'
  ) as trigger_security_definer_locked,
  (select count(*) from policies where enabled) = 7
    as seven_enabled_policies,
  exists (select 1 from policies where action_key='post_create' and burst_max=4 and burst_window_seconds=600 and sustained_max=30 and sustained_window_seconds=86400 and enabled)
    as post_policy_valid,
  exists (select 1 from policies where action_key='poll_create' and burst_max=3 and burst_window_seconds=600 and sustained_max=15 and sustained_window_seconds=86400 and enabled)
    as poll_policy_valid,
  exists (select 1 from policies where action_key='comment_create' and burst_max=12 and burst_window_seconds=60 and sustained_max=180 and sustained_window_seconds=3600 and enabled)
    as comment_policy_valid,
  exists (select 1 from policies where action_key='reaction_mutate' and burst_max=60 and burst_window_seconds=60 and sustained_max=600 and sustained_window_seconds=3600 and enabled)
    as reaction_policy_valid,
  exists (select 1 from policies where action_key='report_create' and burst_max=5 and burst_window_seconds=600 and sustained_max=25 and sustained_window_seconds=86400 and enabled)
    as report_policy_valid,
  exists (select 1 from policies where action_key='vote_submit' and burst_max=60 and burst_window_seconds=60 and sustained_max=500 and sustained_window_seconds=3600 and enabled)
    as vote_policy_valid,
  exists (select 1 from policies where action_key='session_create' and burst_max=5 and burst_window_seconds=3600 and sustained_max=20 and sustained_window_seconds=86400 and enabled)
    as session_policy_valid,
  exists (select 1 from triggers where tgname='social_vote_rate_posts_insert')
    as post_trigger_present,
  exists (select 1 from triggers where tgname='social_vote_rate_polls_insert')
    as poll_trigger_present,
  exists (select 1 from triggers where tgname='social_vote_rate_comments_insert')
    as comment_trigger_present,
  exists (select 1 from triggers where tgname='social_vote_rate_reactions_mutate')
    as reaction_trigger_present,
  exists (select 1 from triggers where tgname='social_vote_rate_reports_insert')
    as report_trigger_present,
  exists (select 1 from triggers where tgname='social_vote_rate_votes_mutate')
    as vote_trigger_present,
  exists (select 1 from triggers where tgname='social_vote_rate_sessions_insert')
    as session_trigger_present,
  position('120' in pg_get_functiondef('public.session_public_join(text,text)'::regprocedure)) > 0
    and position('Too many participant joins' in pg_get_functiondef('public.session_public_join(text,text)'::regprocedure)) > 0
    as existing_anonymous_session_join_guard_preserved;
