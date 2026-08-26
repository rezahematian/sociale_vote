-- Social Vote - World Brief Editorial V2
-- Additive migration: preserves the verified World Brief foundation and adds
-- a clearly separated Social Vote editorial-view field plus stronger source
-- independence checks for publication.

begin;

alter table public.social_vote_world_briefs
  add column if not exists social_vote_view text;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'social_vote_world_briefs_social_vote_view_check'
      and conrelid = 'public.social_vote_world_briefs'::regclass
  ) then
    alter table public.social_vote_world_briefs
      add constraint social_vote_world_briefs_social_vote_view_check
      check (
        social_vote_view is null
        or char_length(btrim(social_vote_view)) between 1 and 12000
      );
  end if;
end;
$$;

grant select (social_vote_view)
on table public.social_vote_world_briefs
to anon, authenticated;

create or replace function app_private.prepare_social_vote_world_brief()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_source text;
  v_host text;
  v_hosts text[] := array[]::text[];
begin
  if (select auth.uid()) is null then
    raise exception using
      errcode = '42501',
      message = 'Authenticated admin required.';
  end if;

  if not public.is_current_auth_user_admin() then
    raise exception using
      errcode = '42501',
      message = 'Admin permission required.';
  end if;

  new.language_code := lower(btrim(new.language_code));
  new.title := btrim(new.title);
  new.what_happened := btrim(new.what_happened);
  new.why_it_matters := btrim(new.why_it_matters);
  new.what_is_uncertain := nullif(btrim(new.what_is_uncertain), '');
  new.social_vote_view := nullif(btrim(new.social_vote_view), '');
  new.country_code := upper(nullif(btrim(new.country_code), ''));
  new.city_id := nullif(btrim(new.city_id), '');
  new.location_label := nullif(btrim(new.location_label), '');
  new.updated_by := auth.uid();
  new.updated_at := clock_timestamp();

  if tg_op = 'INSERT' then
    new.created_by := auth.uid();
    new.created_at := clock_timestamp();
  else
    new.created_by := old.created_by;
    new.created_at := old.created_at;
  end if;

  if new.map_visible and (new.latitude is null or new.longitude is null) then
    raise exception using
      errcode = '22023',
      message = 'Globe visibility requires latitude and longitude.';
  end if;

  if jsonb_array_length(new.source_urls) > 12 then
    raise exception using
      errcode = '22023',
      message = 'World Briefs support at most twelve source URLs.';
  end if;

  if new.status = 'published' then
    for v_source in
      select btrim(source_value)
      from jsonb_array_elements_text(new.source_urls) source_value
      where nullif(btrim(source_value), '') is not null
    loop
      if char_length(v_source) > 2048
         or v_source !~ '^https://[^[:space:]]+$' then
        raise exception using
          errcode = '22023',
          message = 'World Brief sources must be valid HTTPS URLs.';
      end if;

      v_host := regexp_replace(
        lower(substring(v_source from '^https://([^/:?#]+)')),
        '^www\.',
        ''
      );
      if v_host is null or v_host = '' then
        raise exception using
          errcode = '22023',
          message = 'World Brief sources must contain a valid HTTPS host.';
      end if;

      if not (v_host = any(v_hosts)) then
        v_hosts := array_append(v_hosts, v_host);
      end if;
    end loop;

    if cardinality(v_hosts) < 2 then
      raise exception using
        errcode = '22023',
        message = 'Published World Briefs require at least two independent source domains.';
    end if;

    if new.expires_at is not null and new.expires_at <= clock_timestamp() then
      raise exception using
        errcode = '22023',
        message = 'A published World Brief cannot already be expired.';
    end if;

    if tg_op = 'INSERT' then
      new.published_at := clock_timestamp();
    elsif new.published_at is null or old.status is distinct from 'published' then
      new.published_at := clock_timestamp();
    end if;
  end if;

  return new;
end;
$$;

revoke all
on function app_private.prepare_social_vote_world_brief()
from public, anon, authenticated;

comment on column public.social_vote_world_briefs.social_vote_view is
  'Optional Social Vote editorial analysis/viewpoint, deliberately separated from reported facts and uncertainty.';

commit;
