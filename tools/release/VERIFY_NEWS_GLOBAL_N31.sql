-- SOCIAL VOTE — NEWS GLOBAL N3.1 / REPAIR + VERIFICA RUNTIME
-- Eseguire una sola volta nel Supabase SQL Editor dopo il deploy N3.1.
-- Non modifica Globe/UI, GeoScope o i contenuti editoriali.

begin;

drop table if exists pg_temp.social_vote_news_n31_request;

create temporary table social_vote_news_n31_request (
  request_id bigint not null
) on commit preserve rows;

insert into social_vote_news_n31_request (request_id)
select public.invoke_news_global_cache_refresh('it');

commit;

select pg_sleep(20);

with response_data as (
  select
    request.request_id,
    response.status_code,
    response.error_msg,
    case
      when response.content is not null then response.content::jsonb
      else '{}'::jsonb
    end as content
  from social_vote_news_n31_request request
  left join net._http_response response
    on response.id = request.request_id
),
global_cache as (
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
payload_rows as (
  select item
  from global_cache cache
  cross join lateral jsonb_array_elements(
    case
      when jsonb_typeof(cache.payload) = 'array' then cache.payload
      else '[]'::jsonb
    end
  ) item
),
payload_metrics as (
  select
    count(*) as payload_items,
    count(*) filter (
      where coalesce(item ->> 'news_id', '') ~*
        '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    ) as canonical_items,
    count(*) filter (where location.location_json is not null) as located_items,
    count(*) filter (
      where location.location_json is not null
        and not exists (
          select 1
          from public.news_location_catalog catalog
          where catalog.is_active
            and upper(catalog.country_code) = upper(
              coalesce(location.location_json ->> 'countryCode', '')
            )
            and abs(
              catalog.latitude - coalesce(
                nullif(location.location_json ->> 'latitude', '')::double precision,
                nullif(location.location_json ->> 'centerLat', '')::double precision
              )
            ) <= 0.001
            and abs(
              catalog.longitude - coalesce(
                nullif(location.location_json ->> 'longitude', '')::double precision,
                nullif(location.location_json ->> 'centerLng', '')::double precision
              )
            ) <= 0.001
        )
    ) as invalid_located_items,
    coalesce(
      jsonb_agg(
        jsonb_build_object(
          'news_id', item ->> 'news_id',
          'title', item ->> 'title',
          'location', location.location_json
        )
        order by item ->> 'publishedAt' desc nulls last
      ) filter (where location.location_json is not null),
      '[]'::jsonb
    ) as located_news
  from payload_rows
  cross join lateral (
    select coalesce(
      item -> '_sv_content_location',
      item -> 'content_location',
      item -> 'contentLocation',
      item -> '_content_location'
    ) as location_json
  ) location
),
schedule_metrics as (
  select
    count(*) as scheduled_jobs,
    count(*) filter (where active) as active_jobs
  from cron.job
  where jobname like 'news-global-%'
),
runtime_metrics as (
  select
    response.request_id,
    response.status_code,
    response.error_msg,
    response.content,
    response.content ->> 'runtimeVersion' as runtime_version,
    response.content #>> '{results,0,providerOrder,0}' as first_provider,
    response.content #>> '{results,0,providerUsed}' as provider_used,
    coalesce(
      (response.content ->> 'locationCatalogCount')::integer,
      0
    ) as location_catalog_count
  from response_data response
)
select
  runtime.request_id,
  runtime.status_code,
  runtime.error_msg,
  runtime.runtime_version,
  runtime.first_provider,
  runtime.provider_used,
  runtime.location_catalog_count,
  cache.cache_key,
  cache.refreshed_at,
  cache.item_count,
  cache.resolved_location_count,
  cache.payload_version,
  payload.canonical_items,
  payload.located_items,
  payload.invalid_located_items,
  schedule.scheduled_jobs,
  schedule.active_jobs,
  (
    runtime.status_code = 200
    and runtime.runtime_version = 'news-global-n3.1'
    and runtime.first_provider = 'gnews'
    and runtime.location_catalog_count > 0
    and cache.item_count > 0
    and cache.payload_version = 4
    and payload.payload_items = cache.item_count
    and payload.canonical_items = cache.item_count
    and payload.located_items > 0
    and payload.invalid_located_items = 0
    and schedule.scheduled_jobs = 6
    and schedule.active_jobs = 6
  ) as runtime_pass,
  payload.located_news,
  runtime.content
from runtime_metrics runtime
cross join global_cache cache
cross join payload_metrics payload
cross join schedule_metrics schedule;
