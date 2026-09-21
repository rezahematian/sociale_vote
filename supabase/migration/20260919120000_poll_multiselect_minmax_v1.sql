-- Social Vote CURRENT R6: ordinary Vote selection limits.
-- Atomic installation. Existing polls/votes are not rewritten.
-- RLS, participation gates, notifications and Play configuration are unchanged.
BEGIN;

CREATE OR REPLACE FUNCTION public.social_vote_guard_poll_selection_limits_v1()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = ''
AS $function$
DECLARE
  option_count integer;
BEGIN
  IF NEW.type NOT IN ('singleChoice', 'yesNo', 'multipleChoice') THEN
    RETURN NEW;
  END IF;
  IF TG_OP = 'UPDATE' AND NEW.type IS NOT DISTINCT FROM OLD.type
     AND NEW.options IS NOT DISTINCT FROM OLD.options
     AND NEW.min_selections IS NOT DISTINCT FROM OLD.min_selections
     AND NEW.max_selections IS NOT DISTINCT FROM OLD.max_selections THEN
    RETURN NEW;
  END IF;
  IF jsonb_typeof(NEW.options) IS DISTINCT FROM 'array' THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'SV_POLL_OPTIONS_INVALID';
  END IF;
  option_count := jsonb_array_length(NEW.options);
  IF option_count < 2 OR NEW.min_selections IS NULL
     OR NEW.max_selections IS NULL OR NEW.min_selections < 1
     OR NEW.max_selections < NEW.min_selections
     OR NEW.max_selections > option_count
     OR (NEW.type IN ('singleChoice', 'yesNo')
         AND (NEW.min_selections <> 1 OR NEW.max_selections <> 1)) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'SV_POLL_LIMITS_INVALID';
  END IF;
  IF EXISTS (
    SELECT 1 FROM jsonb_array_elements(NEW.options) AS o(value)
    WHERE jsonb_typeof(o.value) IS DISTINCT FROM 'object'
       OR jsonb_typeof(o.value -> 'id') IS DISTINCT FROM 'string'
       OR nullif(btrim(o.value ->> 'id'), '') IS NULL
       OR jsonb_typeof(o.value -> 'label') IS DISTINCT FROM 'string'
       OR nullif(btrim(o.value ->> 'label'), '') IS NULL
  ) OR (SELECT count(DISTINCT o.value ->> 'id')
        FROM jsonb_array_elements(NEW.options) AS o(value)) <> option_count THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'SV_POLL_OPTIONS_INVALID';
  END IF;
  RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.social_vote_guard_vote_selections_v1()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
DECLARE
  poll_type text;
  minimum integer;
  maximum integer;
  poll_options jsonb;
  selected_count integer;
BEGIN
  -- SHARE serializes selection validation with edits of the parent rules.
  SELECT p.type, p.min_selections, p.max_selections, p.options
    INTO poll_type, minimum, maximum, poll_options
    FROM public.polls p WHERE p.id = NEW.poll_id FOR SHARE;
  IF NOT FOUND THEN
    RAISE EXCEPTION USING ERRCODE = '23503', MESSAGE = 'SV_VOTE_POLL_NOT_FOUND';
  END IF;
  IF poll_type NOT IN ('singleChoice', 'yesNo', 'multipleChoice') THEN
    RETURN NEW;
  END IF;
  IF jsonb_typeof(NEW.selected_options) IS DISTINCT FROM 'array' THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'SV_VOTE_SELECTIONS_INVALID';
  END IF;
  IF poll_type IN ('singleChoice', 'yesNo') THEN
    minimum := 1;
    maximum := 1;
  END IF;
  IF jsonb_typeof(poll_options) IS DISTINCT FROM 'array' THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'SV_POLL_OPTIONS_INVALID';
  END IF;
  IF minimum IS NULL OR maximum IS NULL OR minimum < 1
     OR maximum < minimum OR maximum > jsonb_array_length(poll_options) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'SV_POLL_LIMITS_INVALID';
  END IF;
  selected_count := jsonb_array_length(NEW.selected_options);
  IF selected_count < minimum OR selected_count > maximum THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'SV_VOTE_SELECTION_COUNT';
  END IF;
  IF EXISTS (
    SELECT 1 FROM jsonb_array_elements(NEW.selected_options) AS s(value)
    WHERE jsonb_typeof(s.value) IS DISTINCT FROM 'string'
       OR NOT EXISTS (
         SELECT 1 FROM jsonb_array_elements(poll_options) AS o(value)
         WHERE o.value ->> 'id' = s.value #>> '{}'
       )
  ) OR (SELECT count(DISTINCT s.value)
        FROM jsonb_array_elements(NEW.selected_options) AS s(value)) <> selected_count THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'SV_VOTE_SELECTIONS_INVALID';
  END IF;
  RETURN NEW;
