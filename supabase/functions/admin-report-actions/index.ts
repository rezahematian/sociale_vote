import { createClient } from 'npm:@supabase/supabase-js@2'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!

type StaffRole = 'moderator' | 'admin'
type ReportDecision =
  | 'no_violation'
  | 'violation_confirmed'
  | 'escalate_to_admin'
type ContentAction = 'hide' | 'restore'
type AdminResolution =
  | 'no_account_action'
  | 'account_suspended'
  | 'logout_forced'
  | 'account_deleted'

type RequestBody = {
  reportId?: unknown
  decision?: unknown
  reviewNote?: unknown
  contentAction?: unknown
  actionReason?: unknown
  adminResolution?: unknown
  adminResolutionNote?: unknown
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

type ReportContentActionResult = {
  success?: unknown
  changed?: unknown
  reportId?: unknown
  previousReportStatus?: unknown
  reportStatus?: unknown
  targetType?: unknown
  targetId?: unknown
  action?: unknown
  previousIsHidden?: unknown
  isHidden?: unknown
  performedBy?: unknown
  performedAt?: unknown
}

type AdminResolutionResult = {
  success?: unknown
  changed?: unknown
  replayed?: unknown
  reportId?: unknown
  previousStatus?: unknown
  status?: unknown
  resolution?: unknown
  reportedUserId?: unknown
  accountActionVerified?: unknown
  resolvedBy?: unknown
  resolvedAt?: unknown
}

const allowedDecisions = new Set<ReportDecision>([
  'no_violation',
  'violation_confirmed',
  'escalate_to_admin',
])

const allowedContentActions = new Set<ContentAction>([
  'hide',
  'restore',
])

const allowedAdminResolutions = new Set<AdminResolution>([
  'no_account_action',
  'account_suspended',
  'logout_forced',
  'account_deleted',
])

const minimumReviewNoteLength = 3
const maximumReviewNoteLength = 2000
const minimumActionReasonLength = 3
const maximumActionReasonLength = 2000

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

function readContentAction(value: unknown): ContentAction | null {
  if (typeof value !== 'string') {
    return null
  }

  const normalized = value.trim().toLowerCase()

  return allowedContentActions.has(normalized as ContentAction)
    ? (normalized as ContentAction)
    : null
}

function readAdminResolution(value: unknown): AdminResolution | null {
  if (typeof value !== 'string') {
    return null
  }

  const normalized = value.trim().toLowerCase()

  return allowedAdminResolutions.has(normalized as AdminResolution)
    ? (normalized as AdminResolution)
    : null
}

function readBoundedText(
  value: unknown,
  minimumLength: number,
  maximumLength: number,
): string | null {
  if (typeof value !== 'string') {
    return null
  }

  const normalized = value.trim()

  return normalized.length >= minimumLength &&
      normalized.length <= maximumLength
    ? normalized
    : null
}

function readReviewNote(value: unknown): string | null {
  return readBoundedText(
    value,
    minimumReviewNoteLength,
    maximumReviewNoteLength,
  )
}

function readActionReason(value: unknown): string | null {
  return readBoundedText(
    value,
    minimumActionReasonLength,
    maximumActionReasonLength,
  )
}

function readAdminResolutionNote(value: unknown): string | null {
  return readBoundedText(
    value,
    minimumReviewNoteLength,
    maximumReviewNoteLength,
  )
}

function readResultObject<T extends object>(value: unknown): T | null {
  if (value == null || typeof value !== 'object' || Array.isArray(value)) {
    return null
  }

  return value as T
}

function readRequiredString(
  source: Record<string, unknown>,
  key: string,
): string | null {
  const value = source[key]

  if (typeof value !== 'string') {
    return null
  }

  const normalized = value.trim()
  return normalized.length === 0 ? null : normalized
}

function readRequiredBoolean(
  source: Record<string, unknown>,
  key: string,
): boolean | null {
  const value = source[key]
  return typeof value === 'boolean' ? value : null
}

function mapRpcErrorStatus(code: string | undefined): number {
  if (code === '22004' || code === '22023') {
    return 400
  }

  if (code === '42501') {
    return 403
  }

  if (code === 'P0002') {
    return 404
  }

  if (code === '23505' || code === '55000') {
    return 409
  }

  return 500
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

  if (reportId == null) {
    return jsonResponse(400, {
      error: 'A valid report ID is required.',
    })
  }

  const hasDecisionPayload =
    body.decision != null || body.reviewNote != null
  const hasContentActionPayload =
    body.contentAction != null || body.actionReason != null
  const hasAdminResolutionPayload =
    body.adminResolution != null || body.adminResolutionNote != null

  const requestShapeCount = [
    hasDecisionPayload,
    hasContentActionPayload,
    hasAdminResolutionPayload,
  ].filter(Boolean).length

  if (requestShapeCount !== 1) {
    return jsonResponse(400, {
      error:
        'Provide exactly one action: decision/reviewNote, '
        + 'contentAction/actionReason, or '
        + 'adminResolution/adminResolutionNote.',
      errorCode: 'invalid_request_shape',
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
      'Admin report action rejected: inactive session.',
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

  if (hasAdminResolutionPayload) {
    if (callerRole !== 'admin') {
      return jsonResponse(403, {
        error: 'Administrator access is required.',
        errorCode: 'admin_required',
      })
    }

    const adminResolution = readAdminResolution(body.adminResolution)
    const adminResolutionNote = readAdminResolutionNote(
      body.adminResolutionNote,
    )

    if (adminResolution == null) {
      return jsonResponse(400, {
        error:
          'Administrator resolution must be no_account_action, '
          + 'account_suspended, logout_forced, or account_deleted.',
        errorCode: 'invalid_admin_resolution',
      })
    }

    if (adminResolutionNote == null) {
      return jsonResponse(400, {
        error:
          `Administrator resolution note must contain between ${minimumReviewNoteLength} and ${maximumReviewNoteLength} characters.`,
        errorCode: 'invalid_admin_resolution_note',
      })
    }

    const { data, error: resolutionError } = await adminClient.rpc(
      'admin_resolve_escalated_report',
      {
        p_report_id: reportId,
        p_actor_user_id: caller.id,
        p_actor_role: callerRole,
        p_resolution: adminResolution,
        p_note: adminResolutionNote,
      },
    )

    if (resolutionError != null) {
      console.error(
        'Administrator escalated report resolution failed.',
        resolutionError,
      )

      const status = mapRpcErrorStatus(resolutionError.code)

      return jsonResponse(status, {
        error:
          status === 400
            ? 'Invalid administrator resolution request.'
            : status === 403
              ? 'Administrator access was rejected.'
              : status === 404
                ? 'Report was not found.'
                : status === 409
                  ? 'The report was already resolved, is no longer pending, '
                    + 'or the required account action has not been completed.'
                  : 'Unable to resolve the escalated report.',
        errorCode:
          status === 409
            ? 'admin_resolution_conflict'
            : status === 404
              ? 'report_not_found'
              : status === 403
                ? 'access_denied'
                : status === 400
                  ? 'invalid_request'
                  : 'server_error',
      })
    }

    const result = readResultObject<AdminResolutionResult>(data)

    if (result == null || result.success !== true) {
      console.error(
        'Administrator resolution returned an invalid result.',
      )

      return jsonResponse(500, {
        error: 'Invalid administrator resolution response.',
        errorCode: 'invalid_response',
      })
    }

    const resultRecord = result as Record<string, unknown>
    const changed = readRequiredBoolean(resultRecord, 'changed')
    const replayed = readRequiredBoolean(resultRecord, 'replayed')
    const resultReportId = readRequiredString(resultRecord, 'reportId')
    const previousStatus = readRequiredString(
      resultRecord,
      'previousStatus',
    )
    const status = readRequiredString(resultRecord, 'status')
    const resolution = readRequiredString(resultRecord, 'resolution')
    const rawAccountActionVerified = readRequiredBoolean(
      resultRecord,
      'accountActionVerified',
    )
    const accountActionVerified = rawAccountActionVerified ??
      (replayed === true ? resolution !== 'no_account_action' : null)
    const resolvedBy = readRequiredString(resultRecord, 'resolvedBy')
    const resolvedAt = readRequiredString(resultRecord, 'resolvedAt')

    if (
      changed == null ||
      replayed == null ||
      resultReportId == null ||
      previousStatus == null ||
      status == null ||
      resolution == null ||
      accountActionVerified == null ||
      resolvedBy == null ||
      resolvedAt == null
    ) {
      console.error(
        'Administrator resolution response is incomplete.',
      )

      return jsonResponse(500, {
        error: 'Invalid administrator resolution response.',
        errorCode: 'invalid_response',
      })
    }

    return jsonResponse(200, {
      success: true,
      adminResolution: {
        changed,
        replayed,
        reportId: resultReportId,
        previousStatus,
        status,
        resolution,
        reportedUserId:
          typeof result.reportedUserId === 'string'
            ? result.reportedUserId
            : null,
        accountActionVerified,
        resolvedBy,
        resolvedAt,
      },
      permissions: {
        role: callerRole,
        canResolveAdminEscalations: true,
      },
    })
  }

  if (hasDecisionPayload) {
    const decision = readDecision(body.decision)
    const reviewNote = readReviewNote(body.reviewNote)

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

      const status = mapRpcErrorStatus(decisionError.code)

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

    const result = readResultObject<ReportDecisionResult>(data)

    if (result == null || result.success !== true) {
      console.error('Admin report decision returned an invalid result.')

      return jsonResponse(500, {
        error: 'Invalid report decision response.',
        errorCode: 'invalid_response',
      })
    }

    const resultRecord = result as Record<string, unknown>
    const resultReportId = readRequiredString(resultRecord, 'reportId')
    const previousStatus = readRequiredString(
      resultRecord,
      'previousStatus',
    )
    const status = readRequiredString(resultRecord, 'status')
    const resultDecision = readRequiredString(resultRecord, 'decision')
    const reviewedBy = readRequiredString(resultRecord, 'reviewedBy')
    const reviewedAt = readRequiredString(resultRecord, 'reviewedAt')

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
  }

  const contentAction = readContentAction(body.contentAction)
  const actionReason = readActionReason(body.actionReason)

  if (contentAction == null) {
    return jsonResponse(400, {
      error: 'Content action must be hide or restore.',
    })
  }

  if (actionReason == null) {
    return jsonResponse(400, {
      error:
        `Action reason must contain between ${minimumActionReasonLength} and ${maximumActionReasonLength} characters.`,
    })
  }

  const { data, error: contentActionError } = await adminClient.rpc(
    'admin_set_report_content_visibility',
    {
      p_report_id: reportId,
      p_actor_user_id: caller.id,
      p_actor_role: callerRole,
      p_action: contentAction,
      p_reason: actionReason,
    },
  )

  if (contentActionError != null) {
    console.error(
      'Admin report content visibility action failed.',
      contentActionError,
    )

    const status = mapRpcErrorStatus(contentActionError.code)

    return jsonResponse(status, {
      error:
        status === 400
          ? 'Invalid content visibility request.'
          : status === 403
            ? 'Staff access was rejected.'
            : status === 404
              ? 'The report or reported content was not found.'
              : status === 409
                ? 'A confirmed violation is required for this action.'
                : 'Unable to change content visibility.',
      errorCode:
        status === 409
          ? 'confirmed_violation_required'
          : status === 404
            ? 'target_not_found'
            : status === 403
              ? 'access_denied'
              : status === 400
                ? 'invalid_request'
                : 'server_error',
    })
  }

  const result = readResultObject<ReportContentActionResult>(data)

  if (result == null || result.success !== true) {
    console.error(
      'Admin report content visibility action returned an invalid result.',
    )

    return jsonResponse(500, {
      error: 'Invalid content visibility response.',
      errorCode: 'invalid_response',
    })
  }

  const resultRecord = result as Record<string, unknown>
  const changed = readRequiredBoolean(resultRecord, 'changed')
  const resultReportId = readRequiredString(resultRecord, 'reportId')
  const previousReportStatus = readRequiredString(
    resultRecord,
    'previousReportStatus',
  )
  const reportStatus = readRequiredString(resultRecord, 'reportStatus')
  const targetType = readRequiredString(resultRecord, 'targetType')
  const targetId = readRequiredString(resultRecord, 'targetId')
  const resultAction = readRequiredString(resultRecord, 'action')
  const previousIsHidden = readRequiredBoolean(
    resultRecord,
    'previousIsHidden',
  )
  const isHidden = readRequiredBoolean(resultRecord, 'isHidden')
  const performedBy = readRequiredString(resultRecord, 'performedBy')
  const performedAt = readRequiredString(resultRecord, 'performedAt')

  if (
    changed == null ||
    resultReportId == null ||
    previousReportStatus == null ||
    reportStatus == null ||
    targetType == null ||
    targetId == null ||
    resultAction == null ||
    previousIsHidden == null ||
    isHidden == null ||
    performedBy == null ||
    performedAt == null
  ) {
    console.error(
      'Admin report content visibility response is incomplete.',
    )

    return jsonResponse(500, {
      error: 'Invalid content visibility response.',
      errorCode: 'invalid_response',
    })
  }

  return jsonResponse(200, {
    success: true,
    contentAction: {
      changed,
      reportId: resultReportId,
      previousReportStatus,
      reportStatus,
      targetType,
      targetId,
      action: resultAction,
      previousIsHidden,
      isHidden,
      performedBy,
      performedAt,
    },
    permissions: {
      role: callerRole,
    },
  })
})
