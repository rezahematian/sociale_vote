-- Social Vote Organizations + Sessions Pilot — security/privacy hardening
-- 2026-08-22
-- Forward-only hardening for 20260821_organization_sessions_pilot.sql.
-- Billing remains hard OFF. No L1/L2, Stripe or legal-vote features are enabled.

begin;

-- Refuse to run against a database where the pilot foundation is absent.
do $$
begin
  if to_regclass('public.organization_entities') is null
     or to_regclass('public.organization_memberships') is null
     or to_regclass('public.organization_workspaces') is null
     or to_regclass('public.live_sessions') is null
     or to_regclass('public.live_verified_reports') is null then
    raise exception using
      errcode = '55000',
      message = 'Organizations/Sessions pilot foundation is missing. Apply 20260821_organization_sessions_pilot.sql first.';
  end if;
end;
$$;

-- ============================================================
-- 1) SECURITY DEFINER SEARCH-PATH HARDENING
-- ============================================================
-- App roles must never be able to create objects in public. With CREATE denied,
-- the controlled pg_catalog/public/extensions search path cannot be poisoned by
-- anon/authenticated callers while preserving compatibility with current bodies.
revoke create on schema public from PUBLIC, anon, authenticated;

do $$
declare
  v_proc record;
begin
  for v_proc in
    select p.oid::regprocedure as proc_identity
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.prosecdef
      and p.proname ~ '^(organization_|session_|sessions_|_session_)'
  loop
    execute format(
      'alter function %s set search_path = pg_catalog, public, extensions',
      v_proc.proc_identity
    );
  end loop;
end;
$$;

-- ============================================================
-- 2) BILLING HARD OFF AT DATABASE LEVEL
-- ============================================================
-- Do not silently rewrite unexpected commercial data. If such a row exists,
-- stop and investigate instead of masking it.
do $$
begin
  if exists (
    select 1
    from public.organization_workspaces
    where plan_key <> 'pilot'
       or commercial_mode <> 'pilot_free'
       or billing_enabled
  ) then
    raise exception using
      errcode = '55000',
      message = 'Unexpected non-pilot billing state found. Hardening stopped without changes.';
  end if;
end;
$$;

alter table public.organization_workspaces
  drop constraint if exists organization_workspaces_pilot_billing_hard_off;

alter table public.organization_workspaces
  add constraint organization_workspaces_pilot_billing_hard_off
  check (
    plan_key = 'pilot'
    and commercial_mode = 'pilot_free'
    and billing_enabled = false
  );

-- ============================================================
-- 3) DELETED-ACCOUNT ORGANIZATION GUARD
-- ============================================================
create or replace function app_private.organization_handle_deleted_auth_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.organization_session_audit (
    organization_id,
    session_id,
    actor_user_id,
    event_key,
    metadata
  )
  select
    om.organization_id,
    null,
    old.id,
    'membership_revoked_account_deleted',
    '{}'::jsonb
  from public.organization_memberships om
  where om.user_id = old.id
    and om.status = 'active';

  update public.organization_memberships
  set status = 'revoked', updated_at = pg_catalog.now()
  where user_id = old.id
    and status = 'active';

  update public.organization_workspaces ow
  set status = 'restricted', updated_at = pg_catalog.now()
  where ow.status = 'active'
    and not exists (
      select 1
      from public.organization_memberships om
      where om.organization_id = ow.organization_id
        and om.membership_role = 'owner'
        and om.status = 'active'
    );

  return old;
end;
$$;

revoke all on function app_private.organization_handle_deleted_auth_user()
from public, anon, authenticated;

drop trigger if exists social_vote_org_deleted_auth_user_guard on auth.users;
create trigger social_vote_org_deleted_auth_user_guard
before delete on auth.users
for each row execute function app_private.organization_handle_deleted_auth_user();

