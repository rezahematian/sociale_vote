-- Social Vote
-- Single active session per account + deleted-account hardening
-- Applied and runtime-verified on 2026-07-29.
--
-- Rule:
-- - only the most recently created Supabase Auth session may perform
--   authenticated reads/writes covered by the policies below;
-- - sessions belonging to deleted Auth users are rejected;
-- - public content remains publicly readable where already intended.

begin;

-- ============================================================
-- PRIVATE ACTIVE-SESSION REGISTRY
-- ============================================================

create schema if not exists app_private;

revoke all on schema app_private from public;
revoke all on schema app_private from anon;
revoke all on schema app_private from authenticated;

create table if not exists app_private.active_user_sessions (
  user_id uuid primary key,
  session_id uuid not null,
  activated_at timestamptz not null default now()
);

alter table app_private.active_user_sessions
enable row level security;

revoke all
on table app_private.active_user_sessions
from public, anon, authenticated;

-- Backfill the most recent currently known session for each user.
insert into app_private.active_user_sessions (
  user_id,
  session_id,
  activated_at
)
select distinct on (s.user_id)
  s.user_id,
  s.id,
  coalesce(s.created_at, now())
from auth.sessions s
order by
  s.user_id,
  s.created_at desc nulls last,
  s.id desc
on conflict (user_id) do update
set
  session_id = excluded.session_id,
  activated_at = excluded.activated_at;

-- Every newly created Auth session becomes the only active session.
create or replace function app_private.capture_latest_auth_session()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into app_private.active_user_sessions (
    user_id,
    session_id,
    activated_at
  )
  values (
    new.user_id,
    new.id,
    coalesce(new.created_at, now())
  )
  on conflict (user_id) do update
  set
    session_id = excluded.session_id,
    activated_at = excluded.activated_at;

  return new;
end;
$$;

revoke all
on function app_private.capture_latest_auth_session()
from public, anon, authenticated;

drop trigger if exists
  social_vote_capture_latest_session
on auth.sessions;

create trigger social_vote_capture_latest_session
after insert on auth.sessions
for each row
execute function app_private.capture_latest_auth_session();

-- Central RLS helper:
-- 1. JWT user exists;
-- 2. Auth user still exists;
-- 3. JWT session_id matches the latest authorized session;
-- 4. matching Auth session still exists.
create or replace function public.is_current_auth_user_active()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select
    (select auth.uid()) is not null
    and exists (
      select 1
      from auth.users au
      where au.id = (select auth.uid())
    )
    and exists (
      select 1
      from app_private.active_user_sessions aus
      join auth.sessions s
        on s.id = aus.session_id
       and s.user_id = aus.user_id
      where aus.user_id = (select auth.uid())
        and aus.session_id =
          nullif(
            (select auth.jwt() ->> 'session_id'),
            ''
          )::uuid
    );
$$;

revoke all
on function public.is_current_auth_user_active()
from public, anon;

grant execute
on function public.is_current_auth_user_active()
to authenticated;

-- ============================================================
-- COMMENTS
-- ============================================================

alter policy comments_insert_own
on public.comments
to authenticated
with check (
  (select auth.uid()) is not null
  and author_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
);

alter policy comments_update_own
on public.comments
to authenticated
using (
  author_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
)
with check (
  author_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
);

alter policy comments_delete_own
on public.comments
to authenticated
using (
  author_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
);

-- ============================================================
-- POSTS
-- ============================================================

alter policy posts_insert_own
on public.posts
to authenticated
with check (
  (select auth.uid()) is not null
  and author_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
);

alter policy posts_update_own
on public.posts
to authenticated
using (
  author_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
)
with check (
  author_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
);

alter policy posts_delete_own
on public.posts
to authenticated
using (
  author_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
);

-- ============================================================
-- VOTES
-- ============================================================

alter policy votes_read_own
on public.votes
to authenticated
using (
  (select auth.uid()) is not null
  and user_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
);

alter policy votes_insert_own
on public.votes
to authenticated
with check (
  (select auth.uid()) is not null
  and user_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
);

alter policy votes_update_own
on public.votes
to authenticated
using (
  user_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
)
with check (
  user_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
);

alter policy votes_delete_own
on public.votes
to authenticated
using (
  user_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
);

-- ============================================================
-- REACTIONS
-- ============================================================

alter policy reactions_insert_own
on public.reactions
to authenticated
with check (
  (select auth.uid()) is not null
  and user_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
);

alter policy reactions_update_own
on public.reactions
to authenticated
using (
  user_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
)
with check (
  user_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
);

alter policy reactions_delete_own
on public.reactions
to authenticated
using (
  user_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
);

-- ============================================================
-- FAVORITES
-- ============================================================

drop policy if exists "users delete own favorites"
on public.favorites;

drop policy if exists "users insert own favorites"
on public.favorites;

drop policy if exists "users read own favorites"
on public.favorites;

alter policy "Favorites select own"
on public.favorites
to authenticated
using (
  (select auth.uid()) is not null
  and user_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
);

alter policy "Favorites insert own"
on public.favorites
to authenticated
with check (
  (select auth.uid()) is not null
  and user_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
);

alter policy "Favorites delete own"
on public.favorites
to authenticated
using (
  (select auth.uid()) is not null
  and user_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
);

-- ============================================================
-- USER PROFILES
-- ============================================================

alter policy "users create own profile"
on public.user_profiles
to authenticated
with check (
  (select auth.uid()) is not null
  and id = (select auth.uid())
  and (select public.is_current_auth_user_active())
);

