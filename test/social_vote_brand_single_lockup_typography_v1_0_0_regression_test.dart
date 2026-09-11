import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  test('Home keeps black AppBar and one centralized exact image lockup', () {
    final home = _read(
      'lib/features/home/presentation/pages/public_home_screen.dart',
    );
    final topBar = _read(
      'lib/features/home/presentation/widgets/home_top_bar.dart',
    );
    final brand = _read(
      'lib/shared/widgets/social_vote_brand_lockup.dart',
    );

    expect(home, contains('backgroundColor: Colors.black'));
    expect(topBar, contains('SocialVoteHeaderBrand'));
    final registry = _read(
      'lib/shared/branding/social_vote_brand_assets.dart',
    );
    expect(
      registry,
      contains('assets/branding/social_vote_header_lockup_master.png'),
    );
    expect(
      registry,
      contains('assets/branding/social_vote_header_neon_glow_lockup.png'),
    );
    expect(brand, contains('SocialVoteBrandAssets.headerLockup'));
    expect(brand, contains('this.height = 48'));
    expect(brand, contains('FilterQuality.high'));
    expect(brand, contains('isAntiAlias: true'));
    expect(brand, isNot(contains("fontFamily: 'sans-serif'")));
    expect(brand, isNot(contains('FontWeight.w800')));
    expect(brand, isNot(contains('Color(0xFFF8FAFC)')));
  });

  test('Home hero contains no second Social Vote wordmark', () {
    final hero = _read(
      'lib/features/home/presentation/widgets/home_hero_section.dart',
    );

    expect(hero, isNot(contains('social_vote_wordmark_horizontal.png')));
    expect(hero, isNot(contains('social_vote_header_wordmark_exact.png')));
    expect(hero, isNot(contains('social_vote_header_neon_lockup.png')));
    expect(hero, isNot(contains('_HeroBrandLockup')));
  });

  test('Admin Center remains separate and does not render the Home lockup', () {
    final admin = _read(
      'lib/features/admin/presentation/pages/admin_center_page.dart',
    );

    expect(admin, contains('adminCenterTitle'));
    expect(admin, isNot(contains('SocialVoteHeaderBrand')));
    expect(
      admin,
      isNot(contains('assets/branding/social_vote_header_neon_lockup.png')),
    );
  });
}
