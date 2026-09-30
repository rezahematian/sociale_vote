import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Radio Mondo finite audio advances as a playlist instead of looping',
      () {
    final service =
        File('lib/shared/services/radio_mondo_service.dart').readAsStringSync();
    final webAudio = File(
      'lib/shared/services/radio_mondo_web_audio_web.dart',
    ).readAsStringSync();

    expect(service, contains('_handleTrackCompleted()'));
    expect(service, contains('_player.onPlayerComplete.listen'));
    expect(service, contains('_webAudio.setOnEnded'));
    expect(service, contains('loop: false'));
    expect(service, contains('ReleaseMode.stop'));
    expect(service, isNot(contains('ReleaseMode.loop')));
    expect(
      service,
      contains("current.sourceType == RadioMondoSourceType.stream"),
    );
    expect(service, contains('(currentIndex + offset) % catalog.length'));

    expect(webAudio, contains("addEventListener('ended'"));
    expect(webAudio, contains("removeEventListener('ended'"));
  });
}
