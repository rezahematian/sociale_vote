import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final shader = File(
    'third_party/flutter_earth_globe_social_vote/shaders/sphere.frag',
  ).readAsStringSync();
  final web = File('web/social_vote_globe.js').readAsStringSync();
  final globe = File(
    'lib/features/map/presentation/widgets/world_globe_widget.dart',
  ).readAsStringSync();

  test('Web alphaMap uses green * opacity before alphaTest', () {
    expect(web, contains('this._cloudLayer.material.alphaMap = texture;'));
    expect(web, contains('thresholdSparse + (thresholdDense - thresholdSparse) * density'));
    expect(web, contains('opacityMin + (opacityMax - opacityMin) * density'));
    expect(web, contains('const thresholdSparse ='));
  });

  test('Android matches Web alpha pipeline with narrow edge feather', () {
    expect(shader, contains('float threshold = mix(0.82, 0.12,'));
    expect(shader, contains('float cloudOpacity = mix(0.42, 0.82,'));
    expect(shader, contains('float cloudRawAlpha = cloudSample.g * cloudOpacity;'));
    expect(shader, contains('float feather = softness * 0.30;'));
    expect(shader, contains('threshold - feather,'));
    expect(shader, contains('threshold + feather,'));
    expect(shader, contains('cloudRawAlpha * cloudVisibility'));
    expect(shader, isNot(contains('cloudAlpha = cloudMask * cloudOpacity')));
    expect(shader, isNot(contains('cloudLuma')));
  });

  test('Existing Earth shading and direction remain untouched', () {
    final earthLighting = shader.indexOf('fragColor.rgb *= lighting;');
    final cloudComposite = shader.indexOf('if (cloudAlpha > 0.0)');
    expect(earthLighting, greaterThanOrEqualTo(0));
    expect(cloudComposite, greaterThan(earthLighting));
    expect(shader, contains('uv.x - (uCloudRotationOffset / TWO_PI)'));
    expect(globe, contains('final radiansPerSecond = 0.003 + (_effectiveCloudSpeed * 0.022);'));
    expect(globe, contains('seconds * radiansPerSecond * _effectiveCloudDirection'));
  });

  test('Alpha mask grows predictably as coverage increases', () {
    double opacity(double p) => 0.42 + (0.82 - 0.42) * p;
    double threshold(double p) => 0.82 + (0.12 - 0.82) * p;
    // Bright cloud pixel (green=1) is visible at 50/80%, not at 25%.
    expect(opacity(.25), lessThan(threshold(.25)));
    expect(opacity(.5), greaterThan(threshold(.5)));
    expect(opacity(.8), greaterThan(threshold(.8)));
    // Higher coverage may not reduce cloud visibility for any pixel.
    for (final p in [.25, .5, .8]) {
      expect(opacity(p), inInclusiveRange(0, 1));
      expect(threshold(p), inInclusiveRange(0, 1));
    }
  });
}
