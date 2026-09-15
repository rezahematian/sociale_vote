import 'dart:typed_data';

class BrowserPickedAudio {
  final String name;
  final Uint8List bytes;

  const BrowserPickedAudio({
    required this.name,
    required this.bytes,
  });
}

Future<BrowserPickedAudio?> pickBrowserAudio() {
  throw UnsupportedError(
    'Browser audio picker is available only on Web.',
  );
}