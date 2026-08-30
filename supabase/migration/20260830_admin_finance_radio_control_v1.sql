-- Social Vote — Admin Finance Ledger + Radio Mondo Catalog V1
-- 2026-08-30
-- Manual EUR cash ledger and public Radio Mondo catalog.
-- All mutations are admin-only, RPC-only and audited.

begin;

-- ============================================================
-- FINANCE — append-only entries with audited voiding
-- ============================================================

create table if not exists public.admin_finance_entries (
  id uuid primary key default gen_random_uuid(),
  occurred_on date not null,
  direction text not null,
  amount_cents bigint not null,
  currency text not null default 'EUR',
  category text not null,
  counterparty text,
  note text,
  created_by uuid not null,
  created_at timestamptz not null default now(),
  voided_by uuid,
  voided_at timestamptz,
  void_reason text,
  constraint admin_finance_entries_direction_check
    check (direction in ('income', 'expense')),
  constraint admin_finance_entries_amount_check
    check (amount_cents between 1 and 999999999999),
  constraint admin_finance_entries_currency_check
    check (currency = 'EUR'),
  constraint admin_finance_entries_category_check
    check (char_length(btrim(category)) between 1 and 80),
  constraint admin_finance_entries_counterparty_check
    check (counterparty is null or char_length(btrim(counterparty)) between 1 and 160),
  constraint admin_finance_entries_note_check
    check (note is null or char_length(btrim(note)) between 1 and 500),
  constraint admin_finance_entries_void_state_check
    check (
      (voided_by is null and voided_at is null and void_reason is null)
      or
      (
        voided_by is not null
        and voided_at is not null
        and char_length(btrim(void_reason)) between 1 and 1000
      )
    )
);

comment on table public.admin_finance_entries is
  'Private manual EUR cash ledger for Social Vote. Entries are never deleted; corrections use audited voiding.';

create index if not exists admin_finance_entries_occurred_idx
on public.admin_finance_entries (occurred_on desc, created_at desc);

alter table public.admin_finance_entries enable row level security;
alter table public.admin_finance_entries force row level security;

revoke all on table public.admin_finance_entries
from public, anon, authenticated;

create or replace function public.admin_finance_snapshot()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := (select auth.uid());
  v_month_start date := date_trunc('month', current_date)::date;
  v_month_end date := (date_trunc('month', current_date) + interval '1 month')::date;
  v_month_income bigint := 0;
  v_month_expense bigint := 0;
  v_total_income bigint := 0;
  v_total_expense bigint := 0;
  v_entries jsonb := '[]'::jsonb;
begin
  if v_actor is null or not (select public.is_current_auth_user_admin()) then
    raise exception using errcode = '42501', message = 'Admin required.';
  end if;

  select
    coalesce(sum(e.amount_cents) filter (
      where e.direction = 'income'
        and e.occurred_on >= v_month_start
        and e.occurred_on < v_month_end
    ), 0)::bigint,
    coalesce(sum(e.amount_cents) filter (
      where e.direction = 'expense'
        and e.occurred_on >= v_month_start
        and e.occurred_on < v_month_end
    ), 0)::bigint,
    coalesce(sum(e.amount_cents) filter (where e.direction = 'income'), 0)::bigint,
    coalesce(sum(e.amount_cents) filter (where e.direction = 'expense'), 0)::bigint
  into v_month_income, v_month_expense, v_total_income, v_total_expense
  from public.admin_finance_entries e
  where e.voided_at is null;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id', x.id,
        'occurred_on', x.occurred_on,
        'direction', x.direction,
        'amount_cents', x.amount_cents,
        'currency', x.currency,
        'category', x.category,
        'counterparty', x.counterparty,
        'note', x.note,
        'created_at', x.created_at
      )
      order by x.occurred_on desc, x.created_at desc
    ),
    '[]'::jsonb
  )
  into v_entries
  from (
    select e.*
    from public.admin_finance_entries e
    where e.voided_at is null
    order by e.occurred_on desc, e.created_at desc
    limit 100
  ) x;

  return jsonb_build_object(
    'currency', 'EUR',
    'month_start', v_month_start,
    'month_income_cents', v_month_income,
    'month_expense_cents', v_month_expense,
    'month_balance_cents', v_month_income - v_month_expense,
    'total_income_cents', v_total_income,
    'total_expense_cents', v_total_expense,
    'total_balance_cents', v_total_income - v_total_expense,
    'entries', v_entries,
    'generated_at', now()
  );
