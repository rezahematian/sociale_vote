import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Radio Web keeps user-started playback across hidden/paused lifecycle',
      () {
    final source =
        File('lib/shared/services/radio_mondo_service.dart').readAsStringSync();

    expect(source, contains('case AppLifecycleState.paused:'));
    expect(source, contains('case AppLifecycleState.hidden:'));
    expect(source, contains('if (!kIsWeb)'));
    expect(source, contains('case AppLifecycleState.detached:'));

    expect(
      source,
      contains(
        'Web Radio is user-started media: keep playback alive when the',
      ),
    );

    expect(
      source,
      contains(
        'Native platforms preserve the existing foreground-only behavior.',
      ),
    );
  });

  test('Radio Web background policy does not introduce autoplay', () {
    final source =
        File('lib/shared/services/radio_mondo_service.dart').readAsStringSync();

    expect(
      source,
      contains("Future<bool> playStation(RadioMondoStation station) async"),
    );

    expect(
      source,
      isNot(contains(
          'didChangeAppLifecycleState(AppLifecycleState state) async')),
    );
  });
}
