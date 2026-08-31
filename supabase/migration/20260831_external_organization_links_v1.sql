-- Social Vote External Organization Links V1
-- Declared public links only. No OAuth tokens, provider secrets or automatic
-- Social Vote verification/Workspace entitlement are introduced here.

begin;

create extension if not exists pgcrypto with schema extensions;

create or replace function public.external_account_link_url_is_valid(
  p_provider text,
  p_url text
)
returns boolean
language sql
immutable
parallel safe
set search_path = ''
as $$
  select
    p_provider in ('youtube', 'linkedin', 'whatsapp', 'instagram', 'telegram')
    and p_url is not null
    and char_length(p_url) between 10 and 500
    and p_url !~ '[[:space:][:cntrl:]]'
    and position('#' in p_url) = 0
    and p_url ~* '^https://'
    and case p_provider
      when 'youtube' then
        p_url ~* '^https://([a-z0-9-]+[.])*youtube[.]com(:443)?(/|$)'
      when 'linkedin' then
        p_url ~* '^https://([a-z0-9-]+[.])*linkedin[.]com(:443)?(/|$)'
      when 'whatsapp' then
        p_url ~* '^https://(wa[.]me|([a-z0-9-]+[.])*whatsapp[.]com)(:443)?(/|$)'
      when 'instagram' then
        p_url ~* '^https://([a-z0-9-]+[.])*instagram[.]com(:443)?(/|$)'
      when 'telegram' then
        p_url ~* '^https://(t[.]me|([a-z0-9-]+[.])*telegram[.]me)(:443)?(/|$)'
      else false
    end;
$$;

revoke all
on function public.external_account_link_url_is_valid(text, text)
from public, anon, authenticated;

create table if not exists public.external_account_links (
  id uuid primary key default gen_random_uuid(),
  subject_type text not null
    constraint external_account_links_subject_value_check
    check (subject_type in ('person', 'organization')),
  user_id uuid references public.user_profiles(id) on delete cascade,
  organization_id uuid
    references public.organization_entities(id) on delete cascade,
  provider text not null
    check (provider in (
      'youtube', 'linkedin', 'whatsapp', 'instagram', 'telegram'
    )),
  connection_mode text not null default 'declared'
    check (connection_mode in (
      'declared', 'oauth_connected', 'ownership_verified'
    )),
  external_subject_id text,
  handle text,
  canonical_url text not null,
  display_name text,
  visibility text not null default 'public'
    check (visibility in ('public', 'private')),
  status text not null default 'active'
    check (status in ('active', 'disabled')),
  verified_at timestamptz,
  created_by uuid not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint external_account_links_exactly_one_subject_check
    check ((user_id is null) <> (organization_id is null)),
  constraint external_account_links_subject_type_check
    check (
      (subject_type = 'person' and user_id is not null)
      or
      (subject_type = 'organization' and organization_id is not null)
    ),
  constraint external_account_links_external_subject_length_check
    check (
      external_subject_id is null
      or char_length(btrim(external_subject_id)) between 1 and 300
    ),
  constraint external_account_links_handle_length_check
    check (
      handle is null or char_length(btrim(handle)) between 1 and 160
    ),
  constraint external_account_links_display_name_length_check
    check (
      display_name is null
      or char_length(btrim(display_name)) between 1 and 200
    ),
  constraint external_account_links_url_check
    check (
      public.external_account_link_url_is_valid(provider, canonical_url)
    ),
  constraint external_account_links_ownership_verified_check
    check (
      connection_mode <> 'ownership_verified' or verified_at is not null
    )
);

create unique index if not exists external_account_links_organization_provider_uidx
on public.external_account_links (organization_id, provider)
where organization_id is not null;

create unique index if not exists external_account_links_user_provider_uidx
on public.external_account_links (user_id, provider)
where user_id is not null;

