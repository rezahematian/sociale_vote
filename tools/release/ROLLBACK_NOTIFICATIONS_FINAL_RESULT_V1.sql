-- SOCIAL VOTE — ROLLBACK NOTIFICATIONS FINAL RESULT V1
-- Restores the previous client poll_result insert policy and archived legacy
-- rows. Final-result rows created by V1 are removed before legacy restoration.

begin;

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

drop function if exists app_private.emit_due_poll_result_notifications_v1();
drop index if exists public.notifications_poll_result_final_unique_v1;

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
      'mention'::text,
      'poll_result'::text
    ]
  )
  and (select public.is_current_auth_user_active())
);

delete from public.notifications
where type = 'poll_result';

insert into public.notifications (
  id,
  recipient_user_id,
  actor_user_id,
  type,
  target_type,
  target_id,
  comment_id,
  is_read,
  created_at
)
select
  archive.id,
  archive.recipient_user_id,
  archive.actor_user_id,
  archive.type,
  archive.target_type,
  archive.target_id,
  archive.comment_id,
  archive.is_read,
  archive.created_at
from app_private.poll_result_notification_legacy_archive_v1 archive
where not exists (
  select 1
  from public.notifications current_row
  where current_row.id = archive.id
);

drop table if exists app_private.poll_result_notification_state_v1;
drop table if exists app_private.poll_result_notification_legacy_archive_v1;

commit;
