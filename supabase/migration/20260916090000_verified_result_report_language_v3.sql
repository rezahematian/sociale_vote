-- SOCIAL VOTE VERIFIED RESULT PDF V3 R2
-- Canonical report language + immutable Verified Result schema v3.
-- Additive migration: existing schema-v2 verified reports are never modified.

begin;

alter table public.live_sessions
  add column if not exists report_language text;

do $$
begin
  if not exists (
    select 1
    from pg_catalog.pg_constraint
    where conrelid = 'public.live_sessions'::regclass
      and conname = 'live_sessions_report_language_check'
  ) then
    alter table public.live_sessions
      add constraint live_sessions_report_language_check
      check (
        report_language is null
        or report_language in ('ar','de','en','es','fa','fr','it','pt','ro','ru','zh')
      );
  end if;
end;
$$;

-- New client signature. The historical five-argument function remains in place
-- so an older installed client is not broken by this migration.
create or replace function public.session_create(
  p_title text,
  p_access_mode text,
  p_results_visibility text,
  p_raw_retention text,
  p_expected_participants integer,
  p_report_language text
)
returns uuid
language plpgsql
security definer
set search_path = pg_catalog, public, extensions
as $$
declare
  v_user_id uuid := auth.uid();
  v_workspace_id uuid;
  v_org_id uuid;
  v_session_id uuid;
  v_join_code text;
  v_report_language text := pg_catalog.lower(pg_catalog.btrim(p_report_language));
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
  if nullif(pg_catalog.btrim(p_title), '') is null then
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
  if v_report_language not in ('ar','de','en','es','fa','fr','it','pt','ro','ru','zh') then
    raise exception using errcode = '22023', message = 'Invalid report language.';
  end if;

  loop
    v_attempt := v_attempt + 1;
    v_join_code := pg_catalog.upper(
      pg_catalog.substr(pg_catalog.encode(extensions.gen_random_bytes(6), 'hex'), 1, 8)
    );
    exit when not exists (
      select 1 from public.live_sessions where join_code = v_join_code
    );
    if v_attempt > 12 then
      raise exception 'Unable to allocate a join code.';
    end if;
  end loop;

  insert into public.live_sessions (
    workspace_id,
    created_by,
    title,
    join_code,
    access_mode,
    results_visibility,
    raw_retention,
    expected_participants,
    max_participants,
    report_language
  ) values (
    v_workspace_id,
    v_user_id,
    pg_catalog.btrim(p_title),
    v_join_code,
    p_access_mode,
    p_results_visibility,
    p_raw_retention,
    p_expected_participants,
    250,
    v_report_language
  ) returning id into v_session_id;

  insert into public.organization_session_audit (
    organization_id,
    session_id,
    actor_user_id,
    event_key,
    metadata
  ) values (
    v_org_id,
    v_session_id,
    v_user_id,
    'session_created',
    jsonb_build_object(
      'access_mode', p_access_mode,
      'results_visibility', p_results_visibility,
      'raw_retention', p_raw_retention,
      'report_language', v_report_language
    )
  );

  return v_session_id;
end;
$$;

revoke all on function public.session_create(text,text,text,text,integer,text)
  from public, anon;
grant execute on function public.session_create(text,text,text,text,integer,text)
  to authenticated;

-- From schema v3 onward, report_language becomes part of the immutable snapshot
-- and therefore of the SHA-256 covered report. Existing live_verified_reports
-- are not rewritten or re-hashed.
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
  v_certificate_number text;
  v_report_language text;