create unique index if not exists external_account_links_provider_subject_uidx
on public.external_account_links (provider, external_subject_id)
where external_subject_id is not null;

create index if not exists external_account_links_public_org_idx
on public.external_account_links (organization_id, provider)
where subject_type = 'organization'
  and visibility = 'public'
  and status = 'active';

alter table public.external_account_links enable row level security;
alter table public.external_account_links force row level security;

revoke all
on table public.external_account_links
from public, anon, authenticated;

create or replace function public.organization_external_links_list_mine()
returns table (
  id uuid,
  organization_id uuid,
  provider text,
  canonical_url text,
  connection_mode text,
  visibility text,
  status text,
  verified_at timestamptz
)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_organization_id uuid;
begin
  if v_user_id is null or not public.is_current_auth_user_active() then
    raise exception using
      errcode = '42501',
      message = 'Active authentication required.';
  end if;

  select om.organization_id
  into v_organization_id
  from public.organization_memberships om
  where om.user_id = v_user_id
    and om.status = 'active'
  order by (om.membership_role = 'owner') desc, om.created_at asc
  limit 1;

  if v_organization_id is null then
    return;
  end if;

  return query
  select
    eal.id,
    eal.organization_id,
    eal.provider,
    eal.canonical_url,
    eal.connection_mode,
    eal.visibility,
    eal.status,
    eal.verified_at
  from public.external_account_links eal
  where eal.organization_id = v_organization_id
    and eal.subject_type = 'organization'
  order by array_position(
    array['youtube', 'linkedin', 'whatsapp', 'instagram', 'telegram']::text[],
    eal.provider
  );
end;
$$;

revoke all
on function public.organization_external_links_list_mine()
from public, anon;

grant execute
on function public.organization_external_links_list_mine()
to authenticated;

create or replace function public.organization_external_links_public(
  p_organization_id uuid
)
returns table (
  id uuid,
  organization_id uuid,
  provider text,
  canonical_url text,
  connection_mode text,
  visibility text,
  status text,
  verified_at timestamptz
)
language sql
stable
security definer
set search_path = ''
as $$
  select
    eal.id,
    eal.organization_id,
    eal.provider,
    eal.canonical_url,
    eal.connection_mode,
    eal.visibility,
    eal.status,
    eal.verified_at
  from public.external_account_links eal
  join public.organization_entities oe
    on oe.id = eal.organization_id
  where eal.organization_id = p_organization_id
    and eal.subject_type = 'organization'
    and eal.visibility = 'public'
    and eal.status = 'active'
    and oe.verification_status = 'verified'
  order by array_position(
    array['youtube', 'linkedin', 'whatsapp', 'instagram', 'telegram']::text[],
    eal.provider
  );
$$;

revoke all
on function public.organization_external_links_public(uuid)
from public;

grant execute
on function public.organization_external_links_public(uuid)
to anon, authenticated;

create or replace function public.organization_external_links_replace(
  p_links jsonb
)
returns table (
  id uuid,
  organization_id uuid,
  provider text,
  canonical_url text,
  connection_mode text,
  visibility text,
  status text,
  verified_at timestamptz
)
language plpgsql
volatile
security definer
set search_path = ''
as $$
#variable_conflict use_column
declare
  v_user_id uuid := auth.uid();
  v_organization_id uuid;
  v_role text;
  v_item jsonb;
  v_provider text;
  v_url text;
  v_seen text[] := array[]::text[];
  v_row_count integer := 0;
  v_change_count integer := 0;
