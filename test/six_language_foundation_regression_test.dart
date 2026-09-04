import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/app/app.dart';
import 'package:sociale_vote/app/localization/de_fallback.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

void main() {
  const appLanguageCodes = <String>{
    'en',
    'it',
    'de',
    'fa',
    'es',
    'pt',
    'fr',
    'ar',
    'ro',
    'ru',
    'zh',
  };

  test('eleven app locales and system resolution contract', () {
    final codes = AppLocalizations.supportedLocales
        .map((locale) => locale.languageCode)
        .toSet();
    expect(codes, appLanguageCodes);
    expect(codes.length, 11);

    for (final code in <String>['it', 'es', 'pt', 'fr', 'ar', 'ro']) {
      expect(
        AppLocaleController.resolveSystemLocale(
          <Locale>[Locale(code)],
          AppLocalizations.supportedLocales,
        ).languageCode,
        code,
      );
    }

    expect(
      AppLocaleController.resolveSystemLocale(
        const <Locale>[Locale('ja', 'JP')],
        AppLocalizations.supportedLocales,
      ).languageCode,
      'en',
    );
  });

  for (final code in <String>[
    'en',
    'it',
    'de',
    'fa',
    'es',
    'pt',
    'fr',
    'ar',
    'ro',
    'ru',
    'zh',
  ]) {
    testWidgets('$code has Material/Cupertino/App localization delegates',
        (tester) async {
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
            builder: (context) => Text(
              AppLocalizations.of(context)!.profileAppLanguageTitle,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(Text), findsWidgets);
    });
  }

  testWidgets('legacy inline copy is localized for eight non-EN extended locales',
      (tester) async {
    Future<String> read(String code, String english, String german) async {
      late String result;
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
              result = deOrEnglish(
                context,
                english: english,
                german: german,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pump();
      return result;
    }

    expect(await read('fa', 'Content location', 'Inhaltsstandort'), 'مکان محتوا');
    expect(await read('es', 'Content location', 'Inhaltsstandort'), 'Ubicación del contenido');
    expect(await read('pt', 'Content location', 'Inhaltsstandort'), 'Localização do conteúdo');
    expect(await read('fr', 'Content location', 'Inhaltsstandort'), 'Emplacement du contenu');
    expect(await read('ar', 'Content location', 'Inhaltsstandort'), 'موقع المحتوى');
    expect(await read('ro', 'Content location', 'Inhaltsstandort'), 'Locația conținutului');
    expect(await read('ru', 'Content location', 'Inhaltsstandort'), 'Местоположение контента');
    expect(await read('zh', 'Content location', 'Inhaltsstandort'), '内容位置');
    expect(await read('de', 'Content location', 'Inhaltsstandort'), 'Inhaltsstandort');
    expect(await read('en', 'Content location', 'Inhaltsstandort'), 'Content location');
  });

  test('guest locale contract is System and preference is account scoped', () {
    final source = File('lib/app/app.dart').readAsStringSync();
    expect(source, contains("if (userId == null) {\n      locale.value = null;"));
    expect(source, contains('app_locale_preference_v2'));
    expect(source, contains('Guest always uses System'));
  });
}
