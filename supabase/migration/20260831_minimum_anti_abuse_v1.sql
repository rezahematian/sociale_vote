begin;

-- Social Vote Minimum Anti-Abuse V1
-- Scope: authenticated mutation throttling at the PostgreSQL boundary.
-- No client-only protection is relied upon.
-- Existing RLS/session/organization gates remain authoritative and unchanged.

create schema if not exists app_private;

create table if not exists app_private.social_vote_rate_limit_policy (
  action_key text primary key,
  burst_max integer not null check (burst_max > 0),
  burst_window_seconds integer not null check (burst_window_seconds > 0),
  sustained_max integer not null check (sustained_max > 0),
  sustained_window_seconds integer not null check (sustained_window_seconds > 0),
  enabled boolean not null default true,
  updated_at timestamptz not null default now(),
  check (sustained_window_seconds >= burst_window_seconds),
  check (sustained_max >= burst_max)
);

create table if not exists app_private.social_vote_rate_limit_counters (
  actor_user_id uuid not null,
  action_key text not null references app_private.social_vote_rate_limit_policy(action_key) on delete cascade,
  bucket_kind text not null check (bucket_kind in ('burst', 'sustained')),
  bucket_start timestamptz not null,
  action_count integer not null check (action_count > 0),
  updated_at timestamptz not null default now(),
  primary key (actor_user_id, action_key, bucket_kind, bucket_start)
);

create index if not exists social_vote_rate_limit_counters_updated_idx
on app_private.social_vote_rate_limit_counters (updated_at);

revoke all on table app_private.social_vote_rate_limit_policy from public, anon, authenticated;
revoke all on table app_private.social_vote_rate_limit_counters from public, anon, authenticated;

-- Initial conservative defaults. They are server-side policy, not client constants.
-- They can be tuned in a later audited Admin control without changing clients.
insert into app_private.social_vote_rate_limit_policy (
  action_key, burst_max, burst_window_seconds,
  sustained_max, sustained_window_seconds, enabled, updated_at
)
values
  ('post_create',      4, 600,  30, 86400, true, now()),
  ('poll_create',      3, 600,  15, 86400, true, now()),
  ('comment_create',  12,  60, 180,  3600, true, now()),
  ('reaction_mutate', 60,  60, 600,  3600, true, now()),
  ('report_create',    5, 600,  25, 86400, true, now()),
  ('vote_submit',     60,  60, 500,  3600, true, now()),
  ('session_create',   5,3600,  20, 86400, true, now())
on conflict (action_key) do update
set burst_max = excluded.burst_max,
    burst_window_seconds = excluded.burst_window_seconds,
    sustained_max = excluded.sustained_max,
    sustained_window_seconds = excluded.sustained_window_seconds,
    enabled = excluded.enabled,
    updated_at = now();

create or replace function app_private.social_vote_rate_bucket_start(
  p_now timestamptz,
  p_window_seconds integer
)
returns timestamptz
language sql
immutable
set search_path = pg_catalog
as $$
  select to_timestamp(
    floor(extract(epoch from p_now) / p_window_seconds) * p_window_seconds
  );
$$;

revoke all on function app_private.social_vote_rate_bucket_start(timestamptz, integer)
from public, anon, authenticated;

create or replace function app_private.consume_social_vote_rate_limit(
  p_action_key text
)
returns void
language plpgsql
security definer
set search_path = pg_catalog, app_private, public
as $$
declare
  v_actor uuid := auth.uid();
  v_policy app_private.social_vote_rate_limit_policy%rowtype;
  v_now timestamptz := clock_timestamp();
  v_bucket_start timestamptz;
  v_count integer;
