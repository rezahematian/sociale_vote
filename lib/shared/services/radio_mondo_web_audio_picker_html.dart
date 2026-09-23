import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

class BrowserPickedAudio {
  final String name;
  final Uint8List bytes;

  const BrowserPickedAudio({
    required this.name,
    required this.bytes,
  });
}

Future<BrowserPickedAudio?> pickBrowserAudio() {
  final completer = Completer<BrowserPickedAudio?>();

  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept =
        'audio/*,.mp3,.m4a,.mp4,.aac,.ogg,.oga,.opus,.wav,.wave,.flac,.webm'
    ..multiple = false;

  input.style.display = 'none';

  late JSFunction changeListener;
  late JSFunction cancelListener;

  void cleanup() {
    input.removeEventListener('change', changeListener);
    input.removeEventListener('cancel', cancelListener);
    input.remove();
  }

  Future<void> readSelection() async {
    try {
      final files = input.files;

      if (files == null || files.length == 0) {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
        return;
      }

      final file = files.item(0);

      if (file == null) {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
        return;
      }

      final jsBuffer = await file.arrayBuffer().toDart;
      final bytes = Uint8List.view(jsBuffer.toDart);

      if (!completer.isCompleted) {
        completer.complete(
          BrowserPickedAudio(
            name: file.name,
            bytes: bytes,
          ),
        );
      }
    } catch (error, stackTrace) {
      if (!completer.isCompleted) {
        completer.completeError(error, stackTrace);
      }
    } finally {
      cleanup();
    }
  }

  void onChange(web.Event _) {
    unawaited(readSelection());
  }

  void onCancel(web.Event _) {
    if (!completer.isCompleted) {
      completer.complete(null);
    }
    cleanup();
  }

  changeListener = onChange.toJS;
  cancelListener = onCancel.toJS;

  input.addEventListener('change', changeListener);
  input.addEventListener('cancel', cancelListener);

  web.document.body?.appendChild(input);

  // Deve restare nella gesture diretta dell'utente.
  input.click();

  return completer.future;
}
