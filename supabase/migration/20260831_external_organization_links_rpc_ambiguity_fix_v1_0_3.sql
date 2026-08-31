begin;

-- Fixes PostgreSQL 42702 caused by RETURNS TABLE output names colliding with
-- the organization_id/provider names in ON CONFLICT index inference.
create or replace function public.organization_external_links_replace(
  p_links jsonb
)
returns table (
  id uuid,
  organization_id uuid,
  provider text,
  canonical_url text,
  connection_mode text,
  visibility text,
  status text,
  verified_at timestamptz
)
language plpgsql
volatile
security definer
set search_path = ''
as $$
#variable_conflict use_column
declare
  v_user_id uuid := auth.uid();
  v_organization_id uuid;
  v_role text;
  v_item jsonb;
  v_provider text;
  v_url text;
  v_seen text[] := array[]::text[];
  v_row_count integer := 0;
  v_change_count integer := 0;
begin
  if v_user_id is null or not public.is_current_auth_user_active() then
    raise exception using
      errcode = '42501',
      message = 'Active authentication required.';
  end if;

  select om.organization_id, om.membership_role
  into v_organization_id, v_role
  from public.organization_memberships om
  where om.user_id = v_user_id
    and om.status = 'active'
  order by (om.membership_role = 'owner') desc, om.created_at asc
  limit 1;

  if v_organization_id is null or v_role not in ('owner', 'manager') then
    raise exception using
      errcode = '42501',
      message = 'Organization manager permission required.';
  end if;

  if p_links is null or jsonb_typeof(p_links) <> 'array' then
    raise exception using
      errcode = '22023',
      message = 'External links must be a JSON array.';
  end if;

  if jsonb_array_length(p_links) > 5 then
    raise exception using
      errcode = '22023',
      message = 'Too many external links.';
  end if;

  for v_item in select value from jsonb_array_elements(p_links)
  loop
    if jsonb_typeof(v_item) <> 'object' then
      raise exception using
        errcode = '22023',
        message = 'Each external link must be an object.';
    end if;

    v_provider := lower(btrim(coalesce(v_item ->> 'provider', '')));
    v_url := btrim(coalesce(v_item ->> 'canonical_url', ''));

    if v_provider not in (
      'youtube', 'linkedin', 'whatsapp', 'instagram', 'telegram'
    ) then
      raise exception using
        errcode = '22023',
        message = 'Unsupported external link provider.';
    end if;

    if v_provider = any(v_seen) then
      raise exception using
        errcode = '22023',
        message = 'Duplicate external link provider.';
    end if;

    if not public.external_account_link_url_is_valid(v_provider, v_url) then
      raise exception using
        errcode = '22023',
        message = 'Invalid official provider URL.';
    end if;

    v_seen := array_append(v_seen, v_provider);

    insert into public.external_account_links as current_link (
      subject_type,
      organization_id,
      provider,
      connection_mode,
      canonical_url,
      visibility,
      status,
      created_by
    ) values (
      'organization',
      v_organization_id,
      v_provider,
      'declared',
      v_url,
      'public',
      'active',
      v_user_id
    )
    on conflict (organization_id, provider)
      where organization_id is not null
    do update set
      canonical_url = excluded.canonical_url,
      connection_mode = 'declared',
      external_subject_id = null,
      handle = null,
      display_name = null,
      visibility = 'public',
      status = 'active',
      verified_at = null,
      updated_at = now()
    where
      current_link.canonical_url is distinct from excluded.canonical_url
      or current_link.connection_mode <> 'declared'
      or current_link.visibility <> 'public'
      or current_link.status <> 'active'
      or current_link.external_subject_id is not null
      or current_link.handle is not null
      or current_link.display_name is not null
      or current_link.verified_at is not null;

    get diagnostics v_row_count = row_count;
    v_change_count := v_change_count + v_row_count;
  end loop;

  delete from public.external_account_links eal
  where eal.organization_id = v_organization_id
    and eal.subject_type = 'organization'
    and not (eal.provider = any(v_seen));

  get diagnostics v_row_count = row_count;
  v_change_count := v_change_count + v_row_count;

  if v_change_count > 0 then
    insert into public.organization_session_audit (
      organization_id,
      actor_user_id,
      event_key,
      metadata
    ) values (
      v_organization_id,
      v_user_id,
      'organization_external_links_replaced',
      jsonb_build_object(
        'providers', to_jsonb(v_seen),
        'count', cardinality(v_seen)
      )
    );
  end if;

  return query
  select
    eal.id,
    eal.organization_id,
    eal.provider,
    eal.canonical_url,
    eal.connection_mode,
    eal.visibility,
    eal.status,
    eal.verified_at
  from public.external_account_links eal
  where eal.organization_id = v_organization_id
    and eal.subject_type = 'organization'
  order by array_position(
    array['youtube', 'linkedin', 'whatsapp', 'instagram', 'telegram']::text[],
    eal.provider
  );
end;
$$;

revoke all
on function public.organization_external_links_replace(jsonb)
from public, anon;

grant execute
on function public.organization_external_links_replace(jsonb)
to authenticated;

notify pgrst, 'reload schema';

commit;

select 'EXTERNAL ORGANIZATION LINKS RPC AMBIGUITY FIX V1.0.3 APPLIED'
  as result;
