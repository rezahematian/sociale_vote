-- SOCIAL VOTE
-- P1.5 — Enforce username validity + uniqueness before Auth user creation
-- 2026-08-07
--
-- Preserva integralmente le protezioni P1.3:
-- - disposable email blocklist
-- - cooldown email dopo cancellazione
-- e aggiunge:
-- - username obbligatorio per signup email
-- - formato username server-side
-- - unicità case-insensitive prima della creazione auth.users

begin;

create or replace function public.social_vote_before_user_created(event jsonb)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_email text;
  v_domain text;
  v_email_hmac bytea;
  v_cooldown_until timestamptz;
  v_username_raw text;
  v_username text;
begin
  v_email := lower(btrim(coalesce(event->'user'->>'email', '')));

  -- Non interferire con eventuali provider non-email futuri.
  if v_email = '' then
    return '{}'::jsonb;
  end if;

  -- ==========================================================
  -- P1.5 — USERNAME
  -- ==========================================================

  v_username_raw := btrim(
    coalesce(event->'user'->'user_metadata'->>'username', '')
  );
  v_username := lower(v_username_raw);

  if v_username = '' then
    return jsonb_build_object(
      'error',
      jsonb_build_object(
        'http_code', 400,
        'message', 'Username is required.'
      )
    );
  end if;

  if v_username !~ '^[a-z0-9_]{3,20}$' then
    return jsonb_build_object(
      'error',
      jsonb_build_object(
        'http_code', 400,
        'message', 'Invalid username.'
      )
    );
  end if;

  -- Controllo profili già materializzati.
  if exists (
    select 1
    from public.user_profiles profile
    where profile.username is not null
      and lower(btrim(profile.username)) = v_username
  ) then
    return jsonb_build_object(
      'error',
      jsonb_build_object(
        'http_code', 409,
        'message', 'Username already exists.'
      )
    );
  end if;

  -- Controllo anche auth.users: copre account appena registrati ma ancora
  -- in attesa di conferma email, prima che user_profiles venga creato.
  if exists (
    select 1
    from auth.users auth_user
    where auth_user.raw_user_meta_data is not null
      and lower(btrim(coalesce(auth_user.raw_user_meta_data->>'username', ''))) = v_username
  ) then
    return jsonb_build_object(
      'error',
      jsonb_build_object(
        'http_code', 409,
        'message', 'Username already exists.'
      )
    );
  end if;

  -- ==========================================================
  -- P1.3 — DISPOSABLE EMAIL + DELETION COOLDOWN
  -- ==========================================================

  v_domain := lower(split_part(v_email, '@', 2));

  if v_domain = '' then
    return jsonb_build_object(
      'error',
      jsonb_build_object(
        'http_code', 400,
        'message', 'Invalid email address.'
      )
    );
  end if;

  if exists (
    select 1
    from app_private.blocked_signup_email_domains blocked
    where lower(blocked.domain) = v_domain
  ) then
    return jsonb_build_object(
      'error',
      jsonb_build_object(
        'http_code', 403,
        'message', 'Disposable email addresses are not allowed.'
      )
    );
  end if;

  v_email_hmac := app_private.signup_email_hmac(v_email);

  select tombstone.cooldown_until
  into v_cooldown_until
  from app_private.deleted_email_tombstones tombstone
  where tombstone.email_hmac = v_email_hmac
  limit 1;

  if v_cooldown_until is not null and v_cooldown_until > now() then
    return jsonb_build_object(
      'error',
      jsonb_build_object(
        'http_code', 429,
        'message', 'This email address cannot be reused yet after account deletion.'
      )
    );
  end if;

  if v_cooldown_until is not null and v_cooldown_until <= now() then
    delete from app_private.deleted_email_tombstones
    where email_hmac = v_email_hmac;
  end if;

  return '{}'::jsonb;
end;
$$;

revoke all
on function public.social_vote_before_user_created(jsonb)
from public, anon, authenticated;

grant execute
on function public.social_vote_before_user_created(jsonb)
to supabase_auth_admin;

comment on function public.social_vote_before_user_created(jsonb) is
  'P1.3/P1.5 signup guard: username validation/uniqueness, disposable email blocklist and same-email cooldown after account deletion.';

commit;
