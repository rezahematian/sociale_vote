begin;

create extension if not exists pg_cron;
create extension if not exists pg_net;

create or replace function public.invoke_news_cache_refresh()
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_project_url text;
  v_refresh_secret text;
  v_headers jsonb;
  v_body jsonb;
  v_request_id bigint;
begin
  select ds.decrypted_secret
  into v_project_url
  from vault.decrypted_secrets as ds
  where ds.name = 'project_url'
  order by ds.created_at desc
  limit 1;

  if v_project_url is null or btrim(v_project_url) = '' then
    raise exception
      'Missing Vault secret "project_url". Create it before enabling the cron job.';
  end if;

  select ds.decrypted_secret
  into v_refresh_secret
  from vault.decrypted_secrets as ds
  where ds.name = 'news_cache_refresh_secret'
  order by ds.created_at desc
  limit 1;

  v_headers := jsonb_strip_nulls(
    jsonb_build_object(
      'Content-Type', 'application/json',
      'x-refresh-secret', nullif(v_refresh_secret, '')
    )
  );

  v_body := jsonb_build_object(
    'dryRun', false,
    'limit', 25
  );

  select net.http_post(
    url := rtrim(v_project_url, '/') || '/functions/v1/news-cache-refresh',
    headers := v_headers,
    body := v_body,
    timeout_milliseconds := 30000
  )
  into v_request_id;

  return v_request_id;
end;
$$;

comment on function public.invoke_news_cache_refresh() is
  'Invoca la Edge Function news-cache-refresh per aggiornare la cache news backend. Richiede Vault secret "project_url" e opzionalmente "news_cache_refresh_secret".';

select cron.schedule(
  'news-cache-refresh-every-30-minutes',
  '*/30 * * * *',
  $$select public.invoke_news_cache_refresh();$$
);

commit;