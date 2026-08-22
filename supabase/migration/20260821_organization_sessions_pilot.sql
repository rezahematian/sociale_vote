-- Social Vote Organizations + Sessions Pilot
-- Billing remains OFF. No L1/L2 runtime is introduced by this migration.

begin;

create extension if not exists pgcrypto with schema extensions;

-- ============================================================
-- ORGANIZATION ENTITY + WORKSPACE
-- ============================================================

create table if not exists public.organization_entities (
  id uuid primary key default gen_random_uuid(),
  legal_name text not null,
  public_name text not null,
  slug text not null unique,
  entity_type text not null default 'other'
    check (entity_type in (
      'association','nonprofit','company','cooperative','sports',
      'public_body','committee','other'
    )),
  country_code text
    check (country_code is null or country_code ~ '^[A-Z]{2}$'),
  city text,
  website_url text,
  description text,
  logo_url text,
  cover_url text,
  verification_status text not null default 'verified'
    check (verification_status in ('verified','suspended','expired')),
  verification_source text not null default 'legacy_profile',
  verified_at timestamptz,
  created_by uuid not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.organization_memberships (
  organization_id uuid not null references public.organization_entities(id) on delete cascade,
  user_id uuid not null,
  membership_role text not null
    check (membership_role in ('owner','manager','operator','viewer')),
  status text not null default 'active'
    check (status in ('active','revoked')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (organization_id, user_id)
);

create unique index if not exists organization_one_active_owner_idx
on public.organization_memberships (organization_id)
where membership_role = 'owner' and status = 'active';

create table if not exists public.organization_workspaces (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null unique references public.organization_entities(id) on delete cascade,
  plan_key text not null default 'pilot' check (plan_key in ('pilot','free','pro','team')),
  status text not null default 'active' check (status in ('active','restricted','suspended','closed')),
  commercial_mode text not null default 'pilot_free'
    check (commercial_mode in ('pilot_free','free','paid')),
  billing_enabled boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ============================================================
-- LIVE SESSIONS
-- ============================================================

create table if not exists public.live_sessions (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.organization_workspaces(id) on delete cascade,
  created_by uuid not null,
  title text not null check (char_length(btrim(title)) between 1 and 180),
  join_code text not null unique,
  status text not null default 'draft'
    check (status in ('draft','open','closed','archived')),
  access_mode text not null
    check (access_mode in ('open_anonymous','controlled_token_pool')),
  results_visibility text not null
    check (results_visibility in ('live','after_vote','after_close','organizer_only')),
  raw_retention text not null default '7d'
    check (raw_retention in ('24h','7d','30d')),
  delete_raw_after timestamptz,
  expected_participants integer not null default 25
    check (expected_participants between 1 and 250),
  max_participants integer not null default 250
    check (max_participants between 1 and 250),
  opened_at timestamptz,
  first_ballot_at timestamptz,
  closed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists live_sessions_workspace_created_idx
on public.live_sessions (workspace_id, created_at desc);

create table if not exists public.live_questions (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.live_sessions(id) on delete cascade,
  position integer not null,
  title text not null check (char_length(btrim(title)) between 1 and 500),
  question_type text not null
    check (question_type in ('yes_no','single_choice','multiple_choice')),
  min_selections integer not null default 1 check (min_selections between 1 and 20),
  max_selections integer not null default 1 check (max_selections between 1 and 20),
  status text not null default 'draft' check (status in ('draft','open','closed')),
  opened_at timestamptz,
  closed_at timestamptz,
  created_at timestamptz not null default now(),
  unique (session_id, position)
);

create table if not exists public.live_options (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.live_questions(id) on delete cascade,
  position integer not null,
  option_key text check (option_key is null or option_key in ('yes','no')),
  label text,
  created_at timestamptz not null default now(),
  unique (question_id, position),
  check (option_key is not null or nullif(btrim(label), '') is not null)
);

create table if not exists public.live_access_tokens (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.live_sessions(id) on delete cascade,
  token_hash text not null,
  status text not null default 'active' check (status in ('active','revoked')),
  created_at timestamptz not null default now(),
  unique (session_id, token_hash)
);

create table if not exists public.live_participant_credentials (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.live_sessions(id) on delete cascade,
  token_id uuid references public.live_access_tokens(id) on delete cascade,
  secret_hash text not null unique,
  expires_at timestamptz not null,
  created_at timestamptz not null default now()
);

create index if not exists live_participant_credentials_session_idx
on public.live_participant_credentials (session_id);

create table if not exists public.live_token_question_uses (
  question_id uuid not null references public.live_questions(id) on delete cascade,
  token_id uuid not null references public.live_access_tokens(id) on delete cascade,
  primary key (question_id, token_id)
);

create table if not exists public.live_open_question_uses (
  question_id uuid not null references public.live_questions(id) on delete cascade,
  credential_id uuid not null references public.live_participant_credentials(id) on delete cascade,
  primary key (question_id, credential_id)
);

-- Ballots intentionally contain no user/token/credential foreign key.
create table if not exists public.live_ballots (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.live_questions(id) on delete cascade,
  option_ids uuid[] not null,
  receipt_hash text not null unique
);

create index if not exists live_ballots_question_idx
on public.live_ballots (question_id);

create table if not exists public.organization_session_audit (
  id bigint generated by default as identity primary key,
  organization_id uuid not null references public.organization_entities(id) on delete cascade,
  session_id uuid references public.live_sessions(id) on delete set null,
  actor_user_id uuid,
  event_key text not null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.live_verified_reports (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null unique references public.live_sessions(id) on delete cascade,
  organization_id uuid not null references public.organization_entities(id) on delete cascade,
  snapshot jsonb not null,
  snapshot_sha256 text not null,
  created_at timestamptz not null default now()
);

create or replace function public.prevent_verified_report_mutation()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if tg_op = 'DELETE' and current_user in ('postgres','supabase_admin','service_role') then
    return old;
  end if;
  raise exception using errcode = '55000',
    message = 'Verified Result snapshots are immutable.';
end;
$$;

revoke all on function public.prevent_verified_report_mutation() from public, anon, authenticated;

drop trigger if exists live_verified_reports_immutable on public.live_verified_reports;
create trigger live_verified_reports_immutable
before update or delete on public.live_verified_reports
for each row execute function public.prevent_verified_report_mutation();

-- ============================================================
-- RLS: normal clients never write Session internals directly.
-- ============================================================

alter table public.organization_entities enable row level security;
alter table public.organization_memberships enable row level security;
alter table public.organization_workspaces enable row level security;
alter table public.live_sessions enable row level security;
alter table public.live_questions enable row level security;
alter table public.live_options enable row level security;
alter table public.live_access_tokens enable row level security;
alter table public.live_participant_credentials enable row level security;
alter table public.live_token_question_uses enable row level security;
alter table public.live_open_question_uses enable row level security;
alter table public.live_ballots enable row level security;
alter table public.organization_session_audit enable row level security;
alter table public.live_verified_reports enable row level security;

revoke all on table public.organization_entities from public, anon, authenticated;
revoke all on table public.organization_memberships from public, anon, authenticated;
revoke all on table public.organization_workspaces from public, anon, authenticated;
revoke all on table public.live_sessions from public, anon, authenticated;
revoke all on table public.live_questions from public, anon, authenticated;
revoke all on table public.live_options from public, anon, authenticated;
revoke all on table public.live_access_tokens from public, anon, authenticated;
revoke all on table public.live_participant_credentials from public, anon, authenticated;
revoke all on table public.live_token_question_uses from public, anon, authenticated;
revoke all on table public.live_open_question_uses from public, anon, authenticated;
revoke all on table public.live_ballots from public, anon, authenticated;
revoke all on table public.organization_session_audit from public, anon, authenticated;
revoke all on table public.live_verified_reports from public, anon, authenticated;

-- ============================================================
-- SECURITY HELPERS
-- ============================================================

create or replace function public.organization_member_role(
  p_organization_id uuid
)
returns text
language sql
stable
security definer
set search_path = public
as $$
  select om.membership_role
  from public.organization_memberships om
  where om.organization_id = p_organization_id
    and om.user_id = auth.uid()
    and om.status = 'active'
  limit 1;
$$;

revoke all on function public.organization_member_role(uuid) from public, anon;
grant execute on function public.organization_member_role(uuid) to authenticated;

create or replace function public.organization_user_can_manage(
  p_organization_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select auth.uid() is not null and exists (
    select 1
    from public.organization_memberships om
    where om.organization_id = p_organization_id
      and om.user_id = auth.uid()
      and om.status = 'active'
      and om.membership_role in ('owner','manager')
  );
$$;

revoke all on function public.organization_user_can_manage(uuid) from public, anon;
grant execute on function public.organization_user_can_manage(uuid) to authenticated;

create or replace function public.organization_user_can_operate(
  p_organization_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select auth.uid() is not null and exists (
    select 1
    from public.organization_memberships om
    where om.organization_id = p_organization_id
      and om.user_id = auth.uid()
      and om.status = 'active'
      and om.membership_role in ('owner','manager','operator')
  );
$$;

revoke all on function public.organization_user_can_operate(uuid) from public, anon;
grant execute on function public.organization_user_can_operate(uuid) to authenticated;

-- ============================================================
-- ORGANIZATION RPC
-- ============================================================

create or replace function public.organization_get_mine()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_result jsonb;
begin
  if v_user_id is null or not public.is_current_auth_user_active() then
    raise exception using errcode = '42501', message = 'Active authentication required.';
  end if;

  select jsonb_build_object(
    'organization', to_jsonb(oe),
    'workspace', to_jsonb(ow),
    'membership_role', om.membership_role
  )
  into v_result
  from public.organization_memberships om
  join public.organization_entities oe on oe.id = om.organization_id
  join public.organization_workspaces ow on ow.organization_id = oe.id
  where om.user_id = v_user_id
    and om.status = 'active'
  order by (om.membership_role = 'owner') desc, om.created_at asc
  limit 1;

  return v_result;
end;
$$;

revoke all on function public.organization_get_mine() from public, anon;
grant execute on function public.organization_get_mine() to authenticated;

create or replace function public.organization_bootstrap_from_verified_profile()
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_user_id uuid := auth.uid();
  v_profile public.user_profiles%rowtype;
  v_org_id uuid;
  v_workspace_id uuid;
  v_slug_base text;
  v_slug text;
begin
  if v_user_id is null or not public.is_current_auth_user_active() then
    raise exception using errcode = '42501', message = 'Active authentication required.';
  end if;

  if exists (
    select 1 from public.organization_memberships
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

  v_slug_base := trim(both '-' from regexp_replace(
    lower(v_profile.organization_name), '[^a-z0-9]+', '-', 'g'
  ));
  if v_slug_base = '' then v_slug_base := 'organization'; end if;
  v_slug := v_slug_base || '-' || substr(replace(gen_random_uuid()::text, '-', ''), 1, 7);

  insert into public.organization_entities (
    legal_name, public_name, slug, entity_type, country_code, city,
    verification_status, verification_source, verified_at, created_by
  ) values (
    btrim(v_profile.organization_name),
    btrim(v_profile.organization_name),
    v_slug,
    'other',
    case when upper(coalesce(v_profile.country, '')) ~ '^[A-Z]{2}$'
      then upper(v_profile.country) else null end,
    nullif(btrim(v_profile.city), ''),
    'verified',
    'legacy_verified_profile',
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
    v_org_id, v_user_id, 'organization_bootstrapped',
    jsonb_build_object('source', 'legacy_verified_profile')
  );

  return public.organization_get_mine();
end;
$$;

revoke all on function public.organization_bootstrap_from_verified_profile() from public, anon;
grant execute on function public.organization_bootstrap_from_verified_profile() to authenticated;

create or replace function public.organization_update_profile(
  p_entity_type text,
  p_legal_name text,
  p_public_name text,
  p_country_code text default null,
  p_city text default null,
  p_website_url text default null,
  p_description text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_org_id uuid;
  v_role text;
  v_country text := nullif(upper(btrim(coalesce(p_country_code, ''))), '');
begin
  if v_user_id is null or not public.is_current_auth_user_active() then
    raise exception using errcode = '42501', message = 'Active authentication required.';
  end if;

  select om.organization_id, om.membership_role
  into v_org_id, v_role
  from public.organization_memberships om
  where om.user_id = v_user_id and om.status = 'active'
  order by (om.membership_role = 'owner') desc
  limit 1;

  if v_org_id is null or v_role not in ('owner','manager') then
    raise exception using errcode = '42501', message = 'Organization manager permission required.';
  end if;

  if p_entity_type not in (
    'association','nonprofit','company','cooperative','sports','public_body','committee','other'
  ) then
    raise exception using errcode = '22023', message = 'Invalid organization type.';
  end if;
  if nullif(btrim(p_legal_name), '') is null or nullif(btrim(p_public_name), '') is null then
    raise exception using errcode = '22023', message = 'Organization names are required.';
  end if;
  if exists (
    select 1 from public.organization_entities oe
    where oe.id = v_org_id
      and (
        oe.legal_name is distinct from btrim(p_legal_name)
        or oe.public_name is distinct from btrim(p_public_name)
      )
  ) then
    raise exception using errcode = '42501',
      message = 'Verified organization names require a new verification review.';
  end if;
  if v_country is not null and v_country !~ '^[A-Z]{2}$' then
    raise exception using errcode = '22023', message = 'Invalid country code.';
  end if;

  if exists (
    select 1
    from public.organization_entities oe
    where oe.id = v_org_id
      and (
        oe.legal_name is distinct from btrim(p_legal_name)
        or oe.public_name is distinct from btrim(p_public_name)
        or oe.country_code is distinct from v_country
      )
  ) then
    raise exception using errcode = '42501',
      message = 'Verified organization name/country changes require re-verification.';
  end if;

  update public.organization_entities
  set
    entity_type = p_entity_type,
    city = nullif(btrim(coalesce(p_city, '')), ''),
    website_url = nullif(btrim(coalesce(p_website_url, '')), ''),
    description = nullif(btrim(coalesce(p_description, '')), ''),
    updated_at = now()
  where id = v_org_id;

  insert into public.organization_session_audit (
    organization_id, actor_user_id, event_key
  ) values (v_org_id, v_user_id, 'organization_profile_updated');

  return public.organization_get_mine();
end;
$$;

revoke all on function public.organization_update_profile(text,text,text,text,text,text,text) from public, anon;
grant execute on function public.organization_update_profile(text,text,text,text,text,text,text) to authenticated;

create or replace function public.organization_set_media_url(
  p_organization_id uuid,
  p_kind text,
  p_url text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null or not public.is_current_auth_user_active() then
    raise exception using errcode = '42501', message = 'Active authentication required.';
  end if;
  if not public.organization_user_can_manage(p_organization_id) then
    raise exception using errcode = '42501', message = 'Organization manager permission required.';
  end if;
  if p_kind not in ('cover','logo') or nullif(btrim(p_url), '') is null then
    raise exception using errcode = '22023', message = 'Invalid media update.';
  end if;

  update public.organization_entities
  set
    cover_url = case when p_kind = 'cover' then btrim(p_url) else cover_url end,
    logo_url = case when p_kind = 'logo' then btrim(p_url) else logo_url end,
    updated_at = now()
  where id = p_organization_id;

  return public.organization_get_mine();
end;
$$;

revoke all on function public.organization_set_media_url(uuid,text,text) from public, anon;
grant execute on function public.organization_set_media_url(uuid,text,text) to authenticated;

create or replace function public.organization_public_get_by_operator(p_user_id uuid)
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  select jsonb_build_object(
    'id', oe.id,
    'legal_name', oe.public_name,
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
  from public.organization_memberships om
  join public.organization_entities oe on oe.id = om.organization_id
  where om.user_id = p_user_id
    and om.status = 'active'
    and oe.verification_status = 'verified'
  order by (om.membership_role = 'owner') desc
  limit 1;
$$;

revoke all on function public.organization_public_get_by_operator(uuid) from public;
grant execute on function public.organization_public_get_by_operator(uuid) to anon, authenticated;

-- ============================================================
-- STORAGE: PUBLIC ORG LOGO/COVER, WRITE ONLY BY OWNER/MANAGER
-- ============================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'organization-media', 'organization-media', true, 8388608,
  array['image/jpeg','image/png','image/webp']
)
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists organization_media_insert_manager on storage.objects;
create policy organization_media_insert_manager
on storage.objects for insert to authenticated
with check (
  bucket_id = 'organization-media'
  and public.is_current_auth_user_active()
  and public.organization_user_can_manage(
    ((storage.foldername(name))[1])::uuid
  )
);

drop policy if exists organization_media_update_manager on storage.objects;
create policy organization_media_update_manager
on storage.objects for update to authenticated
using (
  bucket_id = 'organization-media'
  and public.is_current_auth_user_active()
  and public.organization_user_can_manage(
    ((storage.foldername(name))[1])::uuid
  )
)
with check (
  bucket_id = 'organization-media'
  and public.is_current_auth_user_active()
  and public.organization_user_can_manage(
    ((storage.foldername(name))[1])::uuid
  )
);

drop policy if exists organization_media_delete_manager on storage.objects;
create policy organization_media_delete_manager
on storage.objects for delete to authenticated
using (
  bucket_id = 'organization-media'
  and public.is_current_auth_user_active()
  and public.organization_user_can_manage(
    ((storage.foldername(name))[1])::uuid
  )
);

-- ============================================================
-- SESSION READ MODEL HELPERS
-- ============================================================

create or replace function public._session_question_json(p_question_id uuid)
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  select jsonb_build_object(
    'id', q.id,
    'title', q.title,
    'question_type', q.question_type,
    'position', q.position,
    'min_selections', q.min_selections,
    'max_selections', q.max_selections,
    'status', q.status,
    'response_count', (select count(*) from public.live_ballots b where b.question_id = q.id),
    'options', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'id', o.id,
          'option_key', o.option_key,
          'label', o.label,
          'position', o.position,
          'votes', (
            select count(*)
            from public.live_ballots b
            where b.question_id = q.id and o.id = any(b.option_ids)
          )
        ) order by o.position
      )
      from public.live_options o
      where o.question_id = q.id
    ), '[]'::jsonb)
  )
  from public.live_questions q
  where q.id = p_question_id;
$$;

revoke all on function public._session_question_json(uuid) from public, anon, authenticated;

create or replace function public._session_detail_json(p_session_id uuid)
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  select jsonb_build_object(
    'session', jsonb_build_object(
      'id', s.id,
      'title', s.title,
      'join_code', s.join_code,
      'status', s.status,
      'access_mode', s.access_mode,
      'results_visibility', s.results_visibility,
      'raw_retention', s.raw_retention,
      'expected_participants', s.expected_participants,
      'token_count', (select count(*) from public.live_access_tokens t where t.session_id = s.id and t.status = 'active'),
      'response_count', (
        select count(*)
        from public.live_ballots b
        join public.live_questions q on q.id = b.question_id
        where q.session_id = s.id
      ),
      'created_at', s.created_at,
      'opened_at', s.opened_at,
      'closed_at', s.closed_at,
      'report_id', (select r.id from public.live_verified_reports r where r.session_id = s.id)
    ),
    'questions', coalesce((
      select jsonb_agg(public._session_question_json(q.id) order by q.position)
      from public.live_questions q
      where q.session_id = s.id
    ), '[]'::jsonb)
  )
  from public.live_sessions s
  where s.id = p_session_id;
$$;

revoke all on function public._session_detail_json(uuid) from public, anon, authenticated;

create or replace function public._session_public_detail_json(p_session_id uuid)
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  select jsonb_build_object(
    'session', jsonb_build_object(
      'id', s.id,
      'title', s.title,
      'join_code', s.join_code,
      'status', s.status,
      'access_mode', s.access_mode,
      'results_visibility', s.results_visibility,
      'raw_retention', s.raw_retention,
      'expected_participants', s.expected_participants,
      'token_count', 0,
      'response_count', 0,
      'created_at', s.created_at,
      'opened_at', s.opened_at,
      'closed_at', s.closed_at,
      'report_id', case when s.status = 'closed' then
        (select r.id from public.live_verified_reports r where r.session_id = s.id)
        else null end
    ),
    'questions', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'id', q.id,
          'title', q.title,
          'question_type', q.question_type,
          'position', q.position,
          'min_selections', q.min_selections,
          'max_selections', q.max_selections,
          'status', q.status,
          'response_count', 0,
          'options', coalesce((
            select jsonb_agg(
              jsonb_build_object(
                'id', o.id,
                'option_key', o.option_key,
                'label', o.label,
                'position', o.position,
                'votes', 0
              ) order by o.position
            )
            from public.live_options o where o.question_id = q.id
          ), '[]'::jsonb)
        ) order by q.position
      )
      from public.live_questions q
      where q.session_id = s.id
        and q.status in ('open','closed')
    ), '[]'::jsonb)
  )
  from public.live_sessions s
  where s.id = p_session_id;
$$;

revoke all on function public._session_public_detail_json(uuid) from public, anon, authenticated;

-- ============================================================
-- ORGANIZER SESSION RPC
-- ============================================================

create or replace function public._session_assert_operator(p_session_id uuid)
returns uuid
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_org_id uuid;
begin
  if auth.uid() is null or not public.is_current_auth_user_active() then
    raise exception using errcode = '42501', message = 'Active authentication required.';
  end if;

  select ow.organization_id into v_org_id
  from public.live_sessions s
  join public.organization_workspaces ow on ow.id = s.workspace_id
  join public.organization_entities oe on oe.id = ow.organization_id
  where s.id = p_session_id
    and ow.status = 'active'
    and oe.verification_status = 'verified';

  if v_org_id is null or not public.organization_user_can_operate(v_org_id) then
    raise exception using errcode = '42501', message = 'Session operator permission required.';
  end if;
  return v_org_id;
end;
$$;

revoke all on function public._session_assert_operator(uuid) from public, anon, authenticated;

create or replace function public.sessions_list_mine()
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_workspace_id uuid;
begin
  if v_user_id is null or not public.is_current_auth_user_active() then
    raise exception using errcode = '42501', message = 'Active authentication required.';
  end if;

  select ow.id into v_workspace_id
  from public.organization_memberships om
  join public.organization_workspaces ow on ow.organization_id = om.organization_id
  where om.user_id = v_user_id
    and om.status = 'active'
    and om.membership_role in ('owner','manager','operator','viewer')
  order by (om.membership_role = 'owner') desc
  limit 1;

  if v_workspace_id is null then return '[]'::jsonb; end if;

  return coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'id', s.id,
        'title', s.title,
        'join_code', s.join_code,
        'status', s.status,
        'access_mode', s.access_mode,
        'results_visibility', s.results_visibility,
        'raw_retention', s.raw_retention,
        'expected_participants', s.expected_participants,
        'token_count', (select count(*) from public.live_access_tokens t where t.session_id = s.id and t.status = 'active'),
        'response_count', (
          select count(*) from public.live_ballots b
          join public.live_questions q on q.id = b.question_id
          where q.session_id = s.id
        ),
        'created_at', s.created_at,
        'opened_at', s.opened_at,
        'closed_at', s.closed_at,
        'report_id', (select r.id from public.live_verified_reports r where r.session_id = s.id)
      ) order by s.created_at desc
    )
    from public.live_sessions s
    where s.workspace_id = v_workspace_id
  ), '[]'::jsonb);
