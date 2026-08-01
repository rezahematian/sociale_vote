-- Social Vote
-- Admin Center AC8.5.3: enforce moderated visibility for first-party content.
--
-- Effects:
-- - hidden posts and polls are excluded from every normal client SELECT;
-- - anonymous users and standard users cannot read hidden content;
-- - synchronized moderator/admin accounts can still inspect hidden content;
-- - service-role backend operations remain unaffected by RLS bypass;
-- - existing permissive policies are preserved unchanged.

begin;

create or replace function public.can_read_moderated_content(
  p_target_type text,
  p_target_id text
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select
    not exists (
      select 1
      from app_private.admin_content_visibility visibility
      where visibility.target_type =
              lower(btrim(coalesce(p_target_type, '')))
        and visibility.target_id =
              btrim(coalesce(p_target_id, ''))
        and visibility.is_hidden = true
    )
    or (
      (select auth.uid()) is not null
      and lower(
        coalesce(
          (select auth.jwt() -> 'app_metadata' ->> 'role'),
          ''
        )
      ) in ('moderator', 'admin')
      and exists (
        select 1
        from public.users staff_user
        where staff_user.id = (select auth.uid())
          and lower(coalesce(staff_user.role::text, '')) =
              lower(
                coalesce(
                  (select auth.jwt() -> 'app_metadata' ->> 'role'),
                  ''
                )
              )
      )
      and (select public.is_current_auth_user_active())
    );
$$;

comment on function public.can_read_moderated_content(text, text) is
  'Returns whether the current client may read a moderated content target. Hidden targets remain available only to synchronized active moderator/admin accounts.';

revoke all
on function public.can_read_moderated_content(text, text)
from public;

grant execute
on function public.can_read_moderated_content(text, text)
to anon, authenticated, service_role;

-- Restrictive policies are AND-ed with all existing permissive SELECT policies.
-- This preserves the current ownership, geo-scope and publication rules.

drop policy if exists
  posts_moderated_visibility_select
on public.posts;

create policy posts_moderated_visibility_select
on public.posts
as restrictive
for select
to public
using (
  public.can_read_moderated_content(
    'post',
    id::text
  )
);

drop policy if exists
  polls_moderated_visibility_select
on public.polls;

create policy polls_moderated_visibility_select
on public.polls
as restrictive
for select
to public
using (
  public.can_read_moderated_content(
    'poll',
    id::text
  )
);

notify pgrst, 'reload schema';

commit;
