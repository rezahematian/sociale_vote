-- Social Vote
-- Minimum account-deletion cleanup for store/privacy compliance.
--
-- Effects for both self-service and administrative Auth deletion:
-- - delete posts, polls and comments created by the deleted account;
-- - delete dependent interactions and bookmarks for content that disappears;
-- - keep votes and reactions on other users' content, but remove user_id;
-- - preserve vote totals and Heat for content that remains online;
-- - preserve minimized account-control and administrative audit records;
-- - backfill the same cleanup for accounts already marked as deleted.

begin;

-- Fail safely if the production schema no longer permits anonymization.
do $$
begin
  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'votes'
      and column_name = 'user_id'
      and is_nullable = 'YES'
  ) then
    raise exception
      'public.votes.user_id must be nullable before account cleanup.';
  end if;

  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'reactions'
      and column_name = 'user_id'
      and is_nullable = 'YES'
  ) then
    raise exception
      'public.reactions.user_id must be nullable before account cleanup.';
  end if;
end;
$$;

create or replace function app_private.erase_deleted_user_content(
  p_user_id uuid
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if p_user_id is null then
    raise exception
      using
        errcode = '22004',
        message = 'A user id is required for account cleanup.';
  end if;

  -- Replies written by other users must not become hidden or orphaned when
  -- their deleted parent comment belonged to content that remains online.
  update public.comments child_comment
  set
    parent_id = null,
    depth = 0
  where child_comment.parent_id is not null
    and exists (
      select 1
      from public.comments parent_comment
      where parent_comment.id::text = child_comment.parent_id::text
        and (
          parent_comment.author_id = p_user_id
          or (
            lower(btrim(parent_comment.target_type::text)) = 'post'
            and exists (
              select 1
              from public.posts owned_post
              where owned_post.author_id = p_user_id
                and owned_post.id::text =
                  btrim(parent_comment.target_id::text)
            )
          )
          or (
            lower(btrim(parent_comment.target_type::text)) = 'poll'
            and exists (
              select 1
              from public.polls owned_poll
              where owned_poll.author_id = p_user_id
                and owned_poll.id::text =
                  btrim(parent_comment.target_id::text)
            )
          )
        )
    )
    and child_comment.author_id <> p_user_id
    and not (
      lower(btrim(child_comment.target_type::text)) = 'post'
      and exists (
        select 1
        from public.posts owned_post
        where owned_post.author_id = p_user_id
          and owned_post.id::text = btrim(child_comment.target_id::text)
      )
    )
    and not (
      lower(btrim(child_comment.target_type::text)) = 'poll'
      and exists (
        select 1
        from public.polls owned_poll
        where owned_poll.author_id = p_user_id
          and owned_poll.id::text = btrim(child_comment.target_id::text)
      )
    );

  -- Remove broken links for content that will disappear. Reports, moderation
  -- state and append-only audit are intentionally preserved for safety.
  delete from public.notifications notification_row
  where (
    lower(btrim(notification_row.target_type::text)) = 'post'
    and exists (
      select 1
      from public.posts owned_post
      where owned_post.author_id = p_user_id
        and owned_post.id::text = btrim(notification_row.target_id::text)
    )
  )
  or (
    lower(btrim(notification_row.target_type::text)) = 'poll'
    and exists (
      select 1
      from public.polls owned_poll
      where owned_poll.author_id = p_user_id
        and owned_poll.id::text = btrim(notification_row.target_id::text)
    )
  );

  delete from public.favorites favorite_row
  where (
    lower(btrim(favorite_row.target_type::text)) = 'post'
    and exists (
      select 1
      from public.posts owned_post
      where owned_post.author_id = p_user_id
        and owned_post.id::text = btrim(favorite_row.target_id::text)
    )
  )
  or (
    lower(btrim(favorite_row.target_type::text)) = 'poll'
    and exists (
      select 1
      from public.polls owned_poll
      where owned_poll.author_id = p_user_id
        and owned_poll.id::text = btrim(favorite_row.target_id::text)
    )
  );

  delete from public.reactions reaction_row
  where (
    lower(btrim(reaction_row.target_type::text)) = 'post'
    and exists (
      select 1
      from public.posts owned_post
      where owned_post.author_id = p_user_id
        and owned_post.id::text = btrim(reaction_row.target_id::text)
    )
  )
  or (
    lower(btrim(reaction_row.target_type::text)) = 'poll'
    and exists (
      select 1
      from public.polls owned_poll
      where owned_poll.author_id = p_user_id
        and owned_poll.id::text = btrim(reaction_row.target_id::text)
    )
  );

  -- Remove the user's comments everywhere and all comments attached to a post
  -- or poll that is itself being deleted.
  delete from public.comments comment_row
  where comment_row.author_id = p_user_id
    or (
      lower(btrim(comment_row.target_type::text)) = 'post'
      and exists (
        select 1
        from public.posts owned_post
        where owned_post.author_id = p_user_id
          and owned_post.id::text = btrim(comment_row.target_id::text)
      )
    )
    or (
      lower(btrim(comment_row.target_type::text)) = 'poll'
      and exists (
        select 1
        from public.polls owned_poll
        where owned_poll.author_id = p_user_id
          and owned_poll.id::text = btrim(comment_row.target_id::text)
      )
    );

  -- Keep aggregate results on content that remains online while removing the
  -- deleted account's identity. PostgreSQL unique indexes permit multiple NULL
  -- values, so the existing one-vote/one-reaction rules remain valid for users.
  update public.votes
  set user_id = null
  where user_id = p_user_id;

  update public.reactions
  set user_id = null
  where user_id = p_user_id;

  delete from public.posts
  where author_id = p_user_id;

  -- Votes belonging to these deleted polls are removed by the existing
  -- votes.poll_id ON DELETE CASCADE. Votes on every other poll remain intact.
  delete from public.polls
  where author_id = p_user_id;
end;
$$;

comment on function app_private.erase_deleted_user_content(uuid) is
  'Deletes user-authored content and removes account identity from retained votes and reactions.';

revoke all
on function app_private.erase_deleted_user_content(uuid)
from public, anon, authenticated;

-- Extend the existing centralized Auth-deletion trigger. This keeps the same
-- behavior for the user Edge Function and the administrative deletion flow.
create or replace function app_private.prepare_deleted_auth_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
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

-- Apply the same policy to accounts deleted before this migration. The
-- account_controls row is the authoritative deletion marker and Auth absence
-- prevents cleanup of any active account.
do $$
declare
  v_deleted_user_id uuid;
begin
  for v_deleted_user_id in
    select account_state.user_id
    from app_private.account_controls account_state
    where account_state.status = 'deleted'
      and not exists (
        select 1
        from auth.users auth_user
        where auth_user.id = account_state.user_id
      )
  loop
    perform app_private.erase_deleted_user_content(v_deleted_user_id);
  end loop;
end;
$$;

commit;
