import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/app/app.dart';
import 'package:sociale_vote/app/localization/de_fallback.dart';
import 'package:sociale_vote/features/profile/presentation/pages/my_profile_page.dart';
import 'package:sociale_vote/features/profile/presentation/pages/world_appearance_settings_page.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/data/countries.dart';
import 'package:sociale_vote/shared/services/anti_abuse_error_service.dart';
import 'package:sociale_vote/shared/widgets/content_directionality.dart';
import 'package:sociale_vote/shared/widgets/content_language_field.dart';

void main() {
  test('FR AR RO are first-class app locales', () {
    final codes = AppLocalizations.supportedLocales
        .map((locale) => locale.languageCode)
        .toSet();
    expect(codes.length, 9);
    expect(codes, containsAll(<String>{'fr', 'ar', 'ro'}));

    for (final code in <String>['fr', 'ar', 'ro']) {
      expect(
        AppLocaleController.resolveSystemLocale(
          <Locale>[Locale(code)],
          AppLocalizations.supportedLocales,
        ).languageCode,
        code,
      );
    }
  });

  for (final code in <String>['fr', 'ar', 'ro']) {
    testWidgets('$code loads generated AppLocalizations', (tester) async {
      late String title;
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(code),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              title = AppLocalizations.of(context)!.profileAppLanguageTitle;
              return Text(title);
            },
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(title.trim(), isNotEmpty);
    });
  }

  testWidgets('Arabic is text-only RTL while French and Romanian stay LTR',
      (tester) async {
    Future<TextDirection> directionFor(String code) async {
      late TextDirection direction;
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(code),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              direction = socialVoteLocaleTextDirection(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pump();
      return direction;
    }

    expect(await directionFor('ar'), TextDirection.rtl);
    expect(await directionFor('fr'), TextDirection.ltr);
    expect(await directionFor('ro'), TextDirection.ltr);
    expect(socialVoteContentDirection('مرحبا 99999'), TextDirection.rtl);
    expect(socialVoteContentDirection('Bonjour 99999'), TextDirection.ltr);
    expect(socialVoteContentDirection('Salut 99999'), TextDirection.ltr);
  });

  testWidgets('legacy fallback is translated for FR AR RO', (tester) async {
    Future<String> read(String code, String english) async {
      late String value;
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(code),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              value = deOrEnglish(
                context,
                english: english,
                german: 'DE',
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pump();
      return value;
    }

    expect(await read('fr', 'Discover what matters'), 'Découvrez ce qui compte');
    expect(await read('ar', 'Discover what matters'), 'اكتشف ما يهم');
    expect(await read('ro', 'Discover what matters'), 'Descoperă ce contează');
  });

  test('legacy FR AR RO maps cover the complete Spanish legacy key set', () {
    final source = File(
      'lib/app/localization/de_fallback.dart',
    ).readAsStringSync();

    Set<String> mapKeys(String name) {
      final block = RegExp(
        'const Map<String, String> _legacy$name = \\{([\\s\\S]*?)\\n\\};',
      ).firstMatch(source);
      expect(block, isNotNull, reason: name);
      return RegExp(r"^\s*'((?:\\'|[^'])*)':", multiLine: true)
          .allMatches(block!.group(1)!)
          .map((match) => match.group(1)!)
          .toSet();
    }

    final reference = mapKeys('Es');
    expect(reference.length, 348);
    for (final name in <String>['Pt', 'Fr', 'Ar', 'Ro']) {
      expect(mapKeys(name), reference, reason: name);
    }
  });

  test('country labels and anti-abuse messages cover FR AR RO', () {
    expect(Countries.nameForCode('DE', languageCode: 'fr'), isNot('Germany'));
    expect(Countries.nameForCode('DE', languageCode: 'ar'), isNot('Germany'));
    expect(Countries.nameForCode('DE', languageCode: 'ro'), isNot('Germany'));

    for (final code in <String>['fr', 'ar', 'ro']) {
      final message = antiAbuseRateLimitMessageForLanguageCode(code);
      expect(message, isNot(contains('too many actions')));
      expect(message.trim(), isNotEmpty);
    }
  });

  test('content language list includes Romanian with existing French and Arabic', () {
    final codes = supportedContentLanguages.map((item) => item.code).toSet();
    expect(codes, containsAll(<String>{'fr', 'ar', 'ro'}));
  });

  test('account language selector and world appearance source include FR AR RO', () {
    final profileSource = File(
      'lib/features/profile/presentation/pages/my_profile_page.dart',
    ).readAsStringSync();
    final appearanceSource = File(
      'lib/features/profile/presentation/pages/world_appearance_settings_page.dart',
    ).readAsStringSync();

    for (final code in <String>['fr', 'ar', 'ro']) {
      expect(profileSource, contains("value: '$code'"), reason: code);
      expect(appearanceSource, contains("'$code' =>"), reason: code);
    }

    expect(profileSource, contains("'ar' => const Locale('ar')"));
    expect(appearanceSource, contains('socialVoteLocaleTextDirection'));
  });

  test('Web document language is synchronized without changing geometry', () {
    final appSource = File('lib/app/app.dart').readAsStringSync();
    final webSource = File(
      'lib/shared/services/web_document_language_web.dart',
    ).readAsStringSync();
    expect(appSource, contains('updateWebDocumentLanguage('));
    expect(appSource, contains('textDirection: TextDirection.ltr'));
    expect(webSource, contains("setAttribute('lang', normalized)"));
    expect(webSource, isNot(contains("setAttribute('dir'")));
  });

  test('target pages compile with nine-language expansion', () {
    expect(MyProfilePage, isNotNull);
    expect(WorldAppearanceSettingsPage, isNotNull);
  });
}
