import { createClient } from 'npm:@supabase/supabase-js@2'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!

type SystemRole = 'user' | 'moderator' | 'admin'

type RequestBody = {
  targetUserId?: unknown
  role?: unknown
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
  const authHeader = req.headers.get('Authorization') ?? ''
  const prefix = 'Bearer '

  if (!authHeader.startsWith(prefix)) {
    return null
  }

  const token = authHeader.substring(prefix.length).trim()
  return token.length === 0 ? null : token
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

function isUuid(value: string): boolean {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(
    value,
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

  let body: RequestBody

  try {
    body = await req.json()
  } catch (_) {
    return jsonResponse(400, {
      error: 'Invalid JSON body.',
    })
  }

  const targetUserId =
    typeof body.targetUserId === 'string' ? body.targetUserId.trim() : ''
  const targetRole = readSystemRole(body.role)

  if (!isUuid(targetUserId)) {
    return jsonResponse(400, {
      error: 'A valid target user ID is required.',
    })
  }

  if (targetRole == null) {
    return jsonResponse(400, {
      error: 'Role must be user, moderator, or admin.',
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

  if (targetUserId === caller.id) {
    return jsonResponse(400, {
      error: 'Administrators cannot change their own role.',
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
      'Unable to verify administrator mirror role:',
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

  const {
    data: { user: targetUser },
    error: targetUserError,
  } = await adminClient.auth.admin.getUserById(targetUserId)

  if (targetUserError != null || targetUser == null) {
    return jsonResponse(404, {
      error: 'Target user was not found.',
    })
  }

  const { data: targetMirror, error: targetMirrorError } = await adminClient
    .from('users')
    .select('role')
    .eq('id', targetUserId)
    .maybeSingle()

  if (targetMirrorError != null) {
    console.error('Unable to read target mirror role:', targetMirrorError)

    return jsonResponse(500, {
      error: 'Unable to read the target user role.',
    })
  }

  if (targetMirror == null) {
    return jsonResponse(409, {
      error: 'Target user role mirror is missing.',
    })
  }

  const previousAppMetadata = targetUser.app_metadata ?? {}
  const previousAuthRole = readSystemRole(previousAppMetadata.role) ?? 'user'
  const previousMirrorRole = readSystemRole(targetMirror.role) ?? 'user'

  if (previousAuthRole === targetRole && previousMirrorRole === targetRole) {
    return jsonResponse(200, {
      success: true,
      changed: false,
      targetUserId,
      role: targetRole,
      requiresReauthentication: false,
    })
  }

  const { error: authUpdateError } =
    await adminClient.auth.admin.updateUserById(targetUserId, {
      app_metadata: {
        ...previousAppMetadata,
        role: targetRole,
      },
    })

  if (authUpdateError != null) {
    console.error('Unable to update Auth system role:', authUpdateError)

    return jsonResponse(500, {
      error: 'Unable to update the target user role.',
    })
  }

  const { data: updatedMirror, error: mirrorUpdateError } = await adminClient
    .from('users')
    .update({
      role: targetRole,
    })
    .eq('id', targetUserId)
    .select('id')
    .maybeSingle()

  if (mirrorUpdateError != null || updatedMirror == null) {
    console.error(
      'Unable to update public user role mirror:',
      mirrorUpdateError,
    )

    const { error: rollbackError } =
      await adminClient.auth.admin.updateUserById(targetUserId, {
        app_metadata: previousAppMetadata,
      })

    if (rollbackError != null) {
      console.error('Unable to roll back Auth system role:', rollbackError)
    }

    return jsonResponse(500, {
      error: 'Role update could not be completed.',
      rollbackSucceeded: rollbackError == null,
    })
  }

  console.info('System role updated.', {
    actorUserId: caller.id,
    targetUserId,
    previousAuthRole,
    previousMirrorRole,
    role: targetRole,
  })

  return jsonResponse(200, {
    success: true,
    changed: true,
    targetUserId,
    previousRole: previousAuthRole,
    role: targetRole,
    requiresReauthentication: true,
  })
})
