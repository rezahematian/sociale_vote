-- DESIGN SIMULATION ONLY. DO NOT DEPLOY.

begin;

create table if not exists public.organization_billing_accounts_v2_design (
  organization_id uuid primary key,
  provider text not null default 'stripe',
  provider_customer_ref text unique,
  billing_country text,
  tax_profile_status text not null default 'incomplete',
  created_at timestamptz not null default now()
);

create table if not exists public.organization_subscriptions_v2_design (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  provider_subscription_ref text unique,
  plan_key text not null check (plan_key in ('starter','pro','team')),
  status text not null check (status in ('trialing','active','past_due','restricted','canceled')),
  current_period_end timestamptz,
  cancel_at_period_end boolean not null default false,
  updated_at timestamptz not null default now()
);

create table if not exists public.billing_webhook_events_v2_design (
  provider text not null,
  provider_event_id text not null,
  event_type text not null,
  processed_at timestamptz not null default now(),
  primary key (provider, provider_event_id)
);

alter table public.organization_billing_accounts_v2_design enable row level security;
alter table public.organization_subscriptions_v2_design enable row level security;
alter table public.billing_webhook_events_v2_design enable row level security;

rollback;
