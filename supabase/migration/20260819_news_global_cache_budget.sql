-- Social Vote — News N3
-- One shared worldwide News catalog, deterministic location catalog and
-- conservative provider budget. No client or city-scope refresh is scheduled.

begin;

create extension if not exists pg_cron;
create extension if not exists pg_net;

create table if not exists public.news_location_catalog (
  catalog_key text primary key,
  location_kind text not null,
  label text not null,
  country_code text not null,
  city_id text,
  latitude double precision not null,
  longitude double precision not null,
  aliases text[] not null default '{}'::text[],
  priority smallint not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default clock_timestamp(),
  updated_at timestamptz not null default clock_timestamp(),

  constraint news_location_catalog_kind_check
    check (location_kind in ('country', 'city')),
  constraint news_location_catalog_country_check
    check (country_code ~ '^[A-Z]{2}$'),
  constraint news_location_catalog_city_check
    check (
      (location_kind = 'country' and city_id is null)
      or
      (location_kind = 'city' and nullif(btrim(city_id), '') is not null)
    ),
  constraint news_location_catalog_latitude_check
    check (latitude between -90 and 90),
  constraint news_location_catalog_longitude_check
    check (longitude between -180 and 180),
  constraint news_location_catalog_priority_check
    check (priority between 0 and 100)
);

comment on table public.news_location_catalog is
  'Curated deterministic locations used only by the backend News cache. It prevents guessed or user-scope coordinates.';

alter table public.news_location_catalog enable row level security;
alter table public.news_location_catalog force row level security;

revoke all
on table public.news_location_catalog
from public, anon, authenticated;

grant select
on table public.news_location_catalog
to service_role;

