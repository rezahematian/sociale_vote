-- SOCIAL VOTE
-- Read-only verification for 20260819_account_identity_discovery_foundation.sql

with checks as (
  select
    to_regclass('public.account_follows') is not null
      as account_follows_table,
    exists (
      select 1
      from pg_class c
      join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public'
        and c.relname = 'account_follows'
        and c.relrowsecurity
    ) as account_follows_rls,
    to_regprocedure('public.get_account_follow_state(uuid)') is not null
      as follow_state_rpc,
    to_regprocedure('public.toggle_account_follow(uuid)') is not null
      as follow_toggle_rpc,
    to_regprocedure('public.get_my_followed_account_ids()') is not null
      as followed_accounts_rpc,
    to_regprocedure(
      'public.search_public_accounts(text,integer,integer)'
    ) is not null as account_discovery_rpc,
    to_regprocedure(
      'public.review_verification_request_secure(uuid,text,text)'
    ) is not null as secure_review_rpc,
    exists (
      select 1
      from pg_trigger t
      join pg_class c on c.oid = t.tgrelid
      join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public'
        and c.relname = 'user_profiles'
        and t.tgname = 'protect_user_profile_identity_fields_trigger'
        and not t.tgisinternal
    ) as identity_guard_trigger,
    exists (
      select 1
      from pg_trigger t
      join pg_class c on c.oid = t.tgrelid
      join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public'
        and c.relname = 'blocked_users'
        and t.tgname = 'remove_account_follows_after_block_trigger'
        and not t.tgisinternal
    ) as block_cleanup_trigger,
    exists (
      select 1
      from pg_constraint con
      join pg_class c on c.oid = con.conrelid
      join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public'
        and c.relname = 'verification_requests'
        and con.conname = 'verification_requests_shape_check'
    ) as verification_shape_guard
)
select
  case
    when account_follows_table
      and account_follows_rls
      and follow_state_rpc
      and follow_toggle_rpc
      and followed_accounts_rpc
      and account_discovery_rpc
      and secure_review_rpc
      and identity_guard_trigger
      and block_cleanup_trigger
      and verification_shape_guard
      then 'ACCOUNT IDENTITY DISCOVERY FOUNDATION PASS'
    else 'ACCOUNT IDENTITY DISCOVERY FOUNDATION FAIL'
  end as result,
  *
from checks;
