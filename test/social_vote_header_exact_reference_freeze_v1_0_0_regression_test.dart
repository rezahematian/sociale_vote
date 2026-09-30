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
  test(
      'Header V4 keeps clean logo visible and Admin normal/flicker modes wired',
      () {
    final brand = _read('lib/shared/widgets/social_vote_brand_lockup.dart');
    final service = _read('lib/shared/services/brand_header_mode_service.dart');
    expect(
        brand, contains('BrandHeaderMode.normal => SocialVoteBrandEffect.off'));
    expect(brand,
        contains('BrandHeaderMode.flicker => SocialVoteBrandEffect.flicker'));
    expect(brand, contains('_nativeImage(SocialVoteHeaderBrand.lockupAsset)'));
    expect(brand, contains('AnimatedOpacity('));
    expect(service, contains("BrandHeaderMode _mode = BrandHeaderMode.normal"));
    expect(service, contains("'normal' => BrandHeaderMode.normal"));
    expect(service, contains("'flicker' => BrandHeaderMode.flicker"));
  });

  test('Current header assets are retained and compatible', () {
    const clean = 'assets/branding/social_vote_header_lockup_master.png';
    const glow = 'assets/branding/social_vote_header_neon_glow_lockup.png';
    final c = _pngContract(clean);
    final g = _pngContract(glow);
    expect(c.colorType, 6);
    expect(g.colorType, 6);
    expect(
        (width: g.width, height: g.height), (width: c.width, height: c.height));
    expect(
        File('assets/branding/HEADER_BRAND_CURRENT.txt').existsSync(), isTrue);
  });

  test('Home Hero does not duplicate Social Vote header lockup', () {
    final hero =
        _read('lib/features/home/presentation/widgets/home_hero_section.dart');
    expect(hero, isNot(contains('_HeroBrandLockup')));
    expect(hero, isNot(contains('SocialVoteHeaderBrand')));
  });
}