insert into public.news_location_catalog (
  catalog_key,
  location_kind,
  label,
  country_code,
  city_id,
  latitude,
  longitude,
  aliases,
  priority,
  is_active,
  updated_at
)
values
  ('country:it', 'country', 'Italia', 'IT', null, 42.8333, 12.8333, array['italia','italy','italian','italiano','italiana'], 40, true, clock_timestamp()),
  ('country:gb', 'country', 'Regno Unito', 'GB', null, 54.0000, -2.0000, array['regno unito','united kingdom','uk','u k','britain','british','inghilterra','england'], 40, true, clock_timestamp()),
  ('country:us', 'country', 'Stati Uniti', 'US', null, 39.8283, -98.5795, array['stati uniti','united states','usa','american','americans','statunitense'], 40, true, clock_timestamp()),
  ('country:fr', 'country', 'Francia', 'FR', null, 46.2276, 2.2137, array['francia','france','french','francese'], 40, true, clock_timestamp()),
  ('country:de', 'country', 'Germania', 'DE', null, 51.1657, 10.4515, array['germania','germany','german','tedesco','tedesca'], 40, true, clock_timestamp()),
  ('country:es', 'country', 'Spagna', 'ES', null, 40.4637, -3.7492, array['spagna','spain','spanish','spagnolo','spagnola'], 40, true, clock_timestamp()),
  ('country:pt', 'country', 'Portogallo', 'PT', null, 39.3999, -8.2245, array['portogallo','portugal','portuguese'], 40, true, clock_timestamp()),
  ('country:nl', 'country', 'Paesi Bassi', 'NL', null, 52.1326, 5.2913, array['paesi bassi','netherlands','dutch','olandese'], 40, true, clock_timestamp()),
  ('country:be', 'country', 'Belgio', 'BE', null, 50.5039, 4.4699, array['belgio','belgium','belgian'], 40, true, clock_timestamp()),
  ('country:ch', 'country', 'Svizzera', 'CH', null, 46.8182, 8.2275, array['svizzera','switzerland','swiss'], 40, true, clock_timestamp()),
  ('country:at', 'country', 'Austria', 'AT', null, 47.5162, 14.5501, array['austria','austrian'], 40, true, clock_timestamp()),
  ('country:dk', 'country', 'Danimarca', 'DK', null, 56.2639, 9.5018, array['danimarca','denmark','danish'], 40, true, clock_timestamp()),
  ('country:se', 'country', 'Svezia', 'SE', null, 60.1282, 18.6435, array['svezia','sweden','swedish'], 40, true, clock_timestamp()),
  ('country:no', 'country', 'Norvegia', 'NO', null, 60.4720, 8.4689, array['norvegia','norway','norwegian'], 40, true, clock_timestamp()),
  ('country:pl', 'country', 'Polonia', 'PL', null, 51.9194, 19.1451, array['polonia','poland','polish'], 40, true, clock_timestamp()),
  ('country:gr', 'country', 'Grecia', 'GR', null, 39.0742, 21.8243, array['grecia','greece','greek'], 40, true, clock_timestamp()),
  ('country:ua', 'country', 'Ucraina', 'UA', null, 48.3794, 31.1656, array['ucraina','ukraine','ukrainian'], 45, true, clock_timestamp()),
  ('country:ru', 'country', 'Russia', 'RU', null, 61.5240, 105.3188, array['russia','russian','russa','russo'], 45, true, clock_timestamp()),
  ('country:tr', 'country', 'Turchia', 'TR', null, 38.9637, 35.2433, array['turchia','turkey','turkiye','türkiye','turkish'], 40, true, clock_timestamp()),
  ('country:ir', 'country', 'Iran', 'IR', null, 32.4279, 53.6880, array['iran','iranian'], 45, true, clock_timestamp()),
  ('country:iq', 'country', 'Iraq', 'IQ', null, 33.2232, 43.6793, array['iraq','iraqi'], 45, true, clock_timestamp()),
  ('country:il', 'country', 'Israele', 'IL', null, 31.0461, 34.8516, array['israele','israel','israeli'], 45, true, clock_timestamp()),
  ('country:ps', 'country', 'Palestina', 'PS', null, 31.9522, 35.2332, array['palestina','palestine','palestinian'], 45, true, clock_timestamp()),
  ('country:lb', 'country', 'Libano', 'LB', null, 33.8547, 35.8623, array['libano','lebanon','lebanese'], 40, true, clock_timestamp()),
  ('country:sy', 'country', 'Siria', 'SY', null, 34.8021, 38.9968, array['siria','syria','syrian'], 40, true, clock_timestamp()),
  ('country:sa', 'country', 'Arabia Saudita', 'SA', null, 23.8859, 45.0792, array['arabia saudita','saudi arabia','saudi'], 40, true, clock_timestamp()),
  ('country:ae', 'country', 'Emirati Arabi Uniti', 'AE', null, 23.4241, 53.8478, array['emirati arabi uniti','united arab emirates','uae'], 40, true, clock_timestamp()),
  ('country:qa', 'country', 'Qatar', 'QA', null, 25.3548, 51.1839, array['qatar','qatari'], 40, true, clock_timestamp()),
  ('country:eg', 'country', 'Egitto', 'EG', null, 26.8206, 30.8025, array['egitto','egypt','egyptian'], 40, true, clock_timestamp()),
  ('country:sd', 'country', 'Sudan', 'SD', null, 12.8628, 30.2176, array['sudan','sudanese'], 40, true, clock_timestamp()),
  ('country:et', 'country', 'Etiopia', 'ET', null, 9.1450, 40.4897, array['etiopia','ethiopia','ethiopian'], 40, true, clock_timestamp()),
  ('country:so', 'country', 'Somalia', 'SO', null, 5.1521, 46.1996, array['somalia','somali'], 40, true, clock_timestamp()),
  ('country:ke', 'country', 'Kenya', 'KE', null, -0.0236, 37.9062, array['kenya','kenyan'], 40, true, clock_timestamp()),
  ('country:ng', 'country', 'Nigeria', 'NG', null, 9.0820, 8.6753, array['nigeria','nigerian'], 40, true, clock_timestamp()),
  ('country:za', 'country', 'Sudafrica', 'ZA', null, -30.5595, 22.9375, array['sudafrica','south africa','south african'], 40, true, clock_timestamp()),
  ('country:cn', 'country', 'Cina', 'CN', null, 35.8617, 104.1954, array['cina','china','chinese'], 45, true, clock_timestamp()),
  ('country:tw', 'country', 'Taiwan', 'TW', null, 23.6978, 120.9605, array['taiwan','taiwanese'], 45, true, clock_timestamp()),
  ('country:jp', 'country', 'Giappone', 'JP', null, 36.2048, 138.2529, array['giappone','japan','japanese'], 40, true, clock_timestamp()),
  ('country:kr', 'country', 'Corea del Sud', 'KR', null, 35.9078, 127.7669, array['corea del sud','south korea','korean'], 40, true, clock_timestamp()),
  ('country:in', 'country', 'India', 'IN', null, 20.5937, 78.9629, array['india','indian'], 45, true, clock_timestamp()),
  ('country:pk', 'country', 'Pakistan', 'PK', null, 30.3753, 69.3451, array['pakistan','pakistani'], 40, true, clock_timestamp()),
  ('country:au', 'country', 'Australia', 'AU', null, -25.2744, 133.7751, array['australia','australian'], 40, true, clock_timestamp()),
  ('country:nz', 'country', 'Nuova Zelanda', 'NZ', null, -40.9006, 174.8860, array['nuova zelanda','new zealand'], 40, true, clock_timestamp()),
  ('country:ca', 'country', 'Canada', 'CA', null, 56.1304, -106.3468, array['canada','canadian'], 40, true, clock_timestamp()),
  ('country:mx', 'country', 'Messico', 'MX', null, 23.6345, -102.5528, array['messico','mexico','mexican'], 40, true, clock_timestamp()),
  ('country:br', 'country', 'Brasile', 'BR', null, -14.2350, -51.9253, array['brasile','brazil','brazilian'], 40, true, clock_timestamp()),
  ('country:ar', 'country', 'Argentina', 'AR', null, -38.4161, -63.6167, array['argentina','argentinian'], 40, true, clock_timestamp()),

  ('city:it:merano', 'city', 'Merano', 'IT', 'merano', 46.6713, 11.1594, array['merano','meran'], 90, true, clock_timestamp()),
  ('city:it:milano', 'city', 'Milano', 'IT', 'milano', 45.4642, 9.1900, array['milano','milan'], 85, true, clock_timestamp()),
  ('city:it:roma', 'city', 'Roma', 'IT', 'roma', 41.9028, 12.4964, array['roma','rome'], 85, true, clock_timestamp()),
  ('city:it:napoli', 'city', 'Napoli', 'IT', 'napoli', 40.8518, 14.2681, array['napoli','naples'], 80, true, clock_timestamp()),
  ('city:it:torino', 'city', 'Torino', 'IT', 'torino', 45.0703, 7.6869, array['torino','turin'], 80, true, clock_timestamp()),
  ('city:it:venezia', 'city', 'Venezia', 'IT', 'venezia', 45.4408, 12.3155, array['venezia','venice'], 80, true, clock_timestamp()),
  ('city:it:bologna', 'city', 'Bologna', 'IT', 'bologna', 44.4949, 11.3426, array['bologna'], 80, true, clock_timestamp()),
  ('city:it:firenze', 'city', 'Firenze', 'IT', 'firenze', 43.7696, 11.2558, array['firenze','florence'], 80, true, clock_timestamp()),
  ('city:gb:london', 'city', 'London', 'GB', 'london', 51.5074, -0.1278, array['london','londra'], 85, true, clock_timestamp()),
  ('city:gb:manchester', 'city', 'Manchester', 'GB', 'manchester', 53.4808, -2.2426, array['manchester'], 75, true, clock_timestamp()),
  ('city:gb:bournemouth', 'city', 'Bournemouth', 'GB', 'bournemouth', 50.7192, -1.8808, array['bournemouth'], 75, true, clock_timestamp()),
  ('city:gb:newcastle', 'city', 'Newcastle', 'GB', 'newcastle', 54.9783, -1.6178, array['newcastle','newcastle upon tyne'], 75, true, clock_timestamp()),
  ('city:gb:sunderland', 'city', 'Sunderland', 'GB', 'sunderland', 54.9069, -1.3838, array['sunderland'], 75, true, clock_timestamp()),
  ('city:fr:paris', 'city', 'Paris', 'FR', 'paris', 48.8566, 2.3522, array['paris','parigi'], 85, true, clock_timestamp()),
  ('city:de:berlin', 'city', 'Berlin', 'DE', 'berlin', 52.5200, 13.4050, array['berlin','berlino'], 85, true, clock_timestamp()),
  ('city:es:madrid', 'city', 'Madrid', 'ES', 'madrid', 40.4168, -3.7038, array['madrid'], 85, true, clock_timestamp()),
  ('city:es:barcelona', 'city', 'Barcelona', 'ES', 'barcelona', 41.3874, 2.1686, array['barcelona','barcellona'], 80, true, clock_timestamp()),
  ('city:at:vienna', 'city', 'Vienna', 'AT', 'vienna', 48.2082, 16.3738, array['vienna','wien'], 85, true, clock_timestamp()),
  ('city:be:brussels', 'city', 'Brussels', 'BE', 'brussels', 50.8503, 4.3517, array['brussels','bruxelles'], 85, true, clock_timestamp()),
  ('city:nl:amsterdam', 'city', 'Amsterdam', 'NL', 'amsterdam', 52.3676, 4.9041, array['amsterdam'], 80, true, clock_timestamp()),
  ('city:dk:copenhagen', 'city', 'Copenhagen', 'DK', 'copenhagen', 55.6761, 12.5683, array['copenhagen','copenaghen'], 80, true, clock_timestamp()),
  ('city:us:washington-dc', 'city', 'Washington, D.C.', 'US', 'washington-dc', 38.9072, -77.0369, array['washington dc','washington d c'], 90, true, clock_timestamp()),
  ('city:us:new-york', 'city', 'New York', 'US', 'new-york', 40.7128, -74.0060, array['new york','new york city'], 85, true, clock_timestamp()),
  ('city:us:los-angeles', 'city', 'Los Angeles', 'US', 'los-angeles', 34.0522, -118.2437, array['los angeles'], 80, true, clock_timestamp()),
  ('city:us:san-francisco', 'city', 'San Francisco', 'US', 'san-francisco', 37.7749, -122.4194, array['san francisco'], 80, true, clock_timestamp()),
  ('city:us:chicago', 'city', 'Chicago', 'US', 'chicago', 41.8781, -87.6298, array['chicago'], 75, true, clock_timestamp()),
  ('city:ru:moscow', 'city', 'Moscow', 'RU', 'moscow', 55.7558, 37.6173, array['moscow','mosca'], 85, true, clock_timestamp()),
  ('city:ua:kyiv', 'city', 'Kyiv', 'UA', 'kyiv', 50.4501, 30.5234, array['kyiv','kiev'], 85, true, clock_timestamp()),
  ('city:cn:beijing', 'city', 'Beijing', 'CN', 'beijing', 39.9042, 116.4074, array['beijing','pechino'], 85, true, clock_timestamp()),
  ('city:cn:shanghai', 'city', 'Shanghai', 'CN', 'shanghai', 31.2304, 121.4737, array['shanghai'], 80, true, clock_timestamp()),
  ('city:jp:tokyo', 'city', 'Tokyo', 'JP', 'tokyo', 35.6762, 139.6503, array['tokyo'], 85, true, clock_timestamp()),
  ('city:kr:seoul', 'city', 'Seoul', 'KR', 'seoul', 37.5665, 126.9780, array['seoul'], 80, true, clock_timestamp()),
  ('city:in:new-delhi', 'city', 'New Delhi', 'IN', 'new-delhi', 28.6139, 77.2090, array['new delhi','delhi'], 85, true, clock_timestamp()),
  ('city:ir:tehran', 'city', 'Tehran', 'IR', 'tehran', 35.6892, 51.3890, array['tehran','teheran'], 85, true, clock_timestamp()),
  ('city:il:tel-aviv', 'city', 'Tel Aviv', 'IL', 'tel-aviv', 32.0853, 34.7818, array['tel aviv'], 85, true, clock_timestamp()),
  ('city:il:jerusalem', 'city', 'Jerusalem', 'IL', 'jerusalem', 31.7683, 35.2137, array['jerusalem','gerusalemme'], 85, true, clock_timestamp()),
  ('city:ps:gaza', 'city', 'Gaza', 'PS', 'gaza', 31.5017, 34.4668, array['gaza'], 85, true, clock_timestamp()),
  ('city:lb:beirut', 'city', 'Beirut', 'LB', 'beirut', 33.8938, 35.5018, array['beirut','beirut'], 80, true, clock_timestamp()),
  ('city:ae:dubai', 'city', 'Dubai', 'AE', 'dubai', 25.2048, 55.2708, array['dubai'], 80, true, clock_timestamp()),
  ('city:ae:abu-dhabi', 'city', 'Abu Dhabi', 'AE', 'abu-dhabi', 24.4539, 54.3773, array['abu dhabi'], 80, true, clock_timestamp()),
  ('city:eg:cairo', 'city', 'Cairo', 'EG', 'cairo', 30.0444, 31.2357, array['cairo','il cairo'], 80, true, clock_timestamp()),
  ('city:au:sydney', 'city', 'Sydney', 'AU', 'sydney', -33.8688, 151.2093, array['sydney'], 80, true, clock_timestamp()),
  ('city:ca:toronto', 'city', 'Toronto', 'CA', 'toronto', 43.6532, -79.3832, array['toronto'], 80, true, clock_timestamp()),
  ('city:br:sao-paulo', 'city', 'São Paulo', 'BR', 'sao-paulo', -23.5505, -46.6333, array['sao paulo','são paulo'], 80, true, clock_timestamp()),
  ('city:ar:buenos-aires', 'city', 'Buenos Aires', 'AR', 'buenos-aires', -34.6037, -58.3816, array['buenos aires'], 80, true, clock_timestamp())
