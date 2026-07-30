begin;

alter table if exists public.user_profiles
  add column if not exists organization_name text;

alter table if exists public.verification_requests
  add column if not exists organization_name text;

-- Replace only single-column CHECK constraints for the identity type columns.
-- Multi-column consistency constraints, if present, are preserved.
do $$
declare
  constraint_row record;
begin
  if to_regclass('public.user_profiles') is not null then
    for constraint_row in
      select con.conname
      from pg_constraint con
      join pg_class rel on rel.oid = con.conrelid
      join pg_namespace nsp on nsp.oid = rel.relnamespace
      join pg_attribute att
        on att.attrelid = rel.oid
       and att.attname = 'actor_type'
      where nsp.nspname = 'public'
        and rel.relname = 'user_profiles'
        and con.contype = 'c'
        and con.conkey = array[att.attnum]::smallint[]
    loop
      execute format(
        'alter table public.user_profiles drop constraint %I',
        constraint_row.conname
      );
    end loop;

    alter table public.user_profiles
      add constraint user_profiles_actor_type_check
      check (
        actor_type in (
          'citizen',
          'public_official',
          'institution',
          'organization'
        )
      );
  end if;

  if to_regclass('public.verification_requests') is not null then
    for constraint_row in
      select con.conname
      from pg_constraint con
      join pg_class rel on rel.oid = con.conrelid
      join pg_namespace nsp on nsp.oid = rel.relnamespace
      join pg_attribute att
        on att.attrelid = rel.oid
       and att.attname = 'request_type'
      where nsp.nspname = 'public'
        and rel.relname = 'verification_requests'
        and con.contype = 'c'
        and con.conkey = array[att.attnum]::smallint[]
    loop
      execute format(
        'alter table public.verification_requests drop constraint %I',
        constraint_row.conname
      );
    end loop;

    alter table public.verification_requests
      add constraint verification_requests_request_type_check
      check (
        request_type in (
          'citizen_level1',
          'citizen_level2',
          'public_official',
          'institution',
          'organization'
        )
      );

    for constraint_row in
      select con.conname
      from pg_constraint con
      join pg_class rel on rel.oid = con.conrelid
      join pg_namespace nsp on nsp.oid = rel.relnamespace
      join pg_attribute att
        on att.attrelid = rel.oid
       and att.attname = 'target_actor_type'
      where nsp.nspname = 'public'
        and rel.relname = 'verification_requests'
        and con.contype = 'c'
        and con.conkey = array[att.attnum]::smallint[]
    loop
      execute format(
        'alter table public.verification_requests drop constraint %I',
        constraint_row.conname
      );
    end loop;

    alter table public.verification_requests
      add constraint verification_requests_target_actor_type_check
      check (
        target_actor_type in (
          'citizen',
          'public_official',
          'institution',
          'organization'
        )
      );
  end if;

  if to_regclass('public.polls') is not null then
    for constraint_row in
      select con.conname
      from pg_constraint con
      join pg_class rel on rel.oid = con.conrelid
      join pg_namespace nsp on nsp.oid = rel.relnamespace
      join pg_attribute att
        on att.attrelid = rel.oid
       and att.attname = 'published_as_actor_type'
      where nsp.nspname = 'public'
        and rel.relname = 'polls'
        and con.contype = 'c'
        and con.conkey = array[att.attnum]::smallint[]
    loop
      execute format(
        'alter table public.polls drop constraint %I',
        constraint_row.conname
      );
    end loop;

    alter table public.polls
      add constraint polls_published_as_actor_type_check
      check (
        published_as_actor_type is null
        or published_as_actor_type in (
          'citizen',
          'public_official',
          'institution',
          'organization'
        )
      );
  end if;
end
$$;

comment on column public.user_profiles.organization_name is
  'Verified public name used only when actor_type is organization.';

comment on column public.verification_requests.organization_name is
  'Organization name submitted with a verification request.';

commit;
