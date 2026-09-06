import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const languages = <String>[
    'en', 'it', 'de', 'fa', 'es', 'pt', 'fr', 'ar', 'ro', 'ru', 'zh',
  ];

  test('A. eleven ARB catalogs remain aligned at 1309 messages', () {
    Set<String>? reference;
    for (final language in languages) {
      final map = jsonDecode(
        File('lib/l10n/app_$language.arb').readAsStringSync(),
      ) as Map<String, dynamic>;
      final keys = map.keys.where((key) => !key.startsWith('@')).toSet();
      expect(keys, hasLength(1309), reason: language);
      reference ??= keys;
      expect(keys, reference, reason: language);
    }
  });

  test('B. Civic Map is localized as ordinary UI in all eleven languages', () {
    const expected = <String, String>{
      'en': 'Civic Map',
      'it': 'Mappa civica',
      'de': 'Beteiligungskarte',
      'fa': 'نقشه مشارکت مدنی',
      'es': 'Mapa cívico',
      'pt': 'Mapa cívico',
      'fr': 'Carte civique',
      'ar': 'خريطة المشاركة المدنية',
      'ro': 'Hartă civică',
      'ru': 'Карта гражданского участия',
      'zh': '公民参与地图',
    };

    for (final entry in expected.entries) {
      final map = jsonDecode(
        File('lib/l10n/app_${entry.key}.arb').readAsStringSync(),
      ) as Map<String, dynamic>;
      expect(map['onboardingCivicMapTitle'], entry.value, reason: entry.key);
    }

    final page = File(
      'lib/features/map/presentation/pages/civic_map_page.dart',
    ).readAsStringSync();
    final router = File('lib/app/router.dart').readAsStringSync();
    expect(page, contains('AppLocalizations.of(context)!.onboardingCivicMapTitle'));
    expect(page, isNot(contains("const Text('Civic Map')")));
    expect(router, contains('l10n.onboardingCivicMapTitle'));
  });

  test('C. map All Auto and details use localized catalog keys', () {
    final page = File(
      'lib/features/map/presentation/pages/civic_map_page.dart',
    ).readAsStringSync();
    expect(page, contains('AppLocalizations.of(context)!.searchTypeAll'));
    expect(page, contains('AppLocalizations.of(context)!.newsFeed_languageAuto'));
    expect(page, contains('AppLocalizations.of(context)!.pollCard_viewDetails'));
    expect(page, isNot(contains("english: 'Open details'")));
  });

  test('D. Auto UI label is localized across all eleven languages', () {
    const expected = <String, String>{
      'en': 'Auto',
      'it': 'Automatico',
      'de': 'Automatisch',
      'fa': 'خودکار',
      'es': 'Automático',
      'pt': 'Automático',
      'fr': 'Automatique',
      'ar': 'تلقائي',
      'ro': 'Automat',
      'ru': 'Автоматически',
      'zh': '自动',
    };
    for (final entry in expected.entries) {
      final map = jsonDecode(
        File('lib/l10n/app_${entry.key}.arb').readAsStringSync(),
      ) as Map<String, dynamic>;
      expect(map['newsFeed_languageAuto'], entry.value, reason: entry.key);
    }
  });

  test('E. Space appearance is localized for all eleven app languages', () {
    final helper = File(
      'lib/app/localization/appearance_label.dart',
    ).readAsStringSync();
    for (final token in <String>[
      "'it' => 'Spazio'",
      "'de' => 'Weltraum'",
      "'fa' => 'فضا'",
      "'es' => 'Espacio'",
      "'pt' => 'Espaço'",
      "'fr' => 'Espace'",
      "'ar' => 'الفضاء'",
      "'ro' => 'Spațiu'",
      "'ru' => 'Космос'",
      "'zh' => '太空'",
      "_ => 'Space'",
    ]) {
      expect(helper, contains(token));
    }
    final home = File(
      'lib/features/home/presentation/pages/public_home_screen.dart',
    ).readAsStringSync();
    final topBar = File(
      'lib/features/home/presentation/widgets/home_top_bar.dart',
    ).readAsStringSync();
    expect(home, contains('socialVoteSpaceAppearanceLabel(context)'));
    expect(topBar, contains('socialVoteSpaceAppearanceLabel(context)'));
    expect(home, isNot(contains("label: Text('Space')")));
    expect(topBar, isNot(contains("label: 'Space'")));
  });

  test('F. RU and ZH hero headlines use a real line break contract', () {
    for (final language in <String>['ru', 'zh']) {
      final raw = File('lib/l10n/app_$language.arb').readAsStringSync();
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final value = map['homeHeroHeadline'] as String;
      expect(value, contains('\n'), reason: language);
      expect(value, isNot(contains(r'\n')), reason: language);
    }
  });

  test('G. desktop World summary remains compact after dual-line signatures', () {
    final panel = File(
      'lib/features/home/presentation/widgets/home_web_world_panel.dart',
    ).readAsStringSync();
    expect(panel, contains('height: 64,'));
    expect(panel, contains('EdgeInsets.fromLTRB(12, 10, 12, 10)'));
    expect(panel, isNot(contains('height: 76,')));
  });
}
