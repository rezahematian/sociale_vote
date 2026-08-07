-- SOCIAL VOTE
-- P1.3 — Signup abuse guard foundation
-- 2026-08-07
--
-- Obiettivi:
-- 1) impedire il riuso immediato della stessa email dopo cancellazione account;
-- 2) bloccare alcuni domini email temporanei noti lato server;
-- 3) non conservare l'email cancellata in chiaro;
-- 4) mantenere questa protezione separata dall'Identity verification.
--
-- NOTA:
-- La funzione hook viene creata qui, ma il Before User Created Hook deve
-- essere attivato una sola volta nelle impostazioni Auth di Supabase.

begin;

create extension if not exists pgcrypto with schema extensions;

-- ============================================================
-- 1. PRIVATE CONFIG
-- ============================================================

create table if not exists app_private.signup_guard_config (
  singleton boolean primary key default true check (singleton),
  email_hmac_secret bytea not null,
  deleted_email_cooldown_days integer not null default 30
    check (deleted_email_cooldown_days between 1 and 365),
  updated_at timestamptz not null default now()
);

insert into app_private.signup_guard_config (
  singleton,
  email_hmac_secret,
  deleted_email_cooldown_days
)
values (
  true,
  extensions.gen_random_bytes(32),
  30
)
on conflict (singleton) do nothing;

revoke all on table app_private.signup_guard_config
from public, anon, authenticated;

-- ============================================================
-- 2. DELETED EMAIL TOMBSTONES
-- ============================================================

create table if not exists app_private.deleted_email_tombstones (
  email_hmac bytea primary key,
  deleted_at timestamptz not null default now(),
  cooldown_until timestamptz not null
);

create index if not exists deleted_email_tombstones_cooldown_until_idx
on app_private.deleted_email_tombstones (cooldown_until);

revoke all on table app_private.deleted_email_tombstones
from public, anon, authenticated;

comment on table app_private.deleted_email_tombstones is
  'Temporary HMAC tombstones used only to prevent immediate email reuse after account deletion. No plaintext email is stored.';

-- ============================================================
-- 3. DISPOSABLE EMAIL DOMAIN BLOCKLIST
-- ============================================================

create table if not exists app_private.blocked_signup_email_domains (
  domain text primary key,
  reason text,
  created_at timestamptz not null default now()
);

revoke all on table app_private.blocked_signup_email_domains
from public, anon, authenticated;

insert into app_private.blocked_signup_email_domains (domain, reason)
values
  ('10minutemail.com', 'Disposable email provider'),
  ('mailinator.com', 'Disposable email provider'),
  ('guerrillamail.com', 'Disposable email provider'),
  ('guerrillamail.info', 'Disposable email provider'),
  ('guerrillamail.biz', 'Disposable email provider'),
  ('guerrillamail.de', 'Disposable email provider'),
  ('guerrillamail.net', 'Disposable email provider'),
  ('guerrillamail.org', 'Disposable email provider'),
  ('guerrillamailblock.com', 'Disposable email provider'),
  ('sharklasers.com', 'Disposable email provider'),
  ('grr.la', 'Disposable email provider'),
  ('yopmail.com', 'Disposable email provider'),
  ('temp-mail.org', 'Disposable email provider'),
  ('tempmail.com', 'Disposable email provider'),
  ('trashmail.com', 'Disposable email provider'),
  ('discard.email', 'Disposable email provider'),
  ('dispostable.com', 'Disposable email provider'),
  ('maildrop.cc', 'Disposable email provider'),
  ('getnada.com', 'Disposable email provider'),
  ('spam4.me', 'Disposable email provider')
on conflict (domain) do nothing;

-- ============================================================
-- 4. EMAIL HMAC HELPER
-- ============================================================

create or replace function app_private.signup_email_hmac(p_email text)
returns bytea
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_secret bytea;
  v_email text;
begin
  v_email := lower(btrim(coalesce(p_email, '')));

  if v_email = '' then
    return null;
  end if;

  select config.email_hmac_secret
  into v_secret
  from app_private.signup_guard_config config
  where config.singleton = true;

  if v_secret is null then
    raise exception 'Signup guard secret is not configured.';
  end if;

  return extensions.hmac(
    convert_to(v_email, 'UTF8'),
    v_secret,
    'sha256'
  );
end;
$$;

revoke all
on function app_private.signup_email_hmac(text)
from public, anon, authenticated;

-- ============================================================
-- 5. ACCOUNT DELETION → TEMPORARY EMAIL TOMBSTONE
-- ============================================================
-- Extends the centralized Auth deletion trigger already used by both
-- personal and administrative deletion flows.

create or replace function app_private.prepare_deleted_auth_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_email_hmac bytea;
  v_cooldown_days integer;
begin
  if old.email is not null and btrim(old.email) <> '' then
    v_email_hmac := app_private.signup_email_hmac(old.email);

    select config.deleted_email_cooldown_days
    into v_cooldown_days
    from app_private.signup_guard_config config
    where config.singleton = true;

    v_cooldown_days := coalesce(v_cooldown_days, 30);

    insert into app_private.deleted_email_tombstones (
      email_hmac,
      deleted_at,
      cooldown_until
    )
    values (
      v_email_hmac,
      now(),
      now() + make_interval(days => v_cooldown_days)
    )
    on conflict (email_hmac) do update
    set
      deleted_at = excluded.deleted_at,
      cooldown_until = excluded.cooldown_until;
  end if;

  perform app_private.erase_deleted_user_content(old.id);

  update public.users
  set
    email = null,
    display_name = null,
    role = 'user'
  where id = old.id;

  insert into app_private.account_controls (
    user_id,
    status,
    updated_at
  )
  values (
    old.id,
    'deleted',
    now()
  )
  on conflict (user_id) do update
  set
    status = 'deleted',
    suspended_at = null,
    suspended_until = null,
    suspended_by = null,
    suspension_reason = null,
    updated_at = now();

  delete from app_private.active_user_sessions
  where user_id = old.id;

  return old;
end;
$$;

revoke all
on function app_private.prepare_deleted_auth_user()
from public, anon, authenticated;

-- ============================================================
-- 6. SUPABASE BEFORE USER CREATED AUTH HOOK
-- ============================================================

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
begin
  v_email := lower(btrim(coalesce(event->'user'->>'email', '')));

  -- Do not interfere with non-email providers.
  if v_email = '' then
    return '{}'::jsonb;
  end if;

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

  -- Once the cooldown has expired, remove the temporary tombstone.
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
  'P1.3 Before User Created hook: blocks configured disposable email domains and enforces temporary same-email cooldown after account deletion.';

commit;
