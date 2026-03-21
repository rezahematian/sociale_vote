import { createClient } from "@supabase/supabase-js";

type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json }
  | Json[];

type ArticleItem = Record<string, unknown>;

type CacheRow = {
  cache_key: string;
  country_code: string | null;
  city_id: string | null;
  topic: string | null;
  language: string | null;
  refreshed_at: string | null;
  item_count: number | null;
  resolved_location_count: number | null;
  provider_signatures: Json | null;
  languages_present: Json | null;
  payload_version: number | null;
  payload: Json | null;
};

type RefreshRequest = {
  dryRun?: boolean;
  limit?: number;
  cacheKey?: string | null;
  countryCode?: string | null;
  cityId?: string | null;
  topic?: string | null;
  language?: string | null;
};

type Candidate = {
  cacheKey: string;
  countryCode: string | null;
  cityId: string | null;
  topic: string | null;
  language: string | null;
  refreshedAt: string | null;
  itemCount: number;
  resolvedLocationCount: number;
  providerSignatures: string[];
  languagesPresent: string[];
  payloadVersion: number | null;
  previousItems: ArticleItem[];
};

type ProviderFetchResult = {
  providerId: string;
  items: ArticleItem[];
  rateLimited?: boolean;
  error?: string | null;
};

type AggregatedFetchResult = {
  providerId: string | null;
  items: ArticleItem[];
  providerOrder: string[];
  attempts: Array<{
    providerId: string;
    items: number;
    rateLimited: boolean;
    error: string | null;
  }>;
};

type SupabaseCacheClient = {
  from: (
    table: string,
  ) => {
    upsert: (
      values: Record<string, unknown>,
      options?: Record<string, unknown>,
    ) => PromiseLike<{ error: { message: string } | null }>;
  };
};

const CACHE_TABLE = "news_feed_cache";
const CACHE_PAYLOAD_VERSION = 2;

const DEFAULT_LIMIT = 25;
const MAX_LIMIT = 100;
const PROVIDER_WARMUP_BATCH_SIZE = 80;

const GNEWS_BASE_URL = "https://gnews.io/api/v4";
const NEWSAPI_BASE_URL = "https://newsapi.org/v2";
const GUARDIAN_BASE_URL = "https://content.guardianapis.com";

const CORS_HEADERS = {
  "access-control-allow-origin": "*",
  "access-control-allow-methods": "POST, GET, OPTIONS",
  "access-control-allow-headers":
    "authorization, x-client-info, apikey, content-type, x-refresh-secret",
};

const LOCATION_KEYS = [
  "_sv_content_location",
  "content_location",
  "contentLocation",
  "_content_location",
] as const;

class HttpError extends Error {
  status: number;
  bodyText: string;

  constructor(status: number, bodyText: string) {
    super(`HTTP ${status}`);
    this.status = status;
    this.bodyText = bodyText;
  }
}

function json(
  body: Record<string, unknown>,
  init?: ResponseInit,
): Response {
  return new Response(JSON.stringify(body, null, 2), {
    headers: {
      "content-type": "application/json; charset=utf-8",
      ...CORS_HEADERS,
    },
    ...init,
  });
}

function normalize(value: unknown): string | null {
  if (typeof value !== "string") {
    return null;
  }

  const trimmed = value.trim();
  if (!trimmed) {
    return null;
  }

  return trimmed.toLowerCase();
}

function normalizeKeepCase(value: unknown): string | null {
  if (typeof value !== "string") {
    return null;
  }

  const trimmed = value.trim();
  return trimmed || null;
}

function normalizeLanguage(value: unknown): string | null {
  const normalized = normalize(value);
  if (!normalized) {
    return null;
  }

  return normalized.replaceAll("_", "-").split("-")[0] || null;
}

function toPositiveInt(
  value: unknown,
  fallback: number,
  max: number,
): number {
  const parsed = Number(value);
  if (!Number.isFinite(parsed) || parsed <= 0) {
    return fallback;
  }

  return Math.min(Math.floor(parsed), max);
}

function extractBearerToken(authHeader: string | null): string | null {
  if (!authHeader) {
    return null;
  }

  const prefix = "Bearer ";
  if (!authHeader.startsWith(prefix)) {
    return null;
  }

  const token = authHeader.slice(prefix.length).trim();
  return token || null;
}

function isAuthorized(req: Request): boolean {
  const configuredSecret = Deno.env.get("NEWS_CACHE_REFRESH_SECRET")?.trim();
  if (!configuredSecret) {
    return true;
  }

  const bearer = extractBearerToken(req.headers.get("authorization"));
  if (bearer && bearer === configuredSecret) {
    return true;
  }

  const headerSecret = req.headers.get("x-refresh-secret")?.trim();
  if (headerSecret && headerSecret === configuredSecret) {
    return true;
  }

  return false;
}

function normalizeStringArray(value: unknown): string[] {
  if (!Array.isArray(value)) {
    return [];
  }

  const out = new Set<string>();
  for (const item of value) {
    const normalized = normalize(item);
    if (normalized) {
      out.add(normalized);
    }
  }

  return [...out].sort();
}

function normalizePayloadArray(value: unknown): ArticleItem[] {
  if (!Array.isArray(value)) {
    return [];
  }

  const items: ArticleItem[] = [];
  for (const item of value) {
    if (!item || typeof item !== "object" || Array.isArray(item)) {
      continue;
    }

    items.push({ ...(item as Record<string, unknown>) });
  }

  return items;
}

