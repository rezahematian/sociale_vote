begin;

-- Defense in depth for the global World marker-density setting.
-- Public clients may read the global value but cannot mutate the table
-- directly. Admin writes remain RPC-only through admin_set_world_marker_density.
revoke all
on table public.social_vote_world_surface_settings
from public;

revoke all
on table public.social_vote_world_surface_settings
from anon, authenticated;

grant select
on table public.social_vote_world_surface_settings
to anon, authenticated;

commit;