begin
  v_org_id := public._session_assert_operator(p_session_id);
  select * into v_session
  from public.live_sessions
  where id = p_session_id
  for update;

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
    set status = 'closed',
        closed_at = coalesce(closed_at, pg_catalog.now())
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

  select * into v_org
  from public.organization_entities
  where id = v_org_id;

  v_report_language := coalesce(
    nullif(pg_catalog.lower(pg_catalog.btrim(v_session.report_language)), ''),
    'en'
  );

  if v_report_language not in ('ar','de','en','es','fa','fr','it','pt','ro','ru','zh') then
    v_report_language := 'en';
  end if;

  v_report_id := extensions.gen_random_uuid();
  v_certificate_number := 'SVR-'
    || pg_catalog.to_char(v_session.closed_at at time zone 'UTC', 'YYYY')
    || '-'
    || pg_catalog.upper(
      pg_catalog.substr(pg_catalog.replace(v_report_id::text, '-', ''), 1, 12)
    );

  select jsonb_build_object(
    'schema_version', 3,
    'report_type', 'social_vote_verified_result',
    'report_language', v_report_language,
    'report_id', v_report_id,
    'certificate_number', v_certificate_number,
    'certificate_issued_at', v_session.closed_at,
    'integrity_algorithm', 'SHA-256',
    'session_id', v_session.id,
    'organization_id', v_org.id,
    'organization_legal_name', v_org.legal_name,
    'organization_name', v_org.public_name,
    'organization_entity_type', v_org.entity_type,
    'organization_country_code', v_org.country_code,
    'organization_city', v_org.city,
    'organization_website_url', v_org.website_url,
    'organization_logo_url', v_org.logo_url,
    'organization_verification_status', v_org.verification_status,
    'organization_verified_at', v_org.verified_at,
    'session_title', v_session.title,
    'join_code', v_session.join_code,
    'access_mode', v_session.access_mode,
    'results_visibility', v_session.results_visibility,
    'raw_retention', v_session.raw_retention,
    'expected_participants', v_session.expected_participants,
    'eligible_credentials', case
      when v_session.access_mode = 'controlled_token_pool' then (
        select count(*)
        from public.live_access_tokens t
        where t.session_id = v_session.id and t.status = 'active'
      )
      else null
    end,
    'participant_credentials_joined', (
      select count(*)
      from public.live_participant_credentials c
      where c.session_id = v_session.id
    ),
    'participants_with_recorded_vote', case
      when v_session.access_mode = 'controlled_token_pool' then (
        select count(distinct u.token_id)
        from public.live_token_question_uses u
        join public.live_questions uq on uq.id = u.question_id
        where uq.session_id = v_session.id
      )
      else (
        select count(distinct u.credential_id)
        from public.live_open_question_uses u
        join public.live_questions uq on uq.id = u.question_id
        where uq.session_id = v_session.id
      )
    end,
    'ballots_total', (
      select count(*)
      from public.live_ballots b
      join public.live_questions q on q.id = b.question_id
      where q.session_id = v_session.id
    ),
    'question_count', (
      select count(*)
      from public.live_questions q
      where q.session_id = v_session.id
    ),
    'opened_at', v_session.opened_at,
    'closed_at', v_session.closed_at,
    'questions', coalesce((
      select jsonb_agg(public._session_question_json(q.id) order by q.position)
      from public.live_questions q
      where q.session_id = v_session.id
    ), '[]'::jsonb),
    'privacy_model', 'aggregate_anonymous_no_identity_ballot_link',
    'integrity_note', 'Immutable aggregate result snapshot. No participant identity, access token or browser credential is linked to a ballot.',
    'legal_scope', 'Social Vote integrity report; not a notarized, electoral or legally binding certification.'
  ) into v_snapshot;

  v_hash := pg_catalog.encode(
    extensions.digest(pg_catalog.convert_to(v_snapshot::text, 'UTF8'), 'sha256'),
    'hex'
  );

  insert into public.live_verified_reports (
    id, session_id, organization_id, snapshot, snapshot_sha256
  ) values (
    v_report_id, p_session_id, v_org_id, v_snapshot, v_hash
  )
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
    v_org_id,
    p_session_id,
    auth.uid(),
    'session_closed',
    jsonb_build_object(
      'report_id', v_report_id,
      'certificate_number', v_certificate_number,
      'sha256', v_hash,
      'schema_version', 3,
      'report_language', v_report_language
    )
  );

  return v_report_id;
end;
$$;

revoke all on function public.session_close(uuid) from public, anon;
grant execute on function public.session_close(uuid) to authenticated;

commit;
