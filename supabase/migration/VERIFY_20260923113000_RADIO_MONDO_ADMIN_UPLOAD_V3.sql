select
  id,
  public,
  file_size_limit,
  allowed_mime_types,
  file_size_limit = 209715200 as limit_200mb_ok,
  array[
    'audio/mpeg',
    'audio/mp4',
    'audio/aac',
    'audio/ogg',
    'audio/wav',
    'audio/flac',
    'audio/webm'
  ]::text[] <@ coalesce(allowed_mime_types, '{}'::text[])
    as required_audio_mimes_present
from storage.buckets
where id = 'radio-mondo';