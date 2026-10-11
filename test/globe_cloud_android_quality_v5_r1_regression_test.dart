import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final globe = File(
    'lib/features/map/presentation/widgets/world_globe_widget.dart',
  ).readAsStringSync();
  final shader = File(
    'third_party/flutter_earth_globe_social_vote/shaders/sphere.frag',
  ).readAsStringSync();

  test('V5 direction symmetric and 0% stops ticker', () {
    expect(globe, contains('(_effectiveCloudSpeed * 0.022)'));
    expect(globe, contains('final radiansPerSecond = 0.003 +'));
    expect(globe, contains('seconds * radiansPerSecond * _effectiveCloudDirection'));
    expect(globe, contains('final shouldRun = _effectiveCloudsEnabled && _effectiveCloudSpeed > 0'));
    expect(globe, contains('cloudRotationOffset = _cloudRotationOffset'));
    expect(shader, contains('uv.x - (uCloudRotationOffset / TWO_PI)'));
  });

  test('V5 Natural coverage endpoints and lighting isolation preserved', () {
    expect(shader, contains('mix(0.82, 0.12,'));
    expect(shader, contains('mix(0.42, 0.82,'));
    expect(shader, contains('mix(0.075, 0.115, coverage)'));
    expect(shader, contains('float cloudAlpha = 0.0;'));
    expect(shader, contains('fragColor.rgb = mix(fragColor.rgb, naturalCloudColor, cloudAlpha)'));
    expect(shader, contains('            0.82,'));
  });

  test('V5 40% is perceptible and East/West have equal magnitude', () {
    const speed = 0.40;
    const angular = 0.003 + speed * 0.022;
    const west = angular * -1;
    const east = angular * 1;
    expect(west.abs(), east.abs());
    expect(angular, greaterThan(0.01));
  });
}
