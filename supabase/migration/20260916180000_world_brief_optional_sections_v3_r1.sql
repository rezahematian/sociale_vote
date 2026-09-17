-- Social Vote
-- World Brief V3 R1 runtime fix:
-- 1) fix INSERT timestamp ordering regression introduced by V3 trigger replacement;
-- 2) make the four editorial sections optional;
-- 3) keep translated optional sections independent (no mixed-language fallback);
-- 4) preserve existing publication/source/location policy.

begin;

alter table public.social_vote_world_briefs
  alter column what_happened drop not null,
  alter column why_it_matters drop not null;

alter table public.social_vote_world_briefs
  drop constraint if exists social_vote_world_briefs_happened_check;
alter table public.social_vote_world_briefs
  add constraint social_vote_world_briefs_happened_check
  check (
    what_happened is null
    or char_length(btrim(what_happened)) between 1 and 12000
  );

alter table public.social_vote_world_briefs
  drop constraint if exists social_vote_world_briefs_matters_check;
alter table public.social_vote_world_briefs
  add constraint social_vote_world_briefs_matters_check
  check (
    why_it_matters is null
    or char_length(btrim(why_it_matters)) between 1 and 12000
  );

alter table public.social_vote_world_brief_translations
  alter column what_happened drop not null,
  alter column why_it_matters drop not null;

alter table public.social_vote_world_brief_translations
  drop constraint if exists social_vote_world_brief_translations_happened_check;
alter table public.social_vote_world_brief_translations
  add constraint social_vote_world_brief_translations_happened_check
  check (
    what_happened is null
    or char_length(btrim(what_happened)) between 1 and 12000
  );

alter table public.social_vote_world_brief_translations
  drop constraint if exists social_vote_world_brief_translations_matters_check;
alter table public.social_vote_world_brief_translations
  add constraint social_vote_world_brief_translations_matters_check
  check (
    why_it_matters is null
    or char_length(btrim(why_it_matters)) between 1 and 12000
  );

update public.social_vote_world_briefs
set what_happened = null
where what_happened is not null and btrim(what_happened) = '';

update public.social_vote_world_briefs
set why_it_matters = null
where why_it_matters is not null and btrim(why_it_matters) = '';

update public.social_vote_world_brief_translations
set what_happened = null
where what_happened is not null and btrim(what_happened) = '';

update public.social_vote_world_brief_translations
set why_it_matters = null
where why_it_matters is not null and btrim(why_it_matters) = '';

create or replace function app_private.prepare_social_vote_world_brief()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_source text;
  v_host text;
  v_hosts text[] := array[]::text[];
  v_now timestamptz := clock_timestamp();
begin
  if (select auth.uid()) is null then
    raise exception using errcode = '42501', message = 'Authenticated admin required.';
  end if;
  if not public.is_current_auth_user_world_brief_admin() then
    raise exception using errcode = '42501', message = 'World Brief admin permission required.';
  end if;

  new.content_kind := lower(btrim(coalesce(new.content_kind, 'reported')));
  new.language_code := lower(btrim(new.language_code));
  new.title := btrim(new.title);
  new.what_happened := nullif(btrim(new.what_happened), '');
  new.why_it_matters := nullif(btrim(new.why_it_matters), '');
  new.what_is_uncertain := nullif(btrim(new.what_is_uncertain), '');
  new.social_vote_view := nullif(btrim(new.social_vote_view), '');
  new.country_code := upper(nullif(btrim(new.country_code), ''));
  new.city_id := nullif(btrim(new.city_id), '');
  new.location_label := nullif(btrim(new.location_label), '');
  new.updated_by := auth.uid();

  if tg_op = 'INSERT' then
    new.created_by := auth.uid();
    new.created_at := v_now;
    new.updated_at := v_now;
  else
    new.created_by := old.created_by;
    new.created_at := old.created_at;
    new.updated_at := v_now;
  end if;

  if new.map_visible and (new.latitude is null or new.longitude is null) then
    raise exception using errcode = '22023', message = 'Globe visibility requires latitude and longitude.';
  end if;

  if jsonb_array_length(new.source_urls) > 12 then
    raise exception using errcode = '22023', message = 'World Briefs support at most twelve source URLs.';
  end if;

  if new.status = 'published' then
    for v_source in
      select btrim(source_value)
      from jsonb_array_elements_text(new.source_urls) source_value
      where nullif(btrim(source_value), '') is not null
    loop
      if char_length(v_source) > 2048 or v_source !~ '^https://[^[:space:]]+$' then
        raise exception using errcode = '22023', message = 'World Brief sources must be valid HTTPS URLs.';
      end if;
      v_host := regexp_replace(lower(substring(v_source from '^https://([^/:?#]+)')), '^www\.', '');
      if v_host is null or v_host = '' then
        raise exception using errcode = '22023', message = 'World Brief sources must contain a valid HTTPS host.';
      end if;
      if not (v_host = any(v_hosts)) then
        v_hosts := array_append(v_hosts, v_host);
      end if;
    end loop;

    if new.content_kind = 'reported' and cardinality(v_hosts) < 2 then
      raise exception using errcode = '22023', message = 'Published sourced World Briefs require at least two independent source domains.';
    end if;

    if new.expires_at is not null and new.expires_at <= v_now then
      raise exception using errcode = '22023', message = 'A published World Brief cannot already be expired.';
    end if;

    if tg_op = 'INSERT' then
      new.published_at := v_now;
    elsif new.published_at is null or old.status is distinct from 'published' then
      new.published_at := v_now;
    end if;
  end if;
  return new;
