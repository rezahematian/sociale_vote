-- Social Vote — Team List Active Only Fix V1
-- Runtime root cause: organization_team_revoke() sets status='revoked',
-- while organization_team_list() previously returned all memberships.
-- This hotfix makes the Team UI list only active memberships.

begin;

create or replace function public.organization_team_list()
returns table (
  user_id uuid,
  username text,
  display_name text,
  email text,
  membership_role text,
  membership_status text,
  created_at timestamptz
)
language plpgsql
security definer
set search_path = pg_catalog, public, auth
as $$
declare
  v_user_id uuid := auth.uid();
  v_org_id uuid;
begin
  if v_user_id is null or not public.is_current_auth_user_active() then
    raise exception using errcode='42501', message='Active authentication required.';
  end if;

  select om.organization_id into v_org_id
  from public.organization_memberships om
  where om.user_id = v_user_id and om.status = 'active'
  order by (om.membership_role='owner') desc, om.created_at asc
  limit 1;

  if v_org_id is null then
    return;
  end if;

  return query
  select
    om.user_id,
    nullif(btrim(up.username),'')::text,
    nullif(btrim(up.display_name),'')::text,
    nullif(btrim(au.email),'')::text,
    om.membership_role,
    om.status,
    om.created_at
  from public.organization_memberships om
  left join public.user_profiles up on up.id = om.user_id
  left join auth.users au on au.id = om.user_id
  where om.organization_id = v_org_id
    and om.status = 'active'
  order by
    case om.membership_role when 'owner' then 0 when 'manager' then 1 when 'operator' then 2 else 3 end,
    om.created_at asc;
end;
$$;

revoke all on function public.organization_team_list() from public, anon;
grant execute on function public.organization_team_list() to authenticated;

commit;