function buildCacheKey(parts: {
  countryCode?: string | null;
  cityId?: string | null;
  topic?: string | null;
  language?: string | null;
}): string {
  return [
    `country=${parts.countryCode ?? "*"}`,
    `city=${parts.cityId ?? "*"}`,
    `topic=${parts.topic ?? "*"}`,
    `language=${parts.language ?? "*"}`,
  ].join("|");
}

function parseCacheKey(cacheKey: string): {
  countryCode: string | null;
  cityId: string | null;
  topic: string | null;
  language: string | null;
} | null {
  const normalized = normalizeKeepCase(cacheKey);
  if (!normalized) {
    return null;
  }

  const out = {
    countryCode: null as string | null,
    cityId: null as string | null,
    topic: null as string | null,
    language: null as string | null,
  };

  const parts = normalized.split("|");
  for (const part of parts) {
    const [rawKey, rawValue] = part.split("=", 2);
    const key = normalize(rawKey);
    const value = normalize(rawValue);

    switch (key) {
      case "country":
        out.countryCode = value === "*" ? null : value;
        break;
      case "city":
        out.cityId = value === "*" ? null : value;
        break;
      case "topic":
        out.topic = value === "*" ? null : value;
        break;
      case "language":
        out.language = value === "*" ? null : normalizeLanguage(value);
        break;
    }
  }

  return out;
}

function buildCandidate(row: CacheRow): Candidate {
  return {
    cacheKey: row.cache_key,
    countryCode: normalize(row.country_code),
    cityId: normalize(row.city_id),
    topic: normalize(row.topic),
    language: normalizeLanguage(row.language),
    refreshedAt: normalizeKeepCase(row.refreshed_at),
    itemCount: Number(row.item_count ?? 0),
    resolvedLocationCount: Number(row.resolved_location_count ?? 0),
    providerSignatures: normalizeStringArray(row.provider_signatures),
    languagesPresent: normalizeStringArray(row.languages_present),
    payloadVersion: row.payload_version ?? null,
    previousItems: normalizePayloadArray(row.payload),
  };
}

function buildSyntheticCandidate(req: RefreshRequest): Candidate | null {
  let parsedFromKey: ReturnType<typeof parseCacheKey> | null = null;
  if (req.cacheKey) {
    parsedFromKey = parseCacheKey(req.cacheKey);
  }

  const countryCode = normalize(req.countryCode) ?? parsedFromKey?.countryCode ??
    null;
  const cityId = normalize(req.cityId) ?? parsedFromKey?.cityId ?? null;
  const topic = normalize(req.topic) ?? parsedFromKey?.topic ?? null;
  const language = normalizeLanguage(req.language) ?? parsedFromKey?.language ??
    null;

  const explicitCacheKey = normalizeKeepCase(req.cacheKey);
  const cacheKey = explicitCacheKey ??
    buildCacheKey({
      countryCode,
      cityId,
      topic,
      language,
    });

  const hasAnyFilter = Boolean(
    explicitCacheKey || countryCode || cityId || topic || language,
  );

  if (!hasAnyFilter) {
    return null;
  }

  return {
    cacheKey,
    countryCode,
    cityId,
    topic,
    language,
    refreshedAt: null,
    itemCount: 0,
    resolvedLocationCount: 0,
    providerSignatures: [],
    languagesPresent: [],
    payloadVersion: null,
    previousItems: [],
  };
}

function matchesFilters(candidate: Candidate, req: RefreshRequest): boolean {
  const requestedCacheKey = normalizeKeepCase(req.cacheKey)?.toLowerCase();
  if (
    requestedCacheKey &&
    candidate.cacheKey.toLowerCase() !== requestedCacheKey
  ) {
    return false;
  }

  const requestedCountryCode = normalize(req.countryCode);
  if (requestedCountryCode && candidate.countryCode !== requestedCountryCode) {
    return false;
  }

  const requestedCityId = normalize(req.cityId);
  if (requestedCityId && candidate.cityId !== requestedCityId) {
    return false;
  }

  const requestedTopic = normalize(req.topic);
  if (requestedTopic && candidate.topic !== requestedTopic) {
    return false;
  }

  const requestedLanguage = normalizeLanguage(req.language);
  if (requestedLanguage && candidate.language !== requestedLanguage) {
    return false;
  }

  return true;
}

function compareCandidates(a: Candidate, b: Candidate): number {
  const aTime = a.refreshedAt ? Date.parse(a.refreshedAt) : 0;
  const bTime = b.refreshedAt ? Date.parse(b.refreshedAt) : 0;

  if (aTime !== bTime) {
    return aTime - bTime;
  }

  return a.cacheKey.localeCompare(b.cacheKey);
}

function resolveExecutionLanguage(candidate: Candidate): string {
  if (candidate.language) {
    return candidate.language;
  }

  if (candidate.languagesPresent.length === 1) {
    return candidate.languagesPresent[0];
  }

  if (candidate.countryCode === "it") {
    return "it";
  }

  return "en";
}