end;
$$;

revoke all on function app_private.prepare_social_vote_world_brief() from public, anon, authenticated;

create or replace function public.admin_world_brief_translation_save(p_payload jsonb)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_brief_id uuid;
  v_language text;
  v_primary text;
  v_row public.social_vote_world_brief_translations%rowtype;
begin
  if not public.is_current_auth_user_world_brief_admin() then
    raise exception using errcode = '42501', message = 'World Brief admin permission required.';
  end if;
  v_brief_id := nullif(btrim(p_payload ->> 'brief_id'), '')::uuid;
  v_language := lower(btrim(coalesce(p_payload ->> 'language_code', '')));
  select language_code into v_primary
  from public.social_vote_world_briefs
  where id = v_brief_id;

  if v_primary is null then
    raise exception using errcode = 'P0002', message = 'World Brief not found.';
  end if;
  if v_language = v_primary then
    raise exception using errcode = '22023', message = 'Primary language is stored on the canonical World Brief.';
  end if;
  if v_language not in ('en','it','de','fa','es','pt','fr','ar','ro','ru','zh') then
    raise exception using errcode = '22023', message = 'Unsupported World Brief language.';
  end if;

  insert into public.social_vote_world_brief_translations (
    brief_id, language_code, title, what_happened, why_it_matters,
    what_is_uncertain, social_vote_view, is_enabled, updated_by
  ) values (
    v_brief_id,
    v_language,
    btrim(coalesce(p_payload ->> 'title','')),
    nullif(btrim(p_payload ->> 'what_happened'),''),
    nullif(btrim(p_payload ->> 'why_it_matters'),''),
    nullif(btrim(p_payload ->> 'what_is_uncertain'),''),
    nullif(btrim(p_payload ->> 'social_vote_view'),''),
    coalesce((p_payload ->> 'is_enabled')::boolean, true),
    auth.uid()
  )
  on conflict (brief_id, language_code) do update set
    title = excluded.title,
    what_happened = excluded.what_happened,
    why_it_matters = excluded.why_it_matters,
    what_is_uncertain = excluded.what_is_uncertain,
    social_vote_view = excluded.social_vote_view,
    is_enabled = excluded.is_enabled,
    updated_by = auth.uid(),
    updated_at = clock_timestamp()
  returning * into v_row;

  return to_jsonb(v_row) - 'updated_by';
end;
$$;

revoke all on function public.admin_world_brief_translation_save(jsonb) from public, anon, authenticated;
grant execute on function public.admin_world_brief_translation_save(jsonb) to authenticated;

