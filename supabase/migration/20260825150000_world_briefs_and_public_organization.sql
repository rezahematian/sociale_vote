-- Social Vote
-- Release-candidate foundation: World Brief editorial workflow and explicit
-- public Organization lookup.
--
-- This migration is idempotent. It does not publish content by itself.

begin;

create table if not exists public.social_vote_world_briefs (
  id uuid primary key default gen_random_uuid(),
  status text not null default 'draft',
  language_code text not null default 'en',
  title text not null,
  what_happened text not null,
  why_it_matters text not null,
  what_is_uncertain text,
  source_urls jsonb not null default '[]'::jsonb,
  country_code text,
  city_id text,
  location_label text,
  latitude double precision,
  longitude double precision,
  map_visible boolean not null default false,
  featured boolean not null default false,
  breaking boolean not null default false,
  priority smallint not null default 50,
  published_at timestamptz,
  expires_at timestamptz,
  created_by uuid not null,
  updated_by uuid not null,
  created_at timestamptz not null default clock_timestamp(),
  updated_at timestamptz not null default clock_timestamp(),

  constraint social_vote_world_briefs_status_check
    check (status in ('draft', 'published', 'withdrawn')),
  constraint social_vote_world_briefs_language_check
    check (language_code in ('it', 'en', 'de', 'fa')),
  constraint social_vote_world_briefs_title_check
    check (char_length(btrim(title)) between 1 and 240),
  constraint social_vote_world_briefs_happened_check
    check (char_length(btrim(what_happened)) between 1 and 12000),
  constraint social_vote_world_briefs_matters_check
    check (char_length(btrim(why_it_matters)) between 1 and 12000),
  constraint social_vote_world_briefs_uncertain_check
    check (
      what_is_uncertain is null
      or char_length(btrim(what_is_uncertain)) between 1 and 12000
    ),
  constraint social_vote_world_briefs_sources_shape_check
    check (jsonb_typeof(source_urls) = 'array'),
  constraint social_vote_world_briefs_country_check
    check (country_code is null or country_code ~ '^[A-Z]{2}$'),
  constraint social_vote_world_briefs_city_check
    check (
      city_id is null
      or char_length(btrim(city_id)) between 1 and 160
    ),
  constraint social_vote_world_briefs_location_check
    check (
      location_label is null
      or char_length(btrim(location_label)) between 1 and 240
    ),
  constraint social_vote_world_briefs_coordinate_pair_check
    check ((latitude is null) = (longitude is null)),
  constraint social_vote_world_briefs_latitude_check
    check (latitude is null or latitude between -90 and 90),
  constraint social_vote_world_briefs_longitude_check
    check (longitude is null or longitude between -180 and 180),
  constraint social_vote_world_briefs_priority_check
    check (priority between 0 and 100),
  constraint social_vote_world_briefs_published_shape_check
    check (status <> 'published' or published_at is not null),
  constraint social_vote_world_briefs_actor_fks_created
    foreign key (created_by) references auth.users (id) on delete restrict,
  constraint social_vote_world_briefs_actor_fks_updated
    foreign key (updated_by) references auth.users (id) on delete restrict,
  constraint social_vote_world_briefs_timestamps_check
    check (updated_at >= created_at)
);

comment on table public.social_vote_world_briefs is
  'Admin-authored Social Vote briefs with explicit evidence, uncertainty, publication state and optional Globe placement.';

create index if not exists social_vote_world_briefs_public_feed_idx
on public.social_vote_world_briefs (
  language_code,
  featured desc,
  priority desc,
  published_at desc
)
where status = 'published';

create index if not exists social_vote_world_briefs_admin_idx
on public.social_vote_world_briefs (status, updated_at desc);

alter table public.social_vote_world_briefs enable row level security;
alter table public.social_vote_world_briefs force row level security;

revoke all
on table public.social_vote_world_briefs
from public, anon, authenticated;

grant select (
  id,
  status,
  language_code,
  title,
  what_happened,
  why_it_matters,
  what_is_uncertain,
  source_urls,
  country_code,
  city_id,
  location_label,
  latitude,
  longitude,
  map_visible,
  featured,
  breaking,
  priority,
  published_at,
  expires_at,
  created_at,
  updated_at
)
on table public.social_vote_world_briefs
to anon, authenticated;

