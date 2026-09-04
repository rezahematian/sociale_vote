import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const pagePath =
      'lib/features/onboarding/presentation/how_social_vote_works_page.dart';

  test('How Social Vote works is first and Rules follows it', () {
    final source = File(pagePath).readAsStringSync();

    final howIndex = source.indexOf("it: 'Come funziona Social Vote'");
    final rulesIndex =
        source.indexOf("it: 'Regole del gioco · Principles v0.3'");

    expect(howIndex, greaterThanOrEqualTo(0));
    expect(rulesIndex, greaterThan(howIndex));
    expect(
      source,
      contains("assetPath: _posterAssetForLocale(context)"),
    );
  });

  test('Legacy How Social Vote works copy covers all nine locales', () {
    final source = File(pagePath).readAsStringSync();

    final requiredMarkers = <String>[
      "fa: 'مشارکت برای مردم. ابزارهای حرفه‌ای برای سازمان‌ها.'",
      "es: 'Participación para las personas. Herramientas profesionales para las organizaciones.'",
      "pt: 'Participação para as pessoas. Ferramentas profissionais para as organizações.'",
      "fr: 'Participation pour les personnes. Outils professionnels pour les organisations.'",
      "ar: 'مشاركة للناس. أدوات احترافية للمنظمات.'",
      "ro: 'Participare pentru oameni. Instrumente profesionale pentru organizații.'",
      "fa: 'ابزار مناسب را انتخاب کنید'",
      "ar: 'التحقق والثقة والخصوصية'",
      "fr: 'Le principe économique'",
      "ro: 'Explorează Social Vote'",
    ];

    for (final marker in requiredMarkers) {
      expect(source, contains(marker), reason: marker);
    }

    expect(source, contains('socialVoteContentDirection(title)'));
    expect(source, contains('socialVoteContentDirection(body)'));
    expect(source, contains('socialVoteContentDirection(item)'));
    expect(source, contains('socialVoteContentTextAlign(title)'));
    expect(source, contains('socialVoteContentTextAlign(body)'));
    expect(source, contains('socialVoteContentTextAlign(item)'));
  });

  test('Localized poster assets are registered and present', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    for (final code in ['en', 'de', 'fa', 'es', 'pt', 'fr', 'ar', 'ro']) {
      final asset = 'assets/vision/social_vote_rules_vision_$code.jpg';
      expect(pubspec, contains('- $asset'), reason: asset);
      final file = File(asset);
      expect(file.existsSync(), isTrue, reason: asset);
      expect(file.lengthSync(), greaterThan(200 * 1024), reason: asset);
    }

    const italianPoster =
        'assets/vision/social_vote_regole_del_gioco_33.png';
    expect(pubspec, contains('- $italianPoster'));
    expect(File(italianPoster).existsSync(), isTrue);
  });

  test('Poster selection maps every supported locale without mirroring layout', () {
    final source = File(pagePath).readAsStringSync();

    for (final code in ['de', 'fa', 'es', 'pt', 'fr', 'ar', 'ro']) {
      expect(
        source,
        contains("'$code' => 'assets/vision/social_vote_rules_vision_$code.jpg'"),
        reason: code,
      );
    }
    expect(
      source,
      contains("_ => 'assets/vision/social_vote_rules_vision_en.jpg'"),
    );

    expect(
      source,
      contains('textDirection: socialVoteLocaleTextDirection(context)'),
    );
    expect(source, isNot(contains('Directionality(textDirection: TextDirection.rtl')));
  });
}
