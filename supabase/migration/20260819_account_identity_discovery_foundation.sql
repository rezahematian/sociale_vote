-- SOCIAL VOTE
-- Account identity, account follow and account discovery foundation — V2.
-- 2026-08-19
--
-- Deliberate boundaries:
-- - account follow is independent from geographic scope follow;
-- - account discovery is global and never changes GeoScopeController;
-- - verification evidence files are not collected by this migration;
-- - follower graphs remain private, while aggregate counts are public;
-- - legacy verification history is preserved without weakening new requests.

begin;

-- ============================================================
-- 1. PROTECT PUBLIC IDENTITY FROM SELF-EDIT
-- ============================================================

create or replace function public.protect_user_profile_identity_fields()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_staff_role text := lower(
    coalesce((select auth.jwt() -> 'app_metadata' ->> 'role'), '')
  );
begin
  if tg_op = 'INSERT' then
    if
      current_user not in ('postgres', 'supabase_admin', 'service_role')
      and v_staff_role not in ('moderator', 'admin')
      and not (
        new.actor_type is not distinct from 'citizen'
        and new.verification_level is not distinct from 'none'
        and new.institution_level is null
        and new.verification_status is not distinct from 'none'
        and new.verification_requested_at is null
        and new.verified_at is null
        and new.official_title is null
        and new.institution_name is null
        and new.organization_name is null
        and new.account_type is not distinct from 'citizen'
        and new.is_verified is false
      )
    then
      raise exception
        using
          errcode = '42501',
          message = 'A new profile must use the default public identity.';
    end if;

    return new;
  end if;

  if
    new.actor_type is distinct from old.actor_type
    or new.verification_level is distinct from old.verification_level
    or new.institution_level is distinct from old.institution_level
    or new.verification_status is distinct from old.verification_status
    or new.verification_requested_at
       is distinct from old.verification_requested_at
    or new.verified_at is distinct from old.verified_at
    or new.official_title is distinct from old.official_title
    or new.institution_name is distinct from old.institution_name
    or new.organization_name is distinct from old.organization_name
    or new.account_type is distinct from old.account_type
    or new.is_verified is distinct from old.is_verified
  then
    if
      current_user not in ('postgres', 'supabase_admin', 'service_role')
      and v_staff_role not in ('moderator', 'admin')
    then
      raise exception
        using
          errcode = '42501',
          message = 'Public identity fields cannot be changed directly.';
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists protect_user_profile_identity_fields_trigger
on public.user_profiles;

create trigger protect_user_profile_identity_fields_trigger
before insert or update on public.user_profiles
for each row
execute function public.protect_user_profile_identity_fields();

comment on function public.protect_user_profile_identity_fields() is
  'Prevents ordinary users from self-assigning a verified public identity.';

revoke all
on function public.protect_user_profile_identity_fields()
from public, anon, authenticated;

-- Every new or modified request must describe exactly one supported identity.
alter table public.verification_requests
  drop constraint if exists verification_requests_shape_check;

alter table public.verification_requests
  add constraint verification_requests_shape_check
  check (
    status not in ('pending', 'approved')
    or coalesce(
      (
        request_type = 'citizen_level1'
        and target_actor_type = 'citizen'
        and target_verification_level = 'level1'
        and target_institution_level is null
        and official_title is null
        and institution_name is null
        and organization_name is null
      )
      or
      (
        request_type = 'citizen_level2'
        and target_actor_type = 'citizen'
        and target_verification_level = 'level2'
        and target_institution_level is null
        and official_title is null
        and institution_name is null
        and organization_name is null
      )
      or
      (
        request_type = 'public_official'
        and target_actor_type = 'public_official'
        and target_verification_level = 'none'
        and target_institution_level is null
        and nullif(btrim(official_title), '') is not null
        and institution_name is null
        and organization_name is null
      )
      or
      (
        request_type = 'institution'
        and target_actor_type = 'institution'
        and target_verification_level = 'none'
        and target_institution_level is not null
        and official_title is null
        and nullif(btrim(institution_name), '') is not null
        and organization_name is null
        and voting_country_code is null
      )
      or
      (
        request_type = 'organization'
        and target_actor_type = 'organization'
        and target_verification_level = 'none'
        and target_institution_level is null
        and official_title is null
        and institution_name is null
        and nullif(btrim(organization_name), '') is not null
        and voting_country_code is null
      ),
      false
    )
  ) not valid;