END;
$function$;

REVOKE ALL ON FUNCTION public.social_vote_guard_poll_selection_limits_v1()
  FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.social_vote_guard_vote_selections_v1()
  FROM PUBLIC, anon, authenticated;

DROP TRIGGER IF EXISTS social_vote_poll_selection_limits_v1 ON public.polls;
CREATE TRIGGER social_vote_poll_selection_limits_v1
BEFORE INSERT OR UPDATE OF type, options, min_selections, max_selections
ON public.polls FOR EACH ROW
EXECUTE FUNCTION public.social_vote_guard_poll_selection_limits_v1();

DROP TRIGGER IF EXISTS social_vote_vote_selections_v1 ON public.votes;
CREATE TRIGGER social_vote_vote_selections_v1
BEFORE INSERT OR UPDATE OF selected_options, poll_id
ON public.votes FOR EACH ROW
EXECUTE FUNCTION public.social_vote_guard_vote_selections_v1();

-- Targeted execution of the installed triggers, in isolated test fixtures.
-- The probe has ONLY the validation trigger: no realtime/notifications.
-- Temporary draft polls are rolled back in the nested subtransaction.
DROP TABLE IF EXISTS pg_temp.sv_multiselect_results_v1;
DROP TABLE IF EXISTS pg_temp.sv_multiselect_vote_probe_v1;
CREATE TEMP TABLE sv_multiselect_results_v1 (check_name text, passed boolean)
  ON COMMIT PRESERVE ROWS;
CREATE TEMP TABLE sv_multiselect_vote_probe_v1 (LIKE public.votes INCLUDING DEFAULTS)
  ON COMMIT DROP;
CREATE TRIGGER sv_multiselect_probe_guard_v1
BEFORE INSERT OR UPDATE OF selected_options, poll_id
ON sv_multiselect_vote_probe_v1 FOR EACH ROW
EXECUTE FUNCTION public.social_vote_guard_vote_selections_v1();

DO $tests$
DECLARE
  fixture uuid := gen_random_uuid();
  probe uuid;
  options_json jsonb := '[{"id":"a","label":"A"},{"id":"b","label":"B"},{"id":"c","label":"C"},{"id":"d","label":"D"},{"id":"e","label":"E"}]';
  item record;
  rejected boolean;
  passed_count integer := 0;
