import { createClient } from 'npm:@supabase/supabase-js@2'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!

type SystemRole = 'user' | 'moderator' | 'admin'

type RequestBody = {
  targetUserId?: string
  newRole?: SystemRole
}

function jsonResponse(status: number, body: Record<string, unknown>) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
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
  return token.length == 0 ? null : token
}

Deno.serve(async (req) => {
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

  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  })

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
  } = await userClient.auth.getUser()

  if (callerError != null || caller == null) {
    return jsonResponse(401, {
      error: 'Invalid session.',
    })
  }

  const callerRole = caller.app_metadata?.role
  if (callerRole !== 'admin') {
    return jsonResponse(403, {
      error: 'Only admin can change system roles.',
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

  const targetUserId = body.targetUserId?.trim()
  const newRole = body.newRole

  if (!targetUserId) {
    return jsonResponse(400, {
      error: 'targetUserId is required.',
    })
  }

  if (newRole !== 'user' && newRole !== 'moderator' && newRole !== 'admin') {
    return jsonResponse(400, {
      error: 'newRole must be one of: user, moderator, admin.',
    })
  }

  const { data: targetUser, error: getUserError } =
    await adminClient.auth.admin.getUserById(targetUserId)

  if (getUserError != null || targetUser.user == null) {
    return jsonResponse(404, {
      error: 'Target user not found.',
    })
  }

  const nextAppMetadata = {
    ...(targetUser.user.app_metadata ?? {}),
    role: newRole,
  }

  const { data: updatedUser, error: updateError } =
    await adminClient.auth.admin.updateUserById(targetUserId, {
      app_metadata: nextAppMetadata,
    })

  if (updateError != null) {
    return jsonResponse(500, {
      error: updateError.message,
    })
  }

  return jsonResponse(200, {
    success: true,
    targetUserId,
    newRole,
    user: {
      id: updatedUser.user.id,
      email: updatedUser.user.email,
      appMetadataRole: updatedUser.user.app_metadata?.role ?? null,
    },
  })
})