function providerPriorityForRequest(
  providerId: string,
  language: string | null,
  topic: string | null,
): number {
  const normalizedProviderId = providerId.trim().toLowerCase();

  if (language == null || language === "auto" || language === "en") {
    switch (normalizedProviderId) {
      case "guardian":
        return 0;
      case "newsapi":
        return 1;
      case "gnews":
        return 2;
      default:
        return 100;
    }
  }

  if (
    language === "it" || language === "fr" || language === "es" ||
    language === "de"
  ) {
    switch (normalizedProviderId) {
      case "newsapi":
        return 0;
      case "gnews":
        return 1;
      case "guardian":
        return 2;
      default:
        return 100;
    }
  }

  if (language === "ar") {
    const isAllTopic = topic == null || topic === "all" || topic === "tutte";

    if (isAllTopic) {
      switch (normalizedProviderId) {
        case "gnews":
          return 0;
        case "newsapi":
          return 1;
        case "guardian":
          return 2;
        default:
          return 100;
      }
    }

    switch (normalizedProviderId) {
      case "newsapi":
        return 0;
      case "gnews":
        return 1;
      case "guardian":
        return 2;
      default:
        return 100;
    }
  }

  if (language === "fa") {
    switch (normalizedProviderId) {
      case "gnews":
        return 0;
      case "newsapi":
        return 1;
      case "guardian":
        return 2;
      default:
        return 100;
    }
  }

  switch (normalizedProviderId) {
    case "newsapi":
      return 0;
    case "gnews":
      return 1;
    case "guardian":
      return 2;
    default:
      return 100;
  }
}

function orderProvidersForRequest(
  language: string | null,
  topic: string | null,
): string[] {
  const providers = ["guardian", "newsapi", "gnews"];
  return providers
    .slice()
    .sort((a, b) =>
      providerPriorityForRequest(a, language, topic) -
      providerPriorityForRequest(b, language, topic)
    );
}

async function fetchJson(
  url: string,
  query: Record<string, string>,
): Promise<unknown> {
  const fullUrl = new URL(url);
  for (const [key, value] of Object.entries(query)) {
    fullUrl.searchParams.set(key, value);
  }

  const response = await fetch(fullUrl.toString(), {
    method: "GET",
    headers: {
      "accept": "application/json",
    },
  });

  const text = await response.text();
  let parsed: unknown = null;

  if (text.trim()) {
    try {
      parsed = JSON.parse(text);
    } catch (_) {
      parsed = text;
    }
  }

  if (!response.ok) {
    throw new HttpError(
      response.status,
      typeof parsed === "string" ? parsed : JSON.stringify(parsed),
    );
  }

  return parsed;
}

function mapHttpError(
  providerId: string,
  error: unknown,
): ProviderFetchResult {
  if (error instanceof HttpError) {
    return {
      providerId,
      items: [],
      rateLimited: error.status === 429,
      error: `http_${error.status}`,
    };
  }

  if (error instanceof Error) {
    return {
      providerId,
      items: [],
      error: error.message,
    };
  }

  return {
    providerId,
    items: [],
    error: String(error),
  };
}

function normalizeLanguageForArticle(value: unknown): string | null {
  return normalizeLanguage(value);
}

function buildCityQuery(
  cityId: string,
  countryCode: string | null,
): string {
  const cleanedCity = cityId.trim();
  if (!cleanedCity) {
    return cityId;
  }

  const suffix = countryCode ? ` ${countryCode.trim().toUpperCase()}` : "";
  return `${cleanedCity}${suffix}`;
}

function isSupportedLanguageByGNews(language: string | null): boolean {
  if (!language) {
    return false;
  }

  return ["it", "en", "es", "fr", "de", "ar"].includes(language);
}

async function fetchGNewsFeed(args: {
  countryCode: string | null;
  cityId: string | null;
  topic: string | null;
  language: string;
  limit: number;
  offset: number;
}): Promise<ProviderFetchResult> {
  const apiKey = Deno.env.get("GNEWS_API_KEY")?.trim();
  if (!apiKey) {
    return {
      providerId: "gnews",
      items: [],
      error: "missing_gnews_api_key",
    };
  }

  try {
    const rawLimit = args.limit || 10;
    const effectiveLimit = Math.min(Math.max(rawLimit, 1), 100);

    const effectiveOffset = args.offset > 0
      ? args.offset - (args.offset % effectiveLimit)
      : args.offset;

    const hasExplicitLanguage = Boolean(args.language);
    if (
      hasExplicitLanguage &&
      !isSupportedLanguageByGNews(normalizeLanguage(args.language))
    ) {
      return {
        providerId: "gnews",
        items: [],
      };
    }

    const autoLang = args.countryCode?.toUpperCase() === "IT" ? "it" : "en";
    const effectiveLanguage = normalizeLanguage(args.language);

    const query: Record<string, string> = {
      apikey: apiKey,
      max: String(effectiveLimit),
      sortby: "publishedAt",
      lang: effectiveLanguage ?? autoLang,
    };

    if (args.countryCode) {
      query.country = args.countryCode.toLowerCase();
    }

    if (args.topic) {
      query.topic = args.topic.trim();
    }

    if (args.cityId) {
      query.q = buildCityQuery(args.cityId, args.countryCode);
      query.in = "title,description";
    }

    if (effectiveOffset > 0 && effectiveLimit > 0) {
      const page = Math.floor(effectiveOffset / effectiveLimit) + 1;
      query.page = String(page);
    }

    const result = await fetchJson(`${GNEWS_BASE_URL}/top-headlines`, query);

    if (!result || typeof result !== "object" || Array.isArray(result)) {
      return { providerId: "gnews", items: [] };
    }

    const articles = Array.isArray((result as Record<string, unknown>).articles)
      ? ((result as Record<string, unknown>).articles as unknown[])
      : [];

    const normalizedArticles = articles
      .filter((article) =>
        article && typeof article === "object" && !Array.isArray(article)
      )
      .map((article) => ({ ...(article as Record<string, unknown>) }));

    if (effectiveLanguage) {
      return {
        providerId: "gnews",
        items: normalizedArticles.filter((article) =>
          normalizeLanguageForArticle(article.lang) === effectiveLanguage
        ),
      };
    }

    return {
      providerId: "gnews",
      items: normalizedArticles,
    };
  } catch (error) {
    return mapHttpError("gnews", error);
  }
}

