-- Social Vote
-- News Map editorial control for Civic Map / Globe.
--
-- Feed scope remains separate from the real article location. Public clients
-- can read only non-expired rows. Only active admins can write through the API.
-- SQL Editor/service-role maintenance must always provide updated_by.

begin;

create table if not exists public.news_map_editorial (
  news_id uuid primary key,
  map_visible boolean not null default true,
  featured boolean not null default false,
  priority smallint not null default 0,
  latitude double precision,
  longitude double precision,
  country_code text,
  city_id text,
  location_label text,
  expires_at timestamptz not null default (clock_timestamp() + interval '30 days'),
  updated_by uuid not null,
  created_at timestamptz not null default clock_timestamp(),
  updated_at timestamptz not null default clock_timestamp(),

  constraint news_map_editorial_news_fk
    foreign key (news_id)
    references public.news_articles (id)
    on delete cascade,

  constraint news_map_editorial_updated_by_fk
    foreign key (updated_by)
    references auth.users (id)
    on delete restrict,

  constraint news_map_editorial_priority_check
    check (priority between 0 and 100),

  constraint news_map_editorial_coordinate_pair_check
    check ((latitude is null) = (longitude is null)),

  constraint news_map_editorial_latitude_check
    check (latitude is null or latitude between -90 and 90),

  constraint news_map_editorial_longitude_check
    check (longitude is null or longitude between -180 and 180),

  constraint news_map_editorial_country_code_check
    check (country_code is null or country_code ~ '^[A-Z]{2}$'),

  constraint news_map_editorial_city_id_check
    check (
      city_id is null
      or (
        nullif(btrim(city_id), '') is not null
        and char_length(city_id) <= 160
      )
    ),

  constraint news_map_editorial_location_label_check
    check (
      location_label is null
      or (
        nullif(btrim(location_label), '') is not null
        and char_length(location_label) <= 240
      )
    ),

  constraint news_map_editorial_timestamps_check
    check (updated_at >= created_at)
);

comment on table public.news_map_editorial is
  'Expiring editorial visibility, ranking and location overrides for canonical News markers.';

comment on column public.news_map_editorial.news_id is
  'Canonical public.news_articles UUID; never a provider-only or Flutter-generated alias.';

comment on column public.news_map_editorial.priority is
  'Editorial Map/Globe priority from 0 to 100; it does not change feed ordering.';

comment on column public.news_map_editorial.expires_at is
  'Required expiry after which the public client ignores the editorial override.';

create index if not exists news_map_editorial_active_priority_idx
on public.news_map_editorial (
  featured desc,
  priority desc,
  expires_at
)
where map_visible;

alter table public.news_map_editorial enable row level security;
alter table public.news_map_editorial force row level security;

revoke all
on table public.news_map_editorial
from public, anon, authenticated;

grant select (
  news_id,
  map_visible,
  featured,
  priority,
  latitude,
  longitude,
  country_code,
  city_id,
  location_label,
  expires_at
)
on table public.news_map_editorial
to anon, authenticated;

grant insert, update, delete
on table public.news_map_editorial
to authenticated;

drop policy if exists news_map_editorial_select_active
on public.news_map_editorial;

create policy news_map_editorial_select_active
on public.news_map_editorial
for select
to anon, authenticated
using (expires_at > clock_timestamp());

drop policy if exists news_map_editorial_admin_insert
on public.news_map_editorial;

create policy news_map_editorial_admin_insert
on public.news_map_editorial
for insert
to authenticated
with check (
  (select public.is_current_auth_user_admin())
  and updated_by = (select auth.uid())
);

drop policy if exists news_map_editorial_admin_update
on public.news_map_editorial;

create policy news_map_editorial_admin_update
on public.news_map_editorial
for update
to authenticated
using (
  (select public.is_current_auth_user_admin())
)
with check (
  (select public.is_current_auth_user_admin())
  and updated_by = (select auth.uid())
);

drop policy if exists news_map_editorial_admin_delete
on public.news_map_editorial;

create policy news_map_editorial_admin_delete
on public.news_map_editorial
for delete
to authenticated
using (
  (select public.is_current_auth_user_admin())
);

create or replace function app_private.prepare_news_map_editorial_write()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    new.created_at := coalesce(new.created_at, clock_timestamp());
  else
    new.created_at := old.created_at;
  end if;

  new.updated_at := clock_timestamp();

  if auth.uid() is not null then
    new.updated_by := auth.uid();
  end if;

  return new;
end;
$$;

revoke all
on function app_private.prepare_news_map_editorial_write()
from public, anon, authenticated;

