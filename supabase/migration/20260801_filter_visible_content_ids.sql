-- Social Vote
-- Admin Center AC8.5.4: client-safe visibility filter for content IDs.
--
-- Primary use:
-- - filter NewsItem IDs after provider/cache aggregation;
-- - avoid depending on the physical news_feed_cache schema;
-- - keep hidden content visible to synchronized active moderator/admin accounts.
--
-- The function returns only IDs supplied by the caller. It does not expose the
-- private moderation table or enumerate hidden content.

begin;

create or replace function public.filter_visible_content_ids(
  p_target_type text,
  p_target_ids text[]
)
returns table (
  target_id text
)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_target_type text :=
    lower(btrim(coalesce(p_target_type, '')));
  v_is_staff boolean := false;
  v_id_count integer := 0;
begin
  if v_target_type not in ('poll', 'post', 'news') then
    raise exception
      using
        errcode = '22023',
        message = 'Target type must be poll, post, or news.';
  end if;

  if p_target_ids is null then
    raise exception
      using
        errcode = '22004',
        message = 'A target ID list is required.';
  end if;

  v_id_count := cardinality(p_target_ids);

  if v_id_count < 1 or v_id_count > 200 then
    raise exception
      using
        errcode = '22023',
        message = 'Target ID list must contain between 1 and 200 items.';
  end if;

  if exists (
    select 1
    from unnest(p_target_ids) supplied_id
    where
      supplied_id is null
      or btrim(supplied_id) = ''
      or char_length(btrim(supplied_id)) > 320
  ) then
    raise exception
      using
        errcode = '22023',
        message = 'Every target ID must contain between 1 and 320 characters.';
  end if;

  v_is_staff :=
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
    and (select public.is_current_auth_user_active());

  return query
  with supplied as (
    select
      btrim(value)::text as normalized_id,
      min(ordinality)::bigint as first_position
    from unnest(p_target_ids) with ordinality as ids(value, ordinality)
    group by btrim(value)
  )
  select supplied.normalized_id
  from supplied
  where
    v_is_staff
    or not exists (
      select 1
      from app_private.admin_content_visibility visibility
      where visibility.target_type = v_target_type
        and visibility.target_id = supplied.normalized_id
        and visibility.is_hidden = true
    )
  order by supplied.first_position;
end;
$$;

comment on function public.filter_visible_content_ids(text, text[]) is
  'Returns the caller-supplied content IDs that remain publicly visible; synchronized active staff may inspect hidden targets.';

revoke all
on function public.filter_visible_content_ids(text, text[])
from public;

grant execute
on function public.filter_visible_content_ids(text, text[])
to anon, authenticated, service_role;

notify pgrst, 'reload schema';

commit;
