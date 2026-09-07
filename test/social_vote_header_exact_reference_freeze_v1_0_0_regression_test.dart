import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

({int width, int height}) _pngSize(String path) {
  final bytes = File(path).readAsBytesSync();
  expect(bytes.length, greaterThanOrEqualTo(24), reason: path);
  final data = ByteData.sublistView(Uint8List.fromList(bytes));
  return (
    width: data.getUint32(16, Endian.big),
    height: data.getUint32(20, Endian.big),
  );
}

void main() {
  const oldHeaderAsset =
      'assets/branding/social_vote_header_wordmark_exact.png';
  const currentHeaderAsset =
      'assets/branding/social_vote_header_neon_lockup.png';

  test('Home header uses the accepted neon exact-image runtime contract', () {
    final topBar = File(
      'lib/features/home/presentation/widgets/home_top_bar.dart',
    ).readAsStringSync();
    final brand = File(
      'lib/shared/widgets/social_vote_brand_lockup.dart',
    ).readAsStringSync();

    expect(topBar, contains('SocialVoteHeaderBrand'));
    expect(topBar, isNot(contains(oldHeaderAsset)));
    expect(brand, contains(currentHeaderAsset));
    expect(brand, contains('this.height = 48'));
    expect(brand, isNot(contains('assets/branding/social_vote_symbol.png')));
  });

  test('Current and historical header images are retained with exact sizes', () {
    const source =
        'assets/branding/social_vote_header_reference_exact_original.png';

    expect(File(currentHeaderAsset).existsSync(), isTrue);
    expect(_pngSize(currentHeaderAsset), (width: 2095, height: 496));
    expect(File(source).existsSync(), isTrue);
    expect(_pngSize(source), (width: 2048, height: 682));
    expect(File(oldHeaderAsset).existsSync(), isTrue);
    expect(_pngSize(oldHeaderAsset), (width: 1705, height: 494));
    expect(
      File('assets/branding/HEADER_BRAND_CURRENT.txt').existsSync(),
      isTrue,
    );
  });

  test('Home Hero no longer renders a second Social Vote lockup', () {
    final hero = File(
      'lib/features/home/presentation/widgets/home_hero_section.dart',
    ).readAsStringSync();

    expect(hero, isNot(contains('social_vote_wordmark_horizontal.png')));
    expect(hero, isNot(contains('social_vote_header_neon_lockup.png')));
    expect(hero, isNot(contains('_HeroBrandLockup')));
  });
}
