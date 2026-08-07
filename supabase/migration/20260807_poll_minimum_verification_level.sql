-- SOCIAL VOTE
-- P1.2 — Minimum verification level required to vote
-- 2026-08-07
--
-- Fondazione di persistenza:
-- - ogni poll può dichiarare il livello minimo Persona richiesto;
-- - i poll esistenti restano invariati con valore 'none';
-- - nessun enforcement sul voto viene introdotto in questa migrazione:
--   verrà collegato nei passi successivi di P1.2.

begin;

-- ============================================================
-- 1. POLLS — MINIMUM VERIFICATION LEVEL
-- ============================================================

alter table public.polls
  add column if not exists minimum_verification_level text
  not null
  default 'none';

alter table public.polls
  drop constraint if exists polls_minimum_verification_level_check;

alter table public.polls
  add constraint polls_minimum_verification_level_check
  check (
    minimum_verification_level in ('none', 'level1', 'level2')
  );

comment on column public.polls.minimum_verification_level is
  'Minimum Persona verification level required to vote: none, level1 or level2.';

-- ============================================================
-- 2. READ MODEL
-- ============================================================
-- Existing view columns keep the same order. The new field is appended
-- after vote_count so CREATE OR REPLACE VIEW remains compatible.

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
  p.minimum_verification_level
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
  'Poll read model with vote count, moderation visibility enforcement, '
  'and minimum verification level required for participation.';

notify pgrst, 'reload schema';

commit;
