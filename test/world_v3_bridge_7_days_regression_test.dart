import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('World Brief and Radio bridge uses title picker instead of raw UUID entry', () {
    final radio = File(
      'lib/features/admin/presentation/widgets/admin_radio_mondo_control_section.dart',
    ).readAsStringSync();
    final editor = File(
      'lib/features/admin/presentation/pages/world_brief_editor_page.dart',
    ).readAsStringSync();

    expect(radio, contains('worldBriefRepository.listForAdmin'));
    expect(radio, contains('worldBriefs: worldBriefs'));
    expect(radio, contains('World Brief collegato'));
    expect(radio, contains('Scegli il Brief per titolo'));
    expect(radio, isNot(contains('World Brief ID (opzionale)')));

    expect(editor, contains('Future<void> _openRadio(WorldBrief brief)'));
    expect(editor, contains('getRadioMondoTracks'));
    expect(editor, contains('track.worldBriefId == brief.id'));
    expect(editor, contains('_WorldBriefRadioDialog'));
    expect(editor, contains('Icons.radio_rounded'));
  });

  test('News feed exposes seven-day World Brief editorial view', () {
    final news = File(
      'lib/features/news/presentation/pages/news_feed_page.dart',
    ).readAsStringSync();

    expect(news, contains('_worldBriefSevenDaysOnly'));
    expect(news, contains('const Duration(days: 7)'));
    expect(news, contains('item.worldBrief != null'));
    expect(news, contains('editorialFeatured'));
    expect(news, contains('editorialPriority'));
    expect(news, contains('World Brief · 7 giorni'));
    expect(news, contains('World Brief · 7 дней'));
    expect(news, contains('World Brief · 7 天'));
  });
}
