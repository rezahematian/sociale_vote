import 'dart:js_interop';

import 'package:web/web.dart' as web;

class RadioMondoWebAudio {
  RadioMondoWebAudio() {
    _audio.preload = 'auto';
  }

  final web.HTMLAudioElement _audio = web.HTMLAudioElement();

  Future<void> playUrl(
    String url, {
    required bool loop,
    required double volume,
  }) async {
    _audio.pause();
    _audio.src = url;
    _audio.loop = loop;
    _audio.volume = volume;
    _audio.load();

    await _audio.play().toDart;
  }

  Future<void> stop() async {
    _audio.pause();
    _audio.currentTime = 0.0;
  }

  Future<void> setVolume(double value) async {
    _audio.volume = value;
  }
}
