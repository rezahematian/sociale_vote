import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

({int width, int height, int colorType}) _pngContract(String path) {
  final bytes = File(path).readAsBytesSync();
  expect(bytes.length, greaterThanOrEqualTo(26), reason: path);
  expect(bytes.sublist(0, 8), equals(<int>[137, 80, 78, 71, 13, 10, 26, 10]),
      reason: '$path must be PNG');
  final data = ByteData.sublistView(Uint8List.fromList(bytes));
  return (
    width: data.getUint32(16, Endian.big),
    height: data.getUint32(20, Endian.big),
    colorType: bytes[25]
  );
}

void main() {
  test('Home header uses the centralized clean/glow Social Vote contract', () {
    final topBar =
        _read('lib/features/home/presentation/widgets/home_top_bar.dart');
    final brand = _read('lib/shared/widgets/social_vote_brand_lockup.dart');
    final registry = _read('lib/shared/branding/social_vote_brand_assets.dart');
    expect(topBar, contains('SocialVoteHeaderBrand'));
    expect(registry,
        contains('assets/branding/social_vote_header_lockup_master.png'));
    expect(registry,
        contains('assets/branding/social_vote_header_neon_glow_lockup.png'));
    expect(brand, contains('SocialVoteBrandAssets.headerLockup'));
    expect(brand, contains('SocialVoteBrandAssets.headerGlowLockup'));
    expect(brand, contains('this.height = 48'));
    expect(brand, contains('FilterQuality.high'));
    expect(brand, contains('isAntiAlias: true'));
    expect(brand, isNot(contains("fontFamily: 'sans-serif'")));
  });

  test('Current header runtime assets are high resolution and alpha-capable',
      () {
    const clean = 'assets/branding/social_vote_header_lockup_master.png';
    const glow = 'assets/branding/social_vote_header_neon_glow_lockup.png';
    expect(File(clean).existsSync(), isTrue);
    expect(File(glow).existsSync(), isTrue);
    final cleanContract = _pngContract(clean);
    final glowContract = _pngContract(glow);
    expect(cleanContract.width, greaterThanOrEqualTo(2000));
    expect(cleanContract.height, greaterThanOrEqualTo(650));
    expect(cleanContract.colorType, equals(6));
    expect(glowContract.width, equals(cleanContract.width));
    expect(glowContract.height, equals(cleanContract.height));
    expect(glowContract.colorType, equals(6));
  });

  test('Current platform icon dimensions match Icons V2 contract', () {
    expect(_pngContract('assets/icons/app_icon.png'),
        (width: 1254, height: 1254, colorType: 6));
    expect(_pngContract('assets/branding/social_vote_symbol.png'),
        (width: 1254, height: 1254, colorType: 6));
    final expected = <String, ({int width, int height})>{
      'web/favicon-16x16.png': (width: 16, height: 16),
      'web/favicon-32x32.png': (width: 32, height: 32),
      'web/favicon-48x48.png': (width: 48, height: 48),
      'web/favicon.png': (width: 96, height: 96),
      'web/apple-touch-icon.png': (width: 180, height: 180),
      'web/icons/Icon-192.png': (width: 192, height: 192),
      'web/icons/Icon-512.png': (width: 512, height: 512),
      'web/icons/Icon-maskable-192.png': (width: 192, height: 192),
      'web/icons/Icon-maskable-512.png': (width: 512, height: 512),
    };
    for (final entry in expected.entries) {
      final c = _pngContract(entry.key);
      expect((width: c.width, height: c.height), entry.value,
          reason: entry.key);
    }
    expect(File('web/favicon.ico').existsSync(), isTrue);
  });

  test('Home Hero and static public pages preserve brand wiring', () {
    final hero =
        _read('lib/features/home/presentation/widgets/home_hero_section.dart');
    final deletePage = _read('web/delete-account/index.html');
    expect(hero, isNot(contains('_HeroBrandLockup')));
    expect(deletePage, contains('/brand/social-vote-symbol-128.png'));
    expect(deletePage, contains('/favicon-48x48.png'));
    expect(deletePage, contains('/apple-touch-icon.png'));
  });
}
