-- Social Vote — AC8.5
-- Fix Poll Hide/Restore for reads through polls_with_vote_count.
--
-- Root cause:
-- - polls_with_vote_count is owned by postgres;
-- - the view therefore does not rely on the caller's polls RLS;
-- - hidden Poll rows could remain visible in list/map/search reads.
--
-- This migration preserves the existing vote-count behavior and adds the
-- authoritative moderation predicate directly to the view.

begin;

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
  coalesce(v.vote_count, 0) as vote_count
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
  'Poll read model with vote count and Admin Center moderation visibility enforcement.';

notify pgrst, 'reload schema';

commit;
