-- Social Vote
-- Transactional anonymization for deleted Auth accounts.
--
-- Purpose:
-- - keep public.users.id so historical posts, polls, comments, reactions
--   and votes retain valid foreign-key references;
-- - remove personal fields when the Auth account is deleted;
-- - remove the private latest-session registry entry;
-- - cover every Auth deletion path, including the delete-account Edge Function.

begin;

create schema if not exists app_private;

create or replace function app_private.prepare_deleted_auth_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.users
  set
    email = null,
    display_name = null,
    role = 'user'
  where id = old.id;

  delete from app_private.active_user_sessions
  where user_id = old.id;

  return old;
end;
$$;

revoke all
on function app_private.prepare_deleted_auth_user()
from public, anon, authenticated;

drop trigger if exists
  social_vote_prepare_deleted_auth_user
on auth.users;

create trigger social_vote_prepare_deleted_auth_user
before delete on auth.users
for each row
execute function app_private.prepare_deleted_auth_user();

commit;