-- Backfill any account deleted before this hardening.
with deleted_memberships as (
  select om.organization_id, om.user_id
  from public.organization_memberships om
  join app_private.account_controls ac on ac.user_id = om.user_id
  where ac.status = 'deleted'
    and om.status = 'active'
    and not exists (
      select 1 from auth.users au where au.id = om.user_id
    )
), audit_rows as (
  insert into public.organization_session_audit (
    organization_id, session_id, actor_user_id, event_key, metadata
  )
  select organization_id, null, user_id,
         'membership_revoked_account_deleted_backfill', '{}'::jsonb
  from deleted_memberships
  returning 1
)
update public.organization_memberships om
set status = 'revoked', updated_at = pg_catalog.now()
from deleted_memberships dm
where om.organization_id = dm.organization_id
  and om.user_id = dm.user_id;

update public.organization_workspaces ow
set status = 'restricted', updated_at = pg_catalog.now()
where ow.status = 'active'
  and not exists (
    select 1
    from public.organization_memberships om
    where om.organization_id = ow.organization_id
      and om.membership_role = 'owner'
      and om.status = 'active'
  );

-- ============================================================
-- 4) ACTIVE-SESSION DEFENCE IN MEMBERSHIP HELPERS
-- ============================================================
create or replace function public.organization_member_role(p_organization_id uuid)
returns text
language sql
stable
security definer
set search_path = pg_catalog, public, extensions
as $$
  select om.membership_role
  from public.organization_memberships om
  where public.is_current_auth_user_active()
    and om.organization_id = p_organization_id
    and om.user_id = auth.uid()
    and om.status = 'active'
  limit 1;
$$;

revoke all on function public.organization_member_role(uuid) from public, anon;
grant execute on function public.organization_member_role(uuid) to authenticated;

