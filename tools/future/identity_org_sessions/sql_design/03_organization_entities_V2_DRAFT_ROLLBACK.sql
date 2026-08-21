-- DESIGN SIMULATION ONLY. DO NOT DEPLOY.

begin;

create table if not exists public.organization_entities_v2_design (
  id uuid primary key default gen_random_uuid(),
  legal_name text not null,
  public_name text not null,
  country_code text not null,
  entity_type text not null,
  fiscal_code text,
  vat_id text,
  registry_type text,
  registry_reference text,
  registry_url text,
  website_url text,
  verification_status text not null default 'draft'
    check (verification_status in (
      'draft','submitted','needs_information','verified','rejected','suspended','expired'
    )),
  verified_at timestamptz,
  reverify_after timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.organization_memberships_v2_design (
  organization_id uuid not null references public.organization_entities_v2_design(id) on delete cascade,
  user_id uuid not null,
  membership_role text not null check (membership_role in ('owner','manager','operator','viewer','billing')),
  status text not null default 'active' check (status in ('invited','active','revoked')),
  created_at timestamptz not null default now(),
  primary key (organization_id, user_id)
);

alter table public.organization_entities_v2_design enable row level security;
alter table public.organization_memberships_v2_design enable row level security;

rollback;
