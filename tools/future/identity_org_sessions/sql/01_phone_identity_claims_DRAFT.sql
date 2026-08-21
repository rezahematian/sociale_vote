-- DRAFT ONLY — DO NOT APPLY YET.
-- Requires a server-side OTP provider and PHONE_HMAC_SECRET before activation.

begin;

create table if not exists public.phone_identity_claims (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  phone_hmac text not null,
  status text not null default 'active'
    check (status in ('active', 'released', 'blocked')),
  verified_at timestamptz not null default now(),
  released_at timestamptz,
  reusable_after timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index if not exists phone_identity_claims_active_phone_uq
  on public.phone_identity_claims(phone_hmac)
  where status = 'active';

create unique index if not exists phone_identity_claims_active_user_uq
  on public.phone_identity_claims(user_id)
  where status = 'active' and user_id is not null;

alter table public.phone_identity_claims enable row level security;

-- Intentionally no client policies. Access must be through protected server-side
-- functions/Edge Functions after caller authentication and authorization.

comment on table public.phone_identity_claims is
  'Pseudonymous uniqueness claims for verified mobile phone numbers. Raw phone numbers must not be stored here.';

commit;
