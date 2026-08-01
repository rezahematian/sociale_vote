-- Social Vote
-- Admin Center AC8.5.1: backend foundation for hiding/restoring reported content.
--
-- Scope of this migration:
-- - stores an authoritative moderation visibility state independently from the
--   current Poll/Post/News schemas;
-- - exposes one backend-only, idempotent RPC for hide/restore;
-- - requires a previously recorded violation_confirmed report decision;
-- - validates a synchronized moderator/admin account;
-- - resolves the report after a valid content action.
--
-- Public feed/detail enforcement, Edge Function wiring, report read-model
-- exposure and Flutter UI remain subsequent AC8.5 micro-steps.
-- Full permanent action audit remains AC8.6.

begin;

create table if not exists app_private.admin_content_visibility (
  target_type text not null,
  target_id text not null,
  is_hidden boolean not null default false,
  hidden_by uuid,
  hidden_at timestamptz,
  hidden_reason text,
  restored_by uuid,
  restored_at timestamptz,
  restore_reason text,
  last_report_id uuid not null,
  version bigint not null default 1,
  updated_at timestamptz not null default now(),

  constraint admin_content_visibility_pk
    primary key (target_type, target_id),

  constraint admin_content_visibility_target_type_check
    check (target_type in ('poll', 'post', 'news')),

  constraint admin_content_visibility_target_id_check
    check (
      nullif(btrim(target_id), '') is not null
      and char_length(target_id) <= 320
    ),

  constraint admin_content_visibility_hidden_metadata_check
    check (
      (
        hidden_by is null
        and hidden_at is null
        and hidden_reason is null
      )
      or
      (
        hidden_by is not null
        and hidden_at is not null
        and nullif(btrim(hidden_reason), '') is not null
        and char_length(hidden_reason) between 3 and 2000
      )
    ),

  constraint admin_content_visibility_restore_metadata_check
    check (
      (
        restored_by is null
        and restored_at is null
        and restore_reason is null
      )
      or
      (
        restored_by is not null
        and restored_at is not null
        and nullif(btrim(restore_reason), '') is not null
        and char_length(restore_reason) between 3 and 2000
      )
    ),

  constraint admin_content_visibility_state_shape_check
    check (
      (
        is_hidden = true
        and hidden_by is not null
        and hidden_at is not null
        and hidden_reason is not null
        and restored_by is null
        and restored_at is null
        and restore_reason is null
      )
      or
      (
        is_hidden = false
        and (
          (
            hidden_by is null
            and hidden_at is null
            and hidden_reason is null
            and restored_by is null
            and restored_at is null
            and restore_reason is null
          )
          or
          (
            hidden_by is not null
            and hidden_at is not null
            and hidden_reason is not null
            and restored_by is not null
            and restored_at is not null
            and restore_reason is not null
          )
        )
      )
    ),

  constraint admin_content_visibility_version_check
    check (version >= 1)
);

comment on table app_private.admin_content_visibility is
  'Private authoritative visibility state for content moderated through Admin Center reports.';

comment on column app_private.admin_content_visibility.target_id is
  'Generic content identifier stored as text to support Poll, Post and News identifiers without coupling to one table type.';

comment on column app_private.admin_content_visibility.version is
  'Monotonic version incremented after every real hide or restore transition.';

alter table app_private.admin_content_visibility
  enable row level security;

alter table app_private.admin_content_visibility
  force row level security;

revoke all
on table app_private.admin_content_visibility
from public, anon, authenticated;

grant select, insert, update
on table app_private.admin_content_visibility
to service_role;

create index if not exists
  admin_content_visibility_hidden_updated_idx
on app_private.admin_content_visibility (
  is_hidden,
  updated_at desc
);

create index if not exists
  admin_content_visibility_report_idx
on app_private.admin_content_visibility (
  last_report_id
);