end;
$$;

create or replace function public.admin_finance_add_entry(
  p_occurred_on date,
  p_direction text,
  p_amount_cents bigint,
  p_category text,
  p_counterparty text,
  p_note text,
  p_reason text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := (select auth.uid());
  v_direction text := lower(btrim(coalesce(p_direction, '')));
  v_category text := btrim(coalesce(p_category, ''));
  v_counterparty text := nullif(btrim(coalesce(p_counterparty, '')), '');
  v_note text := nullif(btrim(coalesce(p_note, '')), '');
  v_reason text := btrim(coalesce(p_reason, ''));
  v_entry public.admin_finance_entries%rowtype;
begin
  if v_actor is null or not (select public.is_current_auth_user_admin()) then
    raise exception using errcode = '42501', message = 'Admin required.';
  end if;
  if p_occurred_on is null or p_occurred_on > current_date then
    raise exception using errcode = '22023', message = 'A non-future finance date is required.';
  end if;
  if v_direction not in ('income', 'expense') then
    raise exception using errcode = '22023', message = 'Invalid finance direction.';
  end if;
  if p_amount_cents is null or p_amount_cents < 1 or p_amount_cents > 999999999999 then
    raise exception using errcode = '22023', message = 'Invalid finance amount.';
  end if;
  if char_length(v_category) not between 1 and 80 then
    raise exception using errcode = '22023', message = 'Category is required.';
  end if;
  if v_counterparty is not null and char_length(v_counterparty) > 160 then
    raise exception using errcode = '22023', message = 'Counterparty is too long.';
  end if;
  if v_note is not null and char_length(v_note) > 500 then
    raise exception using errcode = '22023', message = 'Finance note is too long.';
  end if;
  if char_length(v_reason) not between 1 and 1000 then
    raise exception using errcode = '22023', message = 'Audit reason is required.';
  end if;

  insert into public.admin_finance_entries (
    occurred_on,
    direction,
    amount_cents,
    currency,
    category,
    counterparty,
    note,
    created_by
  ) values (
    p_occurred_on,
    v_direction,
    p_amount_cents,
    'EUR',
    v_category,
    v_counterparty,
    v_note,
    v_actor
  )
  returning * into v_entry;

  insert into public.admin_audit_logs (
    actor_user_id,
    actor_role,
    action,
    target_type,
    target_id,
    previous_value,
    new_value,
    reason,
    result
  ) values (
    v_actor,
    'admin',
    'finance_entry_add',
    'finance_entry',
    v_entry.id::text,
    '{}'::jsonb,
    jsonb_build_object(
      'occurred_on', v_entry.occurred_on,
      'direction', v_entry.direction,
      'amount_cents', v_entry.amount_cents,
      'currency', v_entry.currency,
      'category', v_entry.category
    ),
    v_reason,
    'success'
  );

  return jsonb_build_object('id', v_entry.id, 'created_at', v_entry.created_at);
end;
$$;

create or replace function public.admin_finance_void_entry(
  p_entry_id uuid,
  p_reason text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := (select auth.uid());
  v_reason text := btrim(coalesce(p_reason, ''));
  v_entry public.admin_finance_entries%rowtype;
begin
  if v_actor is null or not (select public.is_current_auth_user_admin()) then
    raise exception using errcode = '42501', message = 'Admin required.';
  end if;
  if p_entry_id is null then
    raise exception using errcode = '22023', message = 'Finance entry id is required.';
  end if;
  if char_length(v_reason) not between 1 and 1000 then
    raise exception using errcode = '22023', message = 'Void reason is required.';
  end if;

  select * into v_entry
  from public.admin_finance_entries e
  where e.id = p_entry_id
  for update;

  if not found then
    raise exception using errcode = 'P0002', message = 'Finance entry not found.';
  end if;

  if v_entry.voided_at is not null then
    insert into public.admin_audit_logs (
      actor_user_id, actor_role, action, target_type, target_id,
      previous_value, new_value, reason, result
    ) values (
      v_actor, 'admin', 'finance_entry_void', 'finance_entry', v_entry.id::text,
      jsonb_build_object('voided', true),
      jsonb_build_object('voided', true),
      v_reason, 'noop'
    );
    return jsonb_build_object('id', v_entry.id, 'voided', true, 'noop', true);
  end if;

  update public.admin_finance_entries e
  set voided_by = v_actor,
      voided_at = now(),
      void_reason = v_reason
  where e.id = v_entry.id;

  insert into public.admin_audit_logs (
    actor_user_id, actor_role, action, target_type, target_id,
    previous_value, new_value, reason, result
  ) values (
    v_actor, 'admin', 'finance_entry_void', 'finance_entry', v_entry.id::text,
    jsonb_build_object('voided', false),
    jsonb_build_object('voided', true),
    v_reason, 'success'
  );

  return jsonb_build_object('id', v_entry.id, 'voided', true, 'noop', false);
end;
$$;

-- ============================================================
-- RADIO MONDO — public read catalog, audited admin mutations
-- ============================================================

create table if not exists public.radio_mondo_tracks (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  audio_url text not null,
  sort_order integer not null default 100,
  is_enabled boolean not null default false,
  attribution text not null,
  license_url text,
  created_by uuid not null,
  updated_by uuid not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint radio_mondo_tracks_title_check
    check (char_length(btrim(title)) between 1 and 120),
  constraint radio_mondo_tracks_audio_url_check
    check (char_length(audio_url) between 9 and 2048 and audio_url ~ '^https://'),
  constraint radio_mondo_tracks_sort_order_check
    check (sort_order between 0 and 1000),
  constraint radio_mondo_tracks_attribution_check
    check (char_length(btrim(attribution)) between 1 and 300),
  constraint radio_mondo_tracks_license_url_check
    check (license_url is null or (char_length(license_url) between 9 and 2048 and license_url ~ '^https://'))
);

comment on table public.radio_mondo_tracks is
  'Radio Mondo remote audio catalog. Public clients receive only enabled tracks through a read-only RPC.';

create index if not exists radio_mondo_tracks_public_order_idx
on public.radio_mondo_tracks (is_enabled desc, sort_order asc, created_at asc);

alter table public.radio_mondo_tracks enable row level security;
alter table public.radio_mondo_tracks force row level security;

revoke all on table public.radio_mondo_tracks
from public, anon, authenticated;

create or replace function public.radio_mondo_public_catalog()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id', t.id,
        'title', t.title,
        'audio_url', t.audio_url,
        'sort_order', t.sort_order,
        'attribution', t.attribution,
        'license_url', t.license_url
      )
      order by t.sort_order asc, t.created_at asc
    ),
    '[]'::jsonb
  )
  from public.radio_mondo_tracks t
  where t.is_enabled = true;
