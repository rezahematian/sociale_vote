-- SOCIAL VOTE
-- P1.1 — Verified voting country foundation
-- 2026-08-07
--
-- Obiettivo:
-- - separare la residenza modificabile del profilo dal paese verificato
--   usato per l'eleggibilità nei poll geografici;
-- - non attribuire automaticamente un paese di voto agli utenti già verificati;
-- - impedire agli utenti normali di modificare direttamente i campi protetti.

begin;

-- ============================================================
-- 1. USER PROFILE — VERIFIED VOTING COUNTRY
-- ============================================================

alter table public.user_profiles
  add column if not exists voting_country_code text;

alter table public.user_profiles
  add column if not exists voting_country_verified_at timestamptz;

alter table public.user_profiles
  drop constraint if exists user_profiles_voting_country_code_check;

alter table public.user_profiles
  add constraint user_profiles_voting_country_code_check
  check (
    voting_country_code is null
    or voting_country_code ~ '^[A-Z]{2}$'
  );

alter table public.user_profiles
  drop constraint if exists user_profiles_voting_country_verification_pair_check;

alter table public.user_profiles
  add constraint user_profiles_voting_country_verification_pair_check
  check (
    (
      voting_country_code is null
      and voting_country_verified_at is null
    )
    or
    (
      voting_country_code is not null
      and voting_country_verified_at is not null
    )
  );

comment on column public.user_profiles.voting_country_code is
  'ISO 3166-1 alpha-2 country code verified for geographic poll eligibility. '
  'Independent from the editable profile country.';

comment on column public.user_profiles.voting_country_verified_at is
  'Timestamp when voting_country_code was explicitly verified.';

-- ============================================================
-- 2. VERIFICATION REQUEST — COUNTRY SNAPSHOT
-- ============================================================

alter table public.verification_requests
  add column if not exists voting_country_code text;

alter table public.verification_requests
  drop constraint if exists verification_requests_voting_country_code_check;

alter table public.verification_requests
  add constraint verification_requests_voting_country_code_check
  check (
    voting_country_code is null
    or voting_country_code ~ '^[A-Z]{2}$'
  );

comment on column public.verification_requests.voting_country_code is
  'Country submitted as part of a verification request. '
  'It is not an authorization until the request is approved.';

-- ============================================================
-- 3. PROTECT VERIFIED PROFILE COUNTRY FROM SELF-EDIT
-- ============================================================

create or replace function public.protect_verified_voting_country()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_staff_role text := coalesce(
    auth.jwt() -> 'app_metadata' ->> 'role',
    ''
  );
begin
  if
    new.voting_country_code is distinct from old.voting_country_code
    or new.voting_country_verified_at
       is distinct from old.voting_country_verified_at
  then
    if
      coalesce(auth.role(), '') <> 'service_role'
      and v_staff_role not in ('moderator', 'admin')
    then
      raise exception
        using
          errcode = '42501',
          message = 'Verified voting country cannot be changed directly.';
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists protect_verified_voting_country_trigger
on public.user_profiles;

create trigger protect_verified_voting_country_trigger
before update of voting_country_code, voting_country_verified_at
on public.user_profiles
for each row
execute function public.protect_verified_voting_country();

-- ============================================================
-- 4. PROTECT REQUEST COUNTRY SNAPSHOT AFTER SUBMISSION
-- ============================================================

create or replace function public.protect_verification_request_voting_country()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_staff_role text := coalesce(
    auth.jwt() -> 'app_metadata' ->> 'role',
    ''
  );
begin
  if new.voting_country_code is distinct from old.voting_country_code then
    if
      coalesce(auth.role(), '') <> 'service_role'
      and v_staff_role not in ('moderator', 'admin')
    then
      raise exception
        using
          errcode = '42501',
          message = 'Verification voting country cannot be changed after submission.';
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists protect_verification_request_voting_country_trigger
on public.verification_requests;

create trigger protect_verification_request_voting_country_trigger
before update of voting_country_code
on public.verification_requests
for each row
execute function public.protect_verification_request_voting_country();

-- Intentionally no backfill:
-- previous identity approvals did not explicitly verify voting eligibility country.

commit;
