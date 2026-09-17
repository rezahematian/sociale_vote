import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('World Brief optional editorial sections V3 R1 source contracts', () {
    final editor = File(
      'lib/features/admin/presentation/pages/world_brief_editor_page.dart',
    ).readAsStringSync();
    final detail = File(
      'lib/features/news/presentation/pages/news_detail_page.dart',
    ).readAsStringSync();
    final news = File(
      'lib/infrastructure/news/repositories/news_repository_impl.dart',
    ).readAsStringSync();
    final repository = File(
      'lib/infrastructure/news/repositories/world_brief_repository_supabase.dart',
    ).readAsStringSync();
    final migration = File(
      'supabase/migration/20260916180000_world_brief_optional_sections_v3_r1.sql',
    ).readAsStringSync();

    expect(editor, contains('_optionalField(\n                          _whatHappened'));
    expect(editor, contains('_optionalField(\n                          _whyItMatters'));
    expect(editor, contains('if (brief.whatHappened.trim().isNotEmpty)'));
    expect(editor, contains('if (brief.whyItMatters.trim().isNotEmpty)'));

    expect(detail, contains('final whatHappened = brief.whatHappened.trim();'));
    expect(detail, contains('if (whatHappened.isNotEmpty)'));
    expect(detail, contains('if (whyItMatters.isNotEmpty)'));
    expect(detail, contains('if (hasSources)'));

    expect(news, contains('if (brief.whatHappened.trim().isNotEmpty)'));
    expect(news, contains('if (brief.whyItMatters.trim().isNotEmpty)'));
    expect(news, contains('final summaryCandidates = <String>['));

    expect(repository, contains("'what_happened': _text(draft.whatHappened)"));
    expect(repository, contains("'why_it_matters': _text(draft.whyItMatters)"));

    expect(migration, contains('new.created_at := v_now;'));
    expect(migration, contains('new.updated_at := v_now;'));
    expect(migration, contains('alter column what_happened drop not null'));
    expect(migration, contains('alter column why_it_matters drop not null'));
    expect(migration, contains("what_happened is null"));
    expect(migration, contains("why_it_matters is null"));
  });
}
