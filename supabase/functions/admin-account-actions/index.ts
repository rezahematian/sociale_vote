import { createClient } from 'npm:@supabase/supabase-js@2'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!

type AccountAction = 'suspend' | 'reactivate' | 'force_logout'

type RequestBody = {
  operationId?: unknown
  targetUserId?: unknown
  action?: unknown
  reason?: unknown
  suspendedUntil?: unknown
}

type AccountActionResult = {
  success?: unknown
  replayed?: unknown
  changed?: unknown
  result?: unknown
  errorCode?: unknown
  accountStatus?: unknown
  suspendedUntil?: unknown
  revokedSessionCount?: unknown
  auditRecorded?: unknown
}

const allowedActions = new Set<AccountAction>([
  'suspend',
  'reactivate',
  'force_logout',
])

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

function readAccountAction(value: unknown): AccountAction | null {
  if (typeof value !== 'string') {
    return null
  }

  const normalized = value.trim().toLowerCase()

  return allowedActions.has(normalized as AccountAction)
    ? (normalized as AccountAction)
    : null
}

function readReason(value: unknown): string | null {
  if (typeof value !== 'string') {
    return null
  }

  const reason = value.trim()

  return reason.length > 0 && reason.length <= 1000 ? reason : null
}

function readSuspendedUntil(
  value: unknown,
  action: AccountAction,
): string | null | undefined {
  if (action !== 'suspend') {
    return value == null ? null : undefined
  }

  if (typeof value !== 'string') {
    return undefined
  }

  const timestamp = Date.parse(value)

  if (!Number.isFinite(timestamp) || timestamp <= Date.now()) {
    return undefined
  }

  return new Date(timestamp).toISOString()
}

function readResultObject(value: unknown): AccountActionResult | null {
  if (
    value == null ||
    typeof value !== 'object' ||
    Array.isArray(value)
  ) {
    return null
  }

  return value as AccountActionResult
}

function statusForRejectedAction(errorCode: unknown): number {
  switch (errorCode) {
    case 'self_account_action_not_allowed':
      return 400
    case 'target_user_not_found':
      return 404
    case 'target_admin_action_not_allowed':
      return 403
    case 'target_mirror_missing':
    case 'target_role_not_synchronized':
    case 'target_account_deleted':
      return 409
    default:
      return 400
  }
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
  const operationId = readUuid(body.operationId)
  const targetUserId = readUuid(body.targetUserId)
  const action = readAccountAction(body.action)
  const reason = readReason(body.reason)

  if (operationId == null) {
    return jsonResponse(400, {
      error: 'A valid operation ID is required.',
    })
  }

  if (targetUserId == null) {
    return jsonResponse(400, {
      error: 'A valid target user ID is required.',
    })
  }

  if (action == null) {
    return jsonResponse(400, {
      error: 'Action must be suspend, reactivate, or force_logout.',
    })
  }

  if (reason == null) {
    return jsonResponse(400, {
      error: 'A reason between 1 and 1000 characters is required.',
    })
  }

  const suspendedUntil = readSuspendedUntil(body.suspendedUntil, action)

  if (suspendedUntil === undefined) {
    return jsonResponse(400, {
      error:
        action === 'suspend'
          ? 'A valid future suspension end time is required.'
          : 'Suspension end time is valid only for suspend.',
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
      'Admin account action rejected: inactive session.',
      activeSessionError,
    )

    return jsonResponse(401, {
      error: 'Session is no longer active.',
    })
  }

  if (caller.app_metadata?.role !== 'admin') {
    return jsonResponse(403, {
      error: 'Administrator access is required.',
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
      'Unable to verify administrator mirror role.',
      callerMirrorError,
    )

    return jsonResponse(500, {
      error: 'Unable to verify administrator access.',
    })
  }

  if (callerMirror?.role !== 'admin') {
    return jsonResponse(403, {
      error: 'Administrator role is not synchronized.',
    })
  }

  const { data, error: actionError } = await adminClient.rpc(
    'admin_apply_account_action',
    {
      p_operation_id: operationId,
      p_actor_user_id: caller.id,
      p_target_user_id: targetUserId,
      p_action: action,
      p_reason: reason,
      p_suspended_until: suspendedUntil,
    },
  )

  if (actionError != null) {
    console.error('Admin account action failed.', actionError)

    const status =
      actionError.code === '23505'
        ? 409
        : actionError.code === '22004' || actionError.code === '22023'
          ? 400
          : actionError.code === '42501'
            ? 403
            : 500

    return jsonResponse(status, {
      error:
        status === 409
          ? 'Operation ID has already been used for another action.'
          : status === 400
            ? 'Invalid account action request.'
            : status === 403
              ? 'Administrator access was rejected.'
              : 'Unable to apply the account action.',
    })
  }

  const result = readResultObject(data)

  if (result == null || typeof result.success !== 'boolean') {
    console.error('Admin account action returned an invalid result.')

    return jsonResponse(500, {
      error: 'Invalid account action response.',
    })
  }

  const response = {
    success: result.success,
    operationId,
    replayed: result.replayed === true,
    changed: result.changed === true,
    result:
      typeof result.result === 'string' ? result.result : null,
    errorCode:
      typeof result.errorCode === 'string' ? result.errorCode : null,
    accountStatus:
      typeof result.accountStatus === 'string'
        ? result.accountStatus
        : null,
    suspendedUntil:
      typeof result.suspendedUntil === 'string'
        ? result.suspendedUntil
        : null,
    revokedSessionCount:
      typeof result.revokedSessionCount === 'number'
        ? result.revokedSessionCount
        : Number(result.revokedSessionCount) || 0,
    auditRecorded: result.auditRecorded === true,
  }

  if (!result.success) {
    return jsonResponse(
      statusForRejectedAction(result.errorCode),
      response,
    )
  }

  return jsonResponse(200, response)
})
