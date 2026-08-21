-- DESIGN SIMULATION ONLY. DO NOT DEPLOY.

begin;

create table if not exists public.verification_evidence_v2_design (
  id uuid primary key default gen_random_uuid(),
  verification_request_id uuid,
  subject_user_id uuid,
  organization_id uuid,
  evidence_class text not null check (evidence_class in (
    'phone_possession','identity_provider','manual_identity',
    'public_registry','representative_authority','official_contact'
  )),
  provider text,
  provider_reference text,
  normalized_status text not null check (normalized_status in (
    'pending','verified','rejected','expired','redacted','deleted'
  )),
  issuing_country text,
  document_type_category text,
  over_18 boolean,
  verified_at timestamptz,
  reverify_after timestamptz,
  redacted_at timestamptz,
  metadata_minimal jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  check (subject_user_id is not null or organization_id is not null)
);

alter table public.verification_evidence_v2_design enable row level security;

comment on table public.verification_evidence_v2_design is
'DESIGN ONLY. Provider-neutral minimal evidence; raw ID/selfie/full ID number forbidden by default.';

rollback;
