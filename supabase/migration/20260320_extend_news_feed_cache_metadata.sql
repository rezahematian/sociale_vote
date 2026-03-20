begin;

alter table public.news_feed_cache
  add column if not exists item_count integer,
  add column if not exists resolved_location_count integer,
  add column if not exists provider_signatures jsonb,
  add column if not exists languages_present jsonb,
  add column if not exists payload_version integer;

alter table public.news_feed_cache
  alter column item_count set default 0,
  alter column resolved_location_count set default 0,
  alter column provider_signatures set default '[]'::jsonb,
  alter column languages_present set default '[]'::jsonb,
  alter column payload_version set default 1;

update public.news_feed_cache
set item_count = case
  when jsonb_typeof(payload) = 'array' then jsonb_array_length(payload)
  else 0
end;

update public.news_feed_cache as n
set resolved_location_count = (
  select count(*)
  from jsonb_array_elements(
    case
      when jsonb_typeof(n.payload) = 'array' then n.payload
      else '[]'::jsonb
    end
  ) as item
  where jsonb_typeof(item) = 'object'
    and (
      (item ? '_sv_content_location'
        and item->'_sv_content_location' is not null
        and jsonb_typeof(item->'_sv_content_location') = 'object')
      or
      (item ? 'content_location'
        and item->'content_location' is not null
        and jsonb_typeof(item->'content_location') = 'object')
      or
      (item ? 'contentLocation'
        and item->'contentLocation' is not null
        and jsonb_typeof(item->'contentLocation') = 'object')
      or
      (item ? '_content_location'
        and item->'_content_location' is not null
        and jsonb_typeof(item->'_content_location') = 'object')
    )
);

update public.news_feed_cache as n
set provider_signatures = (
  select coalesce(jsonb_agg(to_jsonb(p.provider_signature)), '[]'::jsonb)
  from (
    select distinct provider_signature
    from (
      select nullif(
        lower(
          btrim(
            coalesce(
              nullif(item->>'provider', ''),
              nullif(item->>'provider_id', ''),
              nullif(item->>'providerId', ''),
              nullif(item->>'provider_name', ''),
              nullif(item->>'providerName', ''),
              nullif(item->>'source', ''),
              nullif(item->>'source_id', ''),
              nullif(item->>'sourceId', ''),
              nullif(item->>'source_name', ''),
              nullif(item->>'sourceName', '')
            )
          )
        ),
        ''
      ) as provider_signature
      from jsonb_array_elements(
        case
          when jsonb_typeof(n.payload) = 'array' then n.payload
          else '[]'::jsonb
        end
      ) as item
      where jsonb_typeof(item) = 'object'
    ) raw
    where provider_signature is not null
  ) p
);

update public.news_feed_cache as n
set languages_present = (
  select coalesce(jsonb_agg(to_jsonb(l.language_code)), '[]'::jsonb)
  from (
    select distinct language_code
    from (
      select nullif(
        lower(
          split_part(
            replace(
              btrim(
                coalesce(
                  nullif(item->>'language', ''),
                  nullif(item->>'lang', ''),
                  nullif(item->>'locale', ''),
                  nullif(item->>'content_language', ''),
                  nullif(item->>'contentLanguage', ''),
                  nullif(item->>'feed_language', ''),
                  nullif(item->>'feedLanguage', '')
                )
              ),
              '_',
              '-'
            ),
            '-',
            1
          )
        ),
        ''
      ) as language_code
      from jsonb_array_elements(
        case
          when jsonb_typeof(n.payload) = 'array' then n.payload
          else '[]'::jsonb
        end
      ) as item
      where jsonb_typeof(item) = 'object'
    ) raw
    where language_code is not null
  ) l
);

update public.news_feed_cache
set payload_version = coalesce(payload_version, 1);

update public.news_feed_cache
set provider_signatures = '[]'::jsonb
where provider_signatures is null;

update public.news_feed_cache
set languages_present = '[]'::jsonb
where languages_present is null;

update public.news_feed_cache
set item_count = 0
where item_count is null;

update public.news_feed_cache
set resolved_location_count = 0
where resolved_location_count is null;

alter table public.news_feed_cache
  alter column item_count set not null,
  alter column resolved_location_count set not null,
  alter column provider_signatures set not null,
  alter column languages_present set not null,
  alter column payload_version set not null;

comment on column public.news_feed_cache.item_count is
  'Numero articoli presenti nel payload cache per quella cache_key.';

comment on column public.news_feed_cache.resolved_location_count is
  'Numero articoli nel payload che hanno una content location già incorporata.';

comment on column public.news_feed_cache.provider_signatures is
  'Lista provider/sorgenti rilevati dal payload, utile per debug e fallback coerenti.';

comment on column public.news_feed_cache.languages_present is
  'Lista lingue rilevate nel payload, normalizzate sulla lingua base.';

comment on column public.news_feed_cache.payload_version is
  'Versione logica del formato payload cache.';

commit;