create or replace function public.organization_user_can_manage(p_organization_id uuid)
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, public, extensions
as $$
  select public.is_current_auth_user_active() and exists (
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

create or replace function public.organization_user_can_operate(p_organization_id uuid)
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, public, extensions
as $$
  select public.is_current_auth_user_active() and exists (
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
-- 5) ORGANIZATION MEDIA: ONLY CURRENT SOCIAL VOTE SUPABASE BUCKET URLS
-- ============================================================
do $$
declare
  v_bad_count integer;
begin
  select count(*) into v_bad_count
  from public.organization_entities oe
  where (
      oe.logo_url is not null
      and oe.logo_url not in (
        'https://rbuzlrclwhxaigkgndrb.supabase.co/storage/v1/object/public/organization-media/' || oe.id::text || '/logo.jpg',
        'https://rbuzlrclwhxaigkgndrb.supabase.co/storage/v1/object/public/organization-media/' || oe.id::text || '/logo.png',
        'https://rbuzlrclwhxaigkgndrb.supabase.co/storage/v1/object/public/organization-media/' || oe.id::text || '/logo.webp'
      )
    )
    or (
      oe.cover_url is not null
      and oe.cover_url not in (
        'https://rbuzlrclwhxaigkgndrb.supabase.co/storage/v1/object/public/organization-media/' || oe.id::text || '/cover.jpg',
        'https://rbuzlrclwhxaigkgndrb.supabase.co/storage/v1/object/public/organization-media/' || oe.id::text || '/cover.png',
        'https://rbuzlrclwhxaigkgndrb.supabase.co/storage/v1/object/public/organization-media/' || oe.id::text || '/cover.webp'
      )
    );

  if v_bad_count > 0 then
    raise exception using
      errcode = '55000',
      message = 'Unexpected external organization media URL found. Hardening stopped for review.';
  end if;
end;
$$;

create or replace function public.organization_set_media_url(
  p_organization_id uuid,
  p_kind text,
  p_url text
)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public, extensions
as $$
declare
  v_url text := btrim(coalesce(p_url, ''));
  v_prefix text;
begin
  if auth.uid() is null or not public.is_current_auth_user_active() then
    raise exception using errcode = '42501', message = 'Active authentication required.';
  end if;
  if not public.organization_user_can_manage(p_organization_id) then
    raise exception using errcode = '42501', message = 'Organization manager permission required.';
  end if;
  if p_kind not in ('cover','logo') or v_url = '' then
    raise exception using errcode = '22023', message = 'Invalid media update.';
  end if;

  v_prefix :=
    'https://rbuzlrclwhxaigkgndrb.supabase.co/storage/v1/object/public/organization-media/'
    || p_organization_id::text || '/' || p_kind || '.';

  if v_url not in (v_prefix || 'jpg', v_prefix || 'png', v_prefix || 'webp') then
    raise exception using errcode = '22023',
      message = 'Organization media must come from the Social Vote organization-media bucket.';
  end if;

  update public.organization_entities
  set
    cover_url = case when p_kind = 'cover' then v_url else cover_url end,
    logo_url = case when p_kind = 'logo' then v_url else logo_url end,
    updated_at = pg_catalog.now()
  where id = p_organization_id;

  return public.organization_get_mine();
end;
$$;

revoke all on function public.organization_set_media_url(uuid,text,text) from public, anon;
grant execute on function public.organization_set_media_url(uuid,text,text) to authenticated;

-- ============================================================
-- 6) SESSION READ MODELS: INCLUDE ORGANIZATION BRANDING
-- ============================================================
create or replace function public._session_detail_json(p_session_id uuid)
returns jsonb
language sql
stable
security definer
set search_path = pg_catalog, public, extensions
as $$
  select jsonb_build_object(
    'session', jsonb_build_object(
      'id', s.id,
      'title', s.title,
      'join_code', s.join_code,
      'status', s.status,
      'organization_name', oe.public_name,
      'organization_logo_url', oe.logo_url,
      'organization_cover_url', oe.cover_url,
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
  join public.organization_workspaces ow on ow.id = s.workspace_id
  join public.organization_entities oe on oe.id = ow.organization_id
  where s.id = p_session_id;
$$;

revoke all on function public._session_detail_json(uuid) from public, anon, authenticated;

create or replace function public._session_public_detail_json(p_session_id uuid)
returns jsonb
language sql
stable
security definer
set search_path = pg_catalog, public, extensions
as $$
  select jsonb_build_object(
    'session', jsonb_build_object(
      'id', s.id,
      'title', s.title,
      'join_code', s.join_code,
      'status', s.status,
      'organization_name', oe.public_name,
      'organization_logo_url', oe.logo_url,
      'organization_cover_url', oe.cover_url,
      'access_mode', s.access_mode,
      'results_visibility', s.results_visibility,
      'raw_retention', s.raw_retention,
      'expected_participants', s.expected_participants,
      'token_count', 0,
      'response_count', 0,
      'created_at', s.created_at,
      'opened_at', s.opened_at,
      'closed_at', s.closed_at,
      'report_id', case
        when s.status = 'closed'
          and s.results_visibility <> 'organizer_only'
        then (select r.id from public.live_verified_reports r where r.session_id = s.id)
        else null
      end
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
  join public.organization_workspaces ow on ow.id = s.workspace_id
  join public.organization_entities oe on oe.id = ow.organization_id
  where s.id = p_session_id
    and ow.status = 'active'
    and oe.verification_status = 'verified';
$$;

revoke all on function public._session_public_detail_json(uuid) from public, anon, authenticated;

create or replace function public.sessions_list_mine()
returns jsonb
language plpgsql
stable
security definer
set search_path = pg_catalog, public, extensions
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
  join public.organization_entities oe on oe.id = om.organization_id
  where om.user_id = v_user_id
    and om.status = 'active'
    and om.membership_role in ('owner','manager','operator','viewer')
    and ow.status = 'active'
    and oe.verification_status = 'verified'
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
        'organization_name', oe.public_name,
        'organization_logo_url', oe.logo_url,
        'organization_cover_url', oe.cover_url,
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
    join public.organization_workspaces ow on ow.id = s.workspace_id
    join public.organization_entities oe on oe.id = ow.organization_id
    where s.workspace_id = v_workspace_id
  ), '[]'::jsonb);
end;
$$;

revoke all on function public.sessions_list_mine() from public, anon;
grant execute on function public.sessions_list_mine() to authenticated;

-- ============================================================
-- 7) CONTROLLED CREDENTIALS: ONE ACTIVE BROWSER CREDENTIAL PER TOKEN
-- ============================================================
-- Controlled-mode vote uniqueness is token-based, so pruning duplicate
-- credentials does not remove or relink ballots.
with ranked as (
  select id,
         row_number() over (
           partition by token_id
           order by created_at desc, id desc
         ) as rn
  from public.live_participant_credentials
  where token_id is not null
)
delete from public.live_participant_credentials c
using ranked r
where c.id = r.id and r.rn > 1;

create unique index if not exists live_participant_credentials_one_per_token_idx
on public.live_participant_credentials (token_id)
where token_id is not null;

-- ============================================================
-- 8) PUBLIC JOIN HARDENING + BASIC SESSION-LEVEL ABUSE THROTTLE
-- ============================================================
create or replace function public.session_public_join(
  p_join_code text,
  p_token text default null
)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public, extensions
as $$
declare
  v_session public.live_sessions%rowtype;
  v_token_id uuid;
  v_secret text;
  v_secret_hash text;
  v_recent_joins integer;
  v_active_credentials integer;
