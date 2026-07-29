import { createClient } from 'supabase'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!

type RequestBody = {
  confirmation?: string
}

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

  if (body.confirmation !== 'DELETE') {
    return jsonResponse(400, {
      error: 'Account deletion confirmation is required.',
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
    data: { user },
    error: userError,
  } = await userClient.auth.getUser(accessToken)

  if (userError != null || user == null) {
    return jsonResponse(401, {
      error: 'Invalid session.',
    })
  }

  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  })

  // L'app salva l'avatar in avatars/{userId}/avatar.jpg.
  // Supabase non elimina un utente che possiede ancora oggetti Storage.
  const avatarPath = `${user.id}/avatar.jpg`
  const { error: avatarDeleteError } = await adminClient.storage
    .from('avatars')
    .remove([avatarPath])

  if (avatarDeleteError != null) {
    console.error('Avatar deletion failed:', avatarDeleteError)

    return jsonResponse(500, {
      error: 'Unable to remove account files.',
      details: avatarDeleteError.message,
    })
  }

  const { error: deleteError } =
    await adminClient.auth.admin.deleteUser(user.id, false)

  if (deleteError != null) {
    console.error('Account deletion failed:', deleteError)

    return jsonResponse(500, {
      error: 'Unable to delete account.',
      details: deleteError.message,
    })
  }

  return jsonResponse(200, {
    success: true,
    deletedUserId: user.id,
  })
})
