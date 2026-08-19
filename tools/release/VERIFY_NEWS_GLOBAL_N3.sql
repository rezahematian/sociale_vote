-- SOCIAL VOTE — NEWS N3 / VERIFICA RUNTIME
-- Eseguire dopo:
--   1) migrazione 20260819_news_global_cache_budget.sql
--   2) deploy Edge Function news-cache-refresh
--
-- PASS minimo:
--   status_code = 200
--   location_catalog_count > 0 nel content JSON
--   item_count > 0
--   canonical_items > 0
--   located_items > 0 oppure provider senza elementi con vecchia cache preservata
--   scheduled_jobs = 6 e active_jobs = 6

begin;

drop table if exists pg_temp.social_vote_news_n3_request;

create temporary table social_vote_news_n3_request (
  request_id bigint not null
) on commit preserve rows;

insert into social_vote_news_n3_request (request_id)
select public.invoke_news_global_cache_refresh('it');

commit;

select pg_sleep(20);

with global_cache as (
  select
    cache_key,
    refreshed_at,
    item_count,
    resolved_location_count,
    payload_version,
    payload
  from public.news_feed_cache
  where cache_key = 'country=*|city=*|topic=*|language=it'
  limit 1
),
payload_metrics as (
  select
    count(*) filter (
      where coalesce(item ->> 'news_id', '') ~*
        '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    ) as canonical_items,
    count(*) filter (
      where
        coalesce(
          item -> '_sv_content_location',
          item -> 'content_location',
          item -> 'contentLocation',
          item -> '_content_location'
        ) is not null
    ) as located_items,
    coalesce(
      jsonb_agg(
        jsonb_build_object(
          'news_id', item ->> 'news_id',
          'title', item ->> 'title',
          'location', coalesce(
            item -> '_sv_content_location',
            item -> 'content_location',
            item -> 'contentLocation',
            item -> '_content_location'
          )
        )
        order by item ->> 'publishedAt' desc nulls last
      ) filter (
        where coalesce(
          item -> '_sv_content_location',
          item -> 'content_location',
          item -> 'contentLocation',
          item -> '_content_location'
        ) is not null
      ),
      '[]'::jsonb
    ) as located_news
  from global_cache cache
  cross join lateral jsonb_array_elements(
    case
      when jsonb_typeof(cache.payload) = 'array' then cache.payload
      else '[]'::jsonb
    end
  ) item
),
schedule_metrics as (
  select
    count(*) as scheduled_jobs,
    count(*) filter (where active) as active_jobs,
    jsonb_agg(
      jsonb_build_object(
        'jobname', jobname,
        'schedule', schedule,
        'active', active
      )
      order by jobname
    ) as jobs
  from cron.job
  where jobname like 'news-global-%'
)
select
  request.request_id,
  response.status_code,
  response.error_msg,
  response.content,
  cache.cache_key,
  cache.refreshed_at,
  cache.item_count,
  cache.resolved_location_count,
  cache.payload_version,
  payload.canonical_items,
  payload.located_items,
  payload.located_news,
  schedule.scheduled_jobs,
  schedule.active_jobs,
  schedule.jobs
from social_vote_news_n3_request request
left join net._http_response response
  on response.id = request.request_id
left join global_cache cache
  on true
left join payload_metrics payload
  on true
left join schedule_metrics schedule
  on true;
