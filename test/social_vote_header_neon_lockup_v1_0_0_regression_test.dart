import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

({int width, int height, int colorType}) _pngContract(String path) {
  final bytes = File(path).readAsBytesSync();
  expect(bytes.length, greaterThanOrEqualTo(26), reason: path);
  expect(
    bytes.sublist(0, 8),
    equals(<int>[137, 80, 78, 71, 13, 10, 26, 10]),
    reason: '$path must be PNG',
  );
  final data = ByteData.sublistView(Uint8List.fromList(bytes));
  return (
    width: data.getUint32(16, Endian.big),
    height: data.getUint32(20, Endian.big),
    colorType: bytes[25],
  );
}

void main() {
  test('accepted neon lockup is exact RGBA high-resolution asset', () {
    const path = 'assets/branding/social_vote_header_neon_lockup.png';
    expect(File(path).existsSync(), isTrue);
    expect(
      _pngContract(path),
      (width: 2095, height: 496, colorType: 6),
    );
  });

  test('Flutter renders only the exact lockup image in the Home header', () {
    final brand = File(
      'lib/shared/widgets/social_vote_brand_lockup.dart',
    ).readAsStringSync();
    final topBar = File(
      'lib/features/home/presentation/widgets/home_top_bar.dart',
    ).readAsStringSync();

    expect(topBar, contains('SocialVoteHeaderBrand'));
    expect(
      brand,
      contains('assets/branding/social_vote_header_neon_lockup.png'),
    );
    expect(brand, contains('this.height = 48'));
    expect(brand, contains('alignment: AlignmentDirectional.centerStart'));
    expect(brand, contains('filterQuality: FilterQuality.high'));
    expect(brand, contains('isAntiAlias: true'));
    expect(brand, isNot(contains('assets/branding/social_vote_symbol.png')));
    expect(brand, isNot(contains("fontFamily: 'sans-serif'")));
  });

  test('Hero and Admin do not duplicate the Home header lockup', () {
    final hero = File(
      'lib/features/home/presentation/widgets/home_hero_section.dart',
    ).readAsStringSync();
    final admin = File(
      'lib/features/admin/presentation/pages/admin_center_page.dart',
    ).readAsStringSync();

    expect(hero, isNot(contains('social_vote_header_neon_lockup.png')));
    expect(hero, isNot(contains('_HeroBrandLockup')));
    expect(admin, isNot(contains('SocialVoteHeaderBrand')));
    expect(admin, isNot(contains('social_vote_header_neon_lockup.png')));
  });
}
