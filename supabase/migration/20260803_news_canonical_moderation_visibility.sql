-- Social Vote
-- AC8.5: canonical News identity for report Hide/Restore.
--
-- Scope:
-- - canonicalizes legacy Flutter News IDs when reports are written;
-- - backfills existing News reports to their permanent news_articles UUID;
-- - moves existing News visibility state to the same canonical UUID;
-- - leaves Poll, Post, Flutter, UI and the public visibility filter unchanged.

begin;

create or replace function app_private.canonicalize_news_report_target_id()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_target_type text :=
    lower(btrim(coalesce(new.target_type::text, '')));
  v_target_id text :=
    btrim(coalesce(new.target_id::text, ''));
  v_canonical_news_id uuid;
begin
  if v_target_type <> 'news' or v_target_id = '' then
    return new;
  end if;

  if lower(v_target_id) ~
      '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
  then
    select article.id
    into v_canonical_news_id
    from public.news_articles article
    where article.id::text = lower(v_target_id)
    limit 1;
  end if;

  if v_canonical_news_id is null then
    select alias.news_id
    into v_canonical_news_id
    from public.news_article_aliases alias
    where alias.alias_type = 'legacy_flutter_id'
      and alias.alias_value = lower(v_target_id)
    limit 1;
  end if;

  if v_canonical_news_id is not null then
    new.target_id := v_canonical_news_id::text;
  end if;

  return new;
end;
$$;

comment on function
  app_private.canonicalize_news_report_target_id() is
  'Converts a reported legacy Flutter News ID to its permanent news_articles UUID before the report is stored.';

revoke all
on function app_private.canonicalize_news_report_target_id()
from public, anon, authenticated;

drop trigger if exists
  reports_canonicalize_news_target_id_before_write
on public.reports;

create trigger reports_canonicalize_news_target_id_before_write
before insert or update of target_type, target_id
on public.reports
for each row
execute function app_private.canonicalize_news_report_target_id();

-- Existing reports must use the same permanent ID before Hide/Restore reads
-- their target. Only the exact legacy UUID alias is accepted.
update public.reports report
set target_id = alias.news_id::text
from public.news_article_aliases alias
where lower(btrim(report.target_type::text)) = 'news'
  and alias.alias_type = 'legacy_flutter_id'
  and alias.alias_value = lower(btrim(report.target_id::text))
  and btrim(report.target_id::text) <> alias.news_id::text;

-- Preserve the newest authoritative state if both a legacy row and a
-- canonical row happen to exist. Processing from oldest to newest makes the
-- final state deterministic while retaining the highest monotonic version.
do $$
declare
  v_state record;
begin
  for v_state in
    select
      visibility.target_type,
      visibility.target_id,
      visibility.is_hidden,
      visibility.hidden_by,
      visibility.hidden_at,
      visibility.hidden_reason,
      visibility.restored_by,
      visibility.restored_at,
      visibility.restore_reason,
      visibility.last_report_id,
      visibility.version,
      visibility.updated_at,
      alias.news_id::text as canonical_target_id
    from app_private.admin_content_visibility visibility
    join public.news_article_aliases alias
      on alias.alias_type = 'legacy_flutter_id'
      and alias.alias_value = lower(btrim(visibility.target_id))
    where visibility.target_type = 'news'
      and visibility.target_id <> alias.news_id::text
    order by
      visibility.updated_at,
      visibility.version,
      visibility.target_id
  loop
    insert into app_private.admin_content_visibility as current_state (
      target_type,
      target_id,
      is_hidden,
      hidden_by,
      hidden_at,
      hidden_reason,
      restored_by,
      restored_at,
      restore_reason,
      last_report_id,
      version,
      updated_at
    )
    values (
      v_state.target_type,
      v_state.canonical_target_id,
      v_state.is_hidden,
      v_state.hidden_by,
      v_state.hidden_at,
      v_state.hidden_reason,
      v_state.restored_by,
      v_state.restored_at,
      v_state.restore_reason,
      v_state.last_report_id,
      v_state.version,
      v_state.updated_at
    )
    on conflict (target_type, target_id) do update
    set
      is_hidden = excluded.is_hidden,
      hidden_by = excluded.hidden_by,
      hidden_at = excluded.hidden_at,
      hidden_reason = excluded.hidden_reason,
      restored_by = excluded.restored_by,
      restored_at = excluded.restored_at,
      restore_reason = excluded.restore_reason,
      last_report_id = excluded.last_report_id,
      version = greatest(current_state.version, excluded.version),
      updated_at = excluded.updated_at
    where excluded.updated_at >= current_state.updated_at;
  end loop;

  delete from app_private.admin_content_visibility visibility
  using public.news_article_aliases alias
  where visibility.target_type = 'news'
    and alias.alias_type = 'legacy_flutter_id'
    and alias.alias_value = lower(btrim(visibility.target_id))
    and visibility.target_id <> alias.news_id::text;
end;
$$;

notify pgrst, 'reload schema';

commit;
