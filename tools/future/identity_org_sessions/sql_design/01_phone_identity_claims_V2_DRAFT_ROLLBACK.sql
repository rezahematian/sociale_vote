-- DESIGN SIMULATION ONLY. DO NOT DEPLOY.
-- Wrapped in ROLLBACK intentionally.

begin;

create table if not exists public.phone_identity_claims_v2_design (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  phone_hmac text not null,
  status text not null check (status in ('active','released','blocked','reclaim_review')),
  provider text,
  verified_at timestamptz,
  released_at timestamptz,
  reusable_after timestamptz,
  created_at timestamptz not null default now()
);

create unique index if not exists phone_claim_v2_active_phone_uq_design
  on public.phone_identity_claims_v2_design(phone_hmac)
  where status = 'active';

create unique index if not exists phone_claim_v2_active_user_uq_design
  on public.phone_identity_claims_v2_design(user_id)
  where status = 'active';

alter table public.phone_identity_claims_v2_design enable row level security;

comment on table public.phone_identity_claims_v2_design is
'DESIGN ONLY. Raw phone forbidden. Server-side HMAC uniqueness claim. No client policy.';

rollback;
