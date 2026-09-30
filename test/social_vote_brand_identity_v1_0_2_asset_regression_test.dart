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
  test('brand asset dimensions match CURRENT runtime contract', () {
    final exact = <String, ({int width, int height})>{
      'web/favicon-16x16.png': (width: 16, height: 16),
      'web/favicon-32x32.png': (width: 32, height: 32),
      'web/favicon-48x48.png': (width: 48, height: 48),
      'web/favicon.png': (width: 96, height: 96),
      'web/apple-touch-icon.png': (width: 180, height: 180),
      'web/icons/Icon-192.png': (width: 192, height: 192),
      'web/icons/Icon-512.png': (width: 512, height: 512),
      'web/icons/Icon-maskable-192.png': (width: 192, height: 192),
      'web/icons/Icon-maskable-512.png': (width: 512, height: 512),
      'assets/icons/app_icon.png': (width: 1254, height: 1254),
      'assets/branding/social_vote_symbol.png': (width: 1254, height: 1254),
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
    };
    for (final entry in exact.entries) {
      final c = _pngContract(entry.key);
      expect((width: c.width, height: c.height), entry.value,
          reason: entry.key);
    }

    final clean =
        _pngContract('assets/branding/social_vote_header_lockup_master.png');
    final glow =
        _pngContract('assets/branding/social_vote_header_neon_glow_lockup.png');
    expect(clean.width, greaterThanOrEqualTo(2000));
    expect(clean.height, greaterThanOrEqualTo(650));
    expect((width: glow.width, height: glow.height),
        (width: clean.width, height: clean.height));
  });

  test('brand wiring uses clean plus optional glow and no text reconstruction',
      () {
    final brand = _read('lib/shared/widgets/social_vote_brand_lockup.dart');
    final registry = _read('lib/shared/branding/social_vote_brand_assets.dart');
    expect(registry,
        contains('assets/branding/social_vote_header_lockup_master.png'));
    expect(registry,
        contains('assets/branding/social_vote_header_neon_glow_lockup.png'));
    expect(brand, contains('SocialVoteBrandAssets.headerLockup'));
    expect(brand, contains('SocialVoteHeaderWebImage'));
    expect(brand, isNot(contains("fontFamily: 'sans-serif'")));
  });
}