function shouldUseEverythingForGeneralLanguageFeed(
  q: string | null,
  category: string | null,
  language: string | null,
): boolean {
  if (language !== "ar") {
    return false;
  }

  return !q && !category;
}

function defaultEverythingQueryForLanguage(language: string): string {
  switch (language) {
    case "ar":
      return "أخبار";
    default:
      return "news";
  }
}

function mapTopicToNewsApiCategory(topic: string | null): string | null {
  if (!topic) {
    return null;
  }

  switch (topic.trim().toLowerCase()) {
    case "business":
    case "entertainment":
    case "health":
    case "science":
    case "sports":
    case "technology":
      return topic.trim().toLowerCase();
    default:
      return null;
  }
}

async function fetchNewsApiOrgFeed(args: {
  countryCode: string | null;
  cityId: string | null;
  topic: string | null;
  language: string;
  limit: number;
  offset: number;
}): Promise<ProviderFetchResult> {
  const apiKey = Deno.env.get("NEWSAPI_ORG_API_KEY")?.trim();
  if (!apiKey) {
    return {
      providerId: "newsapi",
      items: [],
      error: "missing_newsapi_org_api_key",
    };
  }

  try {
    const pageSize = args.limit > 0 ? args.limit : 10;
    const page = args.offset > 0 ? Math.floor(args.offset / pageSize) + 1 : 1;

    const q = args.cityId?.trim() ? args.cityId.trim() : null;
    const category = mapTopicToNewsApiCategory(args.topic);
    const normalizedLanguage = normalizeLanguage(args.language);

    let endpoint = `${NEWSAPI_BASE_URL}/top-headlines`;
    const query: Record<string, string> = {
      apiKey,
      pageSize: String(pageSize),
      page: String(page),
    };

    if (
      shouldUseEverythingForGeneralLanguageFeed(q, category, normalizedLanguage)
    ) {
      endpoint = `${NEWSAPI_BASE_URL}/everything`;
      query.q = defaultEverythingQueryForLanguage(normalizedLanguage!);
      query.language = normalizedLanguage!;
      query.sortBy = "publishedAt";
    } else {
      if (args.countryCode) {
        query.country = args.countryCode;
      }
      if (q) {
        query.q = q;
      }
      if (category) {
        query.category = category;
      }
      if (normalizedLanguage) {
        query.language = normalizedLanguage;
      }
    }

    const result = await fetchJson(endpoint, query);

    if (!result || typeof result !== "object" || Array.isArray(result)) {
      return { providerId: "newsapi", items: [] };
    }

    const json = result as Record<string, unknown>;
    const status = String(json.status ?? "");
    const code = String(json.code ?? "");
    const rateLimited =
      status === "error" && code.toLowerCase().includes("rate");

    const articles = Array.isArray(json.articles) ? json.articles : [];
    const items: ArticleItem[] = [];

    for (const raw of articles) {
      if (!raw || typeof raw !== "object" || Array.isArray(raw)) {
        continue;
      }

      const article = { ...(raw as Record<string, unknown>) };
      const source =
        article.source && typeof article.source === "object" &&
            !Array.isArray(article.source)
          ? { ...(article.source as Record<string, unknown>) }
          : {};

      const url = normalizeKeepCase(article.url);
      if (!url) {
        continue;
      }

      const publishedAt = normalizeKeepCase(article.publishedAt) ??
        new Date().toISOString();

      items.push({
        id: url,
        title: article.title ?? null,
        description: article.description ?? null,
        content: article.content ?? null,
        url,
        image: article.urlToImage ?? null,
        publishedAt,
        lang: normalizedLanguage,
        source: {
          id: source.id ?? null,
          name: source.name ?? null,
          url: null,
        },
      });
    }

    return {
      providerId: "newsapi",
      items,
      rateLimited,
      error: status === "error" && !rateLimited
        ? code || "newsapi_error"
        : null,
    };
  } catch (error) {
    return mapHttpError("newsapi", error);
  }
}

function mapTopicToGuardianSection(topic: string | null): string | null {
  if (!topic) {
    return null;
  }

  switch (topic.trim().toLowerCase()) {
    case "world":
    case "international":
      return "world";
    case "politics":
      return "politics";
    case "business":
    case "economy":
      return "business";
    case "technology":
    case "tech":
      return "technology";
    case "science":
      return "science";
    case "environment":
      return "environment";
    case "sport":
    case "sports":
      return "sport";
    case "culture":
      return "culture";
    case "media":
      return "media";
    default:
      return null;
  }
}

function guardianCountryNameFromCode(countryCode: string | null): string | null {
  const code = countryCode?.toUpperCase() ?? null;
  switch (code) {
    case "IT":
      return "Italy";
    case "US":
      return "United States";
    case "GB":
    case "UK":
      return "United Kingdom";
    case "FR":
      return "France";
    case "DE":
      return "Germany";
    case "ES":
      return "Spain";
    default:
      return null;
  }
}

function buildGuardianQueryText(args: {
  countryCode: string | null;
  cityId: string | null;
  topic: string | null;
  sectionWasMapped: boolean;
}): string | null {
  const parts: string[] = [];

  if (args.cityId) {
    parts.push(args.cityId.trim());
  }

  const countryName = guardianCountryNameFromCode(args.countryCode);
  if (countryName) {
    parts.push(countryName);
  }

  if (!args.sectionWasMapped && args.topic) {
    parts.push(args.topic.trim());
  }

  if (!parts.length) {
    return null;
  }

  return parts.join(" ");
}