-- Atomic reviewer operation. The request decision and the profile identity
-- update either both commit or both roll back.
create or replace function public.review_verification_request_secure(
  p_request_id uuid,
  p_status text,
  p_review_note text default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_reviewer_id uuid := (select auth.uid());
  v_reviewer_role text := lower(
    coalesce((select auth.jwt() -> 'app_metadata' ->> 'role'), '')
  );
  v_status text := lower(btrim(coalesce(p_status, '')));
  v_note text := nullif(btrim(coalesce(p_review_note, '')), '');
  v_request public.verification_requests%rowtype;
  v_reviewed_at timestamptz := now();
  v_shape_valid boolean := false;
begin
  if
    v_reviewer_id is null
    or v_reviewer_role not in ('moderator', 'admin')
    or not (select public.is_current_auth_user_active())
  then
    raise exception
      using errcode = '42501', message = 'Reviewer access is required.';
  end if;

  if p_request_id is null then
    raise exception
      using errcode = '22004', message = 'A request id is required.';
  end if;

  if v_status not in ('approved', 'rejected') then
    raise exception
      using errcode = '22023', message = 'Invalid review status.';
  end if;

  if v_status = 'rejected' and v_note is null then
    raise exception
      using errcode = '22023', message = 'A rejection note is required.';
  end if;

  if v_note is not null and char_length(v_note) > 1000 then
    raise exception
      using errcode = '22023', message = 'Review note is too long.';
  end if;

  select vr.*
  into v_request
  from public.verification_requests vr
  where vr.id = p_request_id
  for update;

  if not found then
    raise exception
      using errcode = 'P0002', message = 'Verification request not found.';
  end if;

  if v_request.status <> 'pending' then
    raise exception
      using errcode = '55000', message = 'Verification request is not pending.';
  end if;

  -- Legacy final records are preserved by the NOT VALID constraint. A legacy
  -- pending request, however, must never be approved unless its full shape is
  -- coherent with the requested identity.
  v_shape_valid := coalesce(
    (
      v_request.request_type = 'citizen_level1'
      and v_request.target_actor_type = 'citizen'
      and v_request.target_verification_level = 'level1'
      and v_request.target_institution_level is null
      and v_request.official_title is null
      and v_request.institution_name is null
      and v_request.organization_name is null
    )
    or
    (
      v_request.request_type = 'citizen_level2'
      and v_request.target_actor_type = 'citizen'
      and v_request.target_verification_level = 'level2'
      and v_request.target_institution_level is null
      and v_request.official_title is null
      and v_request.institution_name is null
      and v_request.organization_name is null
    )
    or
    (
      v_request.request_type = 'public_official'
      and v_request.target_actor_type = 'public_official'
      and v_request.target_verification_level = 'none'
      and v_request.target_institution_level is null
      and nullif(btrim(v_request.official_title), '') is not null
      and v_request.institution_name is null
      and v_request.organization_name is null
    )
    or
    (
      v_request.request_type = 'institution'
      and v_request.target_actor_type = 'institution'
      and v_request.target_verification_level = 'none'
      and v_request.target_institution_level is not null
      and v_request.official_title is null
      and nullif(btrim(v_request.institution_name), '') is not null
      and v_request.organization_name is null
      and v_request.voting_country_code is null
    )
    or
    (
      v_request.request_type = 'organization'
      and v_request.target_actor_type = 'organization'
      and v_request.target_verification_level = 'none'
      and v_request.target_institution_level is null
      and v_request.official_title is null
      and v_request.institution_name is null
      and nullif(btrim(v_request.organization_name), '') is not null
      and v_request.voting_country_code is null
    ),
    false
  );

  if v_status = 'approved' and not v_shape_valid then
    raise exception
      using
        errcode = '22023',
        message = 'Legacy verification request shape is not approvable.';
  end if;

  perform 1
  from public.user_profiles up
  where up.id = v_request.user_id
  for update;

  if not found then
    raise exception
      using errcode = 'P0002', message = 'User profile not found.';
  end if;

  if
    v_status = 'approved'
    and v_request.target_actor_type in ('citizen', 'public_official')
    and v_request.voting_country_code is null
  then
    raise exception
      using
        errcode = '22023',
        message = 'A verified voting country is required for this identity.';
  end if;

  update public.verification_requests
  set
    status = v_status,
    reviewed_by = v_reviewer_id,
    reviewed_at = v_reviewed_at,
    review_note = v_note,
    updated_at = v_reviewed_at
  where id = v_request.id
  returning * into v_request;

  if v_status = 'approved' then
    update public.user_profiles
    set
      actor_type = v_request.target_actor_type,
      account_type = v_request.target_actor_type,
      verification_level = v_request.target_verification_level,
      verification_status = 'none',
      institution_level = case
        when v_request.target_actor_type = 'institution'
          then v_request.target_institution_level
        else null
      end,
      official_title = case
        when v_request.target_actor_type = 'public_official'
          then v_request.official_title
        else null
      end,
      institution_name = case
        when v_request.target_actor_type = 'institution'
          then v_request.institution_name
        else null
      end,
      organization_name = case
        when v_request.target_actor_type = 'organization'
          then v_request.organization_name
        else null
      end,
      verification_requested_at = v_request.submitted_at,
      verified_at = v_reviewed_at,
      voting_country_code = case
        when v_request.target_actor_type in ('citizen', 'public_official')
          then v_request.voting_country_code
        else null
      end,
      voting_country_verified_at = case
        when v_request.target_actor_type in ('citizen', 'public_official')
          then v_reviewed_at
        else null
      end,
      is_verified = true,
      updated_at = v_reviewed_at
    where id = v_request.user_id;
  else
    update public.user_profiles
    set
      verification_status = 'rejected',
      verification_requested_at = v_request.submitted_at,
      updated_at = v_reviewed_at
    where id = v_request.user_id;
  end if;

  return to_jsonb(v_request);
end;
$$;

revoke all
on function public.review_verification_request_secure(uuid, text, text)
from public, anon;

grant execute
on function public.review_verification_request_secure(uuid, text, text)
to authenticated;

-- ============================================================
-- 2. ACCOUNT FOLLOW — PRIVATE GRAPH, PUBLIC COUNTS
-- ============================================================

create table if not exists public.account_follows (
  follower_user_id uuid not null
    references auth.users(id) on delete cascade,
  followed_user_id uuid not null
    references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),

  constraint account_follows_pkey
    primary key (follower_user_id, followed_user_id),

  constraint account_follows_no_self
    check (follower_user_id <> followed_user_id)
);

