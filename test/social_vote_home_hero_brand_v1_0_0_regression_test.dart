import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_hero_section.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

void main() {
  test('Home hero does not duplicate the global Social Vote lockup', () {
    final source = File(
      'lib/features/home/presentation/widgets/home_hero_section.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('social_vote_wordmark_horizontal.png')));
    expect(source, isNot(contains('_HeroBrandLockup')));
    expect(source, isNot(contains('home_hero_social_vote_brand')));
  });

  Future<void> pumpHero(
    WidgetTester tester, {
    required double width,
    required bool desktopCompact,
  }) async {
    await tester.binding.setSurfaceSize(Size(width, 900));

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('it'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: width,
              child: HomeHeroSection(
                scopeShortLabel: 'World',
                desktopCompact: desktopCompact,
                onOpenPolls: () {},
                onOpenNews: () {},
                onCreate: () {},
                onExplore: () {},
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
  }

  testWidgets('Android/narrow hero remains clean after duplicate brand removal',
      (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpHero(
      tester,
      width: 360,
      desktopCompact: false,
    );

    expect(find.text('Social Vote'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Web compact hero remains clean after duplicate brand removal',
      (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpHero(
      tester,
      width: 520,
      desktopCompact: true,
    );

    expect(find.text('Social Vote'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