async function fetchGuardianFeed(args: {
  countryCode: string | null;
  cityId: string | null;
  topic: string | null;
  language: string;
  limit: number;
  offset: number;
}): Promise<ProviderFetchResult> {
  const apiKey = Deno.env.get("GUARDIAN_API_KEY")?.trim();
  if (!apiKey) {
    return {
      providerId: "guardian",
      items: [],
      error: "missing_guardian_api_key",
    };
  }

  try {
    const pageSize = Math.min(Math.max(args.limit || 20, 1), 50);
    const page = args.offset > 0 ? Math.floor(args.offset / pageSize) + 1 : 1;

    const section = mapTopicToGuardianSection(args.topic);
    const q = buildGuardianQueryText({
      countryCode: args.countryCode,
      cityId: args.cityId,
      topic: args.topic,
      sectionWasMapped: section != null,
    });

    const query: Record<string, string> = {
      "api-key": apiKey,
      "page-size": String(pageSize),
      page: String(page),
      "order-by": "newest",
      "show-fields": "headline,trailText,body,thumbnail,byline",
      "show-tags": "contributor",
    };

    if (section) {
      query.section = section;
    }

    if (q) {
      query.q = q;
    }

    const result = await fetchJson(`${GUARDIAN_BASE_URL}/search`, query);

    if (!result || typeof result !== "object" || Array.isArray(result)) {
      return { providerId: "guardian", items: [] };
    }

    const response = (result as Record<string, unknown>).response;
    if (!response || typeof response !== "object" || Array.isArray(response)) {
      return { providerId: "guardian", items: [] };
    }

    const responseMap = response as Record<string, unknown>;
    const status = String(responseMap.status ?? "").toLowerCase();
    if (status !== "ok") {
      return {
        providerId: "guardian",
        items: [],
        error: `guardian_status_${status || "unknown"}`,
      };
    }

    const results = Array.isArray(responseMap.results)
      ? responseMap.results
      : [];
    const items: ArticleItem[] = [];

    for (const raw of results) {
      if (!raw || typeof raw !== "object" || Array.isArray(raw)) {
        continue;
      }

      const article = { ...(raw as Record<string, unknown>) };
      const fields =
        article.fields && typeof article.fields === "object" &&
            !Array.isArray(article.fields)
          ? { ...(article.fields as Record<string, unknown>) }
          : {};

      const tags = Array.isArray(article.tags) ? article.tags : [];
      let contributorName: string | null = null;

      for (const tag of tags) {
        if (!tag || typeof tag !== "object" || Array.isArray(tag)) {
          continue;
        }

        const typedTag = { ...(tag as Record<string, unknown>) };
        const type = String(typedTag.type ?? "").toLowerCase();
        if (type !== "contributor") {
          continue;
        }

        const webTitle = normalizeKeepCase(typedTag.webTitle);
        if (webTitle) {
          contributorName = webTitle;
          break;
        }
      }

      const articleId = normalizeKeepCase(article.id);
      if (!articleId) {
        continue;
      }

      const title = normalizeKeepCase(fields.headline) ??
        normalizeKeepCase(article.webTitle) ?? "";
      const publishedAt = normalizeKeepCase(article.webPublicationDate) ??
        new Date().toISOString();

      items.push({
        id: articleId,
        title,
        description: normalizeKeepCase(fields.trailText),
        content: normalizeKeepCase(fields.body),
        url: normalizeKeepCase(article.webUrl) ?? "",
        image: normalizeKeepCase(fields.thumbnail),
        publishedAt,
        lang: args.language || null,
        source: {
          id: "the-guardian",
          name: "The Guardian",
          url: "https://www.theguardian.com",
        },
        authorName: contributorName ?? normalizeKeepCase(fields.byline),
      });
    }

    return {
      providerId: "guardian",
      items,
    };
  } catch (error) {
    return mapHttpError("guardian", error);
  }
}

async function fetchProviderFeed(
  providerId: string,
  args: {
    countryCode: string | null;
    cityId: string | null;
    topic: string | null;
    language: string;
    limit: number;
    offset: number;
  },
): Promise<ProviderFetchResult> {
  switch (providerId) {
    case "gnews":
      return await fetchGNewsFeed(args);
    case "newsapi":
      return await fetchNewsApiOrgFeed(args);
    case "guardian":
      return await fetchGuardianFeed(args);
    default:
      return {
        providerId,
        items: [],
        error: "unknown_provider",
      };
  }
}

async function fetchAggregatedNews(
  candidate: Candidate,
): Promise<AggregatedFetchResult> {
  const effectiveLanguage = resolveExecutionLanguage(candidate);
  const providerOrder = orderProvidersForRequest(
    effectiveLanguage,
    candidate.topic,
  );

  const attempts: AggregatedFetchResult["attempts"] = [];

  for (const providerId of providerOrder) {
    const result = await fetchProviderFeed(providerId, {
      countryCode: candidate.countryCode,
      cityId: candidate.cityId,
      topic: candidate.topic,
      language: effectiveLanguage,
      limit: PROVIDER_WARMUP_BATCH_SIZE,
      offset: 0,
    });

    attempts.push({
      providerId,
      items: result.items.length,
      rateLimited: Boolean(result.rateLimited),
      error: result.error ?? null,
    });

    if (result.items.length > 0) {
      return {
        providerId,
        items: result.items,
        providerOrder,
        attempts,
      };
    }
  }

  return {
    providerId: null,
    items: [],
    providerOrder,
    attempts,
  };
}

function firstNonEmptyString(
  json: ArticleItem,
  keys: string[],
): string | null {
  for (const key of keys) {
    const value = json[key];
    if (value == null) {
      continue;
    }

    const text = String(value).trim();
    if (text) {
      return text;
    }
  }

  return null;
}

