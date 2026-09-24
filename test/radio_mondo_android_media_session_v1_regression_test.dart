import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android Radio exposes media session controls', () {
    final source =
        File('lib/shared/services/radio_mondo_service.dart').readAsStringSync();

    expect(source, contains('class _RadioMondoAudioHandler'));
    expect(source, contains('AudioService.init<_RadioMondoAudioHandler>'));
    expect(source, contains('MediaControl.play'));
    expect(source, contains('MediaControl.pause'));
    expect(source, contains('MediaControl.stop'));
    expect(source, contains('publishStation(station)'));
    expect(source, contains('publishReady(playing: true)'));
    expect(source, contains('_pauseFromMediaSession'));
    expect(source, contains('_resumeFromMediaSession'));
    expect(source, contains('_stopFromMediaSession'));
  });

  test('Web direct HTML audio remains present', () {
    final source =
        File('lib/shared/services/radio_mondo_service.dart').readAsStringSync();

    expect(source, contains('RadioMondoWebAudio'));
    expect(source, contains('_webAudio.playUrl('));
    expect(source, contains('if (kIsWeb)'));
  });
}