create or replace function public.world_brief_public_catalog_v3(
  p_language_code text,
  p_limit integer default 50
)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with requested as (
    select case
      when lower(btrim(coalesce(p_language_code,''))) in ('en','it','de','fa','es','pt','fr','ar','ro','ru','zh')
        then lower(btrim(p_language_code))
      else 'en'
    end as language_code,
    greatest(1, least(coalesce(p_limit,50),100)) as row_limit
  )
  select coalesce(
    jsonb_agg(item order by featured desc, priority desc, published_at desc),
    '[]'::jsonb
  )
  from (
    select jsonb_build_object(
      'id', b.id,
      'status', b.status,
      'content_kind', b.content_kind,
      'language_code', coalesce(t.language_code, b.language_code),
      'primary_language_code', b.language_code,
      'title', coalesce(t.title,b.title),
      'what_happened', case when t.brief_id is null then b.what_happened else t.what_happened end,
      'why_it_matters', case when t.brief_id is null then b.why_it_matters else t.why_it_matters end,
      'what_is_uncertain', case when t.brief_id is null then b.what_is_uncertain else t.what_is_uncertain end,
      'social_vote_view', case when t.brief_id is null then b.social_vote_view else t.social_vote_view end,
      'source_urls', b.source_urls,
      'country_code', b.country_code,
      'city_id', b.city_id,
      'location_label', b.location_label,
      'latitude', b.latitude,
      'longitude', b.longitude,
      'map_visible', b.map_visible,
      'featured', b.featured,
      'breaking', b.breaking,
      'priority', b.priority,
      'published_at', b.published_at,
      'expires_at', b.expires_at,
      'created_at', b.created_at,
      'updated_at', greatest(b.updated_at, coalesce(t.updated_at,b.updated_at))
    ) as item,
    b.featured,
    b.priority,
    b.published_at
    from public.social_vote_world_briefs b
    cross join requested r
    left join public.social_vote_world_brief_translations t
      on t.brief_id = b.id
     and t.language_code = r.language_code
     and t.is_enabled = true
    where b.status = 'published'
      and (b.expires_at is null or b.expires_at > clock_timestamp())
    order by b.featured desc, b.priority desc, b.published_at desc
    limit (select row_limit from requested)
  ) q;
$$;

revoke all on function public.world_brief_public_catalog_v3(text,integer) from public;
grant execute on function public.world_brief_public_catalog_v3(text,integer) to anon, authenticated;

create or replace function public.world_brief_public_get_v3(
  p_id uuid,
  p_language_code text
)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with requested as (
    select case
      when lower(btrim(coalesce(p_language_code,''))) in ('en','it','de','fa','es','pt','fr','ar','ro','ru','zh')
        then lower(btrim(p_language_code))
      else 'en'
    end as language_code
  )
  select jsonb_build_object(
    'id', b.id,
    'status', b.status,
    'content_kind', b.content_kind,
    'language_code', coalesce(t.language_code,b.language_code),
    'primary_language_code', b.language_code,
    'title', coalesce(t.title,b.title),
    'what_happened', case when t.brief_id is null then b.what_happened else t.what_happened end,
    'why_it_matters', case when t.brief_id is null then b.why_it_matters else t.why_it_matters end,
    'what_is_uncertain', case when t.brief_id is null then b.what_is_uncertain else t.what_is_uncertain end,
    'social_vote_view', case when t.brief_id is null then b.social_vote_view else t.social_vote_view end,
    'source_urls', b.source_urls,
    'country_code', b.country_code,
    'city_id', b.city_id,
    'location_label', b.location_label,
    'latitude', b.latitude,
    'longitude', b.longitude,
    'map_visible', b.map_visible,
    'featured', b.featured,
    'breaking', b.breaking,
    'priority', b.priority,
    'published_at', b.published_at,
    'expires_at', b.expires_at,
    'created_at', b.created_at,
    'updated_at', greatest(b.updated_at, coalesce(t.updated_at,b.updated_at))
  )
  from public.social_vote_world_briefs b
  cross join requested r
  left join public.social_vote_world_brief_translations t
    on t.brief_id = b.id
   and t.language_code = r.language_code
   and t.is_enabled = true
  where b.id = p_id
    and b.status = 'published'
    and (b.expires_at is null or b.expires_at > clock_timestamp())
  limit 1;
$$;

revoke all on function public.world_brief_public_get_v3(uuid,text) from public;
grant execute on function public.world_brief_public_get_v3(uuid,text) to anon, authenticated;

notify pgrst, 'reload schema';

commit;
