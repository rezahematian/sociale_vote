-- Social Vote
-- Canonical News identity foundation.
--
-- Scope of this migration:
-- - creates one persistent UUID identity for every News article;
-- - stores stable provider, URL and fingerprint identifiers;
-- - maps legacy Flutter/cache identifiers to the canonical News UUID;
-- - keeps both tables backend-only until ingestion and Flutter are wired;
-- - does not modify news_feed_cache or any existing feed behavior.

begin;

create table if not exists public.news_articles (
  id uuid primary key default gen_random_uuid(),
  provider_id text,
  provider_article_id text,
  canonical_url text,
  fingerprint text,
  fingerprint_version smallint,
  published_at timestamptz,
  first_seen_at timestamptz not null default clock_timestamp(),
  last_seen_at timestamptz not null default clock_timestamp(),
  created_at timestamptz not null default clock_timestamp(),
  updated_at timestamptz not null default clock_timestamp(),

  constraint news_articles_provider_id_check
    check (
      provider_id is null
      or (
        nullif(btrim(provider_id), '') is not null
        and char_length(provider_id) <= 160
      )
    ),

  constraint news_articles_provider_article_id_check
    check (
      provider_article_id is null
      or (
        nullif(btrim(provider_article_id), '') is not null
        and char_length(provider_article_id) <= 512
      )
    ),

  constraint news_articles_provider_identity_check
    check (
      provider_article_id is null
      or provider_id is not null
    ),

  constraint news_articles_canonical_url_check
    check (
      canonical_url is null
      or (
        nullif(btrim(canonical_url), '') is not null
        and char_length(canonical_url) <= 2048
      )
    ),

  constraint news_articles_fingerprint_check
    check (
      (
        fingerprint is null
        and fingerprint_version is null
      )
      or
      (
        nullif(btrim(fingerprint), '') is not null
        and char_length(fingerprint) between 16 and 256
        and fingerprint_version between 1 and 32767
      )
    ),

  constraint news_articles_has_identity_check
    check (
      provider_article_id is not null
      or canonical_url is not null
      or fingerprint is not null
    ),

  constraint news_articles_seen_at_check
    check (last_seen_at >= first_seen_at),

  constraint news_articles_timestamps_check
    check (
      created_at >= first_seen_at
      and updated_at >= created_at
    )
);

comment on table public.news_articles is
  'Backend-owned registry assigning one permanent UUID to each News article first seen by Social Vote.';

comment on column public.news_articles.id is
  'Canonical permanent News UUID used by feed, detail, reports, comments and moderation after wiring.';

comment on column public.news_articles.first_seen_at is
  'Precise timestamp at which Social Vote first registered this News article.';

comment on column public.news_articles.last_seen_at is
  'Most recent timestamp at which the article was observed again from a provider or cache refresh.';

comment on column public.news_articles.fingerprint is
  'Versioned backend-generated identity fingerprint used only when provider identity or canonical URL is insufficient.';

create unique index if not exists news_articles_provider_identity_uidx
on public.news_articles (
  lower(btrim(provider_id)),
  btrim(provider_article_id)
)
where provider_id is not null
  and provider_article_id is not null;

create unique index if not exists news_articles_canonical_url_uidx
on public.news_articles (canonical_url)
where canonical_url is not null;

create unique index if not exists news_articles_fingerprint_uidx
on public.news_articles (
  fingerprint_version,
  fingerprint
)
where fingerprint is not null;

create index if not exists news_articles_last_seen_idx
on public.news_articles (last_seen_at desc);

create table if not exists public.news_article_aliases (
  id uuid primary key default gen_random_uuid(),
  news_id uuid not null,
  alias_type text not null,
  alias_value text not null,
  created_at timestamptz not null default clock_timestamp(),

  constraint news_article_aliases_news_fk
    foreign key (news_id)
    references public.news_articles (id)
    on delete cascade,

  constraint news_article_aliases_type_check
    check (
      alias_type in (
        'legacy_flutter_id',
        'cache_item_id',
        'provider_identity',
        'canonical_url',
        'fingerprint'
      )
    ),

  constraint news_article_aliases_value_check
    check (
      nullif(btrim(alias_value), '') is not null
      and char_length(alias_value) <= 2304
    ),

  constraint news_article_aliases_identity_unique
    unique (alias_type, alias_value)
);

comment on table public.news_article_aliases is
  'Backend-owned mapping from legacy/cache/provider News identifiers to one canonical News UUID.';

comment on column public.news_article_aliases.alias_value is
  'Normalized namespaced value; provider aliases must include both provider and provider article ID.';

create index if not exists news_article_aliases_news_idx
on public.news_article_aliases (news_id);

alter table public.news_articles enable row level security;
alter table public.news_articles force row level security;

alter table public.news_article_aliases enable row level security;
alter table public.news_article_aliases force row level security;

revoke all
on table public.news_articles
from public, anon, authenticated;

revoke all
on table public.news_article_aliases
from public, anon, authenticated;

grant select, insert, update, delete
on table public.news_articles
to service_role;

grant select, insert, update, delete
on table public.news_article_aliases
to service_role;

commit;
