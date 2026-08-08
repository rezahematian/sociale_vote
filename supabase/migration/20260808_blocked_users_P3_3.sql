-- P3.3 — Block user
-- Minimal owner-only block relation with RLS.
-- A user may block another authenticated user, but never themselves.

create table if not exists public.blocked_users (
  blocker_user_id uuid not null
    references auth.users(id) on delete cascade,
  blocked_user_id uuid not null
    references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),

  constraint blocked_users_pkey
    primary key (blocker_user_id, blocked_user_id),

  constraint blocked_users_no_self_block
    check (blocker_user_id <> blocked_user_id)
);

create index if not exists blocked_users_blocked_user_id_idx
  on public.blocked_users (blocked_user_id);

alter table public.blocked_users enable row level security;

drop policy if exists "blocked_users_select_own" on public.blocked_users;
create policy "blocked_users_select_own"
on public.blocked_users
for select
to authenticated
using (blocker_user_id = auth.uid());

drop policy if exists "blocked_users_insert_own" on public.blocked_users;
create policy "blocked_users_insert_own"
on public.blocked_users
for insert
to authenticated
with check (
  blocker_user_id = auth.uid()
  and blocked_user_id <> auth.uid()
);

drop policy if exists "blocked_users_delete_own" on public.blocked_users;
create policy "blocked_users_delete_own"
on public.blocked_users
for delete
to authenticated
using (blocker_user_id = auth.uid());
