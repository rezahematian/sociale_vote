-- DESIGN SIMULATION ONLY. DO NOT DEPLOY.
-- Important V2 change: ballot rows DO NOT reference participant token rows.

begin;

create table if not exists public.live_sessions_v2_design (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null,
  created_by uuid not null,
  title text not null,
  join_code text not null unique,
  status text not null check (status in ('draft','scheduled','open','closed','archived','deleting')),
  access_mode text not null check (access_mode in ('open_anonymous','controlled_token_pool')),
  results_visibility text not null
    check (results_visibility in ('live','after_vote','after_close','organizer_only')),
  raw_retention text not null check (raw_retention in ('24h','7d','30d')),
  max_participants integer not null check (max_participants between 1 and 10000),
  opened_at timestamptz,
  closed_at timestamptz,
  delete_raw_after timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.live_questions_v2_design (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.live_sessions_v2_design(id) on delete cascade,
  position integer not null,
  title text not null,
  question_type text not null check (question_type in ('yes_no','single_choice','multiple_choice')),
  min_selections integer not null default 1,
  max_selections integer not null default 1,
  status text not null check (status in ('draft','open','closed')),
  unique (session_id, position)
);

create table if not exists public.live_options_v2_design (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.live_questions_v2_design(id) on delete cascade,
  position integer not null,
  label text not null,
  unique (question_id, position)
);

create table if not exists public.live_access_tokens_v2_design (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.live_sessions_v2_design(id) on delete cascade,
  token_hash text not null,
  status text not null default 'active' check (status in ('active','revoked')),
  unique (session_id, token_hash)
);

-- Participation ledger: proves a credential has used its right for a question.
-- It intentionally contains no ballot choice.
create table if not exists public.live_token_question_uses_v2_design (
  question_id uuid not null references public.live_questions_v2_design(id) on delete cascade,
  token_id uuid not null references public.live_access_tokens_v2_design(id) on delete cascade,
  primary key (question_id, token_id)
);

-- Ballot ledger: contains choice, but no user/token/credential foreign key.
-- No exact submitted_at is required for organizer reporting.
create table if not exists public.live_ballots_v2_design (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.live_questions_v2_design(id) on delete cascade,
  option_ids uuid[] not null,
  receipt_hash text not null unique
);

alter table public.live_sessions_v2_design enable row level security;
alter table public.live_questions_v2_design enable row level security;
alter table public.live_options_v2_design enable row level security;
alter table public.live_access_tokens_v2_design enable row level security;
alter table public.live_token_question_uses_v2_design enable row level security;
alter table public.live_ballots_v2_design enable row level security;

comment on table public.live_ballots_v2_design is
'DESIGN ONLY. No direct token/user reference. Atomic server function must insert token-use + ballot.';

rollback;
