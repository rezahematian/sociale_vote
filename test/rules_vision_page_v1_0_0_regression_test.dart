import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sociale_vote/features/onboarding/presentation/how_social_vote_works_page.dart';

void main() {
  test('Rules and vision page compiles as a Flutter widget', () {
    const page = HowSocialVoteWorksPage();
    expect(page, isA<Widget>());
  });

  test('Rules and vision source keeps the approved product contract', () {
    final source = File(
      'lib/features/onboarding/presentation/how_social_vote_works_page.dart',
    ).readAsStringSync();

    expect(source, contains("static const double _productProgress = 0.33;"));
    expect(source, contains("static const String _principlesVersion = '0.3';"));
    expect(
      source,
      contains('assets/vision/social_vote_regole_del_gioco_33.png'),
    );
    expect(source, contains('Share.share('));
    expect(source, contains('AppRouter.publicHowItWorksUrl()'));
    expect(source, contains('socialVoteContentDirection(rule.body)'));
    expect(RegExp(r'number:\s*\d+,').allMatches(source).length, 10);
  });

  test('High quality poster asset is registered and present', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    const asset = 'assets/vision/social_vote_regole_del_gioco_33.png';

    expect(pubspec, contains('- $asset'));

    final poster = File(asset);
    expect(poster.existsSync(), isTrue);
    expect(poster.lengthSync(), greaterThan(2 * 1024 * 1024));
  });

  test('Rules page keeps nine-language copy hooks without changing ARBs', () {
    final source = File(
      'lib/features/onboarding/presentation/how_social_vote_works_page.dart',
    ).readAsStringSync();

    for (final code in ['fa', 'es', 'pt', 'fr', 'ar', 'ro']) {
      expect(source, contains("'$code' =>"));
    }
    // V1.0.2 keeps the original nine-language Rules contract while the page
    // now opens with the localized How Social Vote works guide.
    expect(source, contains("fa: 'Social Vote چگونه کار می‌کند'"));
    expect(source, contains("ar: 'كيف يعمل Social Vote'"));
    expect(source, contains("fa: 'قواعد بازی · Principles v0.3'"));
    expect(source, contains("ar: 'قواعد اللعبة · Principles v0.3'"));
  });
}