function extractItemLanguage(json: ArticleItem): string | null {
  return normalizeLanguage(
    firstNonEmptyString(json, [
      "language",
      "lang",
      "locale",
      "content_language",
      "contentLanguage",
      "feed_language",
      "feedLanguage",
    ]),
  );
}

function extractProviderSignature(json: ArticleItem): string | null {
  const direct = firstNonEmptyString(json, [
    "provider",
    "provider_id",
    "providerId",
    "provider_name",
    "providerName",
    "source",
    "source_id",
    "sourceId",
    "source_name",
    "sourceName",
  ]);

  if (direct) {
    return normalize(direct);
  }

  const source = json.source;
  if (source && typeof source === "object" && !Array.isArray(source)) {
    const sourceObj = source as Record<string, unknown>;
    return normalizeKeepCase(String(sourceObj.id ?? sourceObj.name ?? ""))
        ?.toLowerCase() ?? null;
  }

  return null;
}

function normalizeIdentitySource(value: string | null): string {
  return normalize(value) ?? "unknown";
}

function normalizeArticleUrl(rawUrl: string | null): string | null {
  if (!rawUrl) {
    return null;
  }

  const trimmed = rawUrl.trim();
  if (!trimmed) {
    return null;
  }

  try {
    const parsed = new URL(trimmed);
    const normalizedPath = parsed.pathname
      ? parsed.pathname.replace(/\/$/, "") || "/"
      : "/";

    const normalized = new URL(parsed.toString());
    normalized.protocol = normalized.protocol.toLowerCase();
    normalized.hostname = normalized.hostname.toLowerCase();
    normalized.pathname = normalizedPath;

    const port = normalized.port;
    if (
      (normalized.protocol === "https:" && port === "443") ||
      (normalized.protocol === "http:" && port === "80")
    ) {
      normalized.port = "";
    }

    normalized.search = "";
    normalized.hash = "";

    return normalized.toString().toLowerCase();
  } catch (_) {
    return trimmed.toLowerCase();
  }
}

function extractPublishedAt(json: ArticleItem): string | null {
  const raw = firstNonEmptyString(json, [
    "published_at",
    "publishedAt",
    "pubDate",
    "date",
    "created_at",
    "createdAt",
  ]);

  if (!raw) {
    return null;
  }

  const parsed = Date.parse(raw);
  if (Number.isNaN(parsed)) {
    return raw;
  }

  return new Date(parsed).toISOString();
}

function buildStableArticleKeysFromJson(json: ArticleItem): string[] {
  const keys = new Set<string>();

  const sourceObj = json.source && typeof json.source === "object" &&
      !Array.isArray(json.source)
    ? (json.source as Record<string, unknown>)
    : null;

  const sourceHint = normalizeIdentitySource(
    firstNonEmptyString(json, [
      "source_id",
      "sourceId",
      "source_name",
      "sourceName",
      "provider",
      "provider_id",
      "providerId",
      "provider_name",
      "providerName",
    ]) ??
      normalizeKeepCase(String(sourceObj?.id ?? sourceObj?.name ?? "")),
  );

  const normalizedUrl = normalizeArticleUrl(
    firstNonEmptyString(json, [
      "url",
      "link",
      "article_url",
      "articleUrl",
      "canonical_url",
      "canonicalUrl",
    ]),
  );

  if (normalizedUrl) {
    keys.add(`url:${normalizedUrl}`);
  }

  const externalId = firstNonEmptyString(json, [
    "external_id",
    "externalId",
    "guid",
    "uuid",
    "provider_article_id",
    "providerArticleId",
    "article_id",
    "articleId",
  ]);

  if (externalId) {
    keys.add(`external:${sourceHint}:${externalId.toLowerCase()}`);
  }

  const rawId = firstNonEmptyString(json, ["id"]);
  if (rawId) {
    keys.add(`id:${sourceHint}:${rawId.toLowerCase()}`);
  }

  const title = firstNonEmptyString(json, ["title", "headline"]);
  const publishedAt = extractPublishedAt(json);

  if (title && publishedAt) {
    keys.add(`title:${sourceHint}:${title.toLowerCase()}:${publishedAt}`);
  }

  return [...keys];
}

function deduplicateJsonListByStableIdentity(items: ArticleItem[]): ArticleItem[] {
  if (items.length <= 1) {
    return items.map((item) => ({ ...item }));
  }

  const seen = new Set<string>();
  const output: ArticleItem[] = [];

  for (const item of items) {
    const copy = { ...item };
    const identityKeys = buildStableArticleKeysFromJson(copy);

    if (identityKeys.length && identityKeys.some((key) => seen.has(key))) {
      continue;
    }

    output.push(copy);
    for (const key of identityKeys) {
      seen.add(key);
    }
  }

  return output;
}

function filterItemsForRequestedLanguage(
  items: ArticleItem[],
  requestedLanguage: string | null,
): ArticleItem[] {
  const normalizedRequestedLanguage = normalizeLanguage(requestedLanguage);
  if (!normalizedRequestedLanguage || !items.length) {
    return items.map((item) => ({ ...item }));
  }

  const explicitMatches: ArticleItem[] = [];
  const unknownLanguage: ArticleItem[] = [];
  let explicitMismatchCount = 0;

  for (const item of items) {
    const itemLanguage = extractItemLanguage(item);

    if (!itemLanguage) {
      unknownLanguage.push({ ...item });
      continue;
    }

    if (itemLanguage === normalizedRequestedLanguage) {
      explicitMatches.push({ ...item });
    } else {
      explicitMismatchCount += 1;
    }
  }

  if (!explicitMatches.length) {
    if (!unknownLanguage.length && explicitMismatchCount > 0) {
      return [];
    }

    return items.map((item) => ({ ...item }));
  }

  return [...explicitMatches, ...unknownLanguage];
}

