-- DRAFT ONLY — DO NOT APPLY YET.

begin;

create table if not exists public.verified_organization_profiles (
  user_id uuid primary key,
  legal_name text not null,
  public_name text not null,
  organization_type text not null,
  country_code text not null,
  registry_name text,
  registry_reference text,
  public_registry_url text,
  website_url text,
  representative_name text,
  representative_role text,
  authority_evidence_type text,
  verified_at timestamptz,
  reverify_after timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.verified_organization_profiles enable row level security;

-- Public UI should expose only the minimal verified public fields via a view.
-- Representative/evidence fields remain protected.

commit;
