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
