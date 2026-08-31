select
  to_regclass('public.external_account_links') is not null
    as external_links_table_present,
  coalesce((
    select c.relrowsecurity and c.relforcerowsecurity
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relname = 'external_account_links'
  ), false) as external_links_rls_forced,
  to_regprocedure('public.organization_external_links_list_mine()') is not null
    as list_mine_rpc_present,
  to_regprocedure('public.organization_external_links_public(uuid)') is not null
    as public_list_rpc_present,
  to_regprocedure('public.organization_external_links_replace(jsonb)') is not null
    as replace_rpc_present,
  to_regprocedure('public.external_account_link_url_is_valid(text,text)')
    is not null as url_validator_present,
  not has_table_privilege(
    'anon', 'public.external_account_links', 'SELECT'
  )
    and not has_table_privilege(
      'authenticated', 'public.external_account_links', 'SELECT'
    )
    and not has_table_privilege(
      'authenticated', 'public.external_account_links', 'INSERT'
    )
    and not has_table_privilege(
      'authenticated', 'public.external_account_links', 'UPDATE'
    )
    and not has_table_privilege(
      'authenticated', 'public.external_account_links', 'DELETE'
    ) as direct_table_access_blocked,
  has_function_privilege(
    'anon',
    'public.organization_external_links_public(uuid)',
    'EXECUTE'
  )
    and has_function_privilege(
      'authenticated',
      'public.organization_external_links_public(uuid)',
      'EXECUTE'
    ) as public_rpc_available,
  not has_function_privilege(
    'anon',
    'public.organization_external_links_list_mine()',
    'EXECUTE'
  )
    and not has_function_privilege(
      'anon',
      'public.organization_external_links_replace(jsonb)',
      'EXECUTE'
    )
    and has_function_privilege(
      'authenticated',
      'public.organization_external_links_list_mine()',
      'EXECUTE'
    )
    and has_function_privilege(
      'authenticated',
      'public.organization_external_links_replace(jsonb)',
      'EXECUTE'
    ) as mutation_rpc_grants_valid,
  coalesce((
    select bool_and(p.prosecdef)
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname in (
        'organization_external_links_list_mine',
        'organization_external_links_public',
        'organization_external_links_replace'
      )
  ), false) as rpcs_security_definer,
  coalesce((
    select p.prosrc ilike '%membership_role%'
      and p.prosrc ilike '%owner%'
      and p.prosrc ilike '%manager%'
      and p.prosrc ilike '%is_current_auth_user_active%'
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname = 'organization_external_links_replace'
  ), false) as replace_manager_gate_present,
  public.external_account_link_url_is_valid(
    'youtube', 'https://www.youtube.com/@socialvote'
  )
    and public.external_account_link_url_is_valid(
      'linkedin', 'https://www.linkedin.com/company/social-vote'
    )
    and public.external_account_link_url_is_valid(
      'whatsapp', 'https://wa.me/390000000000'
    )
    and public.external_account_link_url_is_valid(
      'instagram', 'https://www.instagram.com/socialvote'
    )
    and public.external_account_link_url_is_valid(
      'telegram', 'https://t.me/socialvote'
    ) as supported_provider_urls_valid,
  not public.external_account_link_url_is_valid(
    'youtube', 'http://youtube.com/@socialvote'
  )
    and not public.external_account_link_url_is_valid(
      'youtube', 'https://youtube.com.evil.example/@socialvote'
    )
    and not public.external_account_link_url_is_valid(
      'linkedin', 'https://example.com/company/social-vote'
    ) as unsafe_or_wrong_provider_urls_blocked,
  coalesce((
    select count(*) = 3
    from pg_constraint c
    join pg_class t on t.oid = c.conrelid
    join pg_namespace n on n.oid = t.relnamespace
    where n.nspname = 'public'
      and t.relname = 'external_account_links'
      and c.conname in (
        'external_account_links_exactly_one_subject_check',
        'external_account_links_subject_type_check',
        'external_account_links_url_check'
      )
  ), false) as subject_and_url_constraints_present,
  coalesce((
    select count(*) = 3
    from pg_indexes i
    where i.schemaname = 'public'
      and i.indexname in (
        'external_account_links_organization_provider_uidx',
        'external_account_links_user_provider_uidx',
        'external_account_links_provider_subject_uidx'
      )
  ), false) as uniqueness_indexes_present,
  coalesce((
    select p.prosrc ilike '%visibility = ''public''%'
      and p.prosrc ilike '%status = ''active''%'
      and p.prosrc ilike '%verification_status = ''verified''%'
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname = 'organization_external_links_public'
  ), false) as public_rpc_filters_enforced;