function readEmbeddedContentLocation(
  json: ArticleItem,
): Record<string, unknown> | null {
  for (const key of LOCATION_KEYS) {
    const value = json[key];
    if (value && typeof value === "object" && !Array.isArray(value)) {
      return { ...(value as Record<string, unknown>) };
    }
  }

  return null;
}

function hasResolvedLocation(
  location: Record<string, unknown> | null,
): boolean {
  if (!location) {
    return false;
  }

  const latitude = Number(location.latitude);
  const longitude = Number(location.longitude);
  if (Number.isFinite(latitude) && Number.isFinite(longitude)) {
    return true;
  }

  const centerLat = Number(location.centerLat);
  const centerLng = Number(location.centerLng);
  return Number.isFinite(centerLat) && Number.isFinite(centerLng);
}

function countItemsWithResolvedLocation(items: ArticleItem[]): number {
  let count = 0;
  for (const item of items) {
    const location = readEmbeddedContentLocation(item);
    if (hasResolvedLocation(location)) {
      count += 1;
    }
  }
  return count;
}

function seedLocationsFromPreviousCache(
  items: ArticleItem[],
  previousItems: ArticleItem[],
): ArticleItem[] {
  if (!items.length || !previousItems.length) {
    return items.map((item) => ({ ...item }));
  }

  const previousLocationsByKey = new Map<string, Record<string, unknown>>();

  for (const previousItem of previousItems) {
    const keys = buildStableArticleKeysFromJson(previousItem);
    const location = readEmbeddedContentLocation(previousItem);

    if (!keys.length || !hasResolvedLocation(location)) {
      continue;
    }

    for (const key of keys) {
      previousLocationsByKey.set(
        key,
        { ...(location as Record<string, unknown>) },
      );
    }
  }

  const output: ArticleItem[] = [];

  for (const item of items) {
    const copy = { ...item };
    const currentLocation = readEmbeddedContentLocation(copy);

    if (!hasResolvedLocation(currentLocation)) {
      const keys = buildStableArticleKeysFromJson(copy);

      for (const key of keys) {
        const matched = previousLocationsByKey.get(key);
        if (matched) {
          copy._sv_content_location = { ...matched };
          break;
        }
      }
    }

    output.push(copy);
  }

  return output;
}

function preferStablePayload(args: {
  refreshedItems: ArticleItem[];
  previousItems: ArticleItem[];
}): {
  items: ArticleItem[];
  preservedPreviousPayload: boolean;
} {
  const refreshedItems = args.refreshedItems.map((item) => ({ ...item }));
  const previousItems = args.previousItems.map((item) => ({ ...item }));

  if (!refreshedItems.length && previousItems.length) {
    return {
      items: previousItems,
      preservedPreviousPayload: true,
    };
  }

  const refreshedLocated = countItemsWithResolvedLocation(refreshedItems);
  const previousLocated = countItemsWithResolvedLocation(previousItems);

  if (refreshedLocated > 0) {
    return {
      items: refreshedItems,
      preservedPreviousPayload: false,
    };
  }

  if (refreshedItems.length && previousLocated === 0) {
    return {
      items: refreshedItems,
      preservedPreviousPayload: false,
    };
  }

  if (refreshedLocated === 0 && previousLocated > 0) {
    return {
      items: previousItems,
      preservedPreviousPayload: true,
    };
  }

  return {
    items: refreshedItems,
    preservedPreviousPayload: false,
  };
}

function buildCacheMetadata(items: ArticleItem[]) {
  const providerSignatures = new Set<string>();
  const languagesPresent = new Set<string>();

  for (const item of items) {
    const providerSignature = extractProviderSignature(item);
    if (providerSignature) {
      providerSignatures.add(providerSignature);
    }

    const language = extractItemLanguage(item);
    if (language) {
      languagesPresent.add(language);
    }
  }

  return {
    itemCount: items.length,
    resolvedLocationCount: countItemsWithResolvedLocation(items),
    providerSignatures: [...providerSignatures].sort(),
    languagesPresent: [...languagesPresent].sort(),
    payloadVersion: CACHE_PAYLOAD_VERSION,
  };
}

async function upsertCache(
  supabase: SupabaseCacheClient,
  candidate: Candidate,
  items: ArticleItem[],
): Promise<void> {
  const metadata = buildCacheMetadata(items);

  const { error } = await supabase.from(CACHE_TABLE).upsert(
    {
      cache_key: candidate.cacheKey,
      country_code: candidate.countryCode,
      city_id: candidate.cityId,
      topic: candidate.topic,
      language: candidate.language,
      payload: items,
      item_count: metadata.itemCount,
      resolved_location_count: metadata.resolvedLocationCount,
      provider_signatures: metadata.providerSignatures,
      languages_present: metadata.languagesPresent,
      payload_version: metadata.payloadVersion,
      refreshed_at: new Date().toISOString(),
    },
    { onConflict: "cache_key" },
  );

  if (error) {
    throw new Error(error.message);
  }
}