grant insert, update, delete
on table public.social_vote_world_briefs
to authenticated;

drop policy if exists social_vote_world_briefs_public_read
on public.social_vote_world_briefs;

create policy social_vote_world_briefs_public_read
on public.social_vote_world_briefs
for select
to anon, authenticated
using (
  status = 'published'
  and (expires_at is null or expires_at > clock_timestamp())
);

drop policy if exists social_vote_world_briefs_admin_read
on public.social_vote_world_briefs;

create policy social_vote_world_briefs_admin_read
on public.social_vote_world_briefs
for select
to authenticated
using ((select public.is_current_auth_user_admin()));

drop policy if exists social_vote_world_briefs_admin_insert
on public.social_vote_world_briefs;

create policy social_vote_world_briefs_admin_insert
on public.social_vote_world_briefs
for insert
to authenticated
with check (
  (select public.is_current_auth_user_admin())
  and created_by = (select auth.uid())
  and updated_by = (select auth.uid())
);

drop policy if exists social_vote_world_briefs_admin_update
on public.social_vote_world_briefs;

create policy social_vote_world_briefs_admin_update
on public.social_vote_world_briefs
for update
to authenticated
using ((select public.is_current_auth_user_admin()))
with check (
  (select public.is_current_auth_user_admin())
  and updated_by = (select auth.uid())
);

drop policy if exists social_vote_world_briefs_admin_delete_draft
on public.social_vote_world_briefs;

create policy social_vote_world_briefs_admin_delete_draft
on public.social_vote_world_briefs
for delete
to authenticated
using (
  (select public.is_current_auth_user_admin())
  and status = 'draft'
);

create or replace function app_private.prepare_social_vote_world_brief()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_source text;
begin
  if (select auth.uid()) is null then
    raise exception using
      errcode = '42501',
      message = 'Authenticated admin required.';
  end if;

  if not public.is_current_auth_user_admin() then
    raise exception using
      errcode = '42501',
      message = 'Admin permission required.';
  end if;

  new.language_code := lower(btrim(new.language_code));
  new.title := btrim(new.title);
  new.what_happened := btrim(new.what_happened);
  new.why_it_matters := btrim(new.why_it_matters);
  new.what_is_uncertain := nullif(btrim(new.what_is_uncertain), '');
  new.country_code := upper(nullif(btrim(new.country_code), ''));
  new.city_id := nullif(btrim(new.city_id), '');
  new.location_label := nullif(btrim(new.location_label), '');
  new.updated_by := auth.uid();
  new.updated_at := clock_timestamp();

  if tg_op = 'INSERT' then
    new.created_by := auth.uid();
    new.created_at := clock_timestamp();
  else
    new.created_by := old.created_by;
    new.created_at := old.created_at;
  end if;

  if new.map_visible and (new.latitude is null or new.longitude is null) then
    raise exception using
      errcode = '22023',
      message = 'Globe visibility requires latitude and longitude.';
  end if;

  if new.status = 'published' then
    if (
      select count(distinct btrim(source_value))
      from jsonb_array_elements_text(new.source_urls) source_value
      where nullif(btrim(source_value), '') is not null
    ) < 2 then
      raise exception using
        errcode = '22023',
        message = 'Published World Briefs require at least two sources.';
    end if;

    if new.expires_at is not null and new.expires_at <= clock_timestamp() then
      raise exception using
        errcode = '22023',
        message = 'A published World Brief cannot already be expired.';
    end if;

    for v_source in
      select jsonb_array_elements_text(new.source_urls)
    loop
      if v_source !~ '^https://[^[:space:]]+$' then
        raise exception using
          errcode = '22023',
          message = 'World Brief sources must be HTTPS URLs.';
      end if;
    end loop;

    if tg_op = 'INSERT' then
      new.published_at := clock_timestamp();
    elsif new.published_at is null or old.status is distinct from 'published' then
      new.published_at := clock_timestamp();
    end if;
  end if;

  return new;
end;
$$;

revoke all
on function app_private.prepare_social_vote_world_brief()
from public, anon, authenticated;

drop trigger if exists social_vote_world_brief_prepare
on public.social_vote_world_briefs;

