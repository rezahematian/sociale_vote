-- Social Vote â€” Organization Profile / Verification UX V2
-- 2026-08-22
-- Apply manually after Organizations/Sessions pilot + hardening.
-- No billing activation. No service-role exposure to the client.

begin;

-- ============================================================
-- 1) STORAGE UPSERT SUPPORT
-- Supabase Storage upsert of an existing object requires SELECT + UPDATE.
-- Public download remains handled by the public bucket; this policy only
-- exposes storage.objects metadata to authenticated owner/manager uploads.
-- ============================================================
drop policy if exists organization_media_select_manager on storage.objects;
create policy organization_media_select_manager
on storage.objects for select to authenticated
using (
  bucket_id = 'organization-media'
  and public.is_current_auth_user_active()
  and public.organization_user_can_manage(
    ((storage.foldername(name))[1])::uuid
  )
);

-- ============================================================
-- 2) RICH ORGANIZATION VERIFICATION EVIDENCE
-- Existing verification rows remain valid. New clients may capture richer
-- evidence without changing the meaning of verification approval itself.
-- ============================================================
alter table public.verification_requests
  add column if not exists organization_legal_name text,
  add column if not exists organization_public_name text,
  add column if not exists organization_entity_type text,
  add column if not exists organization_country_code text,
  add column if not exists organization_city text,
  add column if not exists organization_website_url text,
  add column if not exists organization_representative_role text,
  add column if not exists organization_registry_id text,
  add column if not exists organization_authority_note text;

alter table public.verification_requests
  drop constraint if exists verification_requests_org_entity_type_v2_check;
alter table public.verification_requests
  add constraint verification_requests_org_entity_type_v2_check
  check (
    organization_entity_type is null
    or organization_entity_type in (
      'association','nonprofit','company','cooperative',
      'sports','public_body','committee','other'
    )
  );

alter table public.verification_requests
  drop constraint if exists verification_requests_org_country_v2_check;
alter table public.verification_requests
  add constraint verification_requests_org_country_v2_check
  check (
    organization_country_code is null
    or organization_country_code ~ '^[A-Z]{2}$'
  );

alter table public.verification_requests
  drop constraint if exists verification_requests_org_lengths_v2_check;
alter table public.verification_requests
  add constraint verification_requests_org_lengths_v2_check
  check (
    char_length(coalesce(organization_legal_name,'')) <= 200
    and char_length(coalesce(organization_public_name,'')) <= 200
    and char_length(coalesce(organization_city,'')) <= 120
    and char_length(coalesce(organization_website_url,'')) <= 500
    and char_length(coalesce(organization_representative_role,'')) <= 160
    and char_length(coalesce(organization_registry_id,'')) <= 160
    and char_length(coalesce(organization_authority_note,'')) <= 1200
  );

comment on column public.verification_requests.organization_legal_name is
  'Organization verification evidence: legal name submitted by applicant.';
comment on column public.verification_requests.organization_public_name is
  'Organization verification evidence: requested public name.';
comment on column public.verification_requests.organization_entity_type is
  'Organization verification evidence: requested organization category.';
comment on column public.verification_requests.organization_country_code is
  'Organization verification evidence: organization country, ISO alpha-2.';
comment on column public.verification_requests.organization_representative_role is
  'Organization verification evidence: applicant role/authority description.';
comment on column public.verification_requests.organization_authority_note is
  'Organization verification evidence for Admin review; not public profile data.';

-- ============================================================
-- 3) BOOTSTRAP USES APPROVED REQUEST DATA WHEN AVAILABLE
-- Existing/legacy organization profiles continue to bootstrap with fallbacks.
-- Existing organization_entities are not rewritten.
-- ============================================================
create or replace function public.organization_bootstrap_from_verified_profile()
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public, extensions
as $$
declare
  v_user_id uuid := auth.uid();
  v_profile public.user_profiles%rowtype;
  v_request public.verification_requests%rowtype;
  v_has_request boolean := false;
  v_org_id uuid;
  v_workspace_id uuid;
  v_slug_base text;
  v_slug text;
  v_legal_name text;
  v_public_name text;
  v_entity_type text;
  v_country_code text;
  v_city text;
  v_website_url text;
