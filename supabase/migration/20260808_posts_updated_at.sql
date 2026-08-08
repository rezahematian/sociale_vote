-- Post edit timestamp
-- Keep created_at as the original publication time.
-- Track later edits separately in updated_at.

alter table public.posts
  add column if not exists updated_at timestamptz;

-- Existing posts must not appear as edited.
update public.posts
set updated_at = created_at
where updated_at is null;

create or replace function public.set_post_updated_at_on_insert()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = coalesce(new.created_at, now());
  return new;
end;
$$;

drop trigger if exists posts_set_updated_at_on_insert
on public.posts;

create trigger posts_set_updated_at_on_insert
before insert on public.posts
for each row
execute function public.set_post_updated_at_on_insert();

create or replace function public.set_post_updated_at_on_edit()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists posts_set_updated_at_on_edit
on public.posts;

create trigger posts_set_updated_at_on_edit
before update of title, content on public.posts
for each row
execute function public.set_post_updated_at_on_edit();

alter table public.posts
  alter column updated_at set default now(),
  alter column updated_at set not null;