on conflict (catalog_key) do update
set
  location_kind = excluded.location_kind,
  label = excluded.label,
  country_code = excluded.country_code,
  city_id = excluded.city_id,
  latitude = excluded.latitude,
  longitude = excluded.longitude,
  aliases = excluded.aliases,
  priority = excluded.priority,
  is_active = excluded.is_active,
  updated_at = clock_timestamp();

-- The publishable/anon key is public by design. Store it in Vault so pg_cron
-- can satisfy the Edge gateway without exposing service_role credentials.
do $$
begin
  if not exists (
    select 1
    from vault.decrypted_secrets
    where name in ('publishable_key', 'anon_key')
  ) then
    perform vault.create_secret(
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJidXpscmNsd2h4YWlna2duZHJiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMyNDY3MzYsImV4cCI6MjA4ODgyMjczNn0.dHNA8s3NcqnluakSb-NFnb2jNgCcaVm3Ix24LbbIpHI',
      'publishable_key',
      'Public key used only by the scheduled News Edge invocation'
    );
  end if;
end;
$$;

create or replace function public.invoke_news_global_cache_refresh(
  p_language text
)
returns bigint
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_language text := lower(btrim(coalesce(p_language, '')));
  v_project_url text;
  v_publishable_key text;
  v_refresh_secret text;
  v_request_id bigint;
