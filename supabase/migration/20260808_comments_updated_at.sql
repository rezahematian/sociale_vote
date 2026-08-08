-- P2.4 follow-up — comment edit timestamp
-- Preserve created_at as the original publication time.
-- Track content edits separately in updated_at.

alter table public.comments
  add column if not exists updated_at timestamptz;

-- Existing comments must not appear as newly edited.
update public.comments
set updated_at = created_at
where updated_at is null;

alter table public.comments
  alter column updated_at set default now(),
  alter column updated_at set not null;

create or replace function public.set_comment_updated_at_on_content_edit()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists comments_set_updated_at_on_content_edit
on public.comments;

create trigger comments_set_updated_at_on_content_edit
before update of content on public.comments
for each row
execute function public.set_comment_updated_at_on_content_edit();
