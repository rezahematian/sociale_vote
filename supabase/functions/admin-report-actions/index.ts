import { createClient } from 'npm:@supabase/supabase-js@2'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!

type StaffRole = 'moderator' | 'admin'
type ReportDecision =
  | 'no_violation'
  | 'violation_confirmed'
  | 'escalate_to_admin'

type RequestBody = {
  reportId?: unknown
  decision?: unknown
  reviewNote?: unknown
}

type ReportDecisionResult = {
  success?: unknown
  reportId?: unknown
  previousStatus?: unknown
  status?: unknown
  decision?: unknown
  reviewedBy?: unknown
  reviewedAt?: unknown
}

const allowedDecisions = new Set<ReportDecision>([
  'no_violation',
  'violation_confirmed',
  'escalate_to_admin',
])

const minimumReviewNoteLength = 3
const maximumReviewNoteLength = 2000

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

function jsonResponse(status: number, body: Record<string, unknown>) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json',
    },
  })
}

function readBearerToken(req: Request): string | null {
  const authorization = req.headers.get('Authorization') ?? ''
  const prefix = 'Bearer '

  if (!authorization.startsWith(prefix)) {
    return null
  }

  const token = authorization.substring(prefix.length).trim()
  return token.length === 0 ? null : token
}

function readUuid(value: unknown): string | null {
  if (typeof value !== 'string') {
    return null
  }

  const normalized = value.trim().toLowerCase()

  return /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/.test(
    normalized,
  )
    ? normalized
    : null
}

function readStaffRole(value: unknown): StaffRole | null {
  if (typeof value !== 'string') {
    return null
  }

  const normalized = value.trim().toLowerCase()

  return normalized === 'moderator' || normalized === 'admin'
    ? normalized
    : null
}

function readDecision(value: unknown): ReportDecision | null {
  if (typeof value !== 'string') {
    return null
  }

  const normalized = value.trim().toLowerCase()

  return allowedDecisions.has(normalized as ReportDecision)
    ? (normalized as ReportDecision)
    : null
}

function readReviewNote(value: unknown): string | null {
  if (typeof value !== 'string') {
    return null
  }

  const normalized = value.trim()

  return normalized.length >= minimumReviewNoteLength &&
      normalized.length <= maximumReviewNoteLength
    ? normalized
    : null
}

function readResultObject(value: unknown): ReportDecisionResult | null {
  if (value == null || typeof value !== 'object' || Array.isArray(value)) {
    return null
  }

  return value as ReportDecisionResult
}

