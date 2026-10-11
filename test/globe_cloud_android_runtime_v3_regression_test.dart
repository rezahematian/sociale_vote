import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('native cloud V5 speed and direction remain authoritative',
      () {
    final source = File(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    ).readAsStringSync();
    final web = File('web/social_vote_globe.js').readAsStringSync();

    expect(
      web,
      contains('const radiansPerSecond = 0.001 + this._cloudSpeed * 0.009;'),
    );

    expect(
      source,
      contains(
        'final radiansPerSecond = 0.003 + (_effectiveCloudSpeed * 0.022);',
      ),
    );
    expect(
      source,
      contains('seconds * radiansPerSecond * _effectiveCloudDirection'),
    );
    expect(
      source,
      contains('const Duration(milliseconds: 100)'),
    );
  });

  test('native shader uses one natural cloud coverage curve for every preset',
      () {
    final shader = File(
      'third_party/flutter_earth_globe_social_vote/shaders/sphere.frag',
    ).readAsStringSync();

    expect(
        shader, contains('float coverage = clamp(uCloudDensity, 0.0, 1.0);'));
    expect(
      shader,
      contains(
        'float threshold = mix(0.82, 0.12, clamp(uCloudDensity, 0.0, 1.0));',
      ),
    );
    expect(
      shader,
      contains(
        'float cloudOpacity = mix(0.42, 0.82, clamp(uCloudDensity, 0.0, 1.0));',
      ),
    );
    expect(shader, contains('vec3 naturalCloudColor = vec3(0.97, 0.98, 1.0)'));
  });

  test('clouds are composited after Earth lighting so density stays consistent',
      () {
    final shader = File(
      'third_party/flutter_earth_globe_social_vote/shaders/sphere.frag',
    ).readAsStringSync();

    final lighting = shader.indexOf('fragColor.rgb *= lighting;');
    final cloudComposite = shader.indexOf('if (cloudAlpha > 0.0)');

    expect(lighting, greaterThanOrEqualTo(0));
    expect(cloudComposite, greaterThan(lighting));
  });
}