$$;

create or replace function public.admin_radio_mondo_list()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := (select auth.uid());
  v_tracks jsonb;
begin
  if v_actor is null or not (select public.is_current_auth_user_admin()) then
    raise exception using errcode = '42501', message = 'Admin required.';
  end if;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id', t.id,
        'title', t.title,
        'audio_url', t.audio_url,
        'sort_order', t.sort_order,
        'is_enabled', t.is_enabled,
        'attribution', t.attribution,
        'license_url', t.license_url,
        'created_at', t.created_at,
        'updated_at', t.updated_at
      )
      order by t.sort_order asc, t.created_at asc
    ),
    '[]'::jsonb
  )
  into v_tracks
  from public.radio_mondo_tracks t;

  return v_tracks;
end;
$$;

create or replace function public.admin_radio_mondo_upsert(
  p_track_id uuid,
  p_title text,
  p_audio_url text,
  p_sort_order integer,
  p_is_enabled boolean,
  p_attribution text,
  p_license_url text,
  p_rights_confirmed boolean,
  p_reason text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := (select auth.uid());
  v_title text := btrim(coalesce(p_title, ''));
  v_audio_url text := btrim(coalesce(p_audio_url, ''));
  v_attribution text := btrim(coalesce(p_attribution, ''));
  v_license_url text := nullif(btrim(coalesce(p_license_url, '')), '');
  v_reason text := btrim(coalesce(p_reason, ''));
  v_previous public.radio_mondo_tracks%rowtype;
  v_track public.radio_mondo_tracks%rowtype;
  v_is_new boolean := p_track_id is null;
begin
  if v_actor is null or not (select public.is_current_auth_user_admin()) then
    raise exception using errcode = '42501', message = 'Admin required.';
  end if;
  if p_rights_confirmed is distinct from true then
    raise exception using errcode = '22023', message = 'Audio rights confirmation is required.';
  end if;
  if char_length(v_title) not between 1 and 120 then
    raise exception using errcode = '22023', message = 'Track title is required.';
  end if;
  if char_length(v_audio_url) not between 9 and 2048 or v_audio_url !~ '^https://' then
    raise exception using errcode = '22023', message = 'A valid HTTPS audio URL is required.';
  end if;
  if p_sort_order is null or p_sort_order not between 0 and 1000 then
    raise exception using errcode = '22023', message = 'Sort order must be between 0 and 1000.';
  end if;
  if p_is_enabled is null then
    raise exception using errcode = '22023', message = 'Enabled state is required.';
  end if;
  if char_length(v_attribution) not between 1 and 300 then
    raise exception using errcode = '22023', message = 'Rights or attribution note is required.';
  end if;
  if v_license_url is not null and (char_length(v_license_url) > 2048 or v_license_url !~ '^https://') then
    raise exception using errcode = '22023', message = 'License URL must use HTTPS.';
  end if;
  if char_length(v_reason) not between 1 and 1000 then
    raise exception using errcode = '22023', message = 'Audit reason is required.';
  end if;

  if v_is_new then
    insert into public.radio_mondo_tracks (
      title, audio_url, sort_order, is_enabled, attribution, license_url,
      created_by, updated_by
    ) values (
      v_title, v_audio_url, p_sort_order, p_is_enabled, v_attribution,
      v_license_url, v_actor, v_actor
    )
    returning * into v_track;
  else
    select * into v_previous
    from public.radio_mondo_tracks t
    where t.id = p_track_id
    for update;

    if not found then
      raise exception using errcode = 'P0002', message = 'Radio track not found.';
    end if;

    update public.radio_mondo_tracks t
    set title = v_title,
        audio_url = v_audio_url,
        sort_order = p_sort_order,
        is_enabled = p_is_enabled,
        attribution = v_attribution,
        license_url = v_license_url,
        updated_by = v_actor,
        updated_at = now()
    where t.id = p_track_id
    returning * into v_track;
  end if;

  insert into public.admin_audit_logs (
    actor_user_id, actor_role, action, target_type, target_id,
    previous_value, new_value, reason, result
  ) values (
    v_actor,
    'admin',
    case when v_is_new then 'radio_track_add' else 'radio_track_update' end,
    'radio_track',
    v_track.id::text,
    case
      when v_is_new then '{}'::jsonb
      else jsonb_build_object(
        'sort_order', v_previous.sort_order,
        'is_enabled', v_previous.is_enabled,
        'audio_url_changed', false
      )
    end,
    jsonb_build_object(
      'sort_order', v_track.sort_order,
      'is_enabled', v_track.is_enabled,
      'audio_url_changed', v_is_new or v_previous.audio_url is distinct from v_track.audio_url
    ),
    v_reason,
    'success'
  );

  return jsonb_build_object(
    'id', v_track.id,
    'title', v_track.title,
    'audio_url', v_track.audio_url,
    'sort_order', v_track.sort_order,
    'is_enabled', v_track.is_enabled,
    'attribution', v_track.attribution,
    'license_url', v_track.license_url,
    'created_at', v_track.created_at,
    'updated_at', v_track.updated_at
  );
end;
$$;

create or replace function public.admin_radio_mondo_set_enabled(
  p_track_id uuid,
  p_is_enabled boolean,
  p_reason text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor uuid := (select auth.uid());
  v_reason text := btrim(coalesce(p_reason, ''));
  v_track public.radio_mondo_tracks%rowtype;
  v_previous boolean;
begin
  if v_actor is null or not (select public.is_current_auth_user_admin()) then
    raise exception using errcode = '42501', message = 'Admin required.';
  end if;
  if p_track_id is null or p_is_enabled is null then
    raise exception using errcode = '22023', message = 'Track and enabled state are required.';
  end if;
  if char_length(v_reason) not between 1 and 1000 then
    raise exception using errcode = '22023', message = 'Audit reason is required.';
  end if;

  select * into v_track
  from public.radio_mondo_tracks t
  where t.id = p_track_id
  for update;

  if not found then
    raise exception using errcode = 'P0002', message = 'Radio track not found.';
  end if;

  v_previous := v_track.is_enabled;

  if v_previous is distinct from p_is_enabled then
    update public.radio_mondo_tracks t
    set is_enabled = p_is_enabled,
        updated_by = v_actor,
        updated_at = now()
    where t.id = p_track_id
    returning * into v_track;
  end if;

  insert into public.admin_audit_logs (
    actor_user_id, actor_role, action, target_type, target_id,
    previous_value, new_value, reason, result
  ) values (
    v_actor, 'admin', 'radio_track_enabled_change', 'radio_track', v_track.id::text,
    jsonb_build_object('is_enabled', v_previous),
    jsonb_build_object('is_enabled', p_is_enabled),
    v_reason,
    case when v_previous is distinct from p_is_enabled then 'success' else 'noop' end
  );

  return jsonb_build_object(
    'id', v_track.id,
    'is_enabled', v_track.is_enabled,
    'noop', v_previous is not distinct from p_is_enabled
  );
end;
$$;

revoke all on function public.admin_finance_snapshot()
from public, anon, authenticated;
revoke all on function public.admin_finance_add_entry(date, text, bigint, text, text, text, text)
from public, anon, authenticated;
revoke all on function public.admin_finance_void_entry(uuid, text)
from public, anon, authenticated;
revoke all on function public.admin_radio_mondo_list()
from public, anon, authenticated;
revoke all on function public.admin_radio_mondo_upsert(uuid, text, text, integer, boolean, text, text, boolean, text)
from public, anon, authenticated;
revoke all on function public.admin_radio_mondo_set_enabled(uuid, boolean, text)
from public, anon, authenticated;
revoke all on function public.radio_mondo_public_catalog()
from public, anon, authenticated;

grant execute on function public.admin_finance_snapshot()
to authenticated;
grant execute on function public.admin_finance_add_entry(date, text, bigint, text, text, text, text)
to authenticated;
grant execute on function public.admin_finance_void_entry(uuid, text)
to authenticated;
grant execute on function public.admin_radio_mondo_list()
to authenticated;
grant execute on function public.admin_radio_mondo_upsert(uuid, text, text, integer, boolean, text, text, boolean, text)
to authenticated;
grant execute on function public.admin_radio_mondo_set_enabled(uuid, boolean, text)
to authenticated;
grant execute on function public.radio_mondo_public_catalog()
to anon, authenticated;

commit;
