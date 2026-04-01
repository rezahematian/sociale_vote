// supabase/functions/news-proxy/index.ts


type Json = Record<string, unknown>;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Content-Type": "application/json",
};

const NEWSAPI_KEY = Deno.env.get("NEWSAPI_KEY") ?? "";
const GNEWS_KEY = Deno.env.get("GNEWS_KEY") ?? "";
const GUARDIAN_KEY = Deno.env.get("GUARDIAN_KEY") ?? "";

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: corsHeaders,
    });
  }

  if (req.method !== "POST") {
    return jsonResponse(
      {
        error: "Method not allowed",
        statusCode: 405,
      },
      405,
    );
  }

  try {
    const body = (await req.json()) as Json;
    const action = readString(body.action);

    if (action === "feed") {
      return await handleFeed(body);
    }

    if (action === "detail") {
      return await handleDetail(body);
    }

    return jsonResponse(
      {
        error: "Unsupported action",
        statusCode: 400,
      },
      400,
    );
  } catch (error) {
    return jsonResponse(
      {
        error: error instanceof Error ? error.message : String(error),
        statusCode: 500,
      },
      500,
    );
  }
});

async function handleFeed(body: Json): Promise<Response> {
  const countryCode = normalizeText(body.countryCode);
  const cityId = normalizeText(body.cityId);
  const topic = normalizeTopic(body.topic);
  const language = effectiveLanguage(body.language);
  const limit = clampInt(body.limit, 1, 50, 20);
  const offset = clampInt(body.offset, 0, 500, 0);

  const providerOrder = orderProvidersForLanguage(language, topic);

  let lastError: unknown = null;
  let lastStatusCode: number | null = null;
  let sawRateLimit = false;

  for (const provider of providerOrder) {
    try {
      const result = await fetchProviderFeed(provider, {
        countryCode,
        cityId,
        topic,
        language,
        limit,
        offset,
      });

      if (result.items.length > 0) {
        return jsonResponse({
          providerId: provider,
          items: result.items,
          rateLimited: false,
          statusCode: result.statusCode,
        });
      }

      if (result.rateLimited) {
        sawRateLimit = true;
      }

      lastStatusCode = result.statusCode;
      lastError = result.error;
    } catch (error) {
      lastError = error;
      lastStatusCode = extractStatusCode(error);
      if (looksRateLimited(error)) {
        sawRateLimit = true;
      }
    }
  }

  return jsonResponse({
    providerId: "webproxy",
    items: [],
    rateLimited: sawRateLimit,
    statusCode: lastStatusCode,
    error: serializeError(lastError),
  });
}

async function handleDetail(body: Json): Promise<Response> {
  const id = readString(body.id)?.trim();
  if (!id) {
    return jsonResponse(
      {
        error: "Missing id",
        statusCode: 400,
      },
      400,
    );
  }

  const providerOrder = ["guardian", "newsapi", "gnews"];

  let lastError: unknown = null;
  let lastStatusCode: number | null = null;

  for (const provider of providerOrder) {
    try {
      const item = await fetchProviderDetail(provider, id);
      if (item) {
        return jsonResponse({
          providerId: provider,
          item,
          statusCode: 200,
        });
      }
    } catch (error) {
      lastError = error;
      lastStatusCode = extractStatusCode(error);
    }
  }

  return jsonResponse(
    {
      error: serializeError(lastError) ?? "News detail not found",
      statusCode: lastStatusCode ?? 404,
    },
    lastStatusCode ?? 404,
  );
}

function orderProvidersForLanguage(
  language: string,
  topic: string | null,
): string[] {
  if (language === "en") {
    return ["guardian", "newsapi", "gnews"];
  }

  if (["it", "fr", "es", "de"].includes(language)) {
    return ["newsapi", "gnews"];
  }

  if (language === "ar") {
    const isAllTopic = topic == null || topic === "all" || topic === "tutte";
    return isAllTopic ? ["gnews", "newsapi"] : ["newsapi", "gnews"];
  }

  if (language === "fa") {
    return ["gnews", "newsapi"];
  }

  return ["newsapi", "gnews", "guardian"];
}

