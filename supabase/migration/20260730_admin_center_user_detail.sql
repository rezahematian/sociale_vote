-- Social Vote
-- Admin Center: backend-only account detail.
--
-- Security rules:
-- - this function is callable only with the service role;
-- - the Edge Function must authorize the current admin first;
-- - no token, password, identity document or private verification payload is
--   exposed;
-- - deleted Auth accounts are not returned.

begin;

create or replace function public.admin_get_user_detail(
  p_user_id uuid
)
returns table (
  user_id uuid,
  email text,
  email_confirmed_at timestamptz,
  last_sign_in_at timestamptz,
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
  created_at timestamptz
)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if coalesce((select auth.role()), '') <> 'service_role' then
    raise exception
      using
        errcode = '42501',
        message = 'Service role access is required.';
  end if;

  if p_user_id is null then
    raise exception
      using
        errcode = '22023',
        message = 'A target user ID is required.';
  end if;

  return query
  select
    au.id as user_id,
    au.email::text as email,
    au.email_confirmed_at,
    au.last_sign_in_at,
    coalesce(
      nullif(btrim(up.display_name), ''),
      nullif(btrim(pu.display_name), '')
    )::text as display_name,
    nullif(btrim(up.username), '')::text as username,
    nullif(btrim(up.avatar_url), '')::text as avatar_url,
    case
      when lower(coalesce(au.raw_app_meta_data ->> 'role', '')) in (
        'user',
        'moderator',
        'admin'
      )
        then lower(au.raw_app_meta_data ->> 'role')
      else 'user'
    end::text as system_role,
    case
      when lower(coalesce(pu.role, '')) in (
        'user',
        'moderator',
        'admin'
      )
        then lower(pu.role)
      else 'user'
    end::text as mirror_role,
    (
      case
        when lower(coalesce(au.raw_app_meta_data ->> 'role', '')) in (
          'user',
          'moderator',
          'admin'
        )
          then lower(au.raw_app_meta_data ->> 'role')
        else 'user'
      end
      =
      case
        when lower(coalesce(pu.role, '')) in (
          'user',
          'moderator',
          'admin'
        )
          then lower(pu.role)
        else 'user'
      end
    ) as role_synchronized,
    coalesce(nullif(btrim(up.actor_type), ''), 'citizen')::text
      as actor_type,
    coalesce(nullif(btrim(up.verification_level), ''), 'none')::text
      as verification_level,
    coalesce(nullif(btrim(up.verification_status), ''), 'none')::text
      as verification_status,
    case
      when ac.status = 'suspended'
        and ac.suspended_until is not null
        and ac.suspended_until <= now()
        then 'active'
      else coalesce(ac.status, 'active')
    end::text as account_status,
    case
      when ac.status = 'suspended'
        and ac.suspended_until is not null
        and ac.suspended_until > now()
        then ac.suspended_until
      else null::timestamptz
    end as suspended_until,
    au.created_at
  from auth.users au
  left join public.users pu
    on pu.id = au.id
  left join public.user_profiles up
    on up.id = au.id
  left join app_private.account_controls ac
    on ac.user_id = au.id
  where au.id = p_user_id
  limit 1;
end;
$$;

comment on function public.admin_get_user_detail(uuid) is
  'Backend-only Admin Center account detail, including Auth confirmation and sign-in timestamps.';

revoke all
on function public.admin_get_user_detail(uuid)
from public, anon, authenticated;

grant execute
on function public.admin_get_user_detail(uuid)
to service_role;

commit;
