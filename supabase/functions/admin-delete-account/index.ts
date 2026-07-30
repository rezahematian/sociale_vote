import { createClient } from 'npm:@supabase/supabase-js@2'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!

type SystemRole = 'user' | 'moderator' | 'admin'

type RequestBody = {
  operationId?: unknown
  targetUserId?: unknown
  reason?: unknown
  confirmation?: unknown
  accountIdentifier?: unknown
}

type DeletionResult = {
  success?: unknown
  allowed?: unknown
  replayed?: unknown
  operationStatus?: unknown
  errorCode?: unknown
  avatarCleanupCompleted?: unknown
  authUserDeleted?: unknown
  requestAuditRecorded?: unknown
  completionAuditRecorded?: unknown
  auditRecorded?: unknown
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

  return /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/.test(
    normalized,
  )
    ? normalized
    : null
}

function readReason(value: unknown): string | null {
  if (typeof value !== 'string') {
    return null
  }

  const reason = value.trim()

  return reason.length > 0 && reason.length <= 1000 ? reason : null
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

function readResultObject(value: unknown): DeletionResult | null {
  if (
    value == null ||
    typeof value !== 'object' ||
    Array.isArray(value)
  ) {
    return null
  }

  return value as DeletionResult
}

function statusForDeletionError(errorCode: unknown): number {
  switch (errorCode) {
    case 'self_account_deletion_not_allowed':
      return 400
    case 'target_user_not_found':
      return 404
    case 'target_admin_deletion_not_allowed':
      return 403
    case 'target_deletion_in_progress':
    case 'target_mirror_missing':
    case 'target_role_not_synchronized':
    case 'target_account_state_missing':
    case 'target_account_already_deleted':
      return 409
    default:
      return 500
  }
}

function isAuthUserNotFound(error: unknown): boolean {
  if (error == null || typeof error !== 'object') {
    return false
  }

  const candidate = error as {
    status?: unknown
    code?: unknown
    message?: unknown
  }

  if (candidate.status === 404 || candidate.code === 'user_not_found') {
    return true
  }

  return (
    typeof candidate.message === 'string' &&
    candidate.message.toLowerCase().includes('user not found')
  )
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
  const reason = readReason(body.reason)
  const confirmation =
    typeof body.confirmation === 'string' ? body.confirmation : ''
  const accountIdentifier =
    typeof body.accountIdentifier === 'string'
      ? body.accountIdentifier.trim().toLowerCase()
      : ''

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

  if (reason == null) {
    return jsonResponse(400, {
      error: 'A reason between 1 and 1000 characters is required.',
    })
  }

  if (confirmation !== 'DELETE') {
    return jsonResponse(400, {
      error: 'The DELETE confirmation is required.',
    })
  }

  if (accountIdentifier !== targetUserId) {
    return jsonResponse(400, {
      error: 'The account identifier does not match the target user.',
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
      'Administrative account deletion rejected: inactive session.',
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
    })
  }

  if (readSystemRole(callerMirror?.role) !== 'admin') {
    return jsonResponse(403, {
      error: 'Administrator role is not synchronized.',
    })
  }

  const { data: beginData, error: beginError } = await adminClient.rpc(
    'admin_begin_account_deletion',
    {
      p_operation_id: operationId,
      p_actor_user_id: caller.id,
      p_target_user_id: targetUserId,
      p_reason: reason,
      p_confirmation: confirmation,
      p_account_identifier: accountIdentifier,
    },
  )

  if (beginError != null) {
    console.error(
      'Unable to begin administrative account deletion.',
      beginError,
    )

    const status =
      beginError.code === '23505'
        ? 409
        : beginError.code === '22004' || beginError.code === '22023'
          ? 400
          : beginError.code === '42501'
            ? 403
            : beginError.code === 'P0002'
              ? 404
              : 500

    return jsonResponse(status, {
      error:
        status === 409
          ? 'Operation ID has already been used for another action.'
          : status === 400
            ? 'Invalid account deletion request.'
            : status === 403
              ? 'Administrator access was rejected.'
              : status === 404
                ? 'Administrator account was not found.'
                : 'Unable to begin account deletion.',
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
    console.error(
      'Administrative account deletion returned an invalid start result.',
    )

    return jsonResponse(500, {
      error: 'Invalid account deletion response.',
      operationId,
    })
  }

  const replayResponse = {
    success: beginResult.success,
    operationId,
    deletedUserId:
      beginResult.operationStatus === 'completed' ? targetUserId : null,
    replayed: beginResult.replayed === true,
    operationStatus: beginResult.operationStatus,
    errorCode:
      typeof beginResult.errorCode === 'string'
        ? beginResult.errorCode
        : null,
    avatarCleanupCompleted:
      beginResult.avatarCleanupCompleted === true,
    authUserDeleted: beginResult.authUserDeleted === true,
    auditRecorded:
      beginResult.requestAuditRecorded === true &&
      (
        beginResult.operationStatus === 'started' ||
        beginResult.completionAuditRecorded === true
      ),
  }

  if (beginResult.operationStatus === 'completed') {
    return jsonResponse(200, replayResponse)
  }

  if (!beginResult.success || !beginResult.allowed) {
    return jsonResponse(
      statusForDeletionError(beginResult.errorCode),
      replayResponse,
    )
  }

  if (beginResult.operationStatus !== 'started') {
    console.error(
      'Administrative account deletion returned an unknown operation status.',
    )

    return jsonResponse(500, {
      error: 'Invalid account deletion state.',
      operationId,
    })
  }

  const finishDeletion = async ({
    outcome,
    errorCode,
    avatarCleanupCompleted,
    authUserDeleted,
  }: {
    outcome: 'completed' | 'failed'
    errorCode: string | null
    avatarCleanupCompleted: boolean
    authUserDeleted: boolean
  }) => {
    const { data, error } = await adminClient.rpc(
      'admin_finish_account_deletion',
      {
        p_operation_id: operationId,
        p_actor_user_id: caller.id,
        p_target_user_id: targetUserId,
        p_outcome: outcome,
        p_error_code: errorCode,
        p_avatar_cleanup_completed: avatarCleanupCompleted,
        p_auth_user_deleted: authUserDeleted,
      },
    )

    return {
      data: readResultObject(data),
      error,
    }
  }

  let avatarCleanupCompleted =
    beginResult.avatarCleanupCompleted === true

  if (!avatarCleanupCompleted) {
    const avatarPath = `${targetUserId}/avatar.jpg`
    const { error: avatarDeleteError } = await adminClient.storage
      .from('avatars')
      .remove([avatarPath])

    if (avatarDeleteError != null) {
      console.error(
        'Administrative avatar cleanup failed.',
        avatarDeleteError,
      )

      const finalization = await finishDeletion({
        outcome: 'failed',
        errorCode: 'avatar_cleanup_failed',
        avatarCleanupCompleted: false,
        authUserDeleted: false,
      })

      if (finalization.error != null) {
        console.error(
          'Unable to finalize failed avatar cleanup.',
          finalization.error,
        )

        return jsonResponse(500, {
          error: 'Account deletion could not be finalized.',
          operationId,
          retryable: true,
        })
      }

      return jsonResponse(500, {
        error: 'Unable to remove account files.',
        success: false,
        operationId,
        operationStatus: 'failed',
        errorCode: 'avatar_cleanup_failed',
        avatarCleanupCompleted: false,
        authUserDeleted: false,
        auditRecorded: finalization.data?.auditRecorded === true,
      })
    }

    avatarCleanupCompleted = true
  }

  let authUserDeleted = beginResult.authUserDeleted === true

  if (!authUserDeleted) {
    const {
      data: { user: targetUser },
      error: targetUserError,
    } = await adminClient.auth.admin.getUserById(targetUserId)

    if (targetUserError != null && !isAuthUserNotFound(targetUserError)) {
      console.error(
        'Unable to revalidate the target account before deletion.',
        targetUserError,
      )

      const finalization = await finishDeletion({
        outcome: 'failed',
        errorCode: 'target_revalidation_failed',
        avatarCleanupCompleted,
        authUserDeleted: false,
      })

      if (finalization.error != null) {
        console.error(
          'Unable to finalize failed target revalidation.',
          finalization.error,
        )

        return jsonResponse(500, {
          error: 'Account deletion could not be finalized.',
          operationId,
          retryable: true,
        })
      }

      return jsonResponse(500, {
        error: 'Unable to revalidate the target account.',
        success: false,
        operationId,
        operationStatus: 'failed',
        errorCode: 'target_revalidation_failed',
        avatarCleanupCompleted,
        authUserDeleted: false,
        auditRecorded: finalization.data?.auditRecorded === true,
      })
    }

    if (targetUser == null) {
      if (!isAuthUserNotFound(targetUserError)) {
        console.error(
          'Target account revalidation returned an invalid result.',
        )

        const finalization = await finishDeletion({
          outcome: 'failed',
          errorCode: 'target_revalidation_failed',
          avatarCleanupCompleted,
          authUserDeleted: false,
        })

        if (finalization.error != null) {
          console.error(
            'Unable to finalize invalid target revalidation.',
            finalization.error,
          )

          return jsonResponse(500, {
            error: 'Account deletion could not be finalized.',
            operationId,
            retryable: true,
          })
        }

        return jsonResponse(500, {
          error: 'Unable to revalidate the target account.',
          success: false,
          operationId,
          operationStatus: 'failed',
          errorCode: 'target_revalidation_failed',
          avatarCleanupCompleted,
          authUserDeleted: false,
          auditRecorded: finalization.data?.auditRecorded === true,
        })
      }

      // A retry may arrive after Auth deletion succeeded but before the
      // completion RPC was recorded.
      authUserDeleted = true
    } else {
      const { data: targetMirror, error: targetMirrorError } =
        await adminClient
          .from('users')
          .select('role')
          .eq('id', targetUserId)
          .maybeSingle()

      if (targetMirrorError != null || targetMirror == null) {
        console.error(
          'Unable to revalidate the target mirror role.',
          targetMirrorError,
        )

        const finalization = await finishDeletion({
          outcome: 'failed',
          errorCode: 'target_revalidation_failed',
          avatarCleanupCompleted,
          authUserDeleted: false,
        })

        if (finalization.error != null) {
          console.error(
            'Unable to finalize failed target mirror revalidation.',
            finalization.error,
          )

          return jsonResponse(500, {
            error: 'Account deletion could not be finalized.',
            operationId,
            retryable: true,
          })
        }

        return jsonResponse(500, {
          error: 'Unable to revalidate the target account.',
          success: false,
          operationId,
          operationStatus: 'failed',
          errorCode: 'target_revalidation_failed',
          avatarCleanupCompleted,
          authUserDeleted: false,
          auditRecorded: finalization.data?.auditRecorded === true,
        })
      }

      const targetAuthRole = normalizeSystemRole(
        targetUser.app_metadata?.role,
      )
      const targetMirrorRole = normalizeSystemRole(targetMirror.role)

      if (
        targetAuthRole === 'admin' ||
        targetMirrorRole === 'admin'
      ) {
        const finalization = await finishDeletion({
          outcome: 'failed',
          errorCode: 'target_admin_deletion_not_allowed',
          avatarCleanupCompleted,
          authUserDeleted: false,
        })

        if (finalization.error != null) {
          console.error(
            'Unable to finalize rejected admin deletion.',
            finalization.error,
          )

          return jsonResponse(500, {
            error: 'Account deletion could not be finalized.',
            operationId,
            retryable: true,
          })
        }

        return jsonResponse(403, {
          error: 'Administrator accounts cannot be deleted here.',
          success: false,
          operationId,
          operationStatus: 'failed',
          errorCode: 'target_admin_deletion_not_allowed',
          avatarCleanupCompleted,
          authUserDeleted: false,
          auditRecorded: finalization.data?.auditRecorded === true,
        })
      }

      if (targetAuthRole !== targetMirrorRole) {
        const finalization = await finishDeletion({
          outcome: 'failed',
          errorCode: 'target_role_not_synchronized',
          avatarCleanupCompleted,
          authUserDeleted: false,
        })

        if (finalization.error != null) {
          console.error(
            'Unable to finalize unsynchronized target role.',
            finalization.error,
          )

          return jsonResponse(500, {
            error: 'Account deletion could not be finalized.',
            operationId,
            retryable: true,
          })
        }

        return jsonResponse(409, {
          error: 'Target account role is not synchronized.',
          success: false,
          operationId,
          operationStatus: 'failed',
          errorCode: 'target_role_not_synchronized',
          avatarCleanupCompleted,
          authUserDeleted: false,
          auditRecorded: finalization.data?.auditRecorded === true,
        })
      }

      const { error: deleteError } =
        await adminClient.auth.admin.deleteUser(targetUserId, false)

      if (deleteError != null && !isAuthUserNotFound(deleteError)) {
        console.error(
          'Administrative Auth user deletion failed.',
          deleteError,
        )

        const finalization = await finishDeletion({
          outcome: 'failed',
          errorCode: 'auth_user_deletion_failed',
          avatarCleanupCompleted,
          authUserDeleted: false,
        })

        if (finalization.error != null) {
          console.error(
            'Unable to finalize failed Auth user deletion.',
            finalization.error,
          )

          return jsonResponse(500, {
            error: 'Account deletion could not be finalized.',
            operationId,
            retryable: true,
          })
        }

        return jsonResponse(500, {
          error: 'Unable to delete the account.',
          success: false,
          operationId,
          operationStatus: 'failed',
          errorCode: 'auth_user_deletion_failed',
          avatarCleanupCompleted,
          authUserDeleted: false,
          auditRecorded: finalization.data?.auditRecorded === true,
        })
      }

      authUserDeleted = true
    }
  }

  const finalization = await finishDeletion({
    outcome: 'completed',
    errorCode: null,
    avatarCleanupCompleted,
    authUserDeleted,
  })

  if (finalization.error != null) {
    console.error(
      'Unable to finalize administrative account deletion.',
      finalization.error,
    )

    return jsonResponse(500, {
      error: 'Account deletion could not be finalized.',
      operationId,
      retryable: true,
    })
  }

  const finalResult = finalization.data

  if (
    finalResult == null ||
    typeof finalResult.success !== 'boolean' ||
    typeof finalResult.operationStatus !== 'string'
  ) {
    console.error(
      'Administrative account deletion returned an invalid final result.',
    )

    return jsonResponse(500, {
      error: 'Invalid account deletion response.',
      operationId,
      retryable: true,
    })
  }

  const response = {
    success: finalResult.success,
    operationId,
    deletedUserId: finalResult.success ? targetUserId : null,
    replayed: finalResult.replayed === true,
    operationStatus: finalResult.operationStatus,
    errorCode:
      typeof finalResult.errorCode === 'string'
        ? finalResult.errorCode
        : null,
    avatarCleanupCompleted:
      finalResult.avatarCleanupCompleted === true,
    authUserDeleted: finalResult.authUserDeleted === true,
    auditRecorded: finalResult.auditRecorded === true,
  }

  return jsonResponse(finalResult.success ? 200 : 500, response)
})