async function fetchProviderFeed(
  providerId: string,
  params: {
    countryCode: string | null;
    cityId: string | null;
    topic: string | null;
    language: string;
    limit: number;
    offset: number;
  },
): Promise<{
  items: Json[];
  rateLimited: boolean;
  statusCode: number | null;
  error: unknown;
}> {
  switch (providerId) {
    case "guardian":
      return await fetchGuardianFeed(params);
    case "newsapi":
      return await fetchNewsApiFeed(params);
    case "gnews":
      return await fetchGNewsFeed(params);
    default:
      return {
        items: [],
        rateLimited: false,
        statusCode: 400,
        error: `Unsupported provider: ${providerId}`,
      };
  }
}

async function fetchProviderDetail(
  providerId: string,
  id: string,
): Promise<Json | null> {
  switch (providerId) {
    case "guardian":
      return await fetchGuardianDetail(id);
    case "newsapi":
      return null;
    case "gnews":
      return null;
    default:
      return null;
  }
}

async function fetchGuardianFeed(params: {
  countryCode: string | null;
  cityId: string | null;
  topic: string | null;
  language: string;
  limit: number;
  offset: number;
}) {
  if (!GUARDIAN_KEY) {
    return {
      items: [],
      rateLimited: false,
      statusCode: 500,
      error: "Missing GUARDIAN_KEY",
    };
  }

  const page = Math.floor(params.offset / Math.max(params.limit, 1)) + 1;
  const section = mapTopicToGuardianSection(params.topic);

  const url = new URL("https://content.guardianapis.com/search");
  url.searchParams.set("api-key", GUARDIAN_KEY);
  url.searchParams.set("show-fields", "headline,trailText,body,thumbnail");
  url.searchParams.set("page-size", String(params.limit));
  url.searchParams.set("page", String(page));
  url.searchParams.set("order-by", "newest");

  if (section) {
    url.searchParams.set("section", section);
  }

  const response = await fetch(url.toString());
  const data = await safeJson(response);

  if (!response.ok) {
    return {
      items: [],
      rateLimited: response.status === 429,
      statusCode: response.status,
      error: data,
    };
  }

  const results = Array.isArray(data?.response?.results)
    ? data.response.results
    : [];

  const items = results.map((item: any) => {
    const fields = item?.fields ?? {};
    const webUrl = stringOrNull(item?.webUrl);
    const sourceName = "The Guardian";

    return {
      id: stringOrNull(item?.id) ?? webUrl ?? crypto.randomUUID(),
      title: stringOrNull(fields?.headline) ?? stringOrNull(item?.webTitle) ??
        "",
      description: stringOrNull(fields?.trailText),
      content: stringOrNull(fields?.body),
      url: webUrl,
      publishedAt: stringOrNull(item?.webPublicationDate),
      imageUrl: stringOrNull(fields?.thumbnail),
      sourceName,
      sourceId: "guardian",
      language: "en",
    };
  }).filter((item: Json) => hasText(item.title));

  return {
    items,
    rateLimited: false,
    statusCode: response.status,
    error: null,
  };
}

