-- Social Vote — AC8.5 News Open Content diagnostic
-- READ ONLY: no schema or data changes.
--
-- Run in Supabase SQL Editor and return the single JSON result.

with report_columns as (
  select
    ordinal_position,
    column_name,
    data_type,
    is_nullable
  from information_schema.columns
  where table_schema = 'public'
    and table_name = 'reports'
  order by ordinal_position
),
recent_news_reports as (
  select
    r.id::text as report_id,
    r.target_type::text as target_type,
    r.target_id::text as target_id,
    r.reason,
    r.status::text as status,
    r.created_at,
    to_jsonb(r) as complete_report_row,
    coalesce(
      to_jsonb(r) ->> 'target_url',
      to_jsonb(r) ->> 'original_url',
      to_jsonb(r) ->> 'content_url',
      to_jsonb(r) ->> 'source_url',
      to_jsonb(r) ->> 'article_url',
      to_jsonb(r) ->> 'url',
      to_jsonb(r) #>> '{metadata,targetUrl}',
      to_jsonb(r) #>> '{metadata,target_url}',
      to_jsonb(r) #>> '{metadata,originalUrl}',
      to_jsonb(r) #>> '{metadata,original_url}',
      to_jsonb(r) #>> '{metadata,articleUrl}',
      to_jsonb(r) #>> '{metadata,article_url}',
      to_jsonb(r) #>> '{metadata,url}'
    ) as detected_original_url,
    coalesce(
      to_jsonb(r) ->> 'target_title',
      to_jsonb(r) ->> 'content_title',
      to_jsonb(r) ->> 'title',
      to_jsonb(r) #>> '{metadata,targetTitle}',
      to_jsonb(r) #>> '{metadata,target_title}',
      to_jsonb(r) #>> '{metadata,title}'
    ) as detected_title
  from public.reports r
  where lower(btrim(r.target_type::text)) = 'news'
  order by r.created_at desc
  limit 20
)
select jsonb_pretty(
  jsonb_build_object(
    'generated_at', clock_timestamp(),
    'reports_columns',
      coalesce(
        (select jsonb_agg(to_jsonb(c)) from report_columns c),
        '[]'::jsonb
      ),
    'recent_news_reports',
      coalesce(
        (select jsonb_agg(to_jsonb(n)) from recent_news_reports n),
        '[]'::jsonb
      )
  )
) as news_open_content_diagnostic;
