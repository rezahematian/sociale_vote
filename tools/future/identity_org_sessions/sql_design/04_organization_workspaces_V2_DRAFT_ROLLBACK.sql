-- DESIGN SIMULATION ONLY. DO NOT DEPLOY.

begin;

create table if not exists public.organization_workspaces_v2_design (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  plan_key text not null default 'free'
    check (plan_key in ('free','starter','pro','team','event')),
  status text not null default 'active'
    check (status in ('active','restricted','suspended','closed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.workspace_entitlements_v2_design (
  workspace_id uuid not null references public.organization_workspaces_v2_design(id) on delete cascade,
  entitlement_key text not null,
  value_json jsonb not null,
  source text not null check (source in ('plan','event_pass','admin_grant','pilot')),
  valid_until timestamptz,
  primary key (workspace_id, entitlement_key)
);

alter table public.organization_workspaces_v2_design enable row level security;
alter table public.workspace_entitlements_v2_design enable row level security;

rollback;
