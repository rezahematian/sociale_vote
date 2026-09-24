import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Radio Mondo keeps Web and Android playback alive when backgrounded',
      () {
    final service =
        File('lib/shared/services/radio_mondo_service.dart').readAsStringSync();
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

    expect(service, contains('AudioContextConfig('));
    expect(service, contains('stayAwake: true'));
    expect(
      service,
      contains(
        'kIsWeb || defaultTargetPlatform == TargetPlatform.android',
      ),
    );

    expect(
      manifest,
      contains('android.permission.WAKE_LOCK'),
    );
  });

  test('Radio Mondo still has no autoplay/background package dependency', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(pubspec, contains('version: 1.0.0+5'));
    expect(pubspec, contains('audioplayers: ^6.8.1'));
    expect(pubspec, isNot(contains('audio_service:')));
  });
}
