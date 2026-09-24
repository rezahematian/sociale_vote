import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Radio Mondo Web uses direct HTMLAudioElement', () {
    final service =
        File('lib/shared/services/radio_mondo_service.dart').readAsStringSync();
    final web = File('lib/shared/services/radio_mondo_web_audio_web.dart')
        .readAsStringSync();

    expect(service, contains('final RadioMondoWebAudio _webAudio'));
    expect(service, contains('await _webAudio.playUrl('));
    expect(service, contains('if (kIsWeb)'));

    expect(web, contains('HTMLAudioElement'));
    expect(web, contains('await _audio.play().toDart'));
    expect(web, contains('_audio.pause()'));
    expect(web, contains('_audio.loop = loop'));
  });

  test('Android audioplayers path is preserved', () {
    final service =
        File('lib/shared/services/radio_mondo_service.dart').readAsStringSync();

    expect(service, contains('AudioPlayer _player'));
    expect(service, contains('stayAwake: true'));
    expect(service, contains('TargetPlatform.android'));
    expect(service, contains('await _player.play('));
  });
}