async function refreshSingleCandidate(
  supabase: SupabaseCacheClient,
  candidate: Candidate,
) {
  const previousItems = candidate.previousItems.map((item) => ({ ...item }));
  const effectiveLanguage = resolveExecutionLanguage(candidate);

  const aggregated = await fetchAggregatedNews(candidate);

  if (!aggregated.items.length) {
    return {
      cacheKey: candidate.cacheKey,
      ok: previousItems.length > 0,
      updated: false,
      providerUsed: null,
      effectiveLanguage,
      providerOrder: aggregated.providerOrder,
      attempts: aggregated.attempts,
      itemCount: previousItems.length,
      resolvedLocationCount: countItemsWithResolvedLocation(previousItems),
      preservedPreviousPayload: previousItems.length > 0,
      reason: previousItems.length > 0
        ? "no_provider_items_kept_existing_cache"
        : "no_provider_items_no_existing_cache",
    };
  }

  const filtered = filterItemsForRequestedLanguage(
    deduplicateJsonListByStableIdentity(aggregated.items),
    candidate.language,
  );

  const seeded = seedLocationsFromPreviousCache(filtered, previousItems);

  const stabilized = preferStablePayload({
    refreshedItems: seeded,
    previousItems,
  });

  await upsertCache(supabase, candidate, stabilized.items);

  return {
    cacheKey: candidate.cacheKey,
    ok: true,
    updated: true,
    providerUsed: aggregated.providerId,
    effectiveLanguage,
    providerOrder: aggregated.providerOrder,
    attempts: aggregated.attempts,
    itemCount: stabilized.items.length,
    resolvedLocationCount: countItemsWithResolvedLocation(stabilized.items),
    preservedPreviousPayload: stabilized.preservedPreviousPayload,
    reason: stabilized.preservedPreviousPayload
      ? "refreshed_items_kept_previous_payload_for_location_stability"
      : "cache_refreshed",
  };
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: CORS_HEADERS,
    });
  }

  if (!isAuthorized(req)) {
    return json(
      {
        ok: false,
        error: "unauthorized",
        message:
          "Missing or invalid refresh secret. Set NEWS_CACHE_REFRESH_SECRET and send it as Bearer token or x-refresh-secret.",
      },
      { status: 401 },
    );
  }

  if (req.method !== "GET" && req.method !== "POST") {
    return json(
      {
        ok: false,
        error: "method_not_allowed",
      },
      { status: 405 },
    );
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !serviceRoleKey) {
    return json(
      {
        ok: false,
        error: "missing_env",
        message:
          "SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY is missing in function secrets.",
      },
      { status: 500 },
    );
  }

  const supabase = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false },
  });

  let body: RefreshRequest = {};
  if (req.method === "POST") {
    try {
      body = await req.json();
    } catch (_) {
      body = {};
    }
  }

  const dryRun = body.dryRun ?? true;
  const limit = toPositiveInt(body.limit, DEFAULT_LIMIT, MAX_LIMIT);

  const { data, error } = await supabase
    .from(CACHE_TABLE)
    .select(
      `
      cache_key,
      country_code,
      city_id,
      topic,
      language,
      refreshed_at,
      item_count,
      resolved_location_count,
      provider_signatures,
      languages_present,
      payload_version,
      payload
    `,
    )
    .order("refreshed_at", { ascending: true, nullsFirst: true })
    .limit(MAX_LIMIT);

  if (error) {
    return json(
      {
        ok: false,
        error: "cache_read_failed",
        message: error.message,
      },
      { status: 500 },
    );
  }

  const rows = (data ?? []) as CacheRow[];
  const allCandidates = rows.map(buildCandidate);

  let filteredCandidates = allCandidates
    .filter((candidate) => matchesFilters(candidate, body))
    .sort(compareCandidates)
    .slice(0, limit);

  if (!filteredCandidates.length) {
    const synthetic = buildSyntheticCandidate(body);
    if (synthetic) {
      filteredCandidates = [synthetic];
    }
  }

  if (dryRun) {
    return json({
      ok: true,
      mode: "dry-run",
      scannedCount: allCandidates.length,
      selectedCount: filteredCandidates.length,
      candidates: filteredCandidates.map((candidate) => ({
        cacheKey: candidate.cacheKey,
        countryCode: candidate.countryCode,
        cityId: candidate.cityId,
        topic: candidate.topic,
        storedLanguage: candidate.language,
        effectiveLanguage: resolveExecutionLanguage(candidate),
        refreshedAt: candidate.refreshedAt,
        itemCount: candidate.itemCount,
        resolvedLocationCount: candidate.resolvedLocationCount,
        providerSignatures: candidate.providerSignatures,
        languagesPresent: candidate.languagesPresent,
        providerOrder: orderProvidersForRequest(
          resolveExecutionLanguage(candidate),
          candidate.topic,
        ),
      })),
    });
  }

  const results: Array<Record<string, unknown>> = [];
  let updatedCount = 0;
  let failedCount = 0;

  for (const candidate of filteredCandidates) {
    try {
      const result = await refreshSingleCandidate(supabase, candidate);
      results.push(result);

      if (result.updated) {
        updatedCount += 1;
      }

      if (!result.ok) {
        failedCount += 1;
      }
    } catch (err) {
      failedCount += 1;

      results.push({
        cacheKey: candidate.cacheKey,
        ok: false,
        updated: false,
        providerUsed: null,
        effectiveLanguage: resolveExecutionLanguage(candidate),
        providerOrder: orderProvidersForRequest(
          resolveExecutionLanguage(candidate),
          candidate.topic,
        ),
        attempts: [],
        itemCount: candidate.itemCount,
        resolvedLocationCount: candidate.resolvedLocationCount,
        preservedPreviousPayload: false,
        reason: err instanceof Error ? err.message : String(err),
      });
    }
  }

  return json({
    ok: failedCount === 0,
    mode: "execute",
    scannedCount: allCandidates.length,
    selectedCount: filteredCandidates.length,
    updatedCount,
    failedCount,
    results,
  });
});