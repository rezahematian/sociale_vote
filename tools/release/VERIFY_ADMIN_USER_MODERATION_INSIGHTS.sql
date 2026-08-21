-- Read-only verification for Admin Center V2 user moderation insights.
-- Run in Supabase SQL Editor after applying the migration.

select
  p.proname as function_name,
  pg_get_function_result(p.oid) as result_signature,
  p.prosecdef as security_definer
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.proname = 'admin_get_user_detail';

select
  has_function_privilege('anon', 'public.admin_get_user_detail(uuid)', 'EXECUTE')
    as anon_can_execute,
  has_function_privilege('authenticated', 'public.admin_get_user_detail(uuid)', 'EXECUTE')
    as authenticated_can_execute,
  has_function_privilege('service_role', 'public.admin_get_user_detail(uuid)', 'EXECUTE')
    as service_role_can_execute;
