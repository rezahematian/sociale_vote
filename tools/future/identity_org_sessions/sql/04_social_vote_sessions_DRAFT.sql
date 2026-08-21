-- DRAFT ONLY — DO NOT APPLY YET.
-- Social Vote Sessions V1 data model.

begin;

create table if not exists public.organization_workspaces (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid not null,
  organization_profile_user_id uuid not null,
  plan_key text not null default 'free'
    check (plan_key in ('free', 'pro', 'team', 'event')),
  status text not null default 'active'
    check (status in ('active', 'suspended', 'closed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.organization_workspace_members (
  workspace_id uuid not null references public.organization_workspaces(id) on delete cascade,
  user_id uuid not null,
  workspace_role text not null default 'operator'
    check (workspace_role in ('owner', 'manager', 'operator', 'viewer')),
  created_at timestamptz not null default now(),
  primary key (workspace_id, user_id)
);

create table if not exists public.live_sessions (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.organization_workspaces(id) on delete cascade,
  created_by uuid not null,
  title text not null,
  description text,
  join_code text not null unique,
  status text not null default 'draft'
    check (status in ('draft', 'open', 'closed', 'archived', 'deleted')),
  access_mode text not null default 'controlled_anonymous'
    check (access_mode in ('open_anonymous', 'controlled_anonymous')),
  results_visibility text not null default 'after_close'
    check (results_visibility in ('live', 'after_vote', 'after_close', 'organizer_only')),
  retention_policy text not null default '7d'
    check (retention_policy in ('24h', '7d', '30d', 'archive')),
  max_participants integer not null check (max_participants between 1 and 10000),
  opened_at timestamptz,
  closed_at timestamptz,
  delete_after timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.live_questions (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.live_sessions(id) on delete cascade,
  position integer not null,
  title text not null,
  description text,
  question_type text not null
    check (question_type in ('yes_no', 'single_choice', 'multiple_choice')),
  min_selections integer not null default 1,
  max_selections integer not null default 1,
  status text not null default 'draft'
    check (status in ('draft', 'open', 'closed')),
  opened_at timestamptz,
  closed_at timestamptz,
  created_at timestamptz not null default now(),
  unique(session_id, position)
);

create table if not exists public.live_question_options (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.live_questions(id) on delete cascade,
  position integer not null,
  label text not null,
  created_at timestamptz not null default now(),
  unique(question_id, position)
);

create table if not exists public.live_participant_tokens (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.live_sessions(id) on delete cascade,
  token_hash text not null,
  status text not null default 'active'
    check (status in ('active', 'revoked')),
  first_joined_at timestamptz,
  last_seen_at timestamptz,
  created_at timestamptz not null default now(),
  unique(session_id, token_hash)
);

create table if not exists public.live_votes (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.live_sessions(id) on delete cascade,
  question_id uuid not null references public.live_questions(id) on delete cascade,
  participant_token_id uuid not null references public.live_participant_tokens(id) on delete cascade,
  option_ids uuid[] not null,
  submitted_at timestamptz not null default now(),
  unique(question_id, participant_token_id)
);

alter table public.organization_workspaces enable row level security;
alter table public.organization_workspace_members enable row level security;
alter table public.live_sessions enable row level security;
alter table public.live_questions enable row level security;
alter table public.live_question_options enable row level security;
alter table public.live_participant_tokens enable row level security;
alter table public.live_votes enable row level security;

-- RLS/function policy is intentionally NOT included in the draft migration.
-- Before activation, all organizer mutations and anonymous participant voting
-- must be routed through reviewed SECURITY DEFINER functions / Edge Functions.

commit;
