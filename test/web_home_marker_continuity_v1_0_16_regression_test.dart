import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Web Home marker visibility no longer redirects passive rotation', () {
    final jsSource = File('web/social_vote_globe.js').readAsStringSync();

    expect(
      jsSource,
      contains('WEB-WORLD-V10.8-CONTINUOUS-ROTATION-V1.0.17'),
    );
    expect(jsSource, contains('const visible = facing > 0.055;'));
    expect(jsSource, isNot(contains('_homeMarkerBlankSince')));
    expect(jsSource, isNot(contains('_homeMarkerRecoveryCooldownUntil')));
    expect(jsSource, isNot(contains('_maintainHomeMarkerContinuity(')));
    expect(jsSource, isNot(contains("home-marker-continuity-recovery")));
  });
}
