class RadioMondoWebAudio {
  Future<void> playUrl(
    String url, {
    required bool loop,
    required double volume,
  }) async {
    throw UnsupportedError('Web audio is available only on Web.');
  }

  Future<void> stop() async {}

  Future<void> setVolume(double value) async {}
}
