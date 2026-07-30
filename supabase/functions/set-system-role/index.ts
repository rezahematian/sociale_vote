import { createClient } from 'npm:@supabase/supabase-js@2'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!

type SystemRole = 'user' | 'moderator' | 'admin'

type RequestBody = {
  operationId?: unknown
  targetUserId?: unknown
  role?: unknown
  reason?: unknown
}

type RoleChangeResult = {
  success?: unknown
  allowed?: unknown
  replayed?: unknown
  operationStatus?: unknown
  result?: unknown
  errorCode?: unknown
  previousAuthRole?: unknown
  previousMirrorRole?: unknown
  requestedRole?: unknown
  changed?: unknown
  authRoleUpdated?: unknown
  mirrorRoleUpdated?: unknown
  sessionsRevoked?: unknown
  revokedSessionCount?: unknown
  rollbackSucceeded?: unknown
  requestAuditRecorded?: unknown
  completionAuditRecorded?: unknown
  auditRecorded?: unknown
  requiresRollback?: unknown
}

const allowedRoles = new Set<SystemRole>(['user', 'moderator', 'admin'])

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

function readSystemRole(value: unknown): SystemRole | null {
  if (typeof value !== 'string') {
    return null
  }

  const normalized = value.trim().toLowerCase()

  return allowedRoles.has(normalized as SystemRole)
    ? (normalized as SystemRole)
    : null
}

function normalizeSystemRole(value: unknown): SystemRole {
  return readSystemRole(value) ?? 'user'
}

function readReason(value: unknown): string | null {
  if (typeof value !== 'string') {
    return null
  }

  const reason = value.trim()

  return reason.length > 0 && reason.length <= 1000 ? reason : null
}

function readResultObject(value: unknown): RoleChangeResult | null {
  if (
    value == null ||
    typeof value !== 'object' ||
    Array.isArray(value)
  ) {
    return null
  }

  return value as RoleChangeResult
}

function readRevokedSessionCount(value: unknown): number {
  if (typeof value === 'number' && Number.isInteger(value) && value >= 0) {
    return value
  }

  if (
    typeof value === 'string' &&
    /^[0-9]+$/.test(value) &&
    Number.isSafeInteger(Number(value))
  ) {
    return Number(value)
  }

  return 0
}

function statusForRejectedChange(errorCode: unknown): number {
  switch (errorCode) {
    case 'self_role_change_not_allowed':
      return 400
    case 'target_user_not_found':
      return 404
    case 'target_role_change_in_progress':
    case 'target_mirror_missing':
    case 'target_role_not_synchronized':
      return 409
    default:
      return 500
  }
}

function statusForRpcError(code: string | undefined): number {
  switch (code) {
    case '22004':
    case '22023':
      return 400
    case '42501':
      return 403
    case 'P0002':
      return 404
    case '23505':
      return 409
    default:
      return 500
  }
}

