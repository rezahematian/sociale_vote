-- Social Vote - World Brief Admin Write Fix V5
-- Purpose:
-- 1) authorize World Brief administration against LIVE Auth app_metadata,
--    the public role mirror and the hardened active-session gate;
-- 2) move client mutations behind explicit SECURITY DEFINER RPCs;
-- 3) keep public reads RLS-protected and preserve all existing editorial checks.
--
-- This migration is additive/idempotent and does not publish content.

begin;

create or replace function public.is_current_auth_user_world_brief_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select
    (select auth.uid()) is not null
    and exists (
      select 1
      from auth.users au
      where au.id = (select auth.uid())
        and lower(coalesce(au.raw_app_meta_data ->> 'role', '')) = 'admin'
    )
    and exists (
      select 1
      from public.users pu
      where pu.id = (select auth.uid())
        and lower(coalesce(pu.role::text, '')) = 'admin'
    )
    and (select public.is_current_auth_user_active());
$$;

revoke all
on function public.is_current_auth_user_world_brief_admin()
from public, anon;

grant execute
on function public.is_current_auth_user_world_brief_admin()
to authenticated;

-- World Brief admin reads use the live authoritative role check. Public reads
-- remain unchanged and still expose only active published briefs.
drop policy if exists social_vote_world_briefs_admin_read
on public.social_vote_world_briefs;

create policy social_vote_world_briefs_admin_read
on public.social_vote_world_briefs
for select
to authenticated
using ((select public.is_current_auth_user_world_brief_admin()));

drop policy if exists social_vote_world_briefs_admin_insert
on public.social_vote_world_briefs;

create policy social_vote_world_briefs_admin_insert
on public.social_vote_world_briefs
for insert
to authenticated
with check (
  (select public.is_current_auth_user_world_brief_admin())
  and created_by = (select auth.uid())
  and updated_by = (select auth.uid())
);

drop policy if exists social_vote_world_briefs_admin_update
on public.social_vote_world_briefs;

create policy social_vote_world_briefs_admin_update
on public.social_vote_world_briefs
for update
to authenticated
using ((select public.is_current_auth_user_world_brief_admin()))
with check (
  (select public.is_current_auth_user_world_brief_admin())
  and updated_by = (select auth.uid())
);

drop policy if exists social_vote_world_briefs_admin_delete_draft
on public.social_vote_world_briefs;

create policy social_vote_world_briefs_admin_delete_draft
on public.social_vote_world_briefs
for delete
to authenticated
using (
  (select public.is_current_auth_user_world_brief_admin())
  and status = 'draft'
);

-- Preserve all Editorial V2 checks while switching the trigger authorization
-- to the live World Brief admin helper.
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
begin
  if (select auth.uid()) is null then
    raise exception using
      errcode = '42501',
      message = 'Authenticated admin required.';
  end if;

  if not public.is_current_auth_user_world_brief_admin() then
    raise exception using
      errcode = '42501',
      message = 'World Brief admin permission required.';
  end if;

  new.language_code := lower(btrim(new.language_code));
  new.title := btrim(new.title);
  new.what_happened := btrim(new.what_happened);
  new.why_it_matters := btrim(new.why_it_matters);
  new.what_is_uncertain := nullif(btrim(new.what_is_uncertain), '');
  new.social_vote_view := nullif(btrim(new.social_vote_view), '');
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

  if jsonb_array_length(new.source_urls) > 12 then
    raise exception using
      errcode = '22023',
      message = 'World Briefs support at most twelve source URLs.';
  end if;

  if new.status = 'published' then
    for v_source in
      select btrim(source_value)
      from jsonb_array_elements_text(new.source_urls) source_value
      where nullif(btrim(source_value), '') is not null
    loop
      if char_length(v_source) > 2048
         or v_source !~ '^https://[^[:space:]]+$' then
        raise exception using
          errcode = '22023',
          message = 'World Brief sources must be valid HTTPS URLs.';
      end if;

      v_host := regexp_replace(
        lower(substring(v_source from '^https://([^/:?#]+)')),
        '^www\.',
        ''
      );
      if v_host is null or v_host = '' then
        raise exception using
          errcode = '22023',
          message = 'World Brief sources must contain a valid HTTPS host.';
      end if;

      if not (v_host = any(v_hosts)) then
        v_hosts := array_append(v_hosts, v_host);
      end if;
    end loop;

    if cardinality(v_hosts) < 2 then
      raise exception using
        errcode = '22023',
        message = 'Published World Briefs require at least two independent source domains.';
    end if;

    if new.expires_at is not null and new.expires_at <= clock_timestamp() then
      raise exception using
        errcode = '22023',
        message = 'A published World Brief cannot already be expired.';
    end if;

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

