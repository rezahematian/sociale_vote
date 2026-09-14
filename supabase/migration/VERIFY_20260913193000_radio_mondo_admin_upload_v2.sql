-- VERIFY SOCIAL VOTE RADIO MONDO ADMIN UPLOAD V2.0.0
select id, name, public
from storage.buckets
where id = 'radio-mondo';

select policyname, cmd, roles
from pg_policies
where schemaname = 'storage'
  and tablename = 'objects'
  and policyname like 'radio_mondo_admin_%'
order by policyname;

select
  to_regclass('public.radio_mondo_tracks') is not null as radio_catalog_present,
  to_regprocedure('public.radio_mondo_public_catalog()') is not null as public_catalog_rpc_present,
  to_regprocedure('public.admin_radio_mondo_upsert(uuid,text,text,integer,boolean,text,text,boolean,text)') is not null as admin_upsert_rpc_present;
