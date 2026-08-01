-- Social Vote — AC8.5 / AC9
-- Final administrator resolution for escalated reports.
--
-- Rules:
-- - only a synchronized administrator may resolve an escalated report;
-- - the report must still be in_review with moderation_decision=escalate_to_admin;
-- - no_account_action may be recorded directly;
-- - account_suspended, logout_forced and account_deleted require a matching
--   successful/noop account-action audit created after the escalation;
-- - the report resolution and permanent audit are committed together;
-- - repeated identical requests are idempotent.

begin;

create or replace function public.admin_resolve_escalated_report(
  p_report_id uuid,
  p_actor_user_id uuid,
  p_actor_role text,
  p_resolution text,
  p_note text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor_role text := lower(btrim(coalesce(p_actor_role, '')));
  v_resolution text := lower(btrim(coalesce(p_resolution, '')));
  v_note text := btrim(coalesce(p_note, ''));

  v_actor_auth_role text;
  v_actor_mirror_role text;

  v_report public.reports%rowtype;
  v_target_type text;
  v_target_id text;
  v_reported_user_id uuid;
  v_required_audit_action text;
  v_account_action_verified boolean := false;
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
        message = 'Report and administrator identifiers are required.';
  end if;

  if v_actor_role <> 'admin' then
    raise exception
      using
        errcode = '42501',
        message = 'Administrator access is required.';
  end if;

  if v_resolution not in (
    'no_account_action',
    'account_suspended',
    'logout_forced',
    'account_deleted'
  ) then
    raise exception
      using
        errcode = '22023',
        message =
          'Resolution must be no_account_action, account_suspended, logout_forced, or account_deleted.';
  end if;

  if char_length(v_note) < 3 or char_length(v_note) > 2000 then
    raise exception
      using
        errcode = '22023',
        message =
          'Administrator resolution note must contain between 3 and 2000 characters.';
  end if;

  select
    lower(coalesce(au.raw_app_meta_data ->> 'role', 'user')),
    lower(coalesce(pu.role::text, 'user'))
  into
    v_actor_auth_role,
    v_actor_mirror_role
  from auth.users au
  left join public.users pu
    on pu.id = au.id
  where au.id = p_actor_user_id;

  if
    not found
    or v_actor_auth_role <> 'admin'
    or v_actor_mirror_role <> 'admin'
  then
    raise exception
      using
        errcode = '42501',
        message = 'Administrator role is not synchronized.';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(
      'admin-resolve-escalated-report:' || p_report_id::text,
      0
    )
  );

  select *
  into v_report
  from public.reports r
  where r.id = p_report_id
  for update;

  if not found then
    raise exception
      using
        errcode = 'P0002',
        message = 'Report was not found.';
  end if;

  if lower(btrim(coalesce(v_report.moderation_decision, ''))) <>
      'escalate_to_admin'
  then
    raise exception
      using
        errcode = '22023',
        message = 'Only reports escalated to an administrator can be resolved here.';
  end if;

  -- Safe retry after the first successful completion.
  if v_report.admin_resolution is not null then
    if
      v_report.admin_resolution = v_resolution
      and v_report.admin_resolution_note = v_note
      and v_report.admin_resolved_by = p_actor_user_id
    then
      return jsonb_build_object(
        'success', true,
        'changed', false,
        'replayed', true,
        'reportId', p_report_id,
        'previousStatus', v_report.status,
        'status', v_report.status,
        'resolution', v_report.admin_resolution,
        'resolvedBy', v_report.admin_resolved_by,
        'resolvedAt', v_report.admin_resolved_at
      );
    end if;

    raise exception
      using
        errcode = '23505',
        message = 'The escalated report already has a final administrator resolution.';
  end if;

  if lower(btrim(coalesce(v_report.status, ''))) <> 'in_review' then
    raise exception
      using
        errcode = '23505',
        message = 'The escalated report is no longer awaiting an administrator decision.';
  end if;

  v_target_type := lower(btrim(coalesce(v_report.target_type::text, '')));
  v_target_id := btrim(coalesce(v_report.target_id::text, ''));

  if v_target_type = 'poll' then
    select p.author_id
    into v_reported_user_id
    from public.polls p
    where p.id::text = v_target_id
    limit 1;
  elsif v_target_type = 'post' then
    select p.author_id
    into v_reported_user_id
    from public.posts p
    where p.id::text = v_target_id
    limit 1;
  else
    v_reported_user_id := null;
  end if;

  if v_resolution <> 'no_account_action' then
    if v_reported_user_id is null then
      raise exception
        using
          errcode = '22023',
          message =
            'This report does not identify an account that can receive the selected action.';
    end if;

    v_required_audit_action := case v_resolution
      when 'account_suspended' then 'suspend_account'
      when 'logout_forced' then 'force_account_logout'
      when 'account_deleted' then 'delete_account'
      else null
    end;

    select exists (
      select 1
      from public.admin_audit_logs aal
      where aal.actor_user_id = p_actor_user_id
        and aal.actor_role = 'admin'
        and aal.action = v_required_audit_action
        and aal.target_type = 'user'
        and aal.target_id = v_reported_user_id::text
        and aal.result in ('success', 'noop')
        and aal.created_at >= coalesce(
          v_report.reviewed_at,
          v_report.created_at
        )
    )
    into v_account_action_verified;

    if not v_account_action_verified then
      raise exception
        using
          errcode = '23505',
          message =
            'The matching administrator account action must be completed before resolving this report.';
    end if;
  end if;

  update public.reports
  set
    admin_resolution = v_resolution,
    admin_resolution_note = v_note,
    admin_resolved_by = p_actor_user_id,
    admin_resolved_at = v_now
  where id = p_report_id;

  -- The escalation-state trigger changes status to resolved in the same update.
  select *
  into v_report
  from public.reports r
  where r.id = p_report_id;

  insert into public.admin_audit_logs (
    actor_user_id,
    actor_role,
    action,
    target_type,
    target_id,
    previous_value,
    new_value,
    reason,
    result,
    error_code
  )
  values (
    p_actor_user_id,
    'admin',
    'resolve_escalated_report',
    'report',
    p_report_id::text,
    jsonb_build_object(
      'status', 'in_review',
      'moderationDecision', 'escalate_to_admin',
      'adminResolution', null
    ),
    jsonb_build_object(
      'status', v_report.status,
      'moderationDecision', v_report.moderation_decision,
      'adminResolution', v_report.admin_resolution,
      'reportedUserId', v_reported_user_id,
      'accountActionVerified', v_account_action_verified
    ),
    v_note,
    'success',
    null
  );

  return jsonb_build_object(
    'success', true,
    'changed', true,
    'replayed', false,
    'reportId', p_report_id,
    'previousStatus', 'in_review',
    'status', v_report.status,
    'resolution', v_report.admin_resolution,
    'reportedUserId', v_reported_user_id,
    'accountActionVerified', v_account_action_verified,
    'resolvedBy', v_report.admin_resolved_by,
    'resolvedAt', v_report.admin_resolved_at
  );
end;
$$;

comment on function public.admin_resolve_escalated_report(
  uuid,
  uuid,
  text,
  text,
  text
) is
  'Backend-only final administrator resolution for an escalated report, with account-action audit verification and permanent audit.';

revoke all
on function public.admin_resolve_escalated_report(
  uuid,
  uuid,
  text,
  text,
  text
)
from public, anon, authenticated;

grant execute
on function public.admin_resolve_escalated_report(
  uuid,
  uuid,
  text,
  text,
  text
)
to service_role;

notify pgrst, 'reload schema';

commit;
