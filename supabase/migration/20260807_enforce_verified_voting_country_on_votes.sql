-- SOCIAL VOTE
-- P1.1 — Enforce verified voting country at database level
-- 2026-08-07
--
-- Scopo:
-- - un poll senza participation_country_code resta votabile secondo le regole esistenti;
-- - un poll limitato a un paese richiede che l'utente abbia
--   user_profiles.voting_country_code verificato e coincidente;
-- - il controllo vale sia per INSERT sia per UPDATE del voto;
-- - profile.country non viene mai usato per autorizzare il voto.

begin;

-- ============================================================
-- 1. CENTRAL BACKEND CHECK
-- ============================================================

create or replace function public.can_current_user_vote_in_poll_country(
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
        nullif(btrim(p.participation_country_code), '') is null
        or exists (
          select 1
          from public.user_profiles up
          where up.id = auth.uid()
            and up.voting_country_verified_at is not null
            and upper(btrim(up.voting_country_code))
                = upper(btrim(p.participation_country_code))
        )
      )
  );
$$;

revoke all
on function public.can_current_user_vote_in_poll_country(uuid)
from public;

grant execute
on function public.can_current_user_vote_in_poll_country(uuid)
to authenticated;

comment on function public.can_current_user_vote_in_poll_country(uuid) is
  'P1.1: database-side eligibility check for country-restricted polls. '
  'Uses only verified user_profiles.voting_country_code, never editable profile.country.';

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
)
with check (
  user_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
  and (
    select public.can_current_user_vote_in_poll_country(poll_id)
  )
);

commit;