create trigger social_vote_world_brief_prepare
before insert or update
on public.social_vote_world_briefs
for each row
execute function app_private.prepare_social_vote_world_brief();

create table if not exists app_private.social_vote_world_brief_audit (
  id bigint generated always as identity primary key,
  brief_id uuid not null,
  operation text not null,
  changed_by uuid,
  changed_at timestamptz not null default clock_timestamp(),
  old_row jsonb,
  new_row jsonb,
  constraint social_vote_world_brief_audit_operation_check
    check (operation in ('INSERT', 'UPDATE', 'DELETE'))
);

revoke all
on table app_private.social_vote_world_brief_audit
from public, anon, authenticated;

grant select
on table app_private.social_vote_world_brief_audit
to service_role;

create or replace function app_private.audit_social_vote_world_brief()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_brief_id uuid;
begin
  v_brief_id := case when tg_op = 'DELETE' then old.id else new.id end;

  insert into app_private.social_vote_world_brief_audit (
    brief_id,
    operation,
    changed_by,
    old_row,
    new_row
  ) values (
    v_brief_id,
    tg_op,
    coalesce(auth.uid(), case when tg_op = 'DELETE' then old.updated_by else new.updated_by end),
    case when tg_op in ('UPDATE', 'DELETE') then to_jsonb(old) else null end,
    case when tg_op in ('INSERT', 'UPDATE') then to_jsonb(new) else null end
  );

  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end;
$$;

revoke all
on function app_private.audit_social_vote_world_brief()
from public, anon, authenticated;

drop trigger if exists social_vote_world_brief_audit
on public.social_vote_world_briefs;

create trigger social_vote_world_brief_audit
after insert or update or delete
on public.social_vote_world_briefs
for each row
execute function app_private.audit_social_vote_world_brief();

create or replace function app_private.register_social_vote_world_brief_news()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.news_articles (
    id,
    provider_id,
    provider_article_id,
    canonical_url,
    published_at,
    first_seen_at,
    last_seen_at,
    created_at,
    updated_at
  ) values (
    new.id,
    'social_vote_editorial',
    new.id::text,
    'https://socialevote.com/news/' || new.id::text,
    new.published_at,
    new.created_at,
    clock_timestamp(),
    new.created_at,
    clock_timestamp()
  )
  on conflict (id) do update set
    published_at = excluded.published_at,
    last_seen_at = clock_timestamp(),
    updated_at = clock_timestamp();

  return new;
end;
$$;

revoke all
on function app_private.register_social_vote_world_brief_news()
from public, anon, authenticated;

drop trigger if exists social_vote_world_brief_register_news
on public.social_vote_world_briefs;

create trigger social_vote_world_brief_register_news
after insert or update of status, published_at
on public.social_vote_world_briefs
for each row
when (new.status = 'published')
execute function app_private.register_social_vote_world_brief_news();

create or replace function public.organization_public_get_by_id(
  p_organization_id uuid
)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'id', oe.id,
    'legal_name', oe.legal_name,
    'public_name', oe.public_name,
    'slug', oe.slug,
    'entity_type', oe.entity_type,
    'country_code', oe.country_code,
    'city', oe.city,
    'website_url', oe.website_url,
    'description', oe.description,
    'logo_url', oe.logo_url,
    'cover_url', oe.cover_url,
    'verification_status', oe.verification_status,
    'verified_at', oe.verified_at
  )
  from public.organization_entities oe
  where oe.id = p_organization_id
    and oe.verification_status = 'verified'
  limit 1;
$$;

revoke all
on function public.organization_public_get_by_id(uuid)
from public;

grant execute
on function public.organization_public_get_by_id(uuid)
to anon, authenticated;

notify pgrst, 'reload schema';

commit;

select
  'WORLD BRIEFS / PUBLIC ORGANIZATION FOUNDATION APPLIED' as result,
  to_regclass('public.social_vote_world_briefs') is not null as brief_table,
  to_regclass('app_private.social_vote_world_brief_audit') is not null as audit_table,
  to_regprocedure('public.organization_public_get_by_id(uuid)') is not null
    as organization_lookup,
  (
    select count(*) = 5
    from pg_policies
    where schemaname = 'public'
      and tablename = 'social_vote_world_briefs'
  ) as rls_policies_ready;
