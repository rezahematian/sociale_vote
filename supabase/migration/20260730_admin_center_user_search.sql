-- Social Vote
-- Admin Center: backend-only paginated user search.
--
-- Security rules:
-- - this function is callable only with the service role;
-- - the Edge Function must authorize the current moderator/admin first;
-- - email is returned only when p_include_email is true;
-- - no token, password, identity document or private verification payload is
--   exposed;
-- - deleted Auth accounts are not returned.

begin;

create or replace function public.admin_search_users(
  p_query text default null,
  p_page integer default 1,
  p_per_page integer default 25,
  p_include_email boolean default false
)
returns table (
  user_id uuid,
  email text,
  display_name text,
  username text,
  avatar_url text,
  system_role text,
  mirror_role text,
  role_synchronized boolean,
  actor_type text,
  verification_level text,
  verification_status text,
  account_status text,
  suspended_until timestamptz,
  created_at timestamptz,
  total_count bigint
)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_query text := nullif(lower(btrim(p_query)), '');
  v_username_query text;
  v_offset integer;
begin
  if coalesce((select auth.role()), '') <> 'service_role' then
    raise exception
      using
        errcode = '42501',
        message = 'Service role access is required.';
  end if;

  if p_page is null or p_page < 1 or p_page > 100000 then
    raise exception
      using
        errcode = '22023',
        message = 'Page must be between 1 and 100000.';
  end if;

  if p_per_page is null or p_per_page < 1 or p_per_page > 50 then
    raise exception
      using
        errcode = '22023',
        message = 'Per-page must be between 1 and 50.';
  end if;

  if v_query is not null and char_length(v_query) > 320 then
    raise exception
      using
        errcode = '22023',
        message = 'Search query is too long.';
  end if;

  v_username_query := nullif(regexp_replace(v_query, '^@+', ''), '');
  v_offset := (p_page - 1) * p_per_page;

  return query
  with matched_users as (
    select
      au.id,
      case
        when p_include_email then au.email::text
        else null::text
      end as visible_email,
      coalesce(
        nullif(btrim(up.display_name), ''),
        nullif(btrim(pu.display_name), '')
      )::text as visible_display_name,
      nullif(btrim(up.username), '')::text as visible_username,
      nullif(btrim(up.avatar_url), '')::text as visible_avatar_url,
      case
        when lower(coalesce(au.raw_app_meta_data ->> 'role', '')) in (
          'user',
          'moderator',
          'admin'
        )
          then lower(au.raw_app_meta_data ->> 'role')
        else 'user'
      end::text as auth_system_role,
      case
        when lower(coalesce(pu.role, '')) in (
          'user',
          'moderator',
          'admin'
        )
          then lower(pu.role)
        else 'user'
      end::text as public_mirror_role,
      coalesce(nullif(btrim(up.actor_type), ''), 'citizen')::text
        as public_actor_type,
      coalesce(nullif(btrim(up.verification_level), ''), 'none')::text
        as public_verification_level,
      coalesce(nullif(btrim(up.verification_status), ''), 'none')::text
        as public_verification_status,
      case
        when ac.status = 'suspended'
          and ac.suspended_until is not null
          and ac.suspended_until <= now()
          then 'active'
        else coalesce(ac.status, 'active')
      end::text as effective_account_status,
      case
        when ac.status = 'suspended'
          and ac.suspended_until is not null
          and ac.suspended_until > now()
          then ac.suspended_until
        else null::timestamptz
      end as effective_suspended_until,
      coalesce(up.created_at, au.created_at) as effective_created_at,
      case
        when v_query is not null and au.id::text = v_query then 0
        when v_username_query is not null
          and lower(coalesce(up.username, '')) = v_username_query
          then 1
        when p_include_email
          and v_query is not null
          and lower(coalesce(au.email, '')) = v_query
          then 1
        else 2
      end as match_priority
    from auth.users au
    left join public.users pu
      on pu.id = au.id
    left join public.user_profiles up
      on up.id = au.id
    left join app_private.account_controls ac
      on ac.user_id = au.id
    where
      v_query is null
      or starts_with(lower(au.id::text), v_query)
      or (
        v_username_query is not null
        and starts_with(
          lower(coalesce(up.username, '')),
          v_username_query
        )
      )
      or (
        p_include_email
        and starts_with(
          lower(coalesce(au.email, '')),
          v_query
        )
      )
  )
  select
    mu.id as user_id,
    mu.visible_email as email,
    mu.visible_display_name as display_name,
    mu.visible_username as username,
    mu.visible_avatar_url as avatar_url,
    mu.auth_system_role as system_role,
    mu.public_mirror_role as mirror_role,
    (
      mu.auth_system_role = mu.public_mirror_role
    ) as role_synchronized,
    mu.public_actor_type as actor_type,
    mu.public_verification_level as verification_level,
    mu.public_verification_status as verification_status,
    mu.effective_account_status as account_status,
    mu.effective_suspended_until as suspended_until,
    mu.effective_created_at as created_at,
    count(*) over() as total_count
  from matched_users mu
  order by
    mu.match_priority asc,
    mu.effective_created_at desc,
    mu.id asc
  limit p_per_page
  offset v_offset;
end;
$$;

comment on function public.admin_search_users(
  text,
  integer,
  integer,
  boolean
) is
  'Backend-only paginated Admin Center user search. Email is opt-in for authorized admins.';

revoke all
on function public.admin_search_users(text, integer, integer, boolean)
from public, anon, authenticated;

grant execute
on function public.admin_search_users(text, integer, integer, boolean)
to service_role;

commit;
