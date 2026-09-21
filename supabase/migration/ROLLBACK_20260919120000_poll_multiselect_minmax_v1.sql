-- MANUAL RECOVERY ONLY. Removes only the two guards introduced by this patch.
-- Client rollback normally does not require removal of these compatible guards.
BEGIN;
DROP TRIGGER IF EXISTS social_vote_vote_selections_v1 ON public.votes;
DROP TRIGGER IF EXISTS social_vote_poll_selection_limits_v1 ON public.polls;
DROP FUNCTION IF EXISTS public.social_vote_guard_vote_selections_v1();
DROP FUNCTION IF EXISTS public.social_vote_guard_poll_selection_limits_v1();
COMMIT;
