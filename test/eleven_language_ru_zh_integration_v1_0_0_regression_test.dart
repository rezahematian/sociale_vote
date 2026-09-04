import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/app/app.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/data/countries.dart';
import 'package:sociale_vote/shared/services/anti_abuse_error_service.dart';

void main() {
  test('eleven locale contract includes Russian and Simplified Chinese', () {
    final codes = AppLocalizations.supportedLocales
        .map((locale) => locale.languageCode)
        .toSet();
    expect(codes.length, 11);
    expect(codes, containsAll(<String>{
      'en', 'it', 'de', 'fa', 'es', 'pt', 'fr', 'ar', 'ro', 'ru', 'zh',
    }));

    expect(
      AppLocaleController.resolveSystemLocale(
        const <Locale>[Locale('ru')],
        AppLocalizations.supportedLocales,
      ).languageCode,
      'ru',
    );
    expect(
      AppLocaleController.resolveSystemLocale(
        const <Locale>[Locale('zh')],
        AppLocalizations.supportedLocales,
      ).languageCode,
      'zh',
    );
  });

  test('all eleven ARB files have exact 1309-message parity', () {
    const codes = <String>[
      'en', 'it', 'de', 'fa', 'es', 'pt', 'fr', 'ar', 'ro', 'ru', 'zh',
    ];

    Set<String> messageKeys(String code) {
      final decoded = jsonDecode(
        File('lib/l10n/app_$code.arb').readAsStringSync(),
      ) as Map<String, dynamic>;
      return decoded.keys.where((key) => !key.startsWith('@')).toSet();
    }

    final reference = messageKeys('en');
    expect(reference.length, 1309);
    for (final code in codes.skip(1)) {
      expect(messageKeys(code), reference, reason: code);
    }
  });

  test('RU and ZH are wired through selector, legacy surfaces and posters', () {
    final profile = File(
      'lib/features/profile/presentation/pages/my_profile_page.dart',
    ).readAsStringSync();
    final fallback = File(
      'lib/app/localization/de_fallback.dart',
    ).readAsStringSync();
    final how = File(
      'lib/features/onboarding/presentation/how_social_vote_works_page.dart',
    ).readAsStringSync();
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(profile, contains("value: 'ru'"));
    expect(profile, contains("value: 'zh'"));
    expect(profile, contains("label: 'Русский'"));
    expect(profile, contains("label: '中文（简体）'"));
    expect(fallback, contains('_legacyRu'));
    expect(fallback, contains('_legacyZh'));
    expect(how, contains('social_vote_rules_vision_ru.jpg'));
    expect(how, contains('social_vote_rules_vision_zh.jpg'));

    for (final code in <String>['ru', 'zh']) {
      final asset = 'assets/vision/social_vote_rules_vision_$code.jpg';
      expect(pubspec, contains('- $asset'));
      expect(File(asset).existsSync(), isTrue);
      expect(File(asset).lengthSync(), greaterThan(200 * 1024));
    }
  });

  test('RU and ZH user-facing helpers do not fall back to English', () {
    expect(Countries.nameForCode('DE', languageCode: 'ru'), isNot('Germany'));
    expect(Countries.nameForCode('DE', languageCode: 'zh'), isNot('Germany'));
    expect(
      antiAbuseRateLimitMessageForLanguageCode('ru'),
      isNot(contains('too many actions')),
    );
    expect(
      antiAbuseRateLimitMessageForLanguageCode('zh'),
      isNot(contains('too many actions')),
    );
  });
}