BEGIN
  IF (SELECT count(*) FROM pg_catalog.pg_trigger
      WHERE NOT tgisinternal AND tgenabled = 'O'
        AND ((tgrelid = 'public.polls'::regclass
              AND tgname = 'social_vote_poll_selection_limits_v1'
              AND tgfoid = 'public.social_vote_guard_poll_selection_limits_v1()'::regprocedure
              AND tgtype = 23)
          OR (tgrelid = 'public.votes'::regclass
              AND tgname = 'social_vote_vote_selections_v1'
              AND tgfoid = 'public.social_vote_guard_vote_selections_v1()'::regprocedure
              AND tgtype = 23))) <> 2 THEN
    RAISE EXCEPTION 'Installed trigger linkage mismatch';
  END IF;
  BEGIN
    INSERT INTO public.polls(id, title, type, status, options, min_selections, max_selections)
    VALUES (fixture, 'TEMPORARY MINMAX TEST - ROLLED BACK', 'multipleChoice',
            'draft', options_json, 1, 3);
    INSERT INTO pg_temp.sv_multiselect_vote_probe_v1(poll_id, selected_options)
    VALUES (fixture, '["a"]'), (fixture, '["a","b","c"]');
    passed_count := passed_count + 1; -- 1..3 boundaries

    UPDATE public.polls SET min_selections = 2, max_selections = 4 WHERE id = fixture;
    INSERT INTO pg_temp.sv_multiselect_vote_probe_v1(poll_id, selected_options)
    VALUES (fixture, '["a","b"]') RETURNING id INTO probe;
    UPDATE pg_temp.sv_multiselect_vote_probe_v1 SET selected_options = '["a","b","c","d"]'
    WHERE id = probe;
    passed_count := passed_count + 1; -- 2..4 insert + update

    FOR item IN SELECT * FROM (VALUES
      ('["a"]'::jsonb, 'SV_VOTE_SELECTION_COUNT'),
      ('["a","b","c","d","e"]'::jsonb, 'SV_VOTE_SELECTION_COUNT'),
      ('["a","a"]'::jsonb, 'SV_VOTE_SELECTIONS_INVALID'),
      ('["a","unknown"]'::jsonb, 'SV_VOTE_SELECTIONS_INVALID'),
      ('{"a":true}'::jsonb, 'SV_VOTE_SELECTIONS_INVALID'),
      ('["a",null]'::jsonb, 'SV_VOTE_SELECTIONS_INVALID')
    ) AS cases(selection, error_message)
    LOOP
      rejected := false;
      BEGIN
        INSERT INTO pg_temp.sv_multiselect_vote_probe_v1(poll_id, selected_options)
        VALUES (fixture, item.selection);
      EXCEPTION WHEN check_violation THEN
        IF SQLERRM <> item.error_message THEN RAISE; END IF;
        rejected := true;
      END;
      IF NOT rejected THEN RAISE EXCEPTION 'Invalid INSERT accepted: %', item.selection; END IF;
      rejected := false;
      BEGIN
        UPDATE pg_temp.sv_multiselect_vote_probe_v1 SET selected_options = item.selection
        WHERE id = probe;
      EXCEPTION WHEN check_violation THEN
        IF SQLERRM <> item.error_message THEN RAISE; END IF;
        rejected := true;
      END;
      IF NOT rejected THEN RAISE EXCEPTION 'Invalid UPDATE accepted: %', item.selection; END IF;
      passed_count := passed_count + 2;
    END LOOP;

    FOR item IN SELECT * FROM (VALUES (0, 4), (4, 2), (1, 6)) AS cases(minimum, maximum)
    LOOP
      rejected := false;
      BEGIN
        UPDATE public.polls SET min_selections = item.minimum, max_selections = item.maximum
        WHERE id = fixture;
      EXCEPTION WHEN check_violation THEN
        IF SQLERRM <> 'SV_POLL_LIMITS_INVALID' THEN RAISE; END IF;
        rejected := true;
      END;
      IF NOT rejected THEN RAISE EXCEPTION 'Invalid poll limits accepted'; END IF;
      passed_count := passed_count + 1;
    END LOOP;

    UPDATE public.polls SET type = 'singleChoice', min_selections = 1, max_selections = 1
    WHERE id = fixture;
    UPDATE pg_temp.sv_multiselect_vote_probe_v1 SET selected_options = '["a"]' WHERE id = probe;
    rejected := false;
    BEGIN
      UPDATE pg_temp.sv_multiselect_vote_probe_v1 SET selected_options = '["a","b"]'
      WHERE id = probe;
    EXCEPTION WHEN check_violation THEN
      IF SQLERRM <> 'SV_VOTE_SELECTION_COUNT' THEN RAISE; END IF;
      rejected := true;
    END;
    IF NOT rejected THEN RAISE EXCEPTION 'Single-choice accepted two answers'; END IF;
    passed_count := passed_count + 1;
    UPDATE public.polls SET type = 'yesNo' WHERE id = fixture;
    UPDATE pg_temp.sv_multiselect_vote_probe_v1 SET selected_options = '["b"]' WHERE id = probe;
    passed_count := passed_count + 1;

    -- Roll back every fixture while retaining the PL/pgSQL test counter.
    RAISE EXCEPTION USING ERRCODE = 'ZV001', MESSAGE = 'ROLLBACK_TEST_FIXTURES';
  EXCEPTION WHEN SQLSTATE 'ZV001' THEN
    NULL;
  END;
  IF passed_count <> 19 OR EXISTS (SELECT 1 FROM public.polls WHERE id = fixture)
     OR EXISTS (SELECT 1 FROM pg_temp.sv_multiselect_vote_probe_v1) THEN
    RAISE EXCEPTION 'Test count or fixture cleanup mismatch: %', passed_count;
  END IF;
  INSERT INTO pg_temp.sv_multiselect_results_v1 VALUES
    ('selection_trigger_linkage', true),
    ('19_insert_update_config_single_choice_checks', passed_count = 19),
    ('all_test_fixtures_rolled_back', true);
END;
$tests$;

COMMIT;
SELECT check_name, passed FROM pg_temp.sv_multiselect_results_v1 ORDER BY check_name;
