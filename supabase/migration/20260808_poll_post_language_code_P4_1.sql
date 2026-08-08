-- SOCIAL VOTE
-- P4.1 — Content language foundation for Poll/Post
-- 2026-08-08
--
-- Goals:
-- - persist content language independently from UI language;
-- - preserve existing content with language_code = 'und';
-- - prepare efficient feed filtering by language;
-- - expose poll language through polls_with_vote_count.

begin;

-- ============================================================
-- 1. POSTS — CONTENT LANGUAGE
-- ============================================================

alter table public.posts
  add column if not exists language_code text
  not null
  default 'und';

update public.posts
set language_code = 'und'
where language_code is null
   or btrim(language_code) = '';

alter table public.posts
  drop constraint if exists posts_language_code_check;

alter table public.posts
  add constraint posts_language_code_check
  check (
    language_code = 'und'
    or language_code ~ '^[a-z]{2,3}(-[a-z0-9]{2,8})*$'
  );

create index if not exists posts_language_code_created_at_idx
  on public.posts (language_code, created_at desc);

comment on column public.posts.language_code is
  'Language of the post content. Lowercase BCP-47-like code; und means undetermined.';

-- ============================================================
-- 2. POLLS — CONTENT LANGUAGE
-- ============================================================

alter table public.polls
  add column if not exists language_code text
  not null
  default 'und';

update public.polls
set language_code = 'und'
where language_code is null
   or btrim(language_code) = '';

alter table public.polls
  drop constraint if exists polls_language_code_check;

alter table public.polls
  add constraint polls_language_code_check
  check (
    language_code = 'und'
    or language_code ~ '^[a-z]{2,3}(-[a-z0-9]{2,8})*$'
  );

create index if not exists polls_language_code_created_at_idx
  on public.polls (language_code, created_at desc);

comment on column public.polls.language_code is
  'Language of the poll content. Lowercase BCP-47-like code; und means undetermined.';

-- ============================================================
-- 3. POLL READ MODEL
-- ============================================================
-- Preserve the existing column order and append language_code
-- after minimum_verification_level.

create or replace view public.polls_with_vote_count as
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
  coalesce(v.vote_count, 0) as vote_count,
  p.minimum_verification_level,
  p.language_code
from public.polls p
left join (
  select
    votes.poll_id,
    count(*)::integer as vote_count
  from public.votes
  group by votes.poll_id
) v
  on v.poll_id = p.id
where public.can_read_moderated_content(
  'poll',
  p.id::text
);

comment on view public.polls_with_vote_count is
  'Poll read model with vote count, moderation visibility, participation verification requirement, and content language.';

notify pgrst, 'reload schema';

commit;