function readRequiredString(
  source: ReportDecisionResult,
  key: keyof ReportDecisionResult,
): string | null {
  const value = source[key]

  if (typeof value !== 'string') {
    return null
  }

  const normalized = value.trim()
  return normalized.length === 0 ? null : normalized
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      status: 200,
      headers: corsHeaders,
    })
  }

  if (req.method !== 'POST') {
    return jsonResponse(405, {
      error: 'Method not allowed.',
    })
  }

  const accessToken = readBearerToken(req)

  if (accessToken == null) {
    return jsonResponse(401, {
      error: 'Missing access token.',
    })
  }

  let decodedBody: unknown

  try {
    decodedBody = await req.json()
  } catch (_) {
    return jsonResponse(400, {
      error: 'Invalid JSON body.',
    })
  }

  if (
    decodedBody == null ||
    typeof decodedBody !== 'object' ||
    Array.isArray(decodedBody)
  ) {
    return jsonResponse(400, {
      error: 'JSON body must be an object.',
    })
  }

  const body = decodedBody as RequestBody
  const reportId = readUuid(body.reportId)
  const decision = readDecision(body.decision)
  const reviewNote = readReviewNote(body.reviewNote)

  if (reportId == null) {
    return jsonResponse(400, {
      error: 'A valid report ID is required.',
    })
  }

  if (decision == null) {
    return jsonResponse(400, {
      error:
        'Decision must be no_violation, violation_confirmed, or escalate_to_admin.',
    })
  }

  if (reviewNote == null) {
    return jsonResponse(400, {
      error:
        `Review note must contain between ${minimumReviewNoteLength} and ${maximumReviewNoteLength} characters.`,
    })
  }

  const userClient = createClient(supabaseUrl, anonKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
    global: {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    },
  })

  const {
    data: { user: caller },
    error: callerError,
  } = await userClient.auth.getUser(accessToken)

  if (callerError != null || caller == null) {
    return jsonResponse(401, {
      error: 'Invalid session.',
    })
  }

  const { data: isCurrentSessionActive, error: activeSessionError } =
    await userClient.rpc('is_current_auth_user_active')

  if (activeSessionError != null || isCurrentSessionActive !== true) {
    console.error(
      'Admin report decision rejected: inactive session.',
      activeSessionError,
    )

    return jsonResponse(401, {
      error: 'Session is no longer active.',
    })
  }

  const callerRole = readStaffRole(caller.app_metadata?.role)

  if (callerRole == null) {
    return jsonResponse(403, {
      error: 'Moderator or administrator access is required.',
    })
  }

  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  })

  const { data: callerMirror, error: callerMirrorError } = await adminClient
    .from('users')
    .select('role')
    .eq('id', caller.id)
    .maybeSingle()

  if (callerMirrorError != null) {
    console.error(
      'Unable to verify the staff role mirror.',
      callerMirrorError,
    )

    return jsonResponse(500, {
      error: 'Unable to verify staff access.',
    })
  }

  if (readStaffRole(callerMirror?.role) !== callerRole) {
    return jsonResponse(403, {
      error: 'Staff role is not synchronized.',
    })
  }

  const { data, error: decisionError } = await adminClient.rpc(
    'admin_record_report_decision',
    {
      p_report_id: reportId,
      p_actor_user_id: caller.id,
      p_actor_role: callerRole,
      p_decision: decision,
      p_review_note: reviewNote,
    },
  )

  if (decisionError != null) {
    console.error('Admin report decision failed.', decisionError)

    const status =
      decisionError.code === '22004' || decisionError.code === '22023'
        ? 400
        : decisionError.code === '42501'
          ? 403
          : decisionError.code === 'P0002'
            ? 404
            : decisionError.code === '55000'
              ? 409
              : 500

    return jsonResponse(status, {
      error:
        status === 400
          ? 'Invalid report decision request.'
          : status === 403
            ? 'Staff access was rejected.'
            : status === 404
              ? 'Report was not found.'
              : status === 409
                ? 'The report is no longer pending or was already reviewed.'
                : 'Unable to record the report decision.',
      errorCode:
        status === 409
          ? 'report_no_longer_pending'
          : status === 404
            ? 'report_not_found'
            : status === 403
              ? 'access_denied'
              : status === 400
                ? 'invalid_request'
                : 'server_error',
    })
  }

  const result = readResultObject(data)

  if (result == null || result.success !== true) {
    console.error('Admin report decision returned an invalid result.')

    return jsonResponse(500, {
      error: 'Invalid report decision response.',
      errorCode: 'invalid_response',
    })
  }

  const resultReportId = readRequiredString(result, 'reportId')
  const previousStatus = readRequiredString(result, 'previousStatus')
  const status = readRequiredString(result, 'status')
  const resultDecision = readRequiredString(result, 'decision')
  const reviewedBy = readRequiredString(result, 'reviewedBy')
  const reviewedAt = readRequiredString(result, 'reviewedAt')

  if (
    resultReportId == null ||
    previousStatus == null ||
    status == null ||
    resultDecision == null ||
    reviewedBy == null ||
    reviewedAt == null
  ) {
    console.error('Admin report decision response is incomplete.')

    return jsonResponse(500, {
      error: 'Invalid report decision response.',
      errorCode: 'invalid_response',
    })
  }

  return jsonResponse(200, {
    success: true,
    report: {
      reportId: resultReportId,
      previousStatus,
      status,
      decision: resultDecision,
      reviewedBy,
      reviewedAt,
    },
    permissions: {
      role: callerRole,
    },
  })
})
