import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Web Home visibility updates never move the camera', () {
    final jsSource = File('web/social_vote_globe.js').readAsStringSync();

    final start = jsSource.indexOf('  _updateMarkerVisibility() {');
    final end = jsSource.indexOf('  _startLoop() {', start);

    expect(start, greaterThanOrEqualTo(0));
    expect(end, greaterThan(start));

    final visibilityFunction = jsSource.substring(start, end);

    expect(visibilityFunction, contains('sprite.visible = visible;'));
    expect(visibilityFunction, contains('facing > 0.055'));
    expect(visibilityFunction, isNot(contains('_setCameraForLatLng(')));
    expect(visibilityFunction, isNot(contains('_maintainHomeMarkerContinuity(')));
    expect(visibilityFunction, isNot(contains('recoveryHoldMs')));
  });

  test('Web globe still has passive rotation and marker tap support', () {
    final jsSource = File('web/social_vote_globe.js').readAsStringSync();

    expect(jsSource, contains('_autoRotatePreference'));
    expect(jsSource, contains('socialvote-marker-tap'));
    expect(jsSource, contains("this._config.profile === 'home'"));
  });
}