async function fetchGuardianDetail(id: string): Promise<Json | null> {
  if (!GUARDIAN_KEY) {
    throw new Error("Missing GUARDIAN_KEY");
  }

  const url = new URL(`https://content.guardianapis.com/${id}`);
  url.searchParams.set("api-key", GUARDIAN_KEY);
  url.searchParams.set("show-fields", "headline,trailText,body,thumbnail");

  const response = await fetch(url.toString());
  const data = await safeJson(response);

  if (!response.ok) {
    throw new Error(
      `Guardian detail failed (${response.status}): ${JSON.stringify(data)}`,
    );
  }

  const item = data?.response?.content;
  if (!item) {
    return null;
  }

  const fields = item?.fields ?? {};
  const webUrl = stringOrNull(item?.webUrl);

  return {
    id: stringOrNull(item?.id) ?? webUrl ?? crypto.randomUUID(),
    title: stringOrNull(fields?.headline) ?? stringOrNull(item?.webTitle) ?? "",
    description: stringOrNull(fields?.trailText),
    content: stringOrNull(fields?.body),
    url: webUrl,
    publishedAt: stringOrNull(item?.webPublicationDate),
    imageUrl: stringOrNull(fields?.thumbnail),
    sourceName: "The Guardian",
    sourceId: "guardian",
    language: "en",
  };
}

async function fetchNewsApiFeed(params: {
  countryCode: string | null;
  cityId: string | null;
  topic: string | null;
  language: string;
  limit: number;
  offset: number;
}) {
  if (!NEWSAPI_KEY) {
    return {
      items: [],
      rateLimited: false,
      statusCode: 500,
      error: "Missing NEWSAPI_KEY",
    };
  }

  const page = Math.floor(params.offset / Math.max(params.limit, 1)) + 1;
  const url = new URL("https://newsapi.org/v2/top-headlines");
  url.searchParams.set("apiKey", NEWSAPI_KEY);
  url.searchParams.set("pageSize", String(params.limit));
  url.searchParams.set("page", String(page));
  url.searchParams.set("language", params.language);

  const mappedCategory = mapTopicToNewsApiCategory(params.topic);
  if (mappedCategory) {
    url.searchParams.set("category", mappedCategory);
  }

  const response = await fetch(url.toString());
  const data = await safeJson(response);

  if (!response.ok) {
    return {
      items: [],
      rateLimited: response.status === 429,
      statusCode: response.status,
      error: data,
    };
  }

  const articles = Array.isArray(data?.articles) ? data.articles : [];

  const items = articles.map((item: any) => ({
    id: stringOrNull(item?.url) ?? crypto.randomUUID(),
    title: stringOrNull(item?.title) ?? "",
    description: stringOrNull(item?.description),
    content: stringOrNull(item?.content),
    url: stringOrNull(item?.url),
    publishedAt: stringOrNull(item?.publishedAt),
    imageUrl: stringOrNull(item?.urlToImage),
    sourceName: stringOrNull(item?.source?.name),
    sourceId: stringOrNull(item?.source?.id) ?? "newsapi",
    authorName: stringOrNull(item?.author),
    language: params.language,
  })).filter((item: Json) => hasText(item.title));

  return {
    items,
    rateLimited: false,
    statusCode: response.status,
    error: null,
  };
}

async function fetchGNewsFeed(params: {
  countryCode: string | null;
  cityId: string | null;
  topic: string | null;
  language: string;
  limit: number;
  offset: number;
}) {
  if (!GNEWS_KEY) {
    return {
      items: [],
      rateLimited: false,
      statusCode: 500,
      error: "Missing GNEWS_KEY",
    };
  }

  const page = Math.floor(params.offset / Math.max(params.limit, 1)) + 1;
  const url = new URL("https://gnews.io/api/v4/top-headlines");
  url.searchParams.set("apikey", GNEWS_KEY);
  url.searchParams.set("max", String(params.limit));
  url.searchParams.set("page", String(page));
  url.searchParams.set("lang", params.language);
  url.searchParams.set("sortby", "publishedAt");

  const mappedTopic = mapTopicToGNewsTopic(params.topic);
  if (mappedTopic) {
    url.searchParams.set("topic", mappedTopic);
  }

  const response = await fetch(url.toString());
  const data = await safeJson(response);

  if (!response.ok) {
    return {
      items: [],
      rateLimited: response.status === 429,
      statusCode: response.status,
      error: data,
    };
  }

  const articles = Array.isArray(data?.articles) ? data.articles : [];

  const items = articles.map((item: any) => ({
    id: stringOrNull(item?.url) ?? crypto.randomUUID(),
    title: stringOrNull(item?.title) ?? "",
    description: stringOrNull(item?.description),
    content: stringOrNull(item?.content),
    url: stringOrNull(item?.url),
    publishedAt: stringOrNull(item?.publishedAt),
    imageUrl: stringOrNull(item?.image),
    sourceName: stringOrNull(item?.source?.name),
    sourceId: stringOrNull(item?.source?.name) ?? "gnews",
    language: params.language,
  })).filter((item: Json) => hasText(item.title));

  return {
    items,
    rateLimited: false,
    statusCode: response.status,
    error: null,
  };
}

