import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'header renderer keeps CURRENT clean/glow registry and high-quality native path',
      () {
    final brand = File('lib/shared/widgets/social_vote_brand_lockup.dart')
        .readAsStringSync();
    final registry = File('lib/shared/branding/social_vote_brand_assets.dart')
        .readAsStringSync();
    expect(registry,
        contains('assets/branding/social_vote_header_lockup_master.png'));
    expect(registry,
        contains('assets/branding/social_vote_header_neon_glow_lockup.png'));
    expect(brand, contains('MediaQuery.devicePixelRatioOf(context)'));
    expect(brand, contains('filterQuality: FilterQuality.high'));
    expect(brand, contains('isAntiAlias: true'));
    expect(brand, contains('SocialVoteHeaderWebImage('));
    expect(brand, contains('glowIntensity: _glowIntensity'));
  });

  test('Web uses a persistent native browser image and CSS filter for V4 glow',
      () {
    final webRenderer =
        File('lib/shared/widgets/social_vote_header_web_image_web.dart')
            .readAsStringSync();
    expect(webRenderer, contains("import 'package:web/web.dart' as web;"));
    expect(webRenderer, contains('web.HTMLImageElement? _image'));
    expect(webRenderer, contains('HtmlElementView.fromTagName'));
    expect(webRenderer, contains("tagName: 'img'"));
    expect(webRenderer, contains('PlatformViewHitTestBehavior.transparent'));
    expect(webRenderer, contains("..src = 'assets/\${widget.assetPath}'"));
    expect(webRenderer, contains("..objectFit = 'contain'"));
    expect(webRenderer, contains("..objectPosition = 'left center'"));
    expect(webRenderer, contains("..imageRendering = 'auto'"));
    expect(webRenderer, contains("..pointerEvents = 'none'"));
    expect(webRenderer, contains("style.setProperty('filter'"));
  });

  test('non-Web path remains high-quality Flutter Image.asset', () {
    final stub =
        File('lib/shared/widgets/social_vote_header_web_image_stub.dart')
            .readAsStringSync();
    expect(stub, contains('Image.asset('));
    expect(stub, contains('filterQuality: FilterQuality.high'));
    expect(stub, contains('isAntiAlias: true'));
  });
}