end;
$$;

revoke all on function public.sessions_list_mine() from public, anon;
grant execute on function public.sessions_list_mine() to authenticated;

create or replace function public.session_create(
  p_title text,
  p_access_mode text,
  p_results_visibility text,
  p_raw_retention text,
  p_expected_participants integer
)
returns uuid
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_user_id uuid := auth.uid();
  v_workspace_id uuid;
  v_org_id uuid;
  v_session_id uuid;
  v_join_code text;
  v_attempt integer := 0;
begin
  if v_user_id is null or not public.is_current_auth_user_active() then
    raise exception using errcode = '42501', message = 'Active authentication required.';
  end if;

  select ow.id, ow.organization_id into v_workspace_id, v_org_id
  from public.organization_memberships om
  join public.organization_workspaces ow on ow.organization_id = om.organization_id
  join public.organization_entities oe on oe.id = om.organization_id
  where om.user_id = v_user_id
    and om.status = 'active'
    and om.membership_role in ('owner','manager','operator')
    and ow.status = 'active'
    and oe.verification_status = 'verified'
  order by (om.membership_role = 'owner') desc
  limit 1;

  if v_workspace_id is null then
    raise exception using errcode = '42501', message = 'Verified organization workspace required.';
  end if;
  if nullif(btrim(p_title), '') is null then
    raise exception using errcode = '22023', message = 'Session title is required.';
  end if;
  if p_access_mode not in ('open_anonymous','controlled_token_pool') then
    raise exception using errcode = '22023', message = 'Invalid access mode.';
  end if;
  if p_results_visibility not in ('live','after_vote','after_close','organizer_only') then
    raise exception using errcode = '22023', message = 'Invalid result visibility.';
  end if;
  if p_raw_retention not in ('24h','7d','30d') then
    raise exception using errcode = '22023', message = 'Invalid raw-data retention.';
  end if;
  if p_expected_participants not between 1 and 250 then
    raise exception using errcode = '22023', message = 'Pilot supports 1 to 250 participants per Session.';
  end if;

  loop
    v_attempt := v_attempt + 1;
    v_join_code := upper(substr(encode(gen_random_bytes(6), 'hex'), 1, 8));
    exit when not exists (select 1 from public.live_sessions where join_code = v_join_code);
    if v_attempt > 12 then
      raise exception 'Unable to allocate a join code.';
    end if;
  end loop;

  insert into public.live_sessions (
    workspace_id, created_by, title, join_code, access_mode,
    results_visibility, raw_retention, expected_participants, max_participants
  ) values (
    v_workspace_id, v_user_id, btrim(p_title), v_join_code, p_access_mode,
    p_results_visibility, p_raw_retention, p_expected_participants, 250
  ) returning id into v_session_id;

  insert into public.organization_session_audit (
    organization_id, session_id, actor_user_id, event_key,
    metadata
  ) values (
    v_org_id, v_session_id, v_user_id, 'session_created',
    jsonb_build_object('access_mode', p_access_mode, 'results_visibility', p_results_visibility, 'raw_retention', p_raw_retention)
  );

  return v_session_id;