begin
  -- Internal/service operations without a user JWT are not throttled here.
  -- Client authenticated mutations always have auth.uid() and are enforced.
  if v_actor is null then
    return;
  end if;

  select *
  into v_policy
  from app_private.social_vote_rate_limit_policy
  where action_key = p_action_key
    and enabled = true;

  if not found then
    raise exception using
      errcode = '55000',
      message = 'Anti-abuse policy is unavailable for this action.';
  end if;

  v_bucket_start := app_private.social_vote_rate_bucket_start(
    v_now,
    v_policy.burst_window_seconds
  );

  insert into app_private.social_vote_rate_limit_counters as c (
    actor_user_id, action_key, bucket_kind, bucket_start, action_count, updated_at
  ) values (
    v_actor, p_action_key, 'burst', v_bucket_start, 1, v_now
  )
  on conflict (actor_user_id, action_key, bucket_kind, bucket_start)
  do update
    set action_count = c.action_count + 1,
        updated_at = excluded.updated_at
    where c.action_count < v_policy.burst_max
  returning action_count into v_count;

  if v_count is null then
    raise exception using
      errcode = '54000',
      message = 'Too many actions. Retry shortly.',
      detail = 'rate_limit=' || p_action_key || ';window=burst';
  end if;

  v_count := null;
  v_bucket_start := app_private.social_vote_rate_bucket_start(
    v_now,
    v_policy.sustained_window_seconds
  );

  insert into app_private.social_vote_rate_limit_counters as c (
    actor_user_id, action_key, bucket_kind, bucket_start, action_count, updated_at
  ) values (
    v_actor, p_action_key, 'sustained', v_bucket_start, 1, v_now
  )
  on conflict (actor_user_id, action_key, bucket_kind, bucket_start)
  do update
    set action_count = c.action_count + 1,
        updated_at = excluded.updated_at
    where c.action_count < v_policy.sustained_max
  returning action_count into v_count;

  if v_count is null then
    raise exception using
      errcode = '54000',
      message = 'Action limit reached. Retry later.',
      detail = 'rate_limit=' || p_action_key || ';window=sustained';
  end if;
end;
$$;

revoke all on function app_private.consume_social_vote_rate_limit(text)
from public, anon, authenticated;

create or replace function app_private.enforce_social_vote_mutation_rate()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, app_private, public
as $$
begin
  if tg_nargs <> 1 or nullif(btrim(tg_argv[0]), '') is null then
    raise exception using
      errcode = '55000',
      message = 'Anti-abuse trigger configuration is invalid.';
  end if;

  perform app_private.consume_social_vote_rate_limit(tg_argv[0]);
  return new;
end;
$$;

revoke all on function app_private.enforce_social_vote_mutation_rate()
from public, anon, authenticated;

-- Direct authenticated content mutations.
drop trigger if exists social_vote_rate_posts_insert on public.posts;
create trigger social_vote_rate_posts_insert
before insert on public.posts
for each row execute function app_private.enforce_social_vote_mutation_rate('post_create');

drop trigger if exists social_vote_rate_polls_insert on public.polls;
create trigger social_vote_rate_polls_insert
before insert on public.polls
for each row execute function app_private.enforce_social_vote_mutation_rate('poll_create');

drop trigger if exists social_vote_rate_comments_insert on public.comments;
create trigger social_vote_rate_comments_insert
before insert on public.comments
for each row execute function app_private.enforce_social_vote_mutation_rate('comment_create');

drop trigger if exists social_vote_rate_reactions_mutate on public.reactions;
create trigger social_vote_rate_reactions_mutate
before insert or update on public.reactions
for each row execute function app_private.enforce_social_vote_mutation_rate('reaction_mutate');

drop trigger if exists social_vote_rate_reports_insert on public.reports;
create trigger social_vote_rate_reports_insert
before insert on public.reports
for each row execute function app_private.enforce_social_vote_mutation_rate('report_create');

drop trigger if exists social_vote_rate_votes_mutate on public.votes;
create trigger social_vote_rate_votes_mutate
before insert or update on public.votes
for each row execute function app_private.enforce_social_vote_mutation_rate('vote_submit');

-- Session creation happens through the existing security-definer RPC, but the
-- authoritative insert still lands in live_sessions and is protected here.
drop trigger if exists social_vote_rate_sessions_insert on public.live_sessions;
create trigger social_vote_rate_sessions_insert
before insert on public.live_sessions
for each row execute function app_private.enforce_social_vote_mutation_rate('session_create');

-- Existing anonymous Session protections remain unchanged:
-- open-anonymous joins already enforce a per-session recent-join ceiling and
-- participant cap; ballot uniqueness is enforced by token/credential use tables.

commit;
