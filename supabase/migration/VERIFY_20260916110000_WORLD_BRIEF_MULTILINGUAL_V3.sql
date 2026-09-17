select
  exists (select 1 from information_schema.columns where table_schema='public' and table_name='social_vote_world_briefs' and column_name='content_kind') as content_kind_present,
  to_regclass('public.social_vote_world_brief_translations') is not null as translations_table_present,
  to_regprocedure('public.world_brief_public_catalog_v3(text,integer)') is not null as public_catalog_v3_present,
  to_regprocedure('public.world_brief_public_get_v3(uuid,text)') is not null as public_get_v3_present,
  to_regprocedure('public.admin_world_brief_translation_list(uuid)') is not null as translation_list_present,
  to_regprocedure('public.admin_world_brief_translation_save(jsonb)') is not null as translation_save_present,
  to_regprocedure('public.admin_world_brief_translation_delete(uuid,text)') is not null as translation_delete_present,
  (
    position('new.content_kind = ''reported''' in pg_get_functiondef('app_private.prepare_social_vote_world_brief()'::regprocedure)) > 0
    and
    position('cardinality(v_hosts) < 2' in pg_get_functiondef('app_private.prepare_social_vote_world_brief()'::regprocedure)) > 0
  ) as original_source_policy_present,
  position('content_kind' in pg_get_functiondef('public.admin_world_brief_save(jsonb)'::regprocedure)) > 0 as save_content_kind_present;

select conname, pg_get_constraintdef(oid) as definition
from pg_constraint
where conrelid='public.social_vote_world_briefs'::regclass
  and conname in ('social_vote_world_briefs_language_check','social_vote_world_briefs_content_kind_check')
order by conname;

