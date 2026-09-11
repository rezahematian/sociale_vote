import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

({int width, int height}) _pngSize(String path) {
  final bytes = File(path).readAsBytesSync();
  expect(bytes.length, greaterThanOrEqualTo(24), reason: path);
  expect(
    bytes.sublist(0, 8),
    equals(<int>[137, 80, 78, 71, 13, 10, 26, 10]),
    reason: '$path must be PNG',
  );
  final data = ByteData.sublistView(Uint8List.fromList(bytes));
  return (
    width: data.getUint32(16, Endian.big),
    height: data.getUint32(20, Endian.big),
  );
}

void main() {
  test('brand professional asset dimensions match runtime contract', () {
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
      'web/social-vote-og.png': (width: 1200, height: 630),
      'assets/icons/app_icon.png': (width: 1024, height: 1024),
      'assets/branding/social_vote_symbol.png': (width: 1024, height: 1024),
      'assets/branding/social_vote_wordmark_horizontal.png': (
        width: 2400,
        height: 600
      ),
      'assets/branding/social_vote_logo_stacked.png': (
        width: 1600,
        height: 1600
      ),
      'assets/branding/social_vote_header_neon_lockup.png': (
        width: 2048,
        height: 682
      ),
      'assets/branding/social_vote_header_neon_glow_lockup.png': (
        width: 2048,
        height: 682
      ),
      'android/app/src/main/res/mipmap-mdpi/ic_launcher.png': (
        width: 48,
        height: 48
      ),
      'android/app/src/main/res/mipmap-hdpi/ic_launcher.png': (
        width: 72,
        height: 72
      ),
      'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png': (
        width: 96,
        height: 96
      ),
      'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png': (
        width: 144,
        height: 144
      ),
      'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png': (
        width: 192,
        height: 192
      ),
      'android/app/src/main/res/drawable/launch_image.png': (
        width: 1280,
        height: 1280
      ),
    };

    for (final entry in expected.entries) {
      expect(_pngSize(entry.key), entry.value, reason: entry.key);
    }
    expect(File('web/favicon.ico').existsSync(), isTrue);
  });

  test('brand wiring uses the frozen exact Home header image lockup', () {
    final topBar = File(
      'lib/features/home/presentation/widgets/home_top_bar.dart',
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
    expect(brand, isNot(contains("fontFamily: 'sans-serif'")));
  });
}
