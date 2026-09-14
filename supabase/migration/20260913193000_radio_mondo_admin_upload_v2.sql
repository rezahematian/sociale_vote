-- SOCIAL VOTE RADIO MONDO ADMIN UPLOAD V2.0.0
-- Scope: managed public audio bucket with admin-only writes.
-- Existing radio_mondo_tracks / audited RPC catalog remain authoritative.

begin;

do $$
begin
  if to_regclass('public.radio_mondo_tracks') is null then
    raise exception 'radio_mondo_tracks is missing; apply Admin Finance/Radio Control V1 first.';
  end if;
end;
$$;

insert into storage.buckets (id, name, public)
values ('radio-mondo', 'radio-mondo', true)
on conflict (id) do update
set name = excluded.name,
    public = true;

-- Apply server-side limits when the installed Storage schema exposes them.
do $$
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'storage'
      and table_name = 'buckets'
      and column_name = 'file_size_limit'
  ) then
    execute $sql$
      update storage.buckets
      set file_size_limit = 26214400
      where id = 'radio-mondo'
    $sql$;
  end if;

  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'storage'
      and table_name = 'buckets'
      and column_name = 'allowed_mime_types'
  ) then
    execute $sql$
      update storage.buckets
      set allowed_mime_types = array['audio/mpeg','audio/mp4','audio/ogg']::text[]
      where id = 'radio-mondo'
    $sql$;
  end if;
end;
$$;

drop policy if exists radio_mondo_admin_select on storage.objects;
drop policy if exists radio_mondo_admin_insert on storage.objects;
drop policy if exists radio_mondo_admin_update on storage.objects;
drop policy if exists radio_mondo_admin_delete on storage.objects;

create policy radio_mondo_admin_select
on storage.objects
for select
to authenticated
using (
  bucket_id = 'radio-mondo'
  and public.is_current_auth_user_admin()
);

create policy radio_mondo_admin_insert
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'radio-mondo'
  and public.is_current_auth_user_admin()
  and name like 'tracks/%'
);

create policy radio_mondo_admin_update
on storage.objects
for update
to authenticated
using (
  bucket_id = 'radio-mondo'
  and public.is_current_auth_user_admin()
  and name like 'tracks/%'
)
with check (
  bucket_id = 'radio-mondo'
  and public.is_current_auth_user_admin()
  and name like 'tracks/%'
);

create policy radio_mondo_admin_delete
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'radio-mondo'
  and public.is_current_auth_user_admin()
  and name like 'tracks/%'
);

commit;