begin
  if v_user_id is null or not public.is_current_auth_user_active() then
    raise exception using errcode = '42501', message = 'Active authentication required.';
  end if;

  if exists (
    select 1
    from public.organization_memberships
    where user_id = v_user_id and status = 'active'
  ) then
    return public.organization_get_mine();
  end if;

  select * into v_profile
  from public.user_profiles
  where id = v_user_id;

  if not found
    or v_profile.actor_type <> 'organization'
    or v_profile.verified_at is null
    or nullif(btrim(v_profile.organization_name), '') is null
  then
    raise exception using errcode = '42501',
      message = 'A verified Social Vote organization identity is required.';
  end if;

  select vr.* into v_request
  from public.verification_requests vr
  where vr.user_id = v_user_id
    and vr.request_type = 'organization'
    and vr.status = 'approved'
  order by vr.reviewed_at desc nulls last, vr.created_at desc
  limit 1;
  v_has_request := found;

  v_legal_name := coalesce(
    nullif(btrim(case when v_has_request then v_request.organization_legal_name end), ''),
    nullif(btrim(v_profile.organization_name), '')
  );
  v_public_name := coalesce(
    nullif(btrim(case when v_has_request then v_request.organization_public_name end), ''),
    nullif(btrim(v_profile.organization_name), '')
  );
  v_entity_type := coalesce(
    nullif(btrim(case when v_has_request then v_request.organization_entity_type end), ''),
    'other'
  );
  if v_entity_type not in (
    'association','nonprofit','company','cooperative',
    'sports','public_body','committee','other'
  ) then
    v_entity_type := 'other';
  end if;

  v_country_code := coalesce(
    nullif(upper(btrim(case when v_has_request then v_request.organization_country_code end)), ''),
    case
      when upper(coalesce(v_profile.country, '')) ~ '^[A-Z]{2}$'
        then upper(v_profile.country)
      else null
    end
  );
  if v_country_code is not null and v_country_code !~ '^[A-Z]{2}$' then
    v_country_code := null;
  end if;

  v_city := coalesce(
    nullif(btrim(case when v_has_request then v_request.organization_city end), ''),
    nullif(btrim(v_profile.city), '')
  );
  v_website_url := nullif(
    btrim(case when v_has_request then v_request.organization_website_url end),
    ''
  );

  v_slug_base := trim(both '-' from regexp_replace(
    lower(v_public_name), '[^a-z0-9]+', '-', 'g'
  ));
  if v_slug_base = '' then v_slug_base := 'organization'; end if;
  v_slug := v_slug_base || '-' || substr(replace(gen_random_uuid()::text, '-', ''), 1, 7);

  insert into public.organization_entities (
    legal_name, public_name, slug, entity_type, country_code, city,
    website_url, verification_status, verification_source, verified_at, created_by
  ) values (
    v_legal_name,
    v_public_name,
    v_slug,
    v_entity_type,
    v_country_code,
    v_city,
    v_website_url,
    'verified',
    case when v_has_request then 'verification_request_v2' else 'legacy_verified_profile' end,
    v_profile.verified_at,
    v_user_id
  ) returning id into v_org_id;

  insert into public.organization_memberships (
    organization_id, user_id, membership_role, status
  ) values (v_org_id, v_user_id, 'owner', 'active');

  insert into public.organization_workspaces (
    organization_id, plan_key, status, commercial_mode, billing_enabled
  ) values (v_org_id, 'pilot', 'active', 'pilot_free', false)
  returning id into v_workspace_id;

  insert into public.organization_session_audit (
    organization_id, actor_user_id, event_key, metadata
  ) values (
    v_org_id,
    v_user_id,
    'organization_bootstrapped',
    jsonb_build_object(
      'source', case when v_has_request then 'verification_request_v2' else 'legacy_verified_profile' end
    )
  );

  return public.organization_get_mine();
end;
$$;

revoke all on function public.organization_bootstrap_from_verified_profile()
from public, anon;
grant execute on function public.organization_bootstrap_from_verified_profile()
to authenticated;

commit;


-- Social Vote â€” Organization Profile / Verification UX V2 â€” READ ONLY
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

