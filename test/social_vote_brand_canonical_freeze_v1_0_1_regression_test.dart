import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'Header uses one centralized exact image lockup and Hero has no duplicate brand',
      () {
    final topBar = File(
      'lib/features/home/presentation/widgets/home_top_bar.dart',
    ).readAsStringSync();
    final hero = File(
      'lib/features/home/presentation/widgets/home_hero_section.dart',
    ).readAsStringSync();
    final brand = File(
      'lib/shared/widgets/social_vote_brand_lockup.dart',
    ).readAsStringSync();

    expect(topBar, contains('SocialVoteHeaderBrand'));
    final registry = File(
      'lib/shared/branding/social_vote_brand_assets.dart',
    ).readAsStringSync();
    expect(
      registry,
      contains('assets/branding/social_vote_header_lockup_master.png'),
    );
    expect(
      registry,
      contains('assets/branding/social_vote_header_neon_glow_lockup.png'),
    );
    expect(brand, contains('SocialVoteBrandAssets.headerLockup'));
    expect(brand, isNot(contains('assets/branding/social_vote_symbol.png')));
    expect(
        brand, isNot(contains("const Text(\n                'Social Vote'")));
    expect(hero, isNot(contains('social_vote_wordmark_horizontal.png')));
    expect(hero, isNot(contains('_HeroBrandLockup')));
  });
}