function mapTopicToGuardianSection(topic: string | null): string | null {
  switch (topic) {
    case "politics":
      return "politics";
    case "world":
      return "world";
    case "business":
      return "business";
    case "technology":
      return "technology";
    case "sport":
    case "sports":
      return "sport";
    default:
      return null;
  }
}

function mapTopicToNewsApiCategory(topic: string | null): string | null {
  switch (topic) {
    case "business":
    case "technology":
    case "sports":
    case "health":
    case "science":
    case "entertainment":
      return topic;
    case "sport":
      return "sports";
    default:
      return null;
  }
}

function mapTopicToGNewsTopic(topic: string | null): string | null {
  switch (topic) {
    case "world":
    case "nation":
    case "business":
    case "technology":
    case "sports":
    case "science":
    case "health":
    case "entertainment":
      return topic;
    case "sport":
      return "sports";
    default:
      return null;
  }
}

function effectiveLanguage(value: unknown): string {
  const normalized = normalizeText(value)?.split("-")[0];
  switch (normalized) {
    case "it":
    case "en":
    case "es":
    case "fr":
    case "de":
    case "ar":
    case "fa":
      return normalized;
    default:
      return "en";
  }
}

function normalizeTopic(value: unknown): string | null {
  const normalized = normalizeText(value);
  if (!normalized || normalized === "all" || normalized === "tutte") {
    return null;
  }
  return normalized;
}

function normalizeText(value: unknown): string | null {
  if (typeof value !== "string") {
    return null;
  }
  const trimmed = value.trim().toLowerCase();
  return trimmed.length > 0 ? trimmed : null;
}

function readString(value: unknown): string | null {
  return typeof value === "string" && value.trim().length > 0
    ? value
    : null;
}

function clampInt(
  value: unknown,
  min: number,
  max: number,
  fallback: number,
): number {
  const parsed = typeof value === "number"
    ? Math.trunc(value)
    : Number.parseInt(String(value ?? ""), 10);

  if (!Number.isFinite(parsed)) {
    return fallback;
  }

  return Math.min(max, Math.max(min, parsed));
}

function stringOrNull(value: unknown): string | null {
  return typeof value === "string" && value.trim().length > 0
    ? value
    : null;
}

function hasText(value: unknown): boolean {
  return typeof value === "string" && value.trim().length > 0;
}

function looksRateLimited(error: unknown): boolean {
  const text = String(error ?? "").toLowerCase();
  return text.includes("429") ||
    text.includes("rate limit") ||
    text.includes("too many requests");
}

function extractStatusCode(error: unknown): number | null {
  const text = String(error ?? "");
  const match = text.match(/\b([1-5]\d{2})\b/);
  return match ? Number.parseInt(match[1], 10) : null;
}

function serializeError(error: unknown): unknown {
  if (error == null) {
    return null;
  }
  if (error instanceof Error) {
    return error.message;
  }
  return error;
}

async function safeJson(response: Response): Promise<any> {
  const text = await response.text();
  if (!text) {
    return null;
  }

  try {
    return JSON.parse(text);
  } catch (_) {
    return { raw: text };
  }
}

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: corsHeaders,
  });
}