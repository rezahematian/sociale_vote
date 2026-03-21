import { createClient } from "@supabase/supabase-js";

type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json }
  | Json[];

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
};

const CACHE_TABLE = "news_feed_cache";
const DEFAULT_LIMIT = 25;
const MAX_LIMIT = 100;

function json(
  body: Record<string, unknown>,
  init?: ResponseInit,
): Response {
  return new Response(JSON.stringify(body, null, 2), {
    headers: {
      "content-type": "application/json; charset=utf-8",
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

function buildCandidate(row: CacheRow): Candidate {
  return {
    cacheKey: row.cache_key,
    countryCode: normalize(row.country_code),
    cityId: normalize(row.city_id),
    topic: normalize(row.topic),
    language: normalizeLanguage(row.language),
    refreshedAt: row.refreshed_at,
    itemCount: Number(row.item_count ?? 0),
    resolvedLocationCount: Number(row.resolved_location_count ?? 0),
  };
}

function matchesFilters(candidate: Candidate, req: RefreshRequest): boolean {
  const requestedCacheKey = normalize(req.cacheKey);
  if (requestedCacheKey && candidate.cacheKey.toLowerCase() !== requestedCacheKey) {
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

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "access-control-allow-origin": "*",
        "access-control-allow-methods": "POST, GET, OPTIONS",
        "access-control-allow-headers":
          "authorization, x-client-info, apikey, content-type, x-refresh-secret",
      },
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

  if (req.method !== "GET" && req.method !== "POST") {
    return json(
      {
        ok: false,
        error: "method_not_allowed",
      },
      { status: 405 },
    );
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
      payload_version
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
  const filteredCandidates = allCandidates
    .filter((candidate) => matchesFilters(candidate, body))
    .sort(compareCandidates)
    .slice(0, limit);

  if (dryRun) {
    return json({
      ok: true,
      mode: "dry-run",
      message:
        "Edge Function wiring is active. Candidate discovery works. Provider refresh is intentionally not enabled yet in this first server-side file.",
      scannedCount: allCandidates.length,
      selectedCount: filteredCandidates.length,
      candidates: filteredCandidates,
      nextStep:
        "Add real provider fetch adapters server-side, then replace dry-run behavior with actual refresh + cache write.",
    });
  }

  return json(
    {
      ok: false,
      mode: "execute",
      error: "not_implemented_yet",
      message:
        "This first backend entrypoint is live, but real provider refresh is not implemented yet. That requires the exact provider REST logic server-side to avoid creating a fake or divergent pipeline.",
      scannedCount: allCandidates.length,
      selectedCount: filteredCandidates.length,
      candidates: filteredCandidates,
    },
    { status: 501 },
  );
});