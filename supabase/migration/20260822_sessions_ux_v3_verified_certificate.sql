-- Social Vote Sessions UX V3 / Verified Result Certificate V2
-- Product/read-model + immutable report snapshot enrichment only.
-- Billing remains OFF. No legal/notarial/electoral validity is introduced.

begin;

-- ============================================================
-- 1) ORGANIZER SESSION READ MODEL: REAL OPERATIONAL COUNTERS
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
      'token_count', (
        select count(*)
        from public.live_access_tokens t
        where t.session_id = s.id and t.status = 'active'
      ),
      'participant_count', (
        select count(*)
        from public.live_participant_credentials c
        where c.session_id = s.id
          and c.expires_at > pg_catalog.now()
      ),
      'used_access_count', case
        when s.access_mode = 'controlled_token_pool' then (
          select count(distinct u.token_id)
          from public.live_token_question_uses u
          join public.live_questions uq on uq.id = u.question_id
          where uq.session_id = s.id
        )
        else (
          select count(distinct u.credential_id)
          from public.live_open_question_uses u
          join public.live_questions uq on uq.id = u.question_id
          where uq.session_id = s.id
        )
      end,
      'question_count', (
        select count(*) from public.live_questions q where q.session_id = s.id
      ),
      'response_count', (
        select count(*)
        from public.live_ballots b
        join public.live_questions q on q.id = b.question_id
        where q.session_id = s.id
      ),
      'created_at', s.created_at,
      'opened_at', s.opened_at,
      'closed_at', s.closed_at,
      'report_id', (
        select r.id from public.live_verified_reports r where r.session_id = s.id
      )
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

-- Public/participant read model intentionally does not reveal organizer counters.
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
      'participant_count', 0,
      'used_access_count', 0,
      'question_count', (
        select count(*)
        from public.live_questions q
        where q.session_id = s.id and q.status in ('open','closed')
      ),
      'response_count', 0,
      'created_at', s.created_at,
      'opened_at', s.opened_at,
      'closed_at', s.closed_at,
      'report_id', case
        when s.status = 'closed' and s.results_visibility <> 'organizer_only'
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
            from public.live_options o
            where o.question_id = q.id
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

  if v_workspace_id is null then
    return '[]'::jsonb;
  end if;

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
        'token_count', (
          select count(*)
          from public.live_access_tokens t
          where t.session_id = s.id and t.status = 'active'
        ),
        'participant_count', (
          select count(*)
          from public.live_participant_credentials c
          where c.session_id = s.id
            and c.expires_at > pg_catalog.now()
        ),
        'used_access_count', case
          when s.access_mode = 'controlled_token_pool' then (
            select count(distinct u.token_id)
            from public.live_token_question_uses u
            join public.live_questions uq on uq.id = u.question_id
            where uq.session_id = s.id
          )
          else (
            select count(distinct u.credential_id)
            from public.live_open_question_uses u
            join public.live_questions uq on uq.id = u.question_id
            where uq.session_id = s.id
          )
        end,
        'question_count', (
          select count(*) from public.live_questions q where q.session_id = s.id
        ),
        'response_count', (
          select count(*)
          from public.live_ballots b
          join public.live_questions q on q.id = b.question_id
          where q.session_id = s.id
        ),
        'created_at', s.created_at,
        'opened_at', s.opened_at,
        'closed_at', s.closed_at,
        'report_id', (
          select r.id from public.live_verified_reports r where r.session_id = s.id
        )
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
-- 2) VERIFIED RESULT CERTIFICATE SNAPSHOT V2
--    Freeze Organization identity/branding at close time.
--    No participant identity/token/credential is linked to a ballot.
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
  v_certificate_number text;
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

  v_report_id := extensions.gen_random_uuid();
  v_certificate_number := 'SVR-'
    || pg_catalog.to_char(v_session.closed_at at time zone 'UTC', 'YYYY')
    || '-'
    || pg_catalog.upper(pg_catalog.substr(pg_catalog.replace(v_report_id::text, '-', ''), 1, 12));

  select jsonb_build_object(
    'schema_version', 2,
    'report_type', 'social_vote_verified_result',
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
      'schema_version', 2
    )
  );

  return v_report_id;
end;
$$;

revoke all on function public.session_close(uuid) from public, anon;
grant execute on function public.session_close(uuid) to authenticated;

-- Reassert controlled search_path for all touched SECURITY DEFINER functions.
alter function public._session_detail_json(uuid)
  set search_path = pg_catalog, public, extensions;
alter function public._session_public_detail_json(uuid)
  set search_path = pg_catalog, public, extensions;
alter function public.sessions_list_mine()
  set search_path = pg_catalog, public, extensions;
alter function public.session_close(uuid)
  set search_path = pg_catalog, public, extensions;

commit;