drop trigger if exists news_map_editorial_prepare_write
on public.news_map_editorial;

create trigger news_map_editorial_prepare_write
before insert or update
on public.news_map_editorial
for each row
execute function app_private.prepare_news_map_editorial_write();

create or replace view app_private.news_map_editorial_candidates
with (security_invoker = true)
as
select distinct on (lower(item ->> 'news_id'))
  lower(item ->> 'news_id')::uuid as news_id,
  nullif(btrim(item ->> 'title'), '') as title,
  nullif(
    btrim(
      coalesce(
        item ->> 'url',
        item ->> 'article_url',
        item ->> 'articleUrl'
      )
    ),
    ''
  ) as article_url,
  nullif(
    btrim(
      coalesce(
        item ->> 'publishedAt',
        item ->> 'published_at'
      )
    ),
    ''
  ) as published_at,
  cache.country_code as feed_country_code,
  cache.city_id as feed_city_id,
  nullif(btrim(location.location_json ->> 'countryCode'), '')
    as detected_country_code,
  nullif(btrim(location.location_json ->> 'cityId'), '')
    as detected_city_id,
  nullif(btrim(location.location_json ->> 'cityName'), '')
    as detected_location_label,
  nullif(
    btrim(
      coalesce(
        location.location_json ->> 'latitude',
        location.location_json ->> 'centerLat'
      )
    ),
    ''
  ) as detected_latitude,
  nullif(
    btrim(
      coalesce(
        location.location_json ->> 'longitude',
        location.location_json ->> 'centerLng'
      )
    ),
    ''
  ) as detected_longitude,
  cache.refreshed_at
from public.news_feed_cache cache
cross join lateral jsonb_array_elements(
  case
    when jsonb_typeof(cache.payload) = 'array' then cache.payload
    else '[]'::jsonb
  end
) item
cross join lateral (
  select coalesce(
    item -> '_sv_content_location',
    item -> 'content_location',
    item -> 'contentLocation',
    item -> '_content_location',
    '{}'::jsonb
  ) as location_json
) location
where coalesce(item ->> 'news_id', '') ~*
  '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
order by lower(item ->> 'news_id'), cache.refreshed_at desc;

comment on view app_private.news_map_editorial_candidates is
  'SQL Editor/service-role catalog of canonical cached News and any already detected location.';

revoke all
on table app_private.news_map_editorial_candidates
from public, anon, authenticated;

grant select
on table app_private.news_map_editorial_candidates
to service_role;

create table if not exists app_private.news_map_editorial_audit (
  id bigint generated always as identity primary key,
  news_id uuid not null,
  operation text not null,
  changed_by uuid,
  changed_at timestamptz not null default clock_timestamp(),
  old_row jsonb,
  new_row jsonb,

  constraint news_map_editorial_audit_operation_check
    check (operation in ('INSERT', 'UPDATE', 'DELETE'))
);

comment on table app_private.news_map_editorial_audit is
  'Private immutable audit trail for every News Map editorial change.';

revoke all
on table app_private.news_map_editorial_audit
from public, anon, authenticated;

grant select
on table app_private.news_map_editorial_audit
to service_role;

create or replace function app_private.audit_news_map_editorial_write()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_news_id uuid;
  v_changed_by uuid;
begin
  if tg_op = 'DELETE' then
    v_news_id := old.news_id;
    v_changed_by := coalesce(auth.uid(), old.updated_by);
  else
    v_news_id := new.news_id;
    v_changed_by := coalesce(auth.uid(), new.updated_by);
  end if;

  insert into app_private.news_map_editorial_audit (
    news_id,
    operation,
    changed_by,
    changed_at,
    old_row,
    new_row
  )
  values (
    v_news_id,
    tg_op,
    v_changed_by,
    clock_timestamp(),
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
on function app_private.audit_news_map_editorial_write()
from public, anon, authenticated;

drop trigger if exists news_map_editorial_audit_write
on public.news_map_editorial;

create trigger news_map_editorial_audit_write
after insert or update or delete
on public.news_map_editorial
for each row
execute function app_private.audit_news_map_editorial_write();

notify pgrst, 'reload schema';

commit;

select
  'NEWS MAP EDITORIAL FOUNDATION APPLIED' as result,
  to_regclass('public.news_map_editorial') is not null as editorial_table,
  to_regclass('app_private.news_map_editorial_audit') is not null
    as audit_table,
  to_regclass('app_private.news_map_editorial_candidates') is not null
    as candidate_catalog,
  (
    select count(*) = 4
    from pg_policies
    where schemaname = 'public'
      and tablename = 'news_map_editorial'
  ) as rls_policies_ready;