create index if not exists account_follows_followed_created_idx
  on public.account_follows (followed_user_id, created_at desc);

create index if not exists account_follows_follower_created_idx
  on public.account_follows (follower_user_id, created_at desc);

alter table public.account_follows enable row level security;

-- The block table was introduced after the single-session migration. Bring
-- its owner policies under the same current-session rule now.
drop policy if exists "blocked_users_select_own" on public.blocked_users;
create policy "blocked_users_select_own"
on public.blocked_users
for select
to authenticated
using (
  blocker_user_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
);

drop policy if exists "blocked_users_insert_own" on public.blocked_users;
create policy "blocked_users_insert_own"
on public.blocked_users
for insert
to authenticated
with check (
  blocker_user_id = (select auth.uid())
  and blocked_user_id <> (select auth.uid())
  and (select public.is_current_auth_user_active())
);

drop policy if exists "blocked_users_delete_own" on public.blocked_users;
create policy "blocked_users_delete_own"
on public.blocked_users
for delete
to authenticated
using (
  blocker_user_id = (select auth.uid())
  and (select public.is_current_auth_user_active())
);

revoke all on table public.account_follows from anon, authenticated;
grant select on table public.account_follows to authenticated;

drop policy if exists account_follows_select_involved
on public.account_follows;

create policy account_follows_select_involved
on public.account_follows
for select
to authenticated
using (
  (
    follower_user_id = (select auth.uid())
    or followed_user_id = (select auth.uid())
  )
  and (select public.is_current_auth_user_active())
);

