-- Social Vote
-- Admin Center AC8.3: expose the reported content author to staff.

begin;

drop function if exists public.admin_get_report_queue(
  text,
  text,
  integer,
  integer
);

create function public.admin_get_report_queue(
  p_status text default null,
  p_target_type text default null,
  p_limit integer default 25,
  p_offset integer default 0
)
returns table (
  report_id text,
  target_type text,
  target_id text,
  target_author_user_id text,
  reporter_user_id text,
  reason text,
  status text,
  created_at timestamptz,
  total_count bigint
)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_status text := nullif(lower(btrim(p_status)), '');
  v_target_type text := nullif(lower(btrim(p_target_type)), '');
begin
  if coalesce((select auth.role()), '') <> 'service_role' then
    raise exception
      using
        errcode = '42501',
        message = 'Service role access is required.';
  end if;

  if v_status is not null
    and v_status not in ('open', 'in_review', 'resolved', 'dismissed')
  then
    raise exception
      using
        errcode = '22023',
        message = 'Invalid report status filter.';
  end if;

  if v_target_type is not null
    and v_target_type not in ('poll', 'post', 'news')
  then
    raise exception
      using
        errcode = '22023',
        message = 'Invalid report target type filter.';
  end if;

  if p_limit is null or p_limit < 1 or p_limit > 100 then
    raise exception
      using
        errcode = '22023',
        message = 'Report queue limit must be between 1 and 100.';
  end if;

  if p_offset is null or p_offset < 0 or p_offset > 1000000 then
    raise exception
      using
        errcode = '22023',
        message = 'Report queue offset must be between 0 and 1000000.';
  end if;

  return query
  select
    r.id::text,
    lower(r.target_type::text),
    r.target_id::text,
    case lower(r.target_type::text)
      when 'poll' then (
        select p.author_id::text
        from public.polls p
        where p.id::text = r.target_id::text
        limit 1
      )
      when 'post' then (
        select p.author_id::text
        from public.posts p
        where p.id::text = r.target_id::text
        limit 1
      )
      else null
    end,
    r.user_id::text,
    r.reason,
    r.status,
    r.created_at,
    count(*) over ()
  from public.reports r
  where
    lower(r.target_type::text) in ('poll', 'post', 'news')
    and (
      (v_status is null and r.status in ('open', 'in_review'))
      or r.status = v_status
    )
    and (
      v_target_type is null
      or lower(r.target_type::text) = v_target_type
    )
  order by
    r.created_at desc,
    r.id::text desc
  limit p_limit
  offset p_offset;
end;
$$;

comment on function public.admin_get_report_queue(
  text,
  text,
  integer,
  integer
) is
  'Backend-only paginated report queue with reported content author context.';

revoke all
on function public.admin_get_report_queue(
  text,
  text,
  integer,
  integer
)
from public, anon, authenticated;

grant execute
on function public.admin_get_report_queue(
  text,
  text,
  integer,
  integer
)
to service_role;

commit;