function roleChangeResponse({
  operationId,
  targetUserId,
  targetRole,
  result,
}: {
  operationId: string
  targetUserId: string
  targetRole: SystemRole
  result: RoleChangeResult
}): Record<string, unknown> {
  const operationStatus =
    typeof result.operationStatus === 'string'
      ? result.operationStatus
      : null
  const changed = result.changed === true
  const requestAuditRecorded = result.requestAuditRecorded === true
  const completionAuditRecorded =
    result.completionAuditRecorded === true || result.auditRecorded === true
  const auditRecorded =
    completionAuditRecorded ||
    (
      requestAuditRecorded &&
      operationStatus === 'started'
    )

  return {
    success: result.success === true,
    operationId,
    targetUserId,
    role: targetRole,
    previousAuthRole:
      typeof result.previousAuthRole === 'string'
        ? result.previousAuthRole
        : null,
    previousMirrorRole:
      typeof result.previousMirrorRole === 'string'
        ? result.previousMirrorRole
        : null,
    changed,
    replayed: result.replayed === true,
    operationStatus,
    result: typeof result.result === 'string' ? result.result : null,
    errorCode:
      typeof result.errorCode === 'string' ? result.errorCode : null,
    requiresReauthentication:
      result.success === true && changed,
    authRoleUpdated: result.authRoleUpdated === true,
    mirrorRoleUpdated: result.mirrorRoleUpdated === true,
    sessionsRevoked: result.sessionsRevoked === true,
    revokedSessionCount: readRevokedSessionCount(
      result.revokedSessionCount,
    ),
    rollbackSucceeded:
      typeof result.rollbackSucceeded === 'boolean'
        ? result.rollbackSucceeded
        : null,
    auditRecorded,
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
  const targetRole = readSystemRole(body.role)
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

  if (targetRole == null) {
    return jsonResponse(400, {
      error: 'Role must be user, moderator, or admin.',
    })
  }

  if (reason == null) {
    return jsonResponse(400, {
      error: 'A reason between 1 and 1000 characters is required.',
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
      'System role update rejected: inactive session.',
      activeSessionError,
    )

    return jsonResponse(401, {
      error: 'Session is no longer active.',
    })
  }

  if (readSystemRole(caller.app_metadata?.role) !== 'admin') {
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
      operationId,
    })
  }

  if (readSystemRole(callerMirror?.role) !== 'admin') {
    return jsonResponse(403, {
      error: 'Administrator role is not synchronized.',
      operationId,
    })
  }

  const { data: beginData, error: beginError } = await adminClient.rpc(
    'admin_begin_system_role_change',
    {
      p_operation_id: operationId,
      p_actor_user_id: caller.id,
      p_target_user_id: targetUserId,
      p_requested_role: targetRole,
      p_reason: reason,
    },
  )

  if (beginError != null) {
    console.error('Unable to begin system role change.', beginError)

    const status = statusForRpcError(beginError.code)

    return jsonResponse(status, {
      error:
        status === 409
          ? 'Operation ID has already been used for another action.'
          : status === 400
            ? 'Invalid system role change request.'
            : status === 403
              ? 'Administrator access was rejected.'
              : status === 404
                ? 'Administrator account was not found.'
                : 'Unable to begin the system role change.',
      operationId,
    })
  }

  const beginResult = readResultObject(beginData)

  if (
    beginResult == null ||
    typeof beginResult.success !== 'boolean' ||
    typeof beginResult.allowed !== 'boolean' ||
    typeof beginResult.operationStatus !== 'string'
  ) {
    console.error('System role change returned an invalid start result.')

    return jsonResponse(500, {
      error: 'Invalid system role change response.',
      operationId,
      retryable: true,
    })
  }

  const beginResponse = roleChangeResponse({
    operationId,
    targetUserId,
    targetRole,
    result: beginResult,
  })

  if (beginResult.operationStatus === 'completed') {
    return jsonResponse(200, beginResponse)
  }

  if (!beginResult.success || !beginResult.allowed) {
    return jsonResponse(
      statusForRejectedChange(beginResult.errorCode),
      beginResponse,
    )
  }

  if (beginResult.operationStatus !== 'started') {
    console.error('System role change returned an unknown operation status.')

    return jsonResponse(500, {
      error: 'Invalid system role change state.',
      operationId,
      retryable: true,
    })
  }

  const previousAuthRole = readSystemRole(beginResult.previousAuthRole)
  const previousMirrorRole = readSystemRole(beginResult.previousMirrorRole)

  if (
    previousAuthRole == null ||
    previousMirrorRole == null ||
    previousAuthRole !== previousMirrorRole
  ) {
    console.error(
      'System role change returned invalid previous role state.',
    )

    return jsonResponse(500, {
      error: 'Invalid previous role state.',
      operationId,
      retryable: true,
    })
  }

  const finishRoleChange = async ({
    outcome,
    errorCode,
    authRoleUpdated,
    mirrorRoleUpdated,
    sessionsRevoked,
    revokedSessionCount,
    rollbackSucceeded,
  }: {
    outcome: 'completed' | 'failed'
    errorCode: string | null
    authRoleUpdated: boolean
    mirrorRoleUpdated: boolean
    sessionsRevoked: boolean
    revokedSessionCount: number
    rollbackSucceeded: boolean | null
  }) => {
    const { data, error } = await adminClient.rpc(
      'admin_finish_system_role_change',
      {
        p_operation_id: operationId,
        p_actor_user_id: caller.id,
        p_target_user_id: targetUserId,
        p_requested_role: targetRole,
        p_outcome: outcome,
        p_error_code: errorCode,
        p_auth_role_updated: authRoleUpdated,
        p_mirror_role_updated: mirrorRoleUpdated,
        p_sessions_revoked: sessionsRevoked,
        p_revoked_session_count: revokedSessionCount,
        p_rollback_succeeded: rollbackSucceeded,
      },
    )

    return {
      data: readResultObject(data),
      error,
    }
  }

  const rollbackRoleChange = async (): Promise<boolean> => {
    const {
      data: { user: currentTargetUser },
      error: currentTargetError,
    } = await adminClient.auth.admin.getUserById(targetUserId)

    if (currentTargetError != null || currentTargetUser == null) {
      console.error(
        'Unable to load target Auth role for rollback.',
        currentTargetError,
      )
      return false
    }

    const currentAppMetadata = currentTargetUser.app_metadata ?? {}
    const { error: authRollbackError } =
      await adminClient.auth.admin.updateUserById(targetUserId, {
        app_metadata: {
          ...currentAppMetadata,
          role: previousAuthRole,
        },
      })

    if (authRollbackError != null) {
      console.error(
        'Unable to roll back target Auth role.',
        authRollbackError,
      )
    }

    const { data: mirrorRollback, error: mirrorRollbackError } =
      await adminClient
        .from('users')
        .update({
          role: previousMirrorRole,
        })
        .eq('id', targetUserId)
        .select('role')
        .maybeSingle()

    if (mirrorRollbackError != null || mirrorRollback == null) {
      console.error(
        'Unable to roll back target mirror role.',
        mirrorRollbackError,
      )
    }

    if (
      authRollbackError != null ||
      mirrorRollbackError != null ||
      mirrorRollback == null
    ) {
      return false
    }

    const {
      data: { user: verifiedTargetUser },
      error: verifiedTargetError,
    } = await adminClient.auth.admin.getUserById(targetUserId)

    const { data: verifiedMirror, error: verifiedMirrorError } =
      await adminClient
        .from('users')
        .select('role')
        .eq('id', targetUserId)
        .maybeSingle()

    if (
      verifiedTargetError != null ||
      verifiedTargetUser == null ||
      verifiedMirrorError != null ||
      verifiedMirror == null
    ) {
      console.error(
        'Unable to verify target role rollback.',
        verifiedTargetError,
        verifiedMirrorError,
      )
      return false
    }

    return (
      normalizeSystemRole(verifiedTargetUser.app_metadata?.role) ===
        previousAuthRole &&
      normalizeSystemRole(verifiedMirror.role) === previousMirrorRole
    )
  }

  let authRoleUpdated = false
  let mirrorRoleUpdated = false
  let sessionsRevoked = false
  let revokedSessionCount = 0

  const finalizeFailure = async ({
    errorCode,
    needsRollback,
  }: {
    errorCode: string
    needsRollback: boolean
  }): Promise<Response> => {
    let rollbackSucceeded: boolean | null = null

    if (needsRollback) {
      rollbackSucceeded = await rollbackRoleChange()

      if (!rollbackSucceeded) {
        return jsonResponse(500, {
          error: 'Role update rollback could not be completed.',
          success: false,
          operationId,
          operationStatus: 'started',
          errorCode,
          authRoleUpdated,
          mirrorRoleUpdated,
          sessionsRevoked,
          revokedSessionCount,
          rollbackSucceeded: false,
          retryable: true,
        })
      }
    }

    const finalization = await finishRoleChange({
      outcome: 'failed',
      errorCode,
      authRoleUpdated,
      mirrorRoleUpdated,
      sessionsRevoked,
      revokedSessionCount,
      rollbackSucceeded,
    })

    if (finalization.error != null || finalization.data == null) {
      console.error(
        'Unable to finalize failed system role change.',
        finalization.error,
      )

      return jsonResponse(500, {
        error: 'System role change could not be finalized.',
        operationId,
        retryable: true,
      })
    }

    return jsonResponse(
      statusForRejectedChange(finalization.data.errorCode),
      roleChangeResponse({
        operationId,
        targetUserId,
        targetRole,
        result: finalization.data,
      }),
    )
  }

  const {
    data: { user: targetUser },
    error: targetUserError,
  } = await adminClient.auth.admin.getUserById(targetUserId)

  if (targetUserError != null || targetUser == null) {
    console.error(
      'Unable to revalidate target Auth role.',
      targetUserError,
    )

    return await finalizeFailure({
      errorCode: 'target_revalidation_failed',
      needsRollback: false,
    })
  }

  const { data: targetMirror, error: targetMirrorError } = await adminClient
    .from('users')
    .select('role')
    .eq('id', targetUserId)
    .maybeSingle()

  if (targetMirrorError != null || targetMirror == null) {
    console.error(
      'Unable to revalidate target mirror role.',
      targetMirrorError,
    )

    return await finalizeFailure({
      errorCode: 'target_revalidation_failed',
      needsRollback: false,
    })
  }

  const currentAuthRole = normalizeSystemRole(
    targetUser.app_metadata?.role,
  )
  const currentMirrorRole = normalizeSystemRole(targetMirror.role)

  if (
    ![previousAuthRole, targetRole].includes(currentAuthRole) ||
    ![previousMirrorRole, targetRole].includes(currentMirrorRole)
  ) {
    console.error('Target role changed outside the reserved operation.')

    return await finalizeFailure({
      errorCode: 'target_role_state_changed',
      needsRollback: false,
    })
  }

  authRoleUpdated = currentAuthRole === targetRole
  mirrorRoleUpdated = currentMirrorRole === targetRole

  if (!authRoleUpdated) {
    const { error: authUpdateError } =
      await adminClient.auth.admin.updateUserById(targetUserId, {
        app_metadata: {
          ...(targetUser.app_metadata ?? {}),
          role: targetRole,
        },
      })

    if (authUpdateError != null) {
      console.error(
        'Unable to update target Auth system role.',
        authUpdateError,
      )

      return await finalizeFailure({
        errorCode: 'auth_role_update_failed',
        needsRollback: false,
      })
    }

    authRoleUpdated = true
  }

  if (!mirrorRoleUpdated) {
    const { data: updatedMirror, error: mirrorUpdateError } =
      await adminClient
        .from('users')
        .update({
          role: targetRole,
        })
        .eq('id', targetUserId)
        .select('id')
        .maybeSingle()

    if (mirrorUpdateError != null || updatedMirror == null) {
      console.error(
        'Unable to update target mirror role.',
        mirrorUpdateError,
      )

      return await finalizeFailure({
        errorCode: 'mirror_role_update_failed',
        needsRollback: authRoleUpdated,
      })
    }

    mirrorRoleUpdated = true
  }

  const { data: revokedSessions, error: sessionRevocationError } =
    await adminClient.rpc('admin_revoke_user_sessions', {
      p_target_user_id: targetUserId,
    })

  if (sessionRevocationError != null) {
    console.error(
      'Unable to revoke target user sessions.',
      sessionRevocationError,
    )

    return await finalizeFailure({
      errorCode: 'session_revocation_failed',
      needsRollback: authRoleUpdated || mirrorRoleUpdated,
    })
  }

  sessionsRevoked = true
  revokedSessionCount = readRevokedSessionCount(revokedSessions)

  const finalization = await finishRoleChange({
    outcome: 'completed',
    errorCode: null,
    authRoleUpdated,
    mirrorRoleUpdated,
    sessionsRevoked,
    revokedSessionCount,
    rollbackSucceeded: null,
  })

  if (finalization.error != null || finalization.data == null) {
    console.error(
      'Unable to finalize completed system role change.',
      finalization.error,
    )

    return jsonResponse(500, {
      error: 'System role change could not be finalized.',
      operationId,
      retryable: true,
    })
  }

  if (finalization.data.requiresRollback === true) {
    return await finalizeFailure({
      errorCode: 'role_change_state_not_confirmed',
      needsRollback: true,
    })
  }

  if (
    finalization.data.success !== true ||
    finalization.data.operationStatus !== 'completed'
  ) {
    console.error('System role change returned an invalid final state.')

    return jsonResponse(500, {
      error: 'Invalid final system role change state.',
      operationId,
      retryable: true,
    })
  }

  console.info('System role updated.', {
    actorUserId: caller.id,
    targetUserId,
    operationId,
    previousAuthRole,
    previousMirrorRole,
    role: targetRole,
    revokedSessionCount,
    replayed: beginResult.replayed === true,
  })

  return jsonResponse(
    200,
    roleChangeResponse({
      operationId,
      targetUserId,
      targetRole,
      result: finalization.data,
    }),
  )
})