begin
  select s.* into v_session
  from public.live_sessions s
  join public.organization_workspaces ow on ow.id = s.workspace_id
  join public.organization_entities oe on oe.id = ow.organization_id
  where s.join_code = upper(btrim(p_join_code))
    and s.status = 'open'
    and ow.status = 'active'
    and oe.verification_status = 'verified';

  if not found then
    raise exception using errcode = 'P0002', message = 'Open Session not found.';
  end if;

  if v_session.access_mode = 'open_anonymous' then
    select count(*) into v_recent_joins
    from public.live_participant_credentials c
    where c.session_id = v_session.id
      and c.token_id is null
      and c.created_at >= pg_catalog.now() - interval '1 minute';

    if v_recent_joins >= 120 then
      raise exception using errcode = '54000',
        message = 'Too many participant joins. Retry shortly.';
    end if;

    select count(*) into v_active_credentials
    from public.live_participant_credentials c
    where c.session_id = v_session.id
      and c.token_id is null
      and c.expires_at > pg_catalog.now();

    if v_active_credentials >= v_session.max_participants then
      raise exception using errcode = '22023',
        message = 'Session participant limit reached.';
    end if;
  end if;

  if v_session.access_mode = 'controlled_token_pool' then
    if nullif(btrim(coalesce(p_token, '')), '') is null then
      raise exception using errcode = '42501', message = 'Participant token required.';
    end if;

    select id into v_token_id
    from public.live_access_tokens
    where session_id = v_session.id
      and token_hash = pg_catalog.encode(
        extensions.digest(pg_catalog.convert_to(btrim(p_token), 'UTF8'), 'sha256'),
        'hex'
      )
      and status = 'active'
    limit 1;

    if v_token_id is null then
      raise exception using errcode = '42501', message = 'Invalid participant token.';
    end if;

    -- Rejoin invalidates only the old browser credential. Vote uniqueness stays
    -- bound to token_id in live_token_question_uses.
    delete from public.live_participant_credentials
    where token_id = v_token_id;
  end if;

  v_secret := 'SP-' || pg_catalog.encode(extensions.gen_random_bytes(24), 'hex');
  v_secret_hash := pg_catalog.encode(
    extensions.digest(pg_catalog.convert_to(v_secret, 'UTF8'), 'sha256'),
    'hex'
  );

  insert into public.live_participant_credentials (
    session_id, token_id, secret_hash, expires_at
  ) values (
    v_session.id, v_token_id, v_secret_hash, pg_catalog.now() + interval '24 hours'
  );

  return public._session_public_detail_json(v_session.id)
    || jsonb_build_object('participant_secret', v_secret);
end;
$$;

revoke all on function public.session_public_join(text,text) from public;
grant execute on function public.session_public_join(text,text) to anon, authenticated;

