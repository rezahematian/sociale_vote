select
  has_table_privilege('anon', 'public.social_vote_world_surface_settings', 'select') as anon_can_read,
  not has_table_privilege('anon', 'public.social_vote_world_surface_settings', 'insert')
    and not has_table_privilege('anon', 'public.social_vote_world_surface_settings', 'update')
    and not has_table_privilege('anon', 'public.social_vote_world_surface_settings', 'delete') as anon_cannot_write,
  has_table_privilege('authenticated', 'public.social_vote_world_surface_settings', 'select') as authenticated_can_read,
  not has_table_privilege('authenticated', 'public.social_vote_world_surface_settings', 'insert')
    and not has_table_privilege('authenticated', 'public.social_vote_world_surface_settings', 'update')
    and not has_table_privilege('authenticated', 'public.social_vote_world_surface_settings', 'delete') as authenticated_cannot_write;
