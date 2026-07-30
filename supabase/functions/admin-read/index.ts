import { createClient } from 'npm:@supabase/supabase-js@2'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!

type StaffRole = 'moderator' | 'admin'
type ReadOperation = 'dashboard' | 'user_detail' | 'audit'
type AuditResult = 'success' | 'failure' | 'denied' | 'noop'

type AuditFilters = {
  actorUserId?: unknown
  action?: unknown
  targetId?: unknown
  result?: unknown
  from?: unknown
  to?: unknown
}

type RequestBody = {
  operation?: unknown
  targetUserId?: unknown
  filters?: unknown
  limit?: unknown
  offset?: unknown
}

type DashboardRow = {
  pending_verification_requests: number | string
  open_reports: number | string
  suspended_accounts: number | string
  total_users: number | string
  staff_users: number | string
}

type UserDetailRow = {
  user_id: string
  email: string | null
  email_confirmed_at: string | null
  last_sign_in_at: string | null
  display_name: string | null
  username: string | null
  avatar_url: string | null
  system_role: string
  mirror_role: string
  role_synchronized: boolean
  actor_type: string
  verification_level: string
  verification_status: string
  account_status: string
  suspended_until: string | null
  created_at: string
}

type AuditRow = {
  id: string
  actor_user_id: string
  actor_role: string
  action: string
  target_type: string
  target_id: string | null
  previous_value: Record<string, unknown>
  new_value: Record<string, unknown>
  reason: string
  result: string
  error_code: string | null
  created_at: string
}

const allowedReadOperations = new Set<ReadOperation>([
  'dashboard',
  'user_detail',
  'audit',
])

const allowedAuditResults = new Set<AuditResult>([
  'success',
  'failure',
  'denied',
  'noop',
])

const maximumActionLength = 80
const maximumTargetIdLength = 320
const maximumAuditLimit = 100
const maximumAuditOffset = 1000000

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

function readStaffRole(value: unknown): StaffRole | null {
  if (typeof value !== 'string') {
    return null
  }

  const normalized = value.trim().toLowerCase()

  return normalized === 'moderator' || normalized === 'admin'
    ? normalized
    : null
}

