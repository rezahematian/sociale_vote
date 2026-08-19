-- SOCIAL VOTE
-- Account follow management lists
-- 2026-08-19
--
-- Extends the already-applied Account / Identity / Discovery V2 foundation.
-- The account graph remains private: an authenticated user can only list
-- their own Following and Followers connections.

begin;

create or replace function public.list_my_account_connections(
  p_direction text,
  p_limit integer default 50,
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
  is_following boolean,
  relationship_created_at timestamptz
)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_direction text := lower(btrim(coalesce(p_direction, '')));
  v_limit integer := least(greatest(coalesce(p_limit, 50), 1), 100);
  v_offset integer := greatest(coalesce(p_offset, 0), 0);
begin
  if
    v_user_id is null
    or not (select public.is_current_auth_user_active())
  then
    raise exception
      using errcode = '42501', message = 'Authentication is required.';
  end if;

  if v_direction not in ('following', 'followers') then
    raise exception
      using errcode = '22023', message = 'Invalid connection direction.';
  end if;

  return query
  select
    up.id,
    up.display_name::text,
    up.username::text,
    up.avatar_url::text,
    up.bio::text,
    up.country::text,
    up.city::text,
    up.actor_type::text,
    up.verification_level::text,
    up.institution_level::text,
    up.official_title::text,
    up.institution_name::text,
    up.organization_name::text,
    up.created_at,
    up.updated_at,
    (
      select count(*)
      from public.account_follows follower_count_rows
      where follower_count_rows.followed_user_id = up.id
    ) as follower_count,
    exists (
      select 1
      from public.account_follows viewer_follow
      where viewer_follow.follower_user_id = v_user_id
        and viewer_follow.followed_user_id = up.id
    ) as is_following,
    af.created_at as relationship_created_at
  from public.account_follows af
  join public.user_profiles up
    on up.id = case
      when v_direction = 'following' then af.followed_user_id
      else af.follower_user_id
    end
  where
    (
      v_direction = 'following'
      and af.follower_user_id = v_user_id
    )
    or
    (
      v_direction = 'followers'
      and af.followed_user_id = v_user_id
    )
  order by af.created_at desc, up.id
  limit v_limit
  offset v_offset;
end;
$$;

revoke all
on function public.list_my_account_connections(text, integer, integer)
from public, anon;

grant execute
on function public.list_my_account_connections(text, integer, integer)
to authenticated;

comment on function public.list_my_account_connections(text, integer, integer)
is 'Lists only the authenticated user own Following or Followers accounts. The account graph remains private.';

commit;

select
  'ACCOUNT FOLLOW MANAGEMENT APPLIED' as result,
  to_regprocedure(
    'public.list_my_account_connections(text,integer,integer)'
  ) is not null as connection_list_ready,
  has_function_privilege(
    'authenticated',
    'public.list_my_account_connections(text,integer,integer)',
    'EXECUTE'
  ) as authenticated_execute,
  not has_function_privilege(
    'anon',
    'public.list_my_account_connections(text,integer,integer)',
    'EXECUTE'
  ) as anon_blocked;
