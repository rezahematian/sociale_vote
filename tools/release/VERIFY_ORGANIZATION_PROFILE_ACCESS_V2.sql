-- Social Vote — Organization Profile / Verification UX V2 — READ ONLY
-- 2026-08-22
-- Expected: every row pass=true, failed_checks=0, overall_status=PASS.

with checks as (
  select
    '01_storage_select_policy_for_upsert'::text as check_name,
    exists (
      select 1
      from pg_policies p
      where p.schemaname = 'storage'
        and p.tablename = 'objects'
        and p.policyname = 'organization_media_select_manager'
        and p.cmd = 'SELECT'
        and 'authenticated' = any(p.roles)
    ) as pass,
    'SELECT policy exists for authenticated organization owner/manager Storage upsert'::text as detail

  union all
  select
    '02_verification_v2_columns_9',
    (
      select count(*) = 9
      from information_schema.columns
      where table_schema = 'public'
        and table_name = 'verification_requests'
        and column_name in (
          'organization_legal_name',
          'organization_public_name',
          'organization_entity_type',
          'organization_country_code',
          'organization_city',
          'organization_website_url',
          'organization_representative_role',
          'organization_registry_id',
          'organization_authority_note'
        )
    ),
    'organization verification V2 evidence columns exist'

  union all
  select
    '03_bootstrap_uses_approved_request_v2',
    position(
      'verification_request_v2'
      in pg_get_functiondef('public.organization_bootstrap_from_verified_profile()'::regprocedure)
    ) > 0
    and position(
      'organization_legal_name'
      in pg_get_functiondef('public.organization_bootstrap_from_verified_profile()'::regprocedure)
    ) > 0,
    'new organization bootstrap uses approved verification request details with legacy fallback'

  union all
  select
    '04_bootstrap_security_definer_safe_path',
    exists (
      select 1
      from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public'
        and p.oid = 'public.organization_bootstrap_from_verified_profile()'::regprocedure
        and p.prosecdef
        and coalesce(array_to_string(p.proconfig, ','), '')
          like '%search_path=pg_catalog, public, extensions%'
    ),
    'bootstrap remains SECURITY DEFINER with controlled search_path'

  union all
  select
    '05_billing_still_hard_off',
    not exists (
      select 1
      from public.organization_workspaces
      where plan_key <> 'pilot'
         or commercial_mode <> 'pilot_free'
         or billing_enabled
    ),
    'no Organization workspace billing activation introduced'

  union all
  select
    '06_social_vote_workspace_preserved',
    exists (
      select 1
      from auth.users au
      join public.organization_memberships om
        on om.user_id = au.id and om.status = 'active'
      join public.organization_entities oe
        on oe.id = om.organization_id
      join public.organization_workspaces ow
        on ow.organization_id = oe.id
      where lower(coalesce(au.email, '')) = 'socialvote@hotmail.com'
        and om.membership_role = 'owner'
        and oe.verification_status = 'verified'
        and ow.status = 'active'
        and ow.plan_key = 'pilot'
        and ow.commercial_mode = 'pilot_free'
        and ow.billing_enabled = false
    ),
    'existing Social Vote organization remains verified owner workspace in pilot/free mode'
)
select
  check_name,
  pass,
  detail,
  count(*) filter (where not pass) over () as failed_checks,
  case when bool_and(pass) over () then 'PASS' else 'FAIL' end as overall_status
from checks
order by check_name;
