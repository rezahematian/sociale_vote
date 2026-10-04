import 'dart:js_interop';

import 'package:web/web.dart' as web;

class RadioMondoWebAudio {
  RadioMondoWebAudio() {
    _audio.preload = 'auto';
    _endedListener = ((web.Event _) {
      _onEnded?.call();
    }).toJS;
    _audio.addEventListener('ended', _endedListener);
  }

  final web.HTMLAudioElement _audio = web.HTMLAudioElement();
  late final JSFunction _endedListener;
  void Function()? _onEnded;

  void setOnEnded(void Function()? callback) {
    _onEnded = callback;
  }

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

  Future<void> pause() async {
    _audio.pause();
  }

  Future<void> resume() async {
    await _audio.play().toDart;
  }

  Future<void> stop() async {
    _audio.pause();
    _audio.currentTime = 0.0;
  }

  Future<void> setVolume(double value) async {
    _audio.volume = value;
  }

  Future<void> dispose() async {
    _audio.removeEventListener('ended', _endedListener);
    _onEnded = null;
    await stop();
  }
}