create or replace function public.get_account_follow_state(
  p_target_user_id uuid
)
returns table (
  is_following boolean,
  follower_count bigint,
  following_count bigint,
  can_follow boolean
)
language sql
stable
security definer
set search_path = ''
as $$
  select
    case
      when (select auth.uid()) is null then false
      else exists (
        select 1
        from public.account_follows af
        where af.follower_user_id = (select auth.uid())
          and af.followed_user_id = p_target_user_id
      )
    end as is_following,
    (
      select count(*)
      from public.account_follows af
      where af.followed_user_id = p_target_user_id
    ) as follower_count,
    (
      select count(*)
      from public.account_follows af
      where af.follower_user_id = p_target_user_id
    ) as following_count,
    (
      (select auth.uid()) is not null
      and (select auth.uid()) <> p_target_user_id
      and (select public.is_current_auth_user_active())
      and exists (
        select 1
        from public.user_profiles up
        where up.id = p_target_user_id
      )
      and not exists (
        select 1
        from public.blocked_users bu
        where
          (
            bu.blocker_user_id = (select auth.uid())
            and bu.blocked_user_id = p_target_user_id
          )
          or
          (
            bu.blocker_user_id = p_target_user_id
            and bu.blocked_user_id = (select auth.uid())
          )
      )
    ) as can_follow;
$$;

revoke all
on function public.get_account_follow_state(uuid)
from public;

grant execute
on function public.get_account_follow_state(uuid)
to anon, authenticated;

create or replace function public.toggle_account_follow(
  p_target_user_id uuid
)
returns table (
  is_following boolean,
  follower_count bigint,
  following_count bigint,
  can_follow boolean
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := (select auth.uid());
begin
  if
    v_user_id is null
    or not (select public.is_current_auth_user_active())
  then
    raise exception
      using errcode = '42501', message = 'Authentication is required.';
  end if;

  if p_target_user_id is null or p_target_user_id = v_user_id then
    raise exception
      using errcode = '22023', message = 'Invalid followed account.';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(
      v_user_id::text || ':' || p_target_user_id::text,
      0
    )
  );

  if exists (
    select 1
    from public.account_follows af
    where af.follower_user_id = v_user_id
      and af.followed_user_id = p_target_user_id
  ) then
    delete from public.account_follows af
    where af.follower_user_id = v_user_id
      and af.followed_user_id = p_target_user_id;
  else
    if not exists (
      select 1
      from public.user_profiles up
      where up.id = p_target_user_id
    ) then
      raise exception
        using errcode = 'P0002', message = 'Followed account not found.';
    end if;

    if exists (
      select 1
      from public.blocked_users bu
      where
        (
          bu.blocker_user_id = v_user_id
          and bu.blocked_user_id = p_target_user_id
        )
        or
        (
          bu.blocker_user_id = p_target_user_id
          and bu.blocked_user_id = v_user_id
        )
    ) then
      raise exception
        using errcode = '42501', message = 'Follow is unavailable.';
    end if;

    insert into public.account_follows (
      follower_user_id,
      followed_user_id
    )
    values (
      v_user_id,
      p_target_user_id
    );
  end if;

  return query
  select *
  from public.get_account_follow_state(p_target_user_id);
end;
$$;

revoke all
on function public.toggle_account_follow(uuid)
from public, anon;

grant execute
on function public.toggle_account_follow(uuid)
to authenticated;

create or replace function public.get_my_followed_account_ids()
returns table (user_id uuid)
language sql
stable
security invoker
set search_path = ''
as $$
  select af.followed_user_id
  from public.account_follows af
  where af.follower_user_id = (select auth.uid())
  order by af.created_at desc, af.followed_user_id;
$$;

revoke all
on function public.get_my_followed_account_ids()
from public, anon;

grant execute
on function public.get_my_followed_account_ids()
to authenticated;

-- A new block immediately removes follows in both directions.
create or replace function public.remove_account_follows_after_block()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from public.account_follows af
  where
    (
      af.follower_user_id = new.blocker_user_id
      and af.followed_user_id = new.blocked_user_id
    )
    or
    (
      af.follower_user_id = new.blocked_user_id
      and af.followed_user_id = new.blocker_user_id
    );

  return new;
end;
$$;

drop trigger if exists remove_account_follows_after_block_trigger
on public.blocked_users;

create trigger remove_account_follows_after_block_trigger
after insert on public.blocked_users
for each row
execute function public.remove_account_follows_after_block();

revoke all
on function public.remove_account_follows_after_block()
from public, anon, authenticated;