create or replace function public.admin_set_report_content_visibility(
  p_report_id uuid,
  p_actor_user_id uuid,
  p_actor_role text,
  p_action text,
  p_reason text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor_role text := lower(btrim(coalesce(p_actor_role, '')));
  v_auth_role text;
  v_mirror_role text;
  v_action text := lower(btrim(coalesce(p_action, '')));
  v_reason text := btrim(coalesce(p_reason, ''));

  v_target_type text;
  v_target_id text;
  v_report_decision text;
  v_previous_report_status text;

  v_state_exists boolean := false;
  v_previous_is_hidden boolean := false;
  v_new_is_hidden boolean;
  v_changed boolean := false;
  v_now timestamptz := clock_timestamp();
begin
  if coalesce((select auth.role()), '') <> 'service_role' then
    raise exception
      using
        errcode = '42501',
        message = 'Service role access is required.';
  end if;

  if p_report_id is null or p_actor_user_id is null then
    raise exception
      using
        errcode = '22004',
        message = 'Report and staff user identifiers are required.';
  end if;

  if v_actor_role not in ('moderator', 'admin') then
    raise exception
      using
        errcode = '42501',
        message = 'Moderator or administrator access is required.';
  end if;

  if v_action not in ('hide', 'restore') then
    raise exception
      using
        errcode = '22023',
        message = 'Content action must be hide or restore.';
  end if;

  if char_length(v_reason) < 3 or char_length(v_reason) > 2000 then
    raise exception
      using
        errcode = '22023',
        message = 'Action reason must contain between 3 and 2000 characters.';
  end if;

  select
    lower(coalesce(au.raw_app_meta_data ->> 'role', 'user')),
    lower(coalesce(pu.role::text, 'user'))
  into
    v_auth_role,
    v_mirror_role
  from auth.users au
  left join public.users pu
    on pu.id = au.id
  where au.id = p_actor_user_id;

  if
    not found
    or v_auth_role <> v_actor_role
    or v_mirror_role <> v_actor_role
  then
    raise exception
      using
        errcode = '42501',
        message = 'Staff role is not synchronized.';
  end if;

  select
    lower(btrim(r.target_type::text)),
    btrim(r.target_id::text),
    lower(btrim(coalesce(r.moderation_decision, ''))),
    lower(btrim(coalesce(r.status, '')))
  into
    v_target_type,
    v_target_id,
    v_report_decision,
    v_previous_report_status
  from public.reports r
  where r.id = p_report_id
  for update;

  if not found then
    raise exception
      using
        errcode = 'P0002',
        message = 'Report was not found.';
  end if;

  if v_target_type not in ('poll', 'post', 'news') then
    raise exception
      using
        errcode = '22023',
        message = 'Unsupported report target type.';
  end if;

  if
    v_target_id is null
    or v_target_id = ''
    or char_length(v_target_id) > 320
  then
    raise exception
      using
        errcode = '22023',
        message = 'The reported content identifier is invalid.';
  end if;

  if v_report_decision <> 'violation_confirmed' then
    raise exception
      using
        errcode = '55000',
        message = 'Content visibility can change only after a confirmed violation.';
  end if;

  -- Poll and Post are first-party records and must still exist.
  -- News can be externally sourced or cache-backed, so the report itself is
  -- the authoritative target reference for this moderation state.
  if
    v_target_type = 'poll'
    and not exists (
      select 1
      from public.polls p
      where p.id::text = v_target_id
    )
  then
    raise exception
      using
        errcode = 'P0002',
        message = 'Reported poll was not found.';
  end if;

  if
    v_target_type = 'post'
    and not exists (
      select 1
      from public.posts p
      where p.id::text = v_target_id
    )
  then
    raise exception
      using
        errcode = 'P0002',
        message = 'Reported post was not found.';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(
      'admin-content-visibility:'
      || v_target_type
      || ':'
      || v_target_id,
      0
    )
  );

  select visibility.is_hidden
  into v_previous_is_hidden
  from app_private.admin_content_visibility visibility
  where visibility.target_type = v_target_type
    and visibility.target_id = v_target_id
  for update;

  v_state_exists := found;

  if v_action = 'hide' then
    v_new_is_hidden := true;

    if not v_state_exists or v_previous_is_hidden = false then
      insert into app_private.admin_content_visibility as visibility (
        target_type,
        target_id,
        is_hidden,
        hidden_by,
        hidden_at,
        hidden_reason,
        restored_by,
        restored_at,
        restore_reason,
        last_report_id,
        version,
        updated_at
      )
      values (
        v_target_type,
        v_target_id,
        true,
        p_actor_user_id,
        v_now,
        v_reason,
        null,
        null,
        null,
        p_report_id,
        1,
        v_now
      )
      on conflict (target_type, target_id) do update
      set
        is_hidden = true,
        hidden_by = excluded.hidden_by,
        hidden_at = excluded.hidden_at,
        hidden_reason = excluded.hidden_reason,
        restored_by = null,
        restored_at = null,
        restore_reason = null,
        last_report_id = excluded.last_report_id,
        version = visibility.version + 1,
        updated_at = excluded.updated_at;

      v_changed := true;
    end if;
  else
    v_new_is_hidden := false;

    if v_state_exists and v_previous_is_hidden = true then
      update app_private.admin_content_visibility visibility
      set
        is_hidden = false,
        restored_by = p_actor_user_id,
        restored_at = v_now,
        restore_reason = v_reason,
        last_report_id = p_report_id,
        version = visibility.version + 1,
        updated_at = v_now
      where visibility.target_type = v_target_type
        and visibility.target_id = v_target_id;

      v_changed := true;
    end if;
  end if;

  update public.reports
  set status = 'resolved'
  where id = p_report_id;

  return jsonb_build_object(
    'success', true,
    'changed', v_changed,
    'reportId', p_report_id,
    'previousReportStatus', v_previous_report_status,
    'reportStatus', 'resolved',
    'targetType', v_target_type,
    'targetId', v_target_id,
    'action', v_action,
    'previousIsHidden', case
      when v_state_exists then v_previous_is_hidden
      else false
    end,
    'isHidden', v_new_is_hidden,
    'performedBy', p_actor_user_id,
    'performedAt', v_now
  );
end;
$$;

comment on function public.admin_set_report_content_visibility(
  uuid,
  uuid,
  text,
  text,
  text
) is
  'Backend-only idempotent hide/restore action for content with a confirmed report violation.';

revoke all
on function public.admin_set_report_content_visibility(
  uuid,
  uuid,
  text,
  text,
  text
)
from public, anon, authenticated;

grant execute
on function public.admin_set_report_content_visibility(
  uuid,
  uuid,
  text,
  text,
  text
)
to service_role;

notify pgrst, 'reload schema';

commit;