begin
  if v_user_id is null or not public.is_current_auth_user_active() then
    raise exception using
      errcode = '42501',
      message = 'Active authentication required.';
  end if;

  select om.organization_id, om.membership_role
  into v_organization_id, v_role
  from public.organization_memberships om
  where om.user_id = v_user_id
    and om.status = 'active'
  order by (om.membership_role = 'owner') desc, om.created_at asc
  limit 1;

  if v_organization_id is null or v_role not in ('owner', 'manager') then
    raise exception using
      errcode = '42501',
      message = 'Organization manager permission required.';
  end if;

  if p_links is null or jsonb_typeof(p_links) <> 'array' then
    raise exception using
      errcode = '22023',
      message = 'External links must be a JSON array.';
  end if;

  if jsonb_array_length(p_links) > 5 then
    raise exception using
      errcode = '22023',
      message = 'Too many external links.';
  end if;

  for v_item in select value from jsonb_array_elements(p_links)
  loop
    if jsonb_typeof(v_item) <> 'object' then
      raise exception using
        errcode = '22023',
        message = 'Each external link must be an object.';
    end if;

    v_provider := lower(btrim(coalesce(v_item ->> 'provider', '')));
    v_url := btrim(coalesce(v_item ->> 'canonical_url', ''));

    if v_provider not in (
      'youtube', 'linkedin', 'whatsapp', 'instagram', 'telegram'
    ) then
      raise exception using
        errcode = '22023',
        message = 'Unsupported external link provider.';
    end if;

    if v_provider = any(v_seen) then
      raise exception using
        errcode = '22023',
        message = 'Duplicate external link provider.';
    end if;

    if not public.external_account_link_url_is_valid(v_provider, v_url) then
      raise exception using
        errcode = '22023',
        message = 'Invalid official provider URL.';
    end if;

    v_seen := array_append(v_seen, v_provider);

    insert into public.external_account_links as current_link (
      subject_type,
      organization_id,
      provider,
      connection_mode,
      canonical_url,
      visibility,
      status,
      created_by
    ) values (
      'organization',
      v_organization_id,
      v_provider,
      'declared',
      v_url,
      'public',
      'active',
      v_user_id
    )
    on conflict (organization_id, provider)
      where organization_id is not null
    do update set
      canonical_url = excluded.canonical_url,
      connection_mode = 'declared',
      external_subject_id = null,
      handle = null,
      display_name = null,
      visibility = 'public',
      status = 'active',
      verified_at = null,
      updated_at = now()
    where
      current_link.canonical_url is distinct from excluded.canonical_url
      or current_link.connection_mode <> 'declared'
      or current_link.visibility <> 'public'
      or current_link.status <> 'active'
      or current_link.external_subject_id is not null
      or current_link.handle is not null
      or current_link.display_name is not null
      or current_link.verified_at is not null;

    get diagnostics v_row_count = row_count;
    v_change_count := v_change_count + v_row_count;
  end loop;

  delete from public.external_account_links eal
  where eal.organization_id = v_organization_id
    and eal.subject_type = 'organization'
    and not (eal.provider = any(v_seen));

  get diagnostics v_row_count = row_count;
  v_change_count := v_change_count + v_row_count;

  if v_change_count > 0 then
    insert into public.organization_session_audit (
      organization_id,
      actor_user_id,
      event_key,
      metadata
    ) values (
      v_organization_id,
      v_user_id,
      'organization_external_links_replaced',
      jsonb_build_object(
        'providers', to_jsonb(v_seen),
        'count', cardinality(v_seen)
      )
    );
  end if;

  return query
  select
    eal.id,
    eal.organization_id,
    eal.provider,
    eal.canonical_url,
    eal.connection_mode,
    eal.visibility,
    eal.status,
    eal.verified_at
  from public.external_account_links eal
  where eal.organization_id = v_organization_id
    and eal.subject_type = 'organization'
  order by array_position(
    array['youtube', 'linkedin', 'whatsapp', 'instagram', 'telegram']::text[],
    eal.provider
  );
end;
$$;

revoke all
on function public.organization_external_links_replace(jsonb)
from public, anon;

grant execute
on function public.organization_external_links_replace(jsonb)
to authenticated;

notify pgrst, 'reload schema';

commit;

select 'EXTERNAL ORGANIZATION LINKS V1 APPLIED' as result;
