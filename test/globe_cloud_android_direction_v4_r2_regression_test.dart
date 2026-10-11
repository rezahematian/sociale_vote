import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android cloud UV motion agrees with Admin direction', () {
    final shader = File(
      'third_party/flutter_earth_globe_social_vote/shaders/sphere.frag',
    ).readAsStringSync();
    final globe = File(
      'lib/features/map/presentation/widgets/world_globe_widget.dart',
    ).readAsStringSync();

    expect(shader, contains('cloudUv.x = fract(uv.x - (uCloudRotationOffset / TWO_PI) + 1.0);'));
    expect(shader, isNot(contains('cloudUv.x = fract(uv.x + (uCloudRotationOffset / TWO_PI) + 1.0);')));
    expect(globe, contains('seconds * radiansPerSecond * _effectiveCloudDirection'));
    expect(globe, contains('(widget.cloudDirectionOverride ?? _clouds.direction) < 0 ? -1 : 1'));
  });
}
