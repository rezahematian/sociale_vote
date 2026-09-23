-- SOCIAL VOTE — NOTIFICATIONS FINAL RESULT V1
-- Goals:
-- 1) stop poll_result creation for every individual vote, including old clients;
-- 2) preserve comment_reply and mention client notifications;
-- 3) keep poll_published broadcast behavior untouched/OFF;
-- 4) emit one final poll_result notification per authenticated participant
--    after a Vote becomes effectively closed;
-- 5) avoid historical notification floods by activating only for Votes whose
--    end_at (or creation when end_at is null) is on/after this migration.

begin;

create extension if not exists pg_cron;

-- Keep a reversible backend-only archive of legacy per-vote poll_result rows.
create table if not exists app_private.poll_result_notification_legacy_archive_v1
(like public.notifications including defaults);

revoke all on table app_private.poll_result_notification_legacy_archive_v1
from public, anon, authenticated;

insert into app_private.poll_result_notification_legacy_archive_v1
select n.*
from public.notifications n
where n.type = 'poll_result'
  and not exists (
    select 1
    from app_private.poll_result_notification_legacy_archive_v1 a
    where a.id = n.id
  );

-- Remove legacy per-vote noise from the live Notification Center.
delete from public.notifications
where type = 'poll_result';

-- Old Play clients still try to insert poll_result after a vote. Deny that
-- specific client-side type while preserving replies and mentions.
drop policy if exists notifications_insert_policy on public.notifications;

create policy notifications_insert_policy
on public.notifications
for insert
to authenticated
with check (
  actor_user_id = (select auth.uid())
  and type = any (
    array[
      'comment_reply'::text,
      'mention'::text
    ]
  )
  and (select public.is_current_auth_user_active())
);

-- One final result notification per participant and Vote.
create unique index if not exists notifications_poll_result_final_unique_v1
on public.notifications (recipient_user_id, target_id)
where type = 'poll_result' and target_type = 'poll';

create table if not exists app_private.poll_result_notification_state_v1 (
  singleton boolean primary key default true check (singleton),
  activated_at timestamptz not null
);

revoke all on table app_private.poll_result_notification_state_v1
from public, anon, authenticated;

insert into app_private.poll_result_notification_state_v1 (
  singleton,
  activated_at
)
values (true, clock_timestamp())
on conflict (singleton) do nothing;

create or replace function app_private.emit_due_poll_result_notifications_v1()
returns integer
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_activated_at timestamptz;
  v_inserted integer := 0;
begin
  select state.activated_at
  into v_activated_at
  from app_private.poll_result_notification_state_v1 state
  where state.singleton = true;

  if v_activated_at is null then
    raise exception using
      errcode = '55000',
      message = 'SV_NOTIFICATION_FINAL_RESULT_STATE_MISSING';
  end if;

  insert into public.notifications (
    recipient_user_id,
    actor_user_id,
    type,
    target_type,
    target_id,
    comment_id,
    is_read,
    created_at
  )
  select distinct
    vote.user_id,
    vote.user_id,
    'poll_result',
    'poll',
    poll.id::text,
    null,
    false,
    clock_timestamp()
  from public.polls poll
  join public.votes vote
    on vote.poll_id = poll.id
  join auth.users auth_user
    on auth_user.id = vote.user_id
  where vote.user_id is not null
    and poll.status in ('open', 'closed', 'scheduled')
    and (
      (poll.end_at is not null and poll.end_at <= clock_timestamp())
      or poll.status = 'closed'
    )
    and (
      (poll.end_at is not null and poll.end_at >= v_activated_at)
      or (
        poll.end_at is null
        and poll.created_at is not null
        and poll.created_at >= v_activated_at
      )
    )
    and not exists (
      select 1
      from public.notifications existing
      where existing.recipient_user_id = vote.user_id
        and existing.type = 'poll_result'
        and existing.target_type = 'poll'
        and existing.target_id = poll.id::text
    )
  on conflict do nothing;

  get diagnostics v_inserted = row_count;
  return v_inserted;
end;
$function$;

revoke all
on function app_private.emit_due_poll_result_notifications_v1()
from public, anon, authenticated;

-- Keep exactly one scheduler entry. Ten minutes is enough for a result-ready
-- notification and avoids creating load proportional to vote traffic.
do $block$
declare
  v_jobid bigint;
begin
  for v_jobid in
    select jobid
    from cron.job
    where jobname = 'poll-final-result-notifications-v1'
  loop
    perform cron.unschedule(v_jobid);
  end loop;
end;
$block$;

select cron.schedule(
  'poll-final-result-notifications-v1',
  '*/10 * * * *',
  $$select app_private.emit_due_poll_result_notifications_v1();$$
);

-- Migration-internal VERIFY. Any failure aborts the whole transaction.
do $verify$
declare
  v_policy text;
  v_live_poll_result_count bigint;
  v_job_count integer;
begin
  select p.with_check
  into v_policy
  from pg_policies p
  where p.schemaname = 'public'
    and p.tablename = 'notifications'
    and p.policyname = 'notifications_insert_policy';

  if v_policy is null
     or position('comment_reply' in v_policy) = 0
     or position('mention' in v_policy) = 0
     or position('poll_result' in v_policy) > 0 then
    raise exception using
      errcode = '55000',
      message = 'SV_NOTIFICATION_POLICY_VERIFY_FAILED';
  end if;

  select count(*)
  into v_live_poll_result_count
  from public.notifications
  where type = 'poll_result';

  if v_live_poll_result_count <> 0 then
    raise exception using
      errcode = '55000',
      message = 'SV_NOTIFICATION_LEGACY_CLEANUP_VERIFY_FAILED';
  end if;

  if to_regprocedure(
    'app_private.emit_due_poll_result_notifications_v1()'
  ) is null then
    raise exception using
      errcode = '55000',
      message = 'SV_NOTIFICATION_FUNCTION_VERIFY_FAILED';
  end if;

  if to_regclass(
    'public.notifications_poll_result_final_unique_v1'
  ) is null then
    raise exception using
      errcode = '55000',
      message = 'SV_NOTIFICATION_DEDUP_VERIFY_FAILED';
  end if;

  select count(*)
  into v_job_count
  from cron.job
  where jobname = 'poll-final-result-notifications-v1'
    and active = true;

  if v_job_count <> 1 then
    raise exception using
      errcode = '55000',
      message = 'SV_NOTIFICATION_CRON_VERIFY_FAILED';
  end if;
end;
$verify$;

commit;
