-- DRAFT ONLY — DO NOT APPLY YET.

begin;

create table if not exists public.verification_evidence (
  id uuid primary key default gen_random_uuid(),
  verification_request_id uuid not null,
  user_id uuid not null,
  evidence_type text not null
    check (evidence_type in (
      'phone_otp',
      'identity_provider',
      'organization_registry',
      'organization_document',
      'representative_authority'
    )),
  provider text,
  provider_reference text,
  status text not null default 'pending'
    check (status in ('pending', 'verified', 'rejected', 'expired', 'deleted')),
  country_code text,
  metadata jsonb not null default '{}'::jsonb,
  verified_at timestamptz,
  expires_at timestamptz,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.verification_evidence enable row level security;

-- No client read/write policy by default. Evidence is sensitive and should be
-- accessed only through protected server-side review endpoints.

commit;