-- Explicit write RPC. The client supplies editorial fields only; actor and
-- timestamps remain backend-owned and the existing trigger performs the final
-- normalization/validation.
create or replace function public.admin_world_brief_save(
  p_payload jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_id uuid;
  v_row public.social_vote_world_briefs%rowtype;
  v_sources jsonb;
begin
  if not public.is_current_auth_user_world_brief_admin() then
    raise exception using
      errcode = '42501',
      message = 'World Brief admin permission required.';
  end if;

  if p_payload is null or jsonb_typeof(p_payload) <> 'object' then
    raise exception using
      errcode = '22023',
      message = 'World Brief payload must be a JSON object.';
  end if;

  begin
    v_id := nullif(btrim(p_payload ->> 'id'), '')::uuid;
  exception
    when invalid_text_representation then
      raise exception using
        errcode = '22023',
        message = 'Invalid World Brief id.';
  end;

  v_sources := case
    when jsonb_typeof(p_payload -> 'source_urls') = 'array'
      then p_payload -> 'source_urls'
    else '[]'::jsonb
  end;

  if v_id is null then
    insert into public.social_vote_world_briefs (
      status,
      language_code,
      title,
      what_happened,
      why_it_matters,
      what_is_uncertain,
      social_vote_view,
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
      expires_at,
      created_by,
      updated_by
    ) values (
      'draft',
      coalesce(nullif(btrim(p_payload ->> 'language_code'), ''), 'en'),
      coalesce(p_payload ->> 'title', ''),
      coalesce(p_payload ->> 'what_happened', ''),
      coalesce(p_payload ->> 'why_it_matters', ''),
      p_payload ->> 'what_is_uncertain',
      p_payload ->> 'social_vote_view',
      v_sources,
      p_payload ->> 'country_code',
      p_payload ->> 'city_id',
      p_payload ->> 'location_label',
      nullif(p_payload ->> 'latitude', '')::double precision,
      nullif(p_payload ->> 'longitude', '')::double precision,
      coalesce(nullif(p_payload ->> 'map_visible', '')::boolean, false),
      coalesce(nullif(p_payload ->> 'featured', '')::boolean, false),
      coalesce(nullif(p_payload ->> 'breaking', '')::boolean, false),
      coalesce(nullif(p_payload ->> 'priority', '')::smallint, 50),
      nullif(p_payload ->> 'expires_at', '')::timestamptz,
      auth.uid(),
      auth.uid()
    )
    returning * into v_row;
  else
    update public.social_vote_world_briefs
    set
      status = 'draft',
      language_code = coalesce(nullif(btrim(p_payload ->> 'language_code'), ''), 'en'),
      title = coalesce(p_payload ->> 'title', ''),
      what_happened = coalesce(p_payload ->> 'what_happened', ''),
      why_it_matters = coalesce(p_payload ->> 'why_it_matters', ''),
      what_is_uncertain = p_payload ->> 'what_is_uncertain',
      social_vote_view = p_payload ->> 'social_vote_view',
      source_urls = v_sources,
      country_code = p_payload ->> 'country_code',
      city_id = p_payload ->> 'city_id',
      location_label = p_payload ->> 'location_label',
      latitude = nullif(p_payload ->> 'latitude', '')::double precision,
      longitude = nullif(p_payload ->> 'longitude', '')::double precision,
      map_visible = coalesce(nullif(p_payload ->> 'map_visible', '')::boolean, false),
      featured = coalesce(nullif(p_payload ->> 'featured', '')::boolean, false),
      breaking = coalesce(nullif(p_payload ->> 'breaking', '')::boolean, false),
      priority = coalesce(nullif(p_payload ->> 'priority', '')::smallint, 50),
      expires_at = nullif(p_payload ->> 'expires_at', '')::timestamptz,
      updated_by = auth.uid()
    where id = v_id
      and status = 'draft'
    returning * into v_row;

    if not found then
      raise exception using
        errcode = '22023',
        message = 'Only an existing draft can be edited.';
    end if;
  end if;

  return to_jsonb(v_row) - 'created_by' - 'updated_by';
end;
$$;

revoke all
on function public.admin_world_brief_save(jsonb)
from public, anon, authenticated;

grant execute
on function public.admin_world_brief_save(jsonb)
to authenticated;

create or replace function public.admin_world_brief_set_status(
  p_id uuid,
  p_status text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_status text := lower(btrim(coalesce(p_status, '')));
  v_row public.social_vote_world_briefs%rowtype;
begin
  if not public.is_current_auth_user_world_brief_admin() then
    raise exception using
      errcode = '42501',
      message = 'World Brief admin permission required.';
  end if;

  if p_id is null or v_status not in ('published', 'withdrawn') then
    raise exception using
      errcode = '22023',
      message = 'Invalid World Brief status change.';
  end if;

  update public.social_vote_world_briefs
  set
    status = v_status,
    updated_by = auth.uid()
  where id = p_id
  returning * into v_row;

  if not found then
    raise exception using
      errcode = '22023',
      message = 'World Brief not found.';
  end if;

  return to_jsonb(v_row) - 'created_by' - 'updated_by';
end;
$$;

revoke all
on function public.admin_world_brief_set_status(uuid, text)
from public, anon, authenticated;

grant execute
on function public.admin_world_brief_set_status(uuid, text)
to authenticated;

create or replace function public.admin_world_brief_delete_draft(
  p_id uuid
)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_deleted uuid;
begin
  if not public.is_current_auth_user_world_brief_admin() then
    raise exception using
      errcode = '42501',
      message = 'World Brief admin permission required.';
  end if;

  delete from public.social_vote_world_briefs
  where id = p_id
    and status = 'draft'
  returning id into v_deleted;

  if v_deleted is null then
    raise exception using
      errcode = '22023',
      message = 'World Brief draft not found.';
  end if;

  return true;
end;
$$;

revoke all
on function public.admin_world_brief_delete_draft(uuid)
from public, anon, authenticated;

grant execute
on function public.admin_world_brief_delete_draft(uuid)
to authenticated;

-- The authenticated client no longer writes this table directly. Mutations go
-- through the three narrow RPCs above. Read grants remain unchanged.
revoke insert, update, delete
on table public.social_vote_world_briefs
from authenticated;


-- Self-diagnostic capability endpoint. It exposes only the current caller's
-- authorization state and is useful when a browser session is stale/mismatched.
create or replace function public.world_brief_admin_capability()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'authenticated', (select auth.uid()) is not null,
    'live_auth_role', coalesce((
      select lower(au.raw_app_meta_data ->> 'role')
      from auth.users au
      where au.id = (select auth.uid())
    ), ''),
    'mirror_role', coalesce((
      select lower(pu.role::text)
      from public.users pu
      where pu.id = (select auth.uid())
    ), ''),
    'account_status', coalesce((
      select lower(ac.status::text)
      from app_private.account_controls ac
      where ac.user_id = (select auth.uid())
    ), ''),
    'jwt_session_id', coalesce((select auth.jwt() ->> 'session_id'), ''),
    'registered_session_id', coalesce((
      select aus.session_id::text
      from app_private.active_user_sessions aus
      where aus.user_id = (select auth.uid())
    ), ''),
    'active_session', (select public.is_current_auth_user_active()),
    'allowed', (select public.is_current_auth_user_world_brief_admin())
  );
$$;

revoke all
on function public.world_brief_admin_capability()
from public, anon, authenticated;

grant execute
on function public.world_brief_admin_capability()
to authenticated;

commit;
