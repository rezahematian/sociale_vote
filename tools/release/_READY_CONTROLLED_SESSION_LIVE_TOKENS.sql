-- SOCIAL VOTE â€” Controlled Session live-token UX/runtime fix
-- 2026-08-22
-- Purpose:
--   * allow an authenticated organization operator to generate additional
--     Controlled Anonymous participant tokens while a Session is DRAFT or OPEN;
--   * keep CLOSED Sessions immutable;
--   * preserve hash-only token storage, participant cap and audit;
--   * accept participant token casing safely (SV-ABCD == sv-abcd).

create or replace function public.session_generate_tokens(
  p_session_id uuid,
  p_count integer
)
returns table(token text)
language plpgsql
security definer
set search_path = pg_catalog, public, extensions
as $$
declare
  v_org_id uuid;
  v_session public.live_sessions%rowtype;
  v_existing integer;
  v_plain text;
  i integer;
begin
  v_org_id := public._session_assert_operator(p_session_id);

  select * into v_session
  from public.live_sessions
  where id = p_session_id
  for update;

  if v_session.status not in ('draft', 'open')
     or v_session.access_mode <> 'controlled_token_pool' then
    raise exception using
      errcode = '22023',
      message = 'Tokens are available only for draft/open Controlled Sessions.';
  end if;

  if p_count is null or p_count not between 1 and 250 then
    raise exception using errcode = '22023', message = 'Invalid token count.';
  end if;

  select count(*) into v_existing
  from public.live_access_tokens
  where session_id = p_session_id
    and status = 'active';

  if v_existing + p_count > v_session.max_participants then
    raise exception using
      errcode = '22023',
      message = 'Token count exceeds pilot participant limit.';
  end if;

  for i in 1..p_count loop
    v_plain := 'SV-' || upper(encode(extensions.gen_random_bytes(10), 'hex'));

    insert into public.live_access_tokens (session_id, token_hash)
    values (
      p_session_id,
      pg_catalog.encode(
        extensions.digest(pg_catalog.convert_to(v_plain, 'UTF8'), 'sha256'),
        'hex'
      )
    );

    token := v_plain;
    return next;
  end loop;

  insert into public.organization_session_audit (
    organization_id,
    session_id,
    actor_user_id,
    event_key,
    metadata
  ) values (
    v_org_id,
    p_session_id,
    auth.uid(),
    'token_batch_generated',
    jsonb_build_object('count', p_count, 'session_status', v_session.status)
  );
end;
$$;

revoke all on function public.session_generate_tokens(uuid,integer) from public, anon;
grant execute on function public.session_generate_tokens(uuid,integer) to authenticated;

-- Keep the hardened join behavior and normalize token casing before hashing.
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
        extensions.digest(
          pg_catalog.convert_to(upper(btrim(p_token)), 'UTF8'),
          'sha256'
        ),
        'hex'
      )
      and status = 'active'
    limit 1;

    if v_token_id is null then
      raise exception using errcode = '42501', message = 'Invalid participant token.';
    end if;

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


-- READ-ONLY verify: Controlled Session token generation while open.
with checks(check_name, pass, detail) as (
  values
    (
      '01_generate_tokens_security_definer',
      coalesce((select p.prosecdef from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public' and p.proname='session_generate_tokens' and pg_get_function_identity_arguments(p.oid)='p_session_id uuid, p_count integer'), false),
      'session_generate_tokens must remain SECURITY DEFINER'
    ),
    (
      '02_generate_tokens_open_supported',
      coalesce((select position('not in (''draft'', ''open'')' in lower(pg_get_functiondef(p.oid))) > 0 from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public' and p.proname='session_generate_tokens' and pg_get_function_identity_arguments(p.oid)='p_session_id uuid, p_count integer'), false),
      'token batches can be generated only while draft/open, never closed'
    ),
    (
      '03_generate_tokens_acl',
      not coalesce(has_function_privilege('anon','public.session_generate_tokens(uuid,integer)','EXECUTE'),false)
      and coalesce(has_function_privilege('authenticated','public.session_generate_tokens(uuid,integer)','EXECUTE'),false),
      'anon=false; authenticated=true; internal membership assertion remains authoritative'
    ),
    (
      '04_join_token_case_normalized',
      coalesce((select position('upper(btrim(p_token))' in lower(pg_get_functiondef(p.oid))) > 0 from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public' and p.proname='session_public_join' and pg_get_function_identity_arguments(p.oid)='p_join_code text, p_token text'), false),
      'controlled token hashing normalizes case + surrounding whitespace'
    ),
    (
      '05_token_plaintext_not_persisted',
      not exists (
        select 1 from information_schema.columns
        where table_schema='public' and table_name='live_access_tokens'
          and lower(column_name) in ('token','plain_token','plaintext_token')
      ),
      'live_access_tokens persists token_hash only'
    )
), totals as (
  select count(*) filter (where not pass) as failed_checks from checks
)
select c.check_name, c.pass, c.detail, t.failed_checks,
       case when t.failed_checks=0 then 'PASS' else 'FAIL' end as overall_status
from checks c cross join totals t
order by c.check_name;