begin
  if v_language not in ('it', 'en', 'es', 'fr', 'de', 'ar') then
    raise exception 'Unsupported scheduled News language: %', p_language;
  end if;

  select ds.decrypted_secret
  into v_project_url
  from vault.decrypted_secrets as ds
  where ds.name = 'project_url'
  order by ds.created_at desc
  limit 1;

  select ds.decrypted_secret
  into v_publishable_key
  from vault.decrypted_secrets as ds
  where ds.name in ('publishable_key', 'anon_key')
  order by case when ds.name = 'publishable_key' then 0 else 1 end,
           ds.created_at desc
  limit 1;

  select ds.decrypted_secret
  into v_refresh_secret
  from vault.decrypted_secrets as ds
  where ds.name = 'news_cache_refresh_secret'
  order by ds.created_at desc
  limit 1;

  if nullif(btrim(v_project_url), '') is null then
    raise exception 'Missing Vault secret project_url';
  end if;

  if nullif(btrim(v_publishable_key), '') is null then
    raise exception 'Missing Vault secret publishable_key/anon_key';
  end if;

  select net.http_post(
    url := rtrim(v_project_url, '/') || '/functions/v1/news-cache-refresh',
    headers := jsonb_strip_nulls(
      jsonb_build_object(
        'Content-Type', 'application/json',
        'apikey', v_publishable_key,
        'Authorization', 'Bearer ' || v_publishable_key,
        'x-refresh-secret', nullif(v_refresh_secret, '')
      )
    ),
    body := jsonb_build_object(
      'dryRun', false,
      'limit', 1,
      'cacheKey', format(
        'country=*|city=*|topic=*|language=%s',
        v_language
      ),
      'language', v_language
    ),
    timeout_milliseconds := 30000
  )
  into v_request_id;

  return v_request_id;
