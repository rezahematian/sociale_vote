-- SOCIAL VOTE — NEWS CACHE N2 / VERIFICA RUNTIME MERANO
-- Eseguire in Supabase SQL Editor dopo il deploy di news-cache-refresh.
-- Risultato atteso:
--   status_code = 200
--   content contiene no_provider_items_canonicalized_existing_cache
--   canonical_candidates > 0

begin;

drop table if exists pg_temp.social_vote_merano_refresh_n2;

create temporary table social_vote_merano_refresh_n2 (
  request_id bigint not null
) on commit preserve rows;

insert into social_vote_merano_refresh_n2 (request_id)
select net.http_post(
  url := rtrim(
    (
      select decrypted_secret
      from vault.decrypted_secrets
      where name = 'project_url'
      order by created_at desc
      limit 1
    ),
    '/'
  ) || '/functions/v1/news-cache-refresh',

  headers := jsonb_strip_nulls(
    jsonb_build_object(
      'Content-Type', 'application/json',

      'apikey',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJidXpscmNsd2h4YWlna2duZHJiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMyNDY3MzYsImV4cCI6MjA4ODgyMjczNn0.dHNA8s3NcqnluakSb-NFnb2jNgCcaVm3Ix24LbbIpHI',

      'Authorization',
      'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJidXpscmNsd2h4YWlna2duZHJiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMyNDY3MzYsImV4cCI6MjA4ODgyMjczNn0.dHNA8s3NcqnluakSb-NFnb2jNgCcaVm3Ix24LbbIpHI',

      'x-refresh-secret',
      (
        select nullif(decrypted_secret, '')
        from vault.decrypted_secrets
        where name = 'news_cache_refresh_secret'
        order by created_at desc
        limit 1
      )
    )
  ),

  body := jsonb_build_object(
    'dryRun', false,
    'limit', 1,
    'countryCode', 'IT',
    'cityId', 'Merano',
    'language', 'it'
  ),

  timeout_milliseconds := 30000
);

commit;

select pg_sleep(12);

select
  request.request_id,
  response.status_code,
  response.error_msg,
  response.content,
  count(candidate.news_id) as canonical_candidates,
  coalesce(
    jsonb_agg(
      jsonb_build_object(
        'news_id', candidate.news_id,
        'title', candidate.title,
        'article_url', candidate.article_url,
        'published_at', candidate.published_at,
        'location_label', candidate.detected_location_label,
        'latitude', candidate.detected_latitude,
        'longitude', candidate.detected_longitude
      )
      order by candidate.published_at desc nulls last
    ) filter (where candidate.news_id is not null),
    '[]'::jsonb
  ) as candidates
from social_vote_merano_refresh_n2 request
left join net._http_response response
  on response.id = request.request_id
left join app_private.news_map_editorial_candidates candidate
  on lower(coalesce(candidate.feed_city_id, '')) = 'merano'
group by
  request.request_id,
  response.status_code,
  response.error_msg,
  response.content;
