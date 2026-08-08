-- SOCIAL VOTE
-- P8 — Vote receipt foundation
-- 2026-08-08
--
-- Privacy model:
-- - one receipt id belongs to the existing vote row;
-- - no duplicate table containing vote selections;
-- - receipt id does not encode user, poll, choice or timestamp;
-- - created_at remains the receipt timestamp;
-- - changing an allowed vote keeps the same receipt id.

begin;

alter table public.votes
  add column if not exists receipt_id uuid
  default gen_random_uuid();

-- Backfill only in case this column already existed nullable from
-- an interrupted/manual migration.
update public.votes
set receipt_id = gen_random_uuid()
where receipt_id is null;

alter table public.votes
  alter column receipt_id set default gen_random_uuid();

alter table public.votes
  alter column receipt_id set not null;

create unique index if not exists votes_receipt_id_unique_idx
  on public.votes (receipt_id);

comment on column public.votes.receipt_id is
  'Opaque user-facing vote receipt identifier. Does not encode vote choice, user identity, poll id, or timestamp.';

notify pgrst, 'reload schema';

commit;