function readOperation(value: unknown): ReadOperation | null {
  if (typeof value !== 'string') {
    return null
  }

  const normalized = value.trim().toLowerCase()

  return allowedReadOperations.has(normalized as ReadOperation)
    ? (normalized as ReadOperation)
    : null
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

function readOptionalUuid(
  value: unknown,
): string | null | undefined {
  if (value == null) {
    return null
  }

  return readUuid(value) ?? undefined
}

function readOptionalAction(
  value: unknown,
): string | null | undefined {
  if (value == null) {
    return null
  }

  if (typeof value !== 'string') {
    return undefined
  }

  const normalized = value.trim().toLowerCase()

  if (normalized.length === 0) {
    return null
  }

  if (
    normalized.length > maximumActionLength ||
    !/^[a-z0-9_]+$/.test(normalized)
  ) {
    return undefined
  }

  return normalized
}

function readOptionalTargetId(
  value: unknown,
): string | null | undefined {
  if (value == null) {
    return null
  }

  if (typeof value !== 'string') {
    return undefined
  }

  const normalized = value.trim()

  if (normalized.length === 0) {
    return null
  }

  return normalized.length <= maximumTargetIdLength
    ? normalized
    : undefined
}

function readOptionalAuditResult(
  value: unknown,
): AuditResult | null | undefined {
  if (value == null) {
    return null
  }

  if (typeof value !== 'string') {
    return undefined
  }

  const normalized = value.trim().toLowerCase()

  if (normalized.length === 0) {
    return null
  }

  return allowedAuditResults.has(normalized as AuditResult)
    ? (normalized as AuditResult)
    : undefined
}

function readOptionalTimestamp(
  value: unknown,
): string | null | undefined {
  if (value == null) {
    return null
  }

  if (typeof value !== 'string') {
    return undefined
  }

  const normalized = value.trim()

  if (normalized.length === 0) {
    return null
  }

  const timestamp = Date.parse(normalized)

  return Number.isFinite(timestamp)
    ? new Date(timestamp).toISOString()
    : undefined
}

function readInteger(
  value: unknown,
  fallback: number,
  minimum: number,
  maximum: number,
): number | null {
  if (value == null) {
    return fallback
  }

  if (
    typeof value !== 'number' ||
    !Number.isInteger(value) ||
    value < minimum ||
    value > maximum
  ) {
    return null
  }

  return value
}

function readFilters(value: unknown): AuditFilters | null {
  if (value == null) {
    return {}
  }

  if (typeof value !== 'object' || Array.isArray(value)) {
    return null
  }

  return value as AuditFilters
}

function readCount(value: unknown): number | null {
  const count = typeof value === 'number' ? value : Number(value)

  return Number.isSafeInteger(count) && count >= 0 ? count : null
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
  const operation = readOperation(body.operation)

  if (operation == null) {
    return jsonResponse(400, {
      error: 'Operation must be dashboard, user_detail, or audit.',
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
    console.error('Admin read rejected: inactive session.')

    return jsonResponse(401, {
      error: 'Session is no longer active.',
    })
  }

  const callerRole = readStaffRole(caller.app_metadata?.role)

  if (callerRole == null) {
    return jsonResponse(403, {
      error: 'Staff access is required.',
    })
  }

  if (operation !== 'dashboard' && callerRole !== 'admin') {
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

  if (operation === 'dashboard') {
    const { data, error } = await adminClient.rpc(
      'admin_get_dashboard_summary',
    )

    if (error != null) {
      console.error('Unable to load the Admin Center dashboard.', error)

      return jsonResponse(500, {
        error: 'Unable to load the Admin Center dashboard.',
      })
    }

    const row = Array.isArray(data)
      ? (data[0] as DashboardRow | undefined)
      : undefined

    const pendingVerificationRequests = readCount(
      row?.pending_verification_requests,
    )
    const openReports = readCount(row?.open_reports)
    const suspendedAccounts = readCount(row?.suspended_accounts)
    const totalUsers = readCount(row?.total_users)
    const staffUsers = readCount(row?.staff_users)

    if (
      pendingVerificationRequests == null ||
      openReports == null ||
      suspendedAccounts == null ||
      totalUsers == null ||
      staffUsers == null ||
      staffUsers > totalUsers
    ) {
      console.error('Invalid Admin Center dashboard response.')

      return jsonResponse(500, {
        error: 'Invalid Admin Center dashboard response.',
      })
    }

    return jsonResponse(200, {
      success: true,
      summary: {
        pendingVerificationRequests,
        openReports,
        suspendedAccounts,
        totalUsers,
        staffUsers,
      },
      permissions: {
        role: callerRole,
      },
    })
  }

  if (operation === 'user_detail') {
    const targetUserId = readUuid(body.targetUserId)

    if (targetUserId == null) {
      return jsonResponse(400, {
        error: 'A valid target user ID is required.',
      })
    }

    const { data, error } = await adminClient.rpc(
      'admin_get_user_detail',
      {
        p_user_id: targetUserId,
      },
    )

    if (error != null) {
      console.error('Unable to load the administrator user detail.', error)

      return jsonResponse(500, {
        error: 'Unable to load the user detail.',
      })
    }

    const row = Array.isArray(data)
      ? (data[0] as UserDetailRow | undefined)
      : undefined

    if (row == null || row.user_id !== targetUserId) {
      return jsonResponse(404, {
        error: 'Target user was not found.',
      })
    }

    return jsonResponse(200, {
      success: true,
      user: {
        userId: row.user_id,
        email: row.email,
        emailConfirmedAt: row.email_confirmed_at,
        lastSignInAt: row.last_sign_in_at,
        displayName: row.display_name,
        username: row.username,
        avatarUrl: row.avatar_url,
        systemRole: row.system_role,
        mirrorRole: row.mirror_role,
        roleSynchronized: row.role_synchronized,
        actorType: row.actor_type,
        verificationLevel: row.verification_level,
        verificationStatus: row.verification_status,
        accountStatus: row.account_status,
        suspendedUntil: row.suspended_until,
        createdAt: row.created_at,
      },
      permissions: {
        role: callerRole,
        canViewEmail: true,
      },
    })
  }

  const filters = readFilters(body.filters)

  if (filters == null) {
    return jsonResponse(400, {
      error: 'Audit filters must be an object.',
    })
  }

  const actorUserId = readOptionalUuid(filters.actorUserId)
  const auditAction = readOptionalAction(filters.action)
  const targetId = readOptionalTargetId(filters.targetId)
  const auditResult = readOptionalAuditResult(filters.result)
  const from = readOptionalTimestamp(filters.from)
  const to = readOptionalTimestamp(filters.to)
  const limit = readInteger(
    body.limit,
    50,
    1,
    maximumAuditLimit,
  )
  const offset = readInteger(
    body.offset,
    0,
    0,
    maximumAuditOffset,
  )

  if (actorUserId === undefined) {
    return jsonResponse(400, {
      error: 'Audit actor user ID must be a valid UUID.',
    })
  }

  if (auditAction === undefined) {
    return jsonResponse(400, {
      error:
        `Audit action must use snake_case and contain at most ${maximumActionLength} characters.`,
    })
  }

  if (targetId === undefined) {
    return jsonResponse(400, {
      error:
        `Audit target ID must contain at most ${maximumTargetIdLength} characters.`,
    })
  }

  if (auditResult === undefined) {
    return jsonResponse(400, {
      error: 'Audit result must be success, failure, denied, or noop.',
    })
  }

  if (from === undefined || to === undefined) {
    return jsonResponse(400, {
      error: 'Audit date filters must be valid timestamps.',
    })
  }

  if (from != null && to != null && Date.parse(from) > Date.parse(to)) {
    return jsonResponse(400, {
      error: 'Audit date range is inverted.',
    })
  }

  if (limit == null) {
    return jsonResponse(400, {
      error: `Audit limit must be between 1 and ${maximumAuditLimit}.`,
    })
  }

  if (offset == null) {
    return jsonResponse(400, {
      error: `Audit offset must be between 0 and ${maximumAuditOffset}.`,
    })
  }

  const { data, error } = await adminClient.rpc(
    'admin_get_audit_entries',
    {
      p_actor_user_id: actorUserId,
      p_action: auditAction,
      p_target_id: targetId,
      p_result: auditResult,
      p_from: from,
      p_to: to,
      p_limit: limit,
      p_offset: offset,
    },
  )

  if (error != null) {
    console.error('Unable to load the administrator audit log.', error)

    return jsonResponse(500, {
      error: 'Unable to load the administrator audit log.',
    })
  }

  const rows = Array.isArray(data) ? (data as AuditRow[]) : []

  return jsonResponse(200, {
    success: true,
    entries: rows.map((row) => ({
      id: row.id,
      actorUserId: row.actor_user_id,
      actorRole: row.actor_role,
      action: row.action,
      targetType: row.target_type,
      targetId: row.target_id,
      previousValue: row.previous_value,
      newValue: row.new_value,
      reason: row.reason,
      result: row.result,
      errorCode: row.error_code,
      createdAt: row.created_at,
    })),
    pagination: {
      limit,
      offset,
      returnedCount: rows.length,
      hasMore: rows.length === limit,
    },
    permissions: {
      role: callerRole,
    },
  })
})
