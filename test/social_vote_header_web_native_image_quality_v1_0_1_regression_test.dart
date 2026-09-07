import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('header quality upgrade preserves the accepted exact PNG', () {
    final brand = File(
      'lib/shared/widgets/social_vote_brand_lockup.dart',
    ).readAsStringSync();

    expect(
      brand,
      contains('assets/branding/social_vote_header_neon_lockup.png'),
    );
    expect(brand, contains('this.height = 48'));
    expect(brand, contains('filterQuality: FilterQuality.high'));
    expect(brand, contains('isAntiAlias: true'));
    expect(brand, contains('MediaQuery.devicePixelRatioOf(context)'));
    expect(
      brand,
      contains('const SocialVoteHeaderWebImage(assetPath: lockupAsset)'),
    );
  });

  test('Web uses native browser image resampling for zoom quality', () {
    final webRenderer = File(
      'lib/shared/widgets/social_vote_header_web_image_web.dart',
    ).readAsStringSync();

    expect(
      webRenderer,
      contains(
        "import 'package:flutter/rendering.dart' show PlatformViewHitTestBehavior;",
      ),
    );
    expect(webRenderer, contains("import 'package:web/web.dart' as web;"));
    expect(webRenderer, contains('HtmlElementView.fromTagName'));
    expect(webRenderer, contains("tagName: 'img'"));
    expect(
      webRenderer,
      contains('hitTestBehavior: PlatformViewHitTestBehavior.transparent'),
    );
    expect(webRenderer, contains("..src = 'assets/\$assetPath'"));
    expect(webRenderer, contains("..objectFit = 'contain'"));
    expect(webRenderer, contains("..objectPosition = 'left center'"));
    expect(webRenderer, contains("..imageRendering = 'auto'"));
    expect(webRenderer, contains("..pointerEvents = 'none'"));
  });

  test('non-Web path remains normal high-quality Flutter Image.asset', () {
    final stub = File(
      'lib/shared/widgets/social_vote_header_web_image_stub.dart',
    ).readAsStringSync();

    expect(stub, contains('Image.asset('));
    expect(stub, contains('filterQuality: FilterQuality.high'));
    expect(stub, contains('isAntiAlias: true'));
  });
}
