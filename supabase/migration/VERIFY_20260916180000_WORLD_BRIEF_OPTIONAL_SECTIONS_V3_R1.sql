-- World Brief Optional Sections V3 R1 verification.
-- Expected: one row, all columns TRUE.

select
  exists (
    select 1 from information_schema.columns
    where table_schema='public'
      and table_name='social_vote_world_briefs'
      and column_name='what_happened'
      and is_nullable='YES'
  ) as main_what_optional,

  exists (
    select 1 from information_schema.columns
    where table_schema='public'
      and table_name='social_vote_world_briefs'
      and column_name='why_it_matters'
      and is_nullable='YES'
  ) as main_why_optional,

  exists (
    select 1 from information_schema.columns
    where table_schema='public'
      and table_name='social_vote_world_brief_translations'
      and column_name='what_happened'
      and is_nullable='YES'
  ) as translation_what_optional,

  exists (
    select 1 from information_schema.columns
    where table_schema='public'
      and table_name='social_vote_world_brief_translations'
      and column_name='why_it_matters'
      and is_nullable='YES'
  ) as translation_why_optional,

  exists (
    select 1
    from pg_proc p
    join pg_namespace n on n.oid=p.pronamespace
    where n.nspname='app_private'
      and p.proname='prepare_social_vote_world_brief'
      and lower(pg_get_functiondef(p.oid)) like '%v_now timestamptz := clock_timestamp()%'
      and lower(pg_get_functiondef(p.oid)) like '%new.created_at := v_now%'
      and lower(pg_get_functiondef(p.oid)) like '%new.updated_at := v_now%'
  ) as insert_timestamp_fix_present,

  exists (
    select 1
    from pg_constraint c
    where c.conrelid='public.social_vote_world_briefs'::regclass
      and c.conname='social_vote_world_briefs_happened_check'
      and lower(pg_get_constraintdef(c.oid)) like '%what_happened is null%'
  ) as main_what_check_optional,

  exists (
    select 1
    from pg_constraint c
    where c.conrelid='public.social_vote_world_briefs'::regclass
      and c.conname='social_vote_world_briefs_matters_check'
      and lower(pg_get_constraintdef(c.oid)) like '%why_it_matters is null%'
  ) as main_why_check_optional,

  exists (
    select 1
    from pg_proc p
    join pg_namespace n on n.oid=p.pronamespace
    where n.nspname='public'
      and p.proname='world_brief_public_catalog_v3'
      and lower(pg_get_functiondef(p.oid)) like '%case when t.brief_id is null then b.what_happened else t.what_happened end%'
      and lower(pg_get_functiondef(p.oid)) like '%case when t.brief_id is null then b.why_it_matters else t.why_it_matters end%'
  ) as catalog_translation_optional_sections_independent,

  exists (
    select 1
    from pg_proc p
    join pg_namespace n on n.oid=p.pronamespace
    where n.nspname='public'
      and p.proname='admin_world_brief_translation_save'
      and lower(pg_get_functiondef(p.oid)) like '%nullif(btrim(p_payload ->> ''what_happened''), '''')%'
      and lower(pg_get_functiondef(p.oid)) like '%nullif(btrim(p_payload ->> ''why_it_matters''), '''')%'
  ) as translation_save_blank_to_null;