alter policy "users update own profile"
on public.user_profiles
to authenticated
using (
  id = (select auth.uid())
  and (select public.is_current_auth_user_active())
)
with check (
  id = (select auth.uid())
  and (select public.is_current_auth_user_active())
);

alter policy user_profiles_update_for_reviewer
on public.user_profiles
to authenticated
using (
  coalesce(
    (select auth.jwt() -> 'app_metadata' ->> 'role'),
    ''
  ) = any (array['moderator', 'admin'])
  and (select public.is_current_auth_user_active())
)
with check (
  coalesce(
    (select auth.jwt() -> 'app_metadata' ->> 'role'),
    ''
  ) = any (array['moderator', 'admin'])
  and (select public.is_current_auth_user_active())
);

-- ============================================================
-- POLLS
-- ============================================================

alter policy "polls authenticated insert"
on public.polls
to authenticated
with check (
  (select auth.uid()) is not null
  and author_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
);

alter policy "polls author update"
on public.polls
to authenticated
using (
  author_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
)
with check (
  author_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
);

alter policy "polls author delete"
on public.polls
to authenticated
using (
  author_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
);

-- ============================================================
-- NOTIFICATIONS
-- ============================================================

alter policy notifications_insert_policy
on public.notifications
to authenticated
with check (
  actor_user_id = (select auth.uid())
  and type = any (
    array[
      'comment_reply'::text,
      'mention'::text,
      'poll_result'::text
    ]
  )
  and (select public.is_current_auth_user_active())
);

alter policy notifications_select_policy
on public.notifications
to authenticated
using (
  (
    recipient_user_id = (select auth.uid())
    or actor_user_id = (select auth.uid())
  )
  and (select public.is_current_auth_user_active())
);

alter policy notifications_update_policy
on public.notifications
to authenticated
using (
  recipient_user_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
)
with check (
  recipient_user_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
);

-- ============================================================
-- PUBLIC USERS MIRROR
-- ============================================================

drop policy if exists "users authenticated insert own profile"
on public.users;

alter policy "users authenticated upsert"
on public.users
to authenticated
with check (
  (select auth.uid()) is not null
  and id = (select auth.uid())
  and (select public.is_current_auth_user_active())
);

alter policy "users authenticated update own profile"
on public.users
to authenticated
using (
  id = (select auth.uid())
  and (select public.is_current_auth_user_active())
)
with check (
  id = (select auth.uid())
  and (select public.is_current_auth_user_active())
);

-- ============================================================
-- REPORTS
-- ============================================================

alter policy users_can_insert_reports
on public.reports
to authenticated
with check (
  (select auth.uid()) is not null
  and user_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
);

alter policy users_can_view_own_reports
on public.reports
to authenticated
using (
  user_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
);

-- ============================================================
-- VERIFICATION REQUESTS
-- ============================================================

alter policy verification_requests_insert_own
on public.verification_requests
to authenticated
with check (
  user_id = (select auth.uid())
  and status = 'pending'
  and reviewed_at is null
  and reviewed_by is null
  and (select public.is_current_auth_user_active())
);

alter policy verification_requests_select_own
on public.verification_requests
to authenticated
using (
  user_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
);

alter policy verification_requests_update_own_pending_cancel
on public.verification_requests
to authenticated
using (
  user_id = (select auth.uid())
  and status = 'pending'
  and (select public.is_current_auth_user_active())
)
with check (
  user_id = (select auth.uid())
  and status = 'cancelled'
  and reviewed_by is null
  and reviewed_at is null
  and review_note is null
  and (select public.is_current_auth_user_active())
);

alter policy verification_requests_select_for_reviewer
on public.verification_requests
to authenticated
using (
  coalesce(
    (select auth.jwt() -> 'app_metadata' ->> 'role'),
    ''
  ) = any (array['moderator', 'admin'])
  and (
    status = 'pending'
    or reviewed_by = (select auth.uid())
  )
  and (select public.is_current_auth_user_active())
);

alter policy verification_requests_select_pending_for_reviewer
on public.verification_requests
to authenticated
using (
  coalesce(
    (select auth.jwt() -> 'app_metadata' ->> 'role'),
    ''
  ) = any (array['moderator', 'admin'])
  and status = 'pending'
  and (select public.is_current_auth_user_active())
);

alter policy verification_requests_update_pending_for_reviewer
on public.verification_requests
to authenticated
using (
  coalesce(
    (select auth.jwt() -> 'app_metadata' ->> 'role'),
    ''
  ) = any (array['moderator', 'admin'])
  and status = 'pending'
  and (select public.is_current_auth_user_active())
)
with check (
  coalesce(
    (select auth.jwt() -> 'app_metadata' ->> 'role'),
    ''
  ) = any (array['moderator', 'admin'])
  and status = any (array['approved', 'rejected'])
  and reviewed_by = (select auth.uid())
  and reviewed_at is not null
  and (select public.is_current_auth_user_active())
);

-- Intentionally unchanged:
-- verification_requests_delete_none_for_users uses USING (false).

-- ============================================================
-- NEWS CACHE PRIVILEGE REDUCTION
-- ============================================================

-- The Flutter app still performs SELECT/INSERT/UPDATE on this cache.
-- Remove only privileges that are not needed by the current pipeline.
revoke delete, truncate, references, trigger
on table public.news_feed_cache
from anon, authenticated;

commit;
