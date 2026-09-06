import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_hero_section.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/widgets/content_directionality.dart';

void main() {
  const languageCodes = <String>[
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
  ];

  Map<String, dynamic> load(String code) => jsonDecode(
        File('lib/l10n/app_$code.arb').readAsStringSync(),
      ) as Map<String, dynamic>;

  test('Persian and Arabic ARB copy stays free of raw bidi controls', () {
    final lri = String.fromCharCode(0x2066);
    final pdi = String.fromCharCode(0x2069);

    for (final code in const <String>['fa', 'ar']) {
      final purpose = load(code)['homeHeroPurpose'] as String;
      expect(purpose, contains('Voce'), reason: code);
      expect(purpose, contains('Vote'), reason: code);
      expect(purpose, isNot(contains(lri)), reason: '$code LRI must be runtime-only');
      expect(purpose, isNot(contains(pdi)), reason: '$code PDI must be runtime-only');

      final isolated = socialVoteIsolateFixedProductNames(purpose);
      expect(isolated, contains('${lri}Voce$pdi'), reason: '$code Voce isolate');
      expect(isolated, contains('${lri}Vote$pdi'), reason: '$code Vote isolate');
    }
  });

  testWidgets('Home hero uses locale-owned text direction across all 11 locales',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final code in languageCodes) {
      final arb = load(code);
      final expectedHeadline = arb['homeHeroHeadline'] as String;
      final rawPurpose = arb['homeHeroPurpose'] as String;
      final expectedDirection =
          code == 'fa' || code == 'ar' ? TextDirection.rtl : TextDirection.ltr;
      final expectedAlign =
          expectedDirection == TextDirection.rtl ? TextAlign.right : TextAlign.left;
      final expectedPurpose = expectedDirection == TextDirection.rtl
          ? socialVoteIsolateFixedProductNames(rawPurpose)
          : rawPurpose;

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
          builder: (context, child) => Directionality(
            textDirection: TextDirection.ltr,
            child: child ?? const SizedBox.shrink(),
          ),
          home: Scaffold(
            body: SizedBox(
              width: 520,
              child: HomeHeroSection(
                scopeShortLabel: 'World',
                desktopCompact: true,
                onOpenPolls: () {},
                onOpenNews: () {},
                onCreate: () {},
                onExplore: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final headline = tester.widget<Text>(find.text(expectedHeadline));
      final purpose = tester.widget<Text>(find.text(expectedPurpose));

      expect(headline.textDirection, expectedDirection,
          reason: '$code headline direction');
      expect(headline.textAlign, expectedAlign,
          reason: '$code headline alignment');
      expect(headline.textWidthBasis, TextWidthBasis.parent,
          reason: '$code headline width basis');
      expect(purpose.textDirection, expectedDirection,
          reason: '$code purpose direction');
      expect(purpose.textAlign, expectedAlign,
          reason: '$code purpose alignment');
      expect(purpose.textWidthBasis, TextWidthBasis.parent,
          reason: '$code purpose width basis');

      expect(rawPurpose, contains('Voce'), reason: '$code invariant Voce');
      expect(rawPurpose, contains('Vote'), reason: '$code invariant Vote');
    }
  });
}
