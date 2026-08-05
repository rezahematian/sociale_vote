-- Social Vote
-- Backfill anonymization for historical public.users rows whose Auth account
-- was already deleted before the current centralized deletion trigger ran.
--
-- This migration intentionally does not delete or modify posts, polls,
-- comments, votes, reactions, vote totals or Heat.

begin;

-- Only records explicitly marked as deleted and no longer present in Auth are
-- eligible. The Auth-absence check protects any currently active account even
-- if its private control state were inconsistent.
update public.users public_user
set
  email = null,
  display_name = null,
  role = 'user'
where exists (
  select 1
  from app_private.account_controls account_state
  where account_state.user_id = public_user.id
    and account_state.status = 'deleted'
)
and not exists (
  select 1
  from auth.users auth_user
  where auth_user.id = public_user.id
)
and (
  public_user.email is not null
  or public_user.display_name is not null
  or lower(coalesce(public_user.role::text, '')) <> 'user'
);

-- Fail the transaction if a historical deleted account still exposes any of
-- the personal fields handled by the production deletion trigger.
do $$
begin
  if exists (
    select 1
    from public.users public_user
    join app_private.account_controls account_state
      on account_state.user_id = public_user.id
     and account_state.status = 'deleted'
    where not exists (
      select 1
      from auth.users auth_user
      where auth_user.id = public_user.id
    )
      and (
        public_user.email is not null
        or public_user.display_name is not null
        or lower(coalesce(public_user.role::text, '')) <> 'user'
      )
  ) then
    raise exception
      'Historical deleted public users were not fully anonymized.';
  end if;
end;
$$;

commit;