-- ============================================================
-- 9) PUBLIC STATE/VOTE/RESULTS MUST RESPECT ORG/WORKSPACE STATUS
-- ============================================================
create or replace function public.session_public_state(
  p_join_code text,
  p_participant_secret text default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = pg_catalog, public, extensions
as $$
declare
  v_session_id uuid;
  v_credential_id uuid;
  v_token_id uuid;
  v_detail jsonb;
  v_open_question_id uuid;
  v_has_voted boolean := false;
begin
  select s.id into v_session_id
  from public.live_sessions s
  join public.organization_workspaces ow on ow.id = s.workspace_id
  join public.organization_entities oe on oe.id = ow.organization_id
  where s.join_code = upper(btrim(p_join_code))
    and ow.status = 'active'
    and oe.verification_status = 'verified';

  if v_session_id is null then
    raise exception using errcode = 'P0002', message = 'Session not found.';
  end if;

  if nullif(btrim(coalesce(p_participant_secret, '')), '') is not null then
    select id, token_id into v_credential_id, v_token_id
    from public.live_participant_credentials
    where session_id = v_session_id
      and secret_hash = pg_catalog.encode(
        extensions.digest(pg_catalog.convert_to(btrim(p_participant_secret), 'UTF8'), 'sha256'),
        'hex'
      )
      and expires_at > pg_catalog.now()
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
  if v_detail is null then
    raise exception using errcode = 'P0002', message = 'Session not available.';
  end if;

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
set search_path = pg_catalog, public, extensions
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
  select s.* into v_session
  from public.live_sessions s
  join public.organization_workspaces ow on ow.id = s.workspace_id
  join public.organization_entities oe on oe.id = ow.organization_id
  where s.join_code = upper(btrim(p_join_code))
    and s.status = 'open'
    and ow.status = 'active'
    and oe.verification_status = 'verified'
  for update of s;

  if not found then
    raise exception using errcode = 'P0002', message = 'Open Session not found.';
  end if;

  select id, token_id into v_credential_id, v_token_id
  from public.live_participant_credentials
  where session_id = v_session.id
    and secret_hash = pg_catalog.encode(
      extensions.digest(pg_catalog.convert_to(btrim(p_participant_secret), 'UTF8'), 'sha256'),
      'hex'
    )
    and expires_at > pg_catalog.now()
  limit 1;

  if v_credential_id is null then
    raise exception using errcode = '42501', message = 'Participant credential is invalid or expired.';
  end if;

  select * into v_question
  from public.live_questions
  where id = p_question_id and session_id = v_session.id and status = 'open'
  for update;

  if not found then
    raise exception using errcode = '22023', message = 'Question is not open.';
  end if;

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
    if v_token_id is null then
      raise exception using errcode = '42501', message = 'Controlled credential required.';
    end if;
    insert into public.live_token_question_uses (question_id, token_id)
    values (v_question.id, v_token_id);
  else
    insert into public.live_open_question_uses (question_id, credential_id)
    values (v_question.id, v_credential_id);
  end if;

  v_receipt := pg_catalog.encode(
    extensions.digest(extensions.gen_random_bytes(32), 'sha256'),
    'hex'
  );

  insert into public.live_ballots (question_id, option_ids, receipt_hash)
  values (v_question.id, p_option_ids, v_receipt);

  update public.live_sessions
  set first_ballot_at = coalesce(first_ballot_at, pg_catalog.now()),
      updated_at = pg_catalog.now()
  where id = v_session.id;

  return jsonb_build_object('receipt', v_receipt);
exception
  when unique_violation then
    raise exception using errcode = '23505',
      message = 'This participant has already voted on this question.';
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
set search_path = pg_catalog, public, extensions
as $$
declare
  v_session public.live_sessions%rowtype;
  v_question public.live_questions%rowtype;
  v_credential_id uuid;
  v_token_id uuid;
  v_has_voted boolean := false;
  v_visible boolean := false;
begin
  select s.* into v_session
  from public.live_sessions s
  join public.organization_workspaces ow on ow.id = s.workspace_id
  join public.organization_entities oe on oe.id = ow.organization_id
  where s.join_code = upper(btrim(p_join_code))
    and ow.status = 'active'
    and oe.verification_status = 'verified';

  if not found then return null; end if;

  select * into v_question from public.live_questions
  where id = p_question_id and session_id = v_session.id;
  if not found then return null; end if;

  select id, token_id into v_credential_id, v_token_id
  from public.live_participant_credentials
  where session_id = v_session.id
    and secret_hash = pg_catalog.encode(
      extensions.digest(pg_catalog.convert_to(btrim(p_participant_secret), 'UTF8'), 'sha256'),
      'hex'
    )
    and expires_at > pg_catalog.now()
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
-- 10) CLOSE IS IDEMPOTENT; ORGANIZER_ONLY REPORT STAYS PRIVATE
-- ============================================================
create or replace function public.session_close(p_session_id uuid)
returns uuid
language plpgsql
security definer
set search_path = pg_catalog, public, extensions
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

  if v_session.status = 'closed' then
    select r.id into v_report_id
    from public.live_verified_reports r
    where r.session_id = p_session_id;
    if v_report_id is not null then
      return v_report_id;
    end if;
  elsif v_session.status <> 'open' then
    raise exception using errcode = '22023', message = 'Only an open Session can be closed.';
  end if;

  if v_session.status = 'open' then
    update public.live_questions
    set status = 'closed', closed_at = coalesce(closed_at, pg_catalog.now())
    where session_id = p_session_id and status = 'open';

    update public.live_sessions
    set status = 'closed',
        closed_at = coalesce(closed_at, pg_catalog.now()),
        delete_raw_after = coalesce(
          delete_raw_after,
          pg_catalog.now() + case raw_retention
            when '24h' then interval '24 hours'
            when '30d' then interval '30 days'
            else interval '7 days'
          end
        ),
        updated_at = pg_catalog.now()
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

  v_hash := pg_catalog.encode(
    extensions.digest(pg_catalog.convert_to(v_snapshot::text, 'UTF8'), 'sha256'),
    'hex'
  );

  insert into public.live_verified_reports (
    session_id, organization_id, snapshot, snapshot_sha256
  ) values (p_session_id, v_org_id, v_snapshot, v_hash)
  on conflict (session_id) do nothing
  returning id into v_report_id;

  if v_report_id is null then
    select r.id into v_report_id
    from public.live_verified_reports r
    where r.session_id = p_session_id;
    return v_report_id;
  end if;

  insert into public.organization_session_audit (
    organization_id, session_id, actor_user_id, event_key, metadata
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
set search_path = pg_catalog, public, extensions
as $$
declare
  v_report public.live_verified_reports%rowtype;
  v_results_visibility text;
  v_recomputed text;
begin
  select r.* into v_report
  from public.live_verified_reports r
  where r.id = p_report_id;

  if not found then
    raise exception using errcode = 'P0002', message = 'Verified result report not found.';
  end if;

  select s.results_visibility into v_results_visibility
  from public.live_sessions s
  where s.id = v_report.session_id;

  if v_results_visibility = 'organizer_only' then
    if auth.uid() is null or not public.is_current_auth_user_active() then
      raise exception using errcode = 'P0002', message = 'Verified result report not found.';
    end if;
    perform public._session_assert_operator(v_report.session_id);
  end if;

  v_recomputed := pg_catalog.encode(
    extensions.digest(pg_catalog.convert_to(v_report.snapshot::text, 'UTF8'), 'sha256'),
    'hex'
  );

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

-- ============================================================
-- 11) RETENTION CLEANUP PRIVILEGES (REASSERT)
-- ============================================================
revoke all on function public.sessions_retention_cleanup() from public, anon, authenticated;
grant execute on function public.sessions_retention_cleanup() to service_role;

-- Re-apply safe search path after all function replacements above.
do $$
declare
  v_proc record;
begin
  for v_proc in
    select p.oid::regprocedure as proc_identity
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.prosecdef
      and p.proname ~ '^(organization_|session_|sessions_|_session_)'
  loop
    execute format(
      'alter function %s set search_path = pg_catalog, public, extensions',
      v_proc.proc_identity
    );
  end loop;
end;
$$;

comment on constraint organization_workspaces_pilot_billing_hard_off
on public.organization_workspaces is
'Pilot invariant: no paid plan, paid commercial mode or billing can be enabled before a dedicated future billing migration.';

commit;
