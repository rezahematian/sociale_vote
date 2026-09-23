-- SOCIAL VOTE RADIO MONDO ADMIN AUDIO UPLOAD V3
-- Common cross-platform audio formats + larger upload limit.
-- Existing RLS/policies remain authoritative.

begin;

do $$
begin
  if not exists (
    select 1
    from storage.buckets
    where id = 'radio-mondo'
  ) then
    raise exception 'radio-mondo bucket is missing';
  end if;
end;
$$;

update storage.buckets
set
  file_size_limit = 209715200,
  allowed_mime_types = array[
    'audio/mpeg',
    'audio/mp4',
    'audio/aac',
    'audio/ogg',
    'audio/wav',
    'audio/flac',
    'audio/webm'
  ]::text[]
where id = 'radio-mondo';

commit;