-- ============================================================
-- 3. GLOBAL ACCOUNT DISCOVERY
-- ============================================================

create or replace function public.search_public_accounts(
  p_query text,
  p_limit integer default 20,
  p_offset integer default 0
)
returns table (
  user_id uuid,
  display_name text,
  username text,
  avatar_url text,
  bio text,
  country text,
  city text,
  actor_type text,
  verification_level text,
  institution_level text,
  official_title text,
  institution_name text,
  organization_name text,
  created_at timestamptz,
  updated_at timestamptz,
  follower_count bigint,
  is_following boolean
)
language sql
stable
security definer
set search_path = ''
as $$
  with input as (
    select
      lower(btrim(coalesce(p_query, ''))) as query,
      least(greatest(coalesce(p_limit, 20), 1), 30) as row_limit,
      greatest(coalesce(p_offset, 0), 0) as row_offset,
      (select auth.uid()) as viewer_id
  ),
  candidates as (
    select
      up.*,
      i.query,
      i.viewer_id,
      (
        select count(*)
        from public.account_follows af
        where af.followed_user_id = up.id
      ) as followers
    from public.user_profiles up
    cross join input i
    where char_length(i.query) >= 2
      and (i.viewer_id is null or up.id <> i.viewer_id)
      and (
        lower(coalesce(up.display_name, '')) like '%' || i.query || '%'
        or lower(coalesce(up.username, '')) like '%' || i.query || '%'
        or lower(coalesce(up.official_title, '')) like '%' || i.query || '%'
        or lower(coalesce(up.institution_name, '')) like '%' || i.query || '%'
        or lower(coalesce(up.organization_name, '')) like '%' || i.query || '%'
      )
      and not exists (
        select 1
        from public.blocked_users bu
        where i.viewer_id is not null
          and (
            (
              bu.blocker_user_id = i.viewer_id
              and bu.blocked_user_id = up.id
            )
            or
            (
              bu.blocker_user_id = up.id
              and bu.blocked_user_id = i.viewer_id
            )
          )
      )
  )
  select
    c.id,
    c.display_name::text,
    c.username::text,
    c.avatar_url::text,
    c.bio::text,
    c.country::text,
    c.city::text,
    c.actor_type::text,
    c.verification_level::text,
    c.institution_level::text,
    c.official_title::text,
    c.institution_name::text,
    c.organization_name::text,
    c.created_at,
    c.updated_at,
    c.followers,
    case
      when c.viewer_id is null then false
      else exists (
        select 1
        from public.account_follows af
        where af.follower_user_id = c.viewer_id
          and af.followed_user_id = c.id
      )
    end
  from candidates c
  cross join input i
  order by
    case when lower(coalesce(c.username, '')) = i.query then 0 else 1 end,
    case when lower(coalesce(c.username, '')) like i.query || '%' then 0 else 1 end,
    case when lower(coalesce(c.display_name, '')) = i.query then 0 else 1 end,
    c.followers desc,
    c.created_at desc,
    c.id
  limit (select row_limit from input)
  offset (select row_offset from input);
$$;

revoke all
on function public.search_public_accounts(text, integer, integer)
from public;

grant execute
on function public.search_public_accounts(text, integer, integer)
to anon, authenticated;

comment on table public.account_follows is
  'Private account-to-account follow graph, separate from geographic follows.';

comment on function public.search_public_accounts(text, integer, integer) is
  'Global account discovery. Verification is returned as an explicit label, not used as a hidden ranking privilege.';

commit;

select
  'ACCOUNT IDENTITY DISCOVERY FOUNDATION APPLIED V2' as result,
  to_regclass('public.account_follows') is not null
    as account_follows_table,
  (
    select c.relrowsecurity
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relname = 'account_follows'
  ) as rls_enabled,
  to_regprocedure(
    'public.review_verification_request_secure(uuid,text,text)'
  ) is not null as secure_identity_review,
  to_regprocedure(
    'public.search_public_accounts(text,integer,integer)'
  ) is not null as account_discovery,
  to_regprocedure('public.toggle_account_follow(uuid)') is not null
    as account_follow,
  exists (
    select 1
    from pg_constraint con
    join pg_class c on c.oid = con.conrelid
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relname = 'verification_requests'
      and con.conname = 'verification_requests_shape_check'
  ) as verification_shape_guard;