end;
$$;

comment on function public.invoke_news_global_cache_refresh(text) is
  'Refreshes one exact worldwide News cache. City/country scopes read this catalog and never trigger providers.';

revoke all
on function public.invoke_news_global_cache_refresh(text)
from public, anon, authenticated;

do $$
declare
  v_job record;
begin
  for v_job in
    select jobid
    from cron.job
    where jobname in (
      'news-cache-refresh-every-30-minutes',
      'news-global-it-every-4-hours',
      'news-global-en-every-4-hours',
      'news-global-es-daily',
      'news-global-fr-daily',
      'news-global-de-daily',
      'news-global-ar-daily'
    )
  loop
    perform cron.unschedule(v_job.jobid);
  end loop;
end;
$$;

select cron.schedule(
  'news-global-it-every-4-hours',
  '5 */4 * * *',
  $$select public.invoke_news_global_cache_refresh('it');$$
);

select cron.schedule(
  'news-global-en-every-4-hours',
  '35 */4 * * *',
  $$select public.invoke_news_global_cache_refresh('en');$$
);

select cron.schedule(
  'news-global-es-daily',
  '15 2 * * *',
  $$select public.invoke_news_global_cache_refresh('es');$$
);

select cron.schedule(
  'news-global-fr-daily',
  '25 2 * * *',
  $$select public.invoke_news_global_cache_refresh('fr');$$
);

select cron.schedule(
  'news-global-de-daily',
  '45 2 * * *',
  $$select public.invoke_news_global_cache_refresh('de');$$
);

select cron.schedule(
  'news-global-ar-daily',
  '15 3 * * *',
  $$select public.invoke_news_global_cache_refresh('ar');$$
);

-- Budget pianificato massimo: 16 esecuzioni backend al giorno.
-- IT 6 + EN 6 + ES 1 + FR 1 + DE 1 + AR 1.

commit;
