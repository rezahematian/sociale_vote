-- SOCIAL VOTE
-- Close Supabase Security Advisor: Security Definer View
-- 2026-08-18
--
-- The public read model must remain a SECURITY INVOKER view, while its
-- vote_count must still represent all votes (not only the caller's vote).
-- The narrow SECURITY DEFINER function below exposes only an integer count,
-- applies the existing moderation gate, and never exposes voter identities or
-- vote payloads.
--
-- Safety:
-- - the migration is atomic;
-- - the current visible poll IDs/counts are snapshotted before the change;
-- - the transaction aborts automatically if any visible ID/count changes;
-- - the view column order and types remain unchanged.

begin;

-- SECURITY INVOKER is safe here only if polls RLS is enabled and the API roles
-- already have their normal SELECT privilege on the base table. Abort before
-- changing anything if the production preconditions are different.
do $preflight$
begin
  if not exists (
    select 1
    from pg_catalog.pg_class relation
    where relation.oid = 'public.polls'::regclass
      and relation.relrowsecurity
  ) then
    raise exception 'Preflight failed: RLS is not enabled on public.polls.';
  end if;

  if not pg_catalog.has_table_privilege(
    'anon',
    'public.polls',
    'SELECT'
  ) then
    raise exception 'Preflight failed: anon has no SELECT on public.polls.';
  end if;

  if not pg_catalog.has_table_privilege(
    'authenticated',
    'public.polls',
    'SELECT'
  ) then
    raise exception 'Preflight failed: authenticated has no SELECT on public.polls.';
  end if;
end;
$preflight$;

-- Preserve the current runtime result so the migration can prove that it did
-- not change visible poll IDs or vote totals for the executing production role.
create temporary table sv_poll_vote_counts_before
on commit drop
as
select
  id,
  vote_count
from public.polls_with_vote_count;

-- The correlated count below needs poll_id as the leading index column. Avoid
-- creating a duplicate index when a suitable valid index already exists.
do $migration$
declare
  v_poll_id_attnum smallint;
begin
  select attribute.attnum
  into v_poll_id_attnum
  from pg_catalog.pg_attribute attribute
  where attribute.attrelid = 'public.votes'::regclass
    and attribute.attname = 'poll_id'
    and not attribute.attisdropped;

  if v_poll_id_attnum is null then
    raise exception 'Preflight failed: public.votes.poll_id does not exist.';
  end if;

  if not exists (
    select 1
    from pg_catalog.pg_index index_definition
    where index_definition.indrelid = 'public.votes'::regclass
      and index_definition.indisvalid
      and index_definition.indisready
      and index_definition.indkey[0] = v_poll_id_attnum
  ) then
    create index votes_poll_id_lookup_idx
      on public.votes (poll_id);
  end if;
end;
$migration$;

create or replace function public.visible_poll_vote_count(
  p_poll_id uuid
)
returns integer
language sql
stable
security definer
set search_path = ''
as $function$
  select
    case
      when p_poll_id is null then 0
      when not public.can_read_moderated_content(
        'poll',
        p_poll_id::text
      ) then 0
      else (
        select count(*)::integer
        from public.votes vote
        where vote.poll_id = p_poll_id
      )
    end;
$function$;

comment on function public.visible_poll_vote_count(uuid) is
  'Returns only the total vote count for a readable poll. It preserves aggregate visibility without exposing voter identities or vote payloads.';

revoke all
on function public.visible_poll_vote_count(uuid)
from public;

grant execute
on function public.visible_poll_vote_count(uuid)
to anon, authenticated, service_role;

-- Preserve the existing column order exactly. SECURITY INVOKER makes the view
-- use the caller's permissions and the RLS policies of public.polls.
create or replace view public.polls_with_vote_count
with (security_invoker = true)
as
select
  p.id,
  p.author_id,
  p.title,
  p.description,
  p.type,
  p.status,
  p.options,
  p.min_selections,
  p.max_selections,
  p.participation_scope,
  p.participation_country_code,
  p.allow_vote_change,
  p.anonymity_level,
  p.results_visibility,
  p.min_quorum_votes,
  p.country_code,
  p.city_id,
  p.start_at,
  p.end_at,
  p.content_location,
  p.created_at,
  p.published_as_actor_type,
  p.published_as_institution_level,
  p.published_as_display_name,
  public.visible_poll_vote_count(p.id) as vote_count,
  p.minimum_verification_level,
  p.language_code
from public.polls p
where public.can_read_moderated_content(
  'poll',
  p.id::text
);

comment on view public.polls_with_vote_count is
  'Security-invoker poll read model with public aggregate vote count, moderation visibility, participation verification requirement, and content language.';

-- Fail closed if the view is not actually marked as SECURITY INVOKER.
do $verification$
begin
  if not exists (
    select 1
    from pg_catalog.pg_class relation
    join pg_catalog.pg_namespace namespace
      on namespace.oid = relation.relnamespace
    where namespace.nspname = 'public'
      and relation.relname = 'polls_with_vote_count'
      and relation.relkind = 'v'
      and 'security_invoker=true' = any(
        coalesce(relation.reloptions, array[]::text[])
      )
  ) then
    raise exception 'Verification failed: polls_with_vote_count is not SECURITY INVOKER.';
  end if;

  if exists (
    select 1
    from sv_poll_vote_counts_before before_change
    full join public.polls_with_vote_count after_change
      on after_change.id = before_change.id
    where before_change.id is null
       or after_change.id is null
       or before_change.vote_count is distinct from after_change.vote_count
  ) then
    raise exception 'Verification failed: visible poll IDs or vote counts changed. Transaction rolled back.';
  end if;

  if not pg_catalog.has_table_privilege(
    'anon',
    'public.polls_with_vote_count',
    'SELECT'
  ) then
    raise exception 'Verification failed: anon lost SELECT on polls_with_vote_count.';
  end if;

  if not pg_catalog.has_table_privilege(
    'authenticated',
    'public.polls_with_vote_count',
    'SELECT'
  ) then
    raise exception 'Verification failed: authenticated lost SELECT on polls_with_vote_count.';
  end if;

  if not pg_catalog.has_function_privilege(
    'anon',
    'public.visible_poll_vote_count(uuid)',
    'EXECUTE'
  ) then
    raise exception 'Verification failed: anon cannot execute visible_poll_vote_count.';
  end if;

  if not pg_catalog.has_function_privilege(
    'authenticated',
    'public.visible_poll_vote_count(uuid)',
    'EXECUTE'
  ) then
    raise exception 'Verification failed: authenticated cannot execute visible_poll_vote_count.';
  end if;
end;
$verification$;

notify pgrst, 'reload schema';

commit;

-- One compact result row for the Supabase SQL Editor.
select
  'SECURITY DEFINER VIEW FIX APPLIED'::text as result,
  exists (
    select 1
    from pg_catalog.pg_class relation
    join pg_catalog.pg_namespace namespace
      on namespace.oid = relation.relnamespace
    where namespace.nspname = 'public'
      and relation.relname = 'polls_with_vote_count'
      and 'security_invoker=true' = any(
        coalesce(relation.reloptions, array[]::text[])
      )
  ) as security_invoker,
  count(*)::integer as visible_polls,
  coalesce(sum(vote_count), 0)::bigint as visible_votes
from public.polls_with_vote_count;

-- MANUAL ROLLBACK (execute only if a later runtime regression is confirmed):
-- 1. Recreate public.polls_with_vote_count from
--    20260808_poll_post_language_code_P4_1.sql without security_invoker.
-- 2. drop function if exists public.visible_poll_vote_count(uuid);
-- 3. Keep votes_poll_id_lookup_idx: it is safe and improves count lookups.
