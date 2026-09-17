import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('World Brief V3 source contracts are installed', () {
    final entity = File('lib/domain/content/news/entities/world_brief.dart').readAsStringSync();
    final repo = File('lib/infrastructure/news/repositories/world_brief_repository_supabase.dart').readAsStringSync();
    final editor = File('lib/features/admin/presentation/pages/world_brief_editor_page.dart').readAsStringSync();
    final news = File('lib/infrastructure/news/repositories/news_repository_impl.dart').readAsStringSync();

    expect(entity, contains('WorldBriefContentKind.socialVoteOriginal'));
    expect(entity, contains('class WorldBriefTranslation'));
    expect(repo, contains('world_brief_public_catalog_v3'));
    expect(repo, contains('admin_world_brief_translation_save'));
    expect(editor, contains('Originale Social Vote'));
    expect(editor, contains('Versioni linguistiche'));
    expect(news, contains("'zh' => const <String>"));
    expect(news, contains('if (brief.sourceUrls.isNotEmpty)'));
  });
}
