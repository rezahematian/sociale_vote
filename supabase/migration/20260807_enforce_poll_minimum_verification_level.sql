-- SOCIAL VOTE
-- P1.2 — Enforce minimum verification level on votes
-- 2026-08-07
--
-- Scopo:
-- - applicare lato database il requisito minimum_verification_level del poll;
-- - mantenere invariato il controllo geografico P1.1;
-- - impedire bypass tramite client modificato;
-- - applicare il controllo sia su INSERT sia su UPDATE del voto.

begin;

-- ============================================================
-- 1. VERIFICATION ELIGIBILITY CHECK
-- ============================================================

create or replace function public.can_current_user_vote_in_poll_verification(
  p_poll_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = public, auth
as $$
  select exists (
    select 1
    from public.polls p
    where p.id = p_poll_id
      and (
        p.minimum_verification_level = 'none'
        or exists (
          select 1
          from public.user_profiles up
          where up.id = auth.uid()
            and up.actor_type = 'citizen'
            and up.verified_at is not null
            and (
              (
                p.minimum_verification_level = 'level1'
                and up.verification_level in ('level1', 'level2')
              )
              or
              (
                p.minimum_verification_level = 'level2'
                and up.verification_level = 'level2'
              )
            )
        )
      )
  );
$$;

revoke all
on function public.can_current_user_vote_in_poll_verification(uuid)
from public;

grant execute
on function public.can_current_user_vote_in_poll_verification(uuid)
to authenticated;

comment on function public.can_current_user_vote_in_poll_verification(uuid) is
  'P1.2: database-side eligibility check for poll minimum Persona verification level.';

-- ============================================================
-- 2. INSERT VOTE
-- ============================================================

alter policy votes_insert_own
on public.votes
to authenticated
with check (
  (select auth.uid()) is not null
  and user_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
  and (
    select public.can_current_user_vote_in_poll_country(poll_id)
  )
  and (
    select public.can_current_user_vote_in_poll_verification(poll_id)
  )
);

-- ============================================================
-- 3. UPDATE EXISTING VOTE
-- ============================================================

alter policy votes_update_own
on public.votes
to authenticated
using (
  user_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
  and (
    select public.can_current_user_vote_in_poll_country(poll_id)
  )
  and (
    select public.can_current_user_vote_in_poll_verification(poll_id)
  )
)
with check (
  user_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
  and (
    select public.can_current_user_vote_in_poll_country(poll_id)
  )
  and (
    select public.can_current_user_vote_in_poll_verification(poll_id)
  )
);

commit;
