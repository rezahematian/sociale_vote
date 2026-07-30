import { createClient } from 'npm:@supabase/supabase-js@2'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!

type StaffRole = 'moderator' | 'admin'

type RequestBody = {
  query?: unknown
  page?: unknown
  perPage?: unknown
}

type UserSearchRow = {
  user_id: string
  email: string | null
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
  total_count: number | string
}

const defaultPerPage = 25
const maximumPerPage = 50
const maximumPage = 100000
const maximumQueryLength = 320

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

function readQuery(value: unknown): string | null | undefined {
  if (value == null) {
    return null
  }

  if (typeof value !== 'string') {
    return undefined
  }

  const query = value.trim()

  if (query.length > maximumQueryLength) {
    return undefined
  }

  return query.length === 0 ? null : query
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
  const query = readQuery(body.query)
  const page = readInteger(body.page, 1, 1, maximumPage)
  const perPage = readInteger(
    body.perPage,
    defaultPerPage,
    1,
    maximumPerPage,
  )

  if (query === undefined) {
    return jsonResponse(400, {
      error: `Query must be text with at most ${maximumQueryLength} characters.`,
    })
  }

  if (page == null) {
    return jsonResponse(400, {
      error: `Page must be an integer between 1 and ${maximumPage}.`,
    })
  }

  if (perPage == null) {
    return jsonResponse(400, {
      error: `Per-page must be an integer between 1 and ${maximumPerPage}.`,
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
    console.error('Admin user search rejected: inactive session.')

    return jsonResponse(401, {
      error: 'Session is no longer active.',
    })
  }

  const callerRole = readStaffRole(caller.app_metadata?.role)

  if (callerRole !== 'admin') {
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

  const includeEmail = true
  const { data, error: searchError } = await adminClient.rpc(
    'admin_search_users',
    {
      p_query: query,
      p_page: page,
      p_per_page: perPage,
      p_include_email: includeEmail,
    },
  )

  if (searchError != null) {
    console.error('Admin user search failed.', searchError)

    return jsonResponse(500, {
      error: 'Unable to search users.',
    })
  }

  const rows = Array.isArray(data) ? (data as UserSearchRow[]) : []
  const totalCount =
    rows.length === 0 ? 0 : Number(rows[0].total_count) || 0
  const totalPages =
    totalCount === 0 ? 0 : Math.ceil(totalCount / perPage)

  const users = rows.map((row) => {
    const user: Record<string, unknown> = {
      userId: row.user_id,
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
    }

    if (includeEmail) {
      user.email = row.email
    }

    return user
  })

  return jsonResponse(200, {
    success: true,
    users,
    pagination: {
      page,
      perPage,
      totalCount,
      totalPages,
    },
    permissions: {
      role: callerRole,
      canViewEmail: includeEmail,
    },
  })
})