end;
$$;

revoke all on function public.session_create(text,text,text,text,integer) from public, anon;
grant execute on function public.session_create(text,text,text,text,integer) to authenticated;

create or replace function public.session_organizer_get(p_session_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
begin
  perform public._session_assert_operator(p_session_id);
  return public._session_detail_json(p_session_id);
end;
$$;

revoke all on function public.session_organizer_get(uuid) from public, anon;
grant execute on function public.session_organizer_get(uuid) to authenticated;

create or replace function public.session_add_question(
  p_session_id uuid,
  p_title text,
  p_question_type text,
  p_options text[] default '{}',
  p_min_selections integer default 1,
  p_max_selections integer default 1
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_org_id uuid;
  v_session public.live_sessions%rowtype;
  v_question_id uuid;
  v_position integer;
  v_option text;
  v_index integer := 0;
  v_clean_options text[] := '{}';
begin
  v_org_id := public._session_assert_operator(p_session_id);
  select * into v_session from public.live_sessions where id = p_session_id;
  if v_session.status <> 'draft' then
    raise exception using errcode = '22023', message = 'Questions can be changed only while Session is draft.';
  end if;
  if nullif(btrim(p_title), '') is null then
    raise exception using errcode = '22023', message = 'Question title is required.';
  end if;
  if p_question_type not in ('yes_no','single_choice','multiple_choice') then
    raise exception using errcode = '22023', message = 'Invalid question type.';
  end if;

  if p_question_type = 'yes_no' then
    p_min_selections := 1;
    p_max_selections := 1;
  else
    foreach v_option in array coalesce(p_options, '{}') loop
      if nullif(btrim(v_option), '') is not null then
        v_clean_options := array_append(v_clean_options, btrim(v_option));
      end if;
    end loop;
    if cardinality(v_clean_options) < 2 or cardinality(v_clean_options) > 20 then
      raise exception using errcode = '22023', message = 'Choice questions require 2 to 20 options.';
    end if;
    if p_question_type = 'single_choice' then
      p_min_selections := 1;
      p_max_selections := 1;
    elsif p_min_selections < 1 or p_max_selections < p_min_selections
      or p_max_selections > cardinality(v_clean_options) then
      raise exception using errcode = '22023', message = 'Invalid multiple-choice selection limits.';
    end if;
  end if;

  select coalesce(max(position), 0) + 1 into v_position
  from public.live_questions where session_id = p_session_id;

  insert into public.live_questions (
    session_id, position, title, question_type, min_selections, max_selections, status
  ) values (
    p_session_id, v_position, btrim(p_title), p_question_type,
    p_min_selections, p_max_selections, 'draft'
  ) returning id into v_question_id;

  if p_question_type = 'yes_no' then
    insert into public.live_options (question_id, position, option_key)
    values (v_question_id, 1, 'yes'), (v_question_id, 2, 'no');
  else
    foreach v_option in array v_clean_options loop
      v_index := v_index + 1;
      insert into public.live_options (question_id, position, label)
      values (v_question_id, v_index, v_option);
    end loop;
  end if;

  insert into public.organization_session_audit (
    organization_id, session_id, actor_user_id, event_key,
    metadata
  ) values (
    v_org_id, p_session_id, auth.uid(), 'question_added',
    jsonb_build_object('question_id', v_question_id, 'question_type', p_question_type)
  );

  return v_question_id;
end;
$$;

revoke all on function public.session_add_question(uuid,text,text,text[],integer,integer) from public, anon;
grant execute on function public.session_add_question(uuid,text,text,text[],integer,integer) to authenticated;

create or replace function public.session_delete_question(p_question_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_session_id uuid;
  v_org_id uuid;
begin
  select session_id into v_session_id from public.live_questions where id = p_question_id;
  if v_session_id is null then return; end if;
  v_org_id := public._session_assert_operator(v_session_id);
  if (select status from public.live_sessions where id = v_session_id) <> 'draft' then
    raise exception using errcode = '22023', message = 'Questions can be deleted only while Session is draft.';
  end if;
  delete from public.live_questions where id = p_question_id;
  insert into public.organization_session_audit (
    organization_id, session_id, actor_user_id, event_key,
    metadata
  ) values (
    v_org_id, v_session_id, auth.uid(), 'question_deleted',
    jsonb_build_object('question_id', p_question_id)
  );
end;
$$;

revoke all on function public.session_delete_question(uuid) from public, anon;
grant execute on function public.session_delete_question(uuid) to authenticated;

create or replace function public.session_generate_tokens(
  p_session_id uuid,
  p_count integer
)
returns table(token text)
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_org_id uuid;
  v_session public.live_sessions%rowtype;
  v_existing integer;
  v_plain text;
  i integer;
begin
  v_org_id := public._session_assert_operator(p_session_id);
  select * into v_session from public.live_sessions where id = p_session_id;
  if v_session.status <> 'draft' or v_session.access_mode <> 'controlled_token_pool' then
    raise exception using errcode = '22023', message = 'Tokens are available only for draft controlled Sessions.';
  end if;
  if p_count not between 1 and 250 then
    raise exception using errcode = '22023', message = 'Invalid token count.';
  end if;
  select count(*) into v_existing
  from public.live_access_tokens where session_id = p_session_id and status = 'active';
  if v_existing + p_count > v_session.max_participants then
    raise exception using errcode = '22023', message = 'Token count exceeds pilot participant limit.';
  end if;

  for i in 1..p_count loop
    v_plain := 'SV-' || upper(encode(gen_random_bytes(10), 'hex'));
    insert into public.live_access_tokens (session_id, token_hash)
    values (
      p_session_id,
      encode(digest(convert_to(v_plain, 'UTF8'), 'sha256'), 'hex')
    );
    token := v_plain;
    return next;
  end loop;

  insert into public.organization_session_audit (
    organization_id, session_id, actor_user_id, event_key,
    metadata
  ) values (
    v_org_id, p_session_id, auth.uid(), 'token_batch_generated',
    jsonb_build_object('count', p_count)
  );
end;
$$;

revoke all on function public.session_generate_tokens(uuid,integer) from public, anon;
grant execute on function public.session_generate_tokens(uuid,integer) to authenticated;

create or replace function public.session_open(p_session_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_org_id uuid;
  v_session public.live_sessions%rowtype;
begin
  v_org_id := public._session_assert_operator(p_session_id);
  select * into v_session from public.live_sessions where id = p_session_id for update;
  if v_session.status <> 'draft' then
    raise exception using errcode = '22023', message = 'Only draft Sessions can be opened.';
  end if;
  if not exists (select 1 from public.live_questions where session_id = p_session_id) then
    raise exception using errcode = '22023', message = 'Add at least one question before opening.';
  end if;
  if v_session.access_mode = 'controlled_token_pool'
    and not exists (select 1 from public.live_access_tokens where session_id = p_session_id and status = 'active') then
    raise exception using errcode = '22023', message = 'Generate participant tokens before opening.';
  end if;

  update public.live_sessions set status = 'open', opened_at = now(), updated_at = now()
  where id = p_session_id;

  insert into public.organization_session_audit (
    organization_id, session_id, actor_user_id, event_key
  ) values (v_org_id, p_session_id, auth.uid(), 'session_opened');
end;
$$;

revoke all on function public.session_open(uuid) from public, anon;
grant execute on function public.session_open(uuid) to authenticated;

create or replace function public.session_question_open(p_question_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_session_id uuid;
  v_org_id uuid;
begin
  select session_id into v_session_id from public.live_questions where id = p_question_id;
  if v_session_id is null then raise exception 'Question not found.'; end if;
  v_org_id := public._session_assert_operator(v_session_id);
  if (select status from public.live_sessions where id = v_session_id) <> 'open' then
    raise exception using errcode = '22023', message = 'Session must be open.';
  end if;

  update public.live_questions
  set status = 'closed', closed_at = coalesce(closed_at, now())
  where session_id = v_session_id and status = 'open' and id <> p_question_id;

  update public.live_questions
  set status = 'open', opened_at = coalesce(opened_at, now()), closed_at = null
  where id = p_question_id and status in ('draft','closed');

  insert into public.organization_session_audit (
    organization_id, session_id, actor_user_id, event_key,
    metadata
  ) values (
    v_org_id, v_session_id, auth.uid(), 'question_opened',
    jsonb_build_object('question_id', p_question_id)
  );
end;
$$;

revoke all on function public.session_question_open(uuid) from public, anon;
grant execute on function public.session_question_open(uuid) to authenticated;

create or replace function public.session_question_close(p_question_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_session_id uuid;
  v_org_id uuid;
begin
  select session_id into v_session_id from public.live_questions where id = p_question_id;
  if v_session_id is null then raise exception 'Question not found.'; end if;
  v_org_id := public._session_assert_operator(v_session_id);
  update public.live_questions
  set status = 'closed', closed_at = coalesce(closed_at, now())
  where id = p_question_id and status = 'open';
  insert into public.organization_session_audit (
    organization_id, session_id, actor_user_id, event_key,
    metadata
  ) values (
    v_org_id, v_session_id, auth.uid(), 'question_closed',
    jsonb_build_object('question_id', p_question_id)
  );
end;
$$;

revoke all on function public.session_question_close(uuid) from public, anon;
grant execute on function public.session_question_close(uuid) to authenticated;

-- ============================================================
-- PUBLIC PARTICIPANT RPC
-- ============================================================

create or replace function public.session_public_join(
  p_join_code text,
  p_token text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_session public.live_sessions%rowtype;
  v_token_id uuid;
  v_secret text;
  v_secret_hash text;
begin
  select * into v_session
  from public.live_sessions
  where join_code = upper(btrim(p_join_code))
    and status = 'open';

  if not found then
    raise exception using errcode = 'P0002', message = 'Open Session not found.';
  end if;

  if v_session.access_mode = 'open_anonymous' and (
    select count(*)
    from public.live_participant_credentials c
    where c.session_id = v_session.id and c.expires_at > now()
  ) >= v_session.max_participants then
    raise exception using errcode = '22023', message = 'Session participant limit reached.';
  end if;

  if v_session.access_mode = 'controlled_token_pool' then
    if nullif(btrim(coalesce(p_token, '')), '') is null then
      raise exception using errcode = '42501', message = 'Participant token required.';
    end if;
    select id into v_token_id
    from public.live_access_tokens
    where session_id = v_session.id
      and token_hash = encode(digest(convert_to(btrim(p_token), 'UTF8'), 'sha256'), 'hex')
      and status = 'active'
    limit 1;
    if v_token_id is null then
      raise exception using errcode = '42501', message = 'Invalid participant token.';
    end if;
  end if;

  v_secret := 'SP-' || encode(gen_random_bytes(24), 'hex');
  v_secret_hash := encode(digest(convert_to(v_secret, 'UTF8'), 'sha256'), 'hex');

  insert into public.live_participant_credentials (
    session_id, token_id, secret_hash, expires_at
  ) values (
    v_session.id, v_token_id, v_secret_hash, now() + interval '24 hours'
  );

  return public._session_public_detail_json(v_session.id)
    || jsonb_build_object('participant_secret', v_secret);
end;
$$;

revoke all on function public.session_public_join(text,text) from public;
grant execute on function public.session_public_join(text,text) to anon, authenticated;

create or replace function public.session_public_state(
  p_join_code text,
  p_participant_secret text default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, extensions
as $$
declare
  v_session_id uuid;
  v_credential_id uuid;
  v_token_id uuid;
  v_detail jsonb;
  v_open_question_id uuid;
  v_has_voted boolean := false;
begin
  select id into v_session_id
  from public.live_sessions
  where join_code = upper(btrim(p_join_code));
  if v_session_id is null then
    raise exception using errcode = 'P0002', message = 'Session not found.';
  end if;

  if nullif(btrim(coalesce(p_participant_secret, '')), '') is not null then
    select id, token_id into v_credential_id, v_token_id
    from public.live_participant_credentials
    where session_id = v_session_id
      and secret_hash = encode(digest(convert_to(btrim(p_participant_secret), 'UTF8'), 'sha256'), 'hex')
      and expires_at > now()
    limit 1;
  end if;

  select id into v_open_question_id
  from public.live_questions
  where session_id = v_session_id and status = 'open'
  order by position limit 1;

  if v_credential_id is not null and v_open_question_id is not null then
    if v_token_id is not null then
      v_has_voted := exists (
        select 1 from public.live_token_question_uses
        where question_id = v_open_question_id and token_id = v_token_id
      );
    else
      v_has_voted := exists (
        select 1 from public.live_open_question_uses
        where question_id = v_open_question_id and credential_id = v_credential_id
      );
    end if;
  end if;

  v_detail := public._session_public_detail_json(v_session_id);
  return v_detail || jsonb_build_object('has_voted_open_question', v_has_voted);
end;
$$;

revoke all on function public.session_public_state(text,text) from public;
grant execute on function public.session_public_state(text,text) to anon, authenticated;

create or replace function public.session_public_vote(
  p_join_code text,
  p_participant_secret text,
  p_question_id uuid,
  p_option_ids uuid[]
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_session public.live_sessions%rowtype;
  v_question public.live_questions%rowtype;
  v_credential_id uuid;
  v_token_id uuid;
  v_selected_count integer;
  v_valid_count integer;
  v_receipt text;
begin
  select * into v_session
  from public.live_sessions
  where join_code = upper(btrim(p_join_code)) and status = 'open'
  for update;
  if not found then raise exception using errcode = 'P0002', message = 'Open Session not found.'; end if;

  select id, token_id into v_credential_id, v_token_id
  from public.live_participant_credentials
  where session_id = v_session.id
    and secret_hash = encode(digest(convert_to(btrim(p_participant_secret), 'UTF8'), 'sha256'), 'hex')
    and expires_at > now()
  limit 1;
  if v_credential_id is null then
    raise exception using errcode = '42501', message = 'Participant credential is invalid or expired.';
  end if;

  select * into v_question
  from public.live_questions
  where id = p_question_id and session_id = v_session.id and status = 'open'
  for update;
  if not found then raise exception using errcode = '22023', message = 'Question is not open.'; end if;

  select count(distinct value) into v_selected_count
  from unnest(coalesce(p_option_ids, '{}')) as value;
  if v_selected_count < v_question.min_selections or v_selected_count > v_question.max_selections then
    raise exception using errcode = '22023', message = 'Invalid number of selections.';
  end if;

  select count(*) into v_valid_count
  from public.live_options o
  where o.question_id = v_question.id
    and o.id = any(coalesce(p_option_ids, '{}'));
  if v_valid_count <> v_selected_count then
    raise exception using errcode = '22023', message = 'One or more selections are invalid.';
  end if;

  if v_session.access_mode = 'controlled_token_pool' then
    if v_token_id is null then raise exception using errcode = '42501', message = 'Controlled credential required.'; end if;
    insert into public.live_token_question_uses (question_id, token_id)
    values (v_question.id, v_token_id);
  else
    insert into public.live_open_question_uses (question_id, credential_id)
    values (v_question.id, v_credential_id);
  end if;

  v_receipt := encode(digest(gen_random_bytes(32), 'sha256'), 'hex');
  insert into public.live_ballots (question_id, option_ids, receipt_hash)
  values (v_question.id, p_option_ids, v_receipt);

  update public.live_sessions
  set first_ballot_at = coalesce(first_ballot_at, now()), updated_at = now()
  where id = v_session.id;

  return jsonb_build_object('receipt', v_receipt);
exception
  when unique_violation then
    raise exception using errcode = '23505', message = 'This participant has already voted on this question.';
end;
$$;

revoke all on function public.session_public_vote(text,text,uuid,uuid[]) from public;
grant execute on function public.session_public_vote(text,text,uuid,uuid[]) to anon, authenticated;

create or replace function public.session_public_results(
  p_join_code text,
  p_participant_secret text,
  p_question_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, extensions
as $$
declare
  v_session public.live_sessions%rowtype;
  v_question public.live_questions%rowtype;
  v_credential_id uuid;
  v_token_id uuid;
  v_has_voted boolean := false;
  v_visible boolean := false;
begin
  select * into v_session from public.live_sessions
  where join_code = upper(btrim(p_join_code));
  if not found then return null; end if;
  select * into v_question from public.live_questions
  where id = p_question_id and session_id = v_session.id;
  if not found then return null; end if;

  select id, token_id into v_credential_id, v_token_id
  from public.live_participant_credentials
  where session_id = v_session.id
    and secret_hash = encode(digest(convert_to(btrim(p_participant_secret), 'UTF8'), 'sha256'), 'hex')
    and expires_at > now()
  limit 1;

  if v_credential_id is not null then
    if v_token_id is not null then
      v_has_voted := exists (
        select 1 from public.live_token_question_uses
        where question_id = p_question_id and token_id = v_token_id
      );
    else
      v_has_voted := exists (
        select 1 from public.live_open_question_uses
        where question_id = p_question_id and credential_id = v_credential_id
      );
    end if;
  end if;

  v_visible := case v_session.results_visibility
    when 'live' then true
    when 'after_vote' then v_has_voted
    when 'after_close' then v_question.status = 'closed' or v_session.status = 'closed'
    else false
  end;

  if not v_visible then return jsonb_build_object('visible', false); end if;
  return public._session_question_json(p_question_id) || jsonb_build_object('visible', true);
end;
$$;

revoke all on function public.session_public_results(text,text,uuid) from public;
grant execute on function public.session_public_results(text,text,uuid) to anon, authenticated;

-- ============================================================
-- CLOSE + VERIFIABLE RESULT REPORT
-- ============================================================

create or replace function public.session_close(p_session_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_org_id uuid;
  v_session public.live_sessions%rowtype;
  v_org public.organization_entities%rowtype;
  v_report_id uuid;
  v_snapshot jsonb;
  v_hash text;
begin
  v_org_id := public._session_assert_operator(p_session_id);
  select * into v_session from public.live_sessions where id = p_session_id for update;
  if v_session.status not in ('open','closed') then
    raise exception using errcode = '22023', message = 'Only an open Session can be closed.';
  end if;

  if v_session.status = 'open' then
    update public.live_questions
    set status = 'closed', closed_at = coalesce(closed_at, now())
    where session_id = p_session_id and status = 'open';
    update public.live_sessions
    set status = 'closed',
        closed_at = coalesce(closed_at, now()),
        delete_raw_after = coalesce(
          delete_raw_after,
          now() + case raw_retention
            when '24h' then interval '24 hours'
            when '30d' then interval '30 days'
            else interval '7 days'
          end
        ),
        updated_at = now()
    where id = p_session_id
    returning * into v_session;
  end if;

  select * into v_org from public.organization_entities where id = v_org_id;

  select jsonb_build_object(
    'schema_version', 1,
    'report_type', 'social_vote_verified_result',
    'session_id', v_session.id,
    'organization_id', v_org.id,
    'organization_name', v_org.public_name,
    'organization_verification_status', v_org.verification_status,
    'session_title', v_session.title,
    'join_code', v_session.join_code,
    'access_mode', v_session.access_mode,
    'results_visibility', v_session.results_visibility,
    'raw_retention', v_session.raw_retention,
    'expected_participants', v_session.expected_participants,
    'eligible_credentials', case
      when v_session.access_mode = 'controlled_token_pool' then
        (select count(*) from public.live_access_tokens t where t.session_id = v_session.id and t.status = 'active')
      else null
    end,
    'opened_at', v_session.opened_at,
    'closed_at', v_session.closed_at,
    'questions', coalesce((
      select jsonb_agg(public._session_question_json(q.id) order by q.position)
      from public.live_questions q where q.session_id = v_session.id
    ), '[]'::jsonb),
    'integrity_note', 'Aggregate result snapshot. No participant identity or token-to-ballot mapping is included.'
  ) into v_snapshot;

  v_hash := encode(digest(convert_to(v_snapshot::text, 'UTF8'), 'sha256'), 'hex');

  select r.id into v_report_id
  from public.live_verified_reports r
  where r.session_id = p_session_id;

  if v_report_id is null then
    insert into public.live_verified_reports (
      session_id, organization_id, snapshot, snapshot_sha256
    ) values (p_session_id, v_org_id, v_snapshot, v_hash)
    returning id into v_report_id;
  end if;

  insert into public.organization_session_audit (
    organization_id, session_id, actor_user_id, event_key,
    metadata
  ) values (
    v_org_id, p_session_id, auth.uid(), 'session_closed',
    jsonb_build_object('report_id', v_report_id, 'sha256', v_hash)
  );

  return v_report_id;
end;
$$;

revoke all on function public.session_close(uuid) from public, anon;
grant execute on function public.session_close(uuid) to authenticated;

create or replace function public.session_verified_report(p_report_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, extensions
as $$
declare
  v_report public.live_verified_reports%rowtype;
  v_recomputed text;
begin
  select * into v_report from public.live_verified_reports where id = p_report_id;
  if not found then
    raise exception using errcode = 'P0002', message = 'Verified result report not found.';
  end if;

  v_recomputed := encode(digest(convert_to(v_report.snapshot::text, 'UTF8'), 'sha256'), 'hex');
  return jsonb_build_object(
    'report_id', v_report.id,
    'sha256', v_report.snapshot_sha256,
    'hash_valid', v_recomputed = v_report.snapshot_sha256,
    'snapshot', v_report.snapshot,
    'created_at', v_report.created_at
  );
end;
$$;

revoke all on function public.session_verified_report(uuid) from public;
grant execute on function public.session_verified_report(uuid) to anon, authenticated;

create or replace function public.sessions_retention_cleanup()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_session record;
  v_cleaned integer := 0;
begin
  if current_user not in ('postgres','supabase_admin','service_role') then
    raise exception using errcode = '42501', message = 'service_role required.';
  end if;

  for v_session in
    select s.id, ow.organization_id
    from public.live_sessions s
    join public.organization_workspaces ow on ow.id = s.workspace_id
    where s.status in ('closed','archived')
      and s.delete_raw_after is not null
      and s.delete_raw_after <= now()
  loop
    delete from public.live_ballots b
    using public.live_questions q
    where b.question_id = q.id and q.session_id = v_session.id;

    delete from public.live_token_question_uses u
    using public.live_questions q
    where u.question_id = q.id and q.session_id = v_session.id;

    delete from public.live_open_question_uses u
    using public.live_questions q
    where u.question_id = q.id and q.session_id = v_session.id;

    delete from public.live_participant_credentials where session_id = v_session.id;
    delete from public.live_access_tokens where session_id = v_session.id;

    update public.live_sessions
    set delete_raw_after = null, updated_at = now()
    where id = v_session.id;

    insert into public.organization_session_audit (
      organization_id, session_id, actor_user_id, event_key
    ) values (
      v_session.organization_id, v_session.id, null, 'raw_data_retention_applied'
    );

    v_cleaned := v_cleaned + 1;
  end loop;

  return v_cleaned;
end;
$$;

revoke all on function public.sessions_retention_cleanup() from public, anon, authenticated;
grant execute on function public.sessions_retention_cleanup() to service_role;

comment on table public.live_ballots is
'Anonymous Session ballot ledger. Intentionally no user/token/credential foreign key and no per-ballot timestamp.';
comment on table public.live_verified_reports is
'Aggregate tamper-evident Session result snapshots. These are verifiable reports, not legal certificates.';
comment on column public.organization_workspaces.billing_enabled is
'Hard OFF during pilot. Enabling billing requires a separate future migration/release.';

commit;
