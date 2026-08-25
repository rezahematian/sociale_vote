-- Read-only verification for 20260825150000_world_briefs_and_public_organization.sql

select
  to_regclass('public.social_vote_world_briefs') is not null as brief_table,
  to_regclass('app_private.social_vote_world_brief_audit') is not null as audit_table,
  to_regprocedure('public.organization_public_get_by_id(uuid)') is not null
    as organization_lookup,
  (
    select relrowsecurity and relforcerowsecurity
    from pg_class
    where oid = 'public.social_vote_world_briefs'::regclass
  ) as rls_forced,
  (
    select count(*) = 5
    from pg_policies
    where schemaname = 'public'
      and tablename = 'social_vote_world_briefs'
  ) as five_policies,
  (
    select count(*) = 0
    from public.social_vote_world_briefs
  ) as no_content_published_by_migration;

select
  policyname,
  cmd,
  roles,
  qual,
  with_check
from pg_policies
where schemaname = 'public'
  and tablename = 'social_vote_world_briefs'
order by policyname;
