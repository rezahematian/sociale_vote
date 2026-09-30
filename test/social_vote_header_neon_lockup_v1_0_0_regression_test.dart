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
  test('V4 flicker never removes the clean header base', () {
    final brand = _read('lib/shared/widgets/social_vote_brand_lockup.dart');
    expect(brand, contains('final header = kIsWeb'));
    expect(brand, contains('SocialVoteHeaderBrand.lockupAsset'));
    expect(brand, contains('SocialVoteHeaderBrand.glowAsset'));
    expect(brand, contains('_flickerSteps'));
    expect(brand, contains('Duration(milliseconds: 55)'));
    expect(brand, contains('AnimatedOpacity('));
  });

  test('Web V4 keeps one image mounted and changes filter only', () {
    final web =
        _read('lib/shared/widgets/social_vote_header_web_image_web.dart');
    expect(web, contains('web.HTMLImageElement? _image'));
    expect(web, contains("style.setProperty('filter'"));
    expect(web, contains("style.setProperty('filter', 'none')"));
    expect(web, contains('HtmlElementView.fromTagName'));
    expect(web, contains("..src = 'assets/\${widget.assetPath}'"));
  });

  test('Header assets remain high resolution', () {
    final clean =
        _pngContract('assets/branding/social_vote_header_lockup_master.png');
    final glow =
        _pngContract('assets/branding/social_vote_header_neon_glow_lockup.png');
    expect(clean.width, greaterThanOrEqualTo(2000));
    expect(clean.height, greaterThanOrEqualTo(650));
    expect((width: glow.width, height: glow.height),
        (width: clean.width, height: clean.height));
  });
}
