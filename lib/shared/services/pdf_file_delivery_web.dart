import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

Future<bool> savePdfFile({
  required Uint8List bytes,
  required String fileName,
}) async {
  String? objectUrl;
  web.HTMLAnchorElement? anchor;

  try {
    final blob = web.Blob(
      [bytes.toJS].toJS,
      web.BlobPropertyBag(type: 'application/pdf'),
    );
    objectUrl = web.URL.createObjectURL(blob);
    anchor = web.HTMLAnchorElement()
      ..href = objectUrl
      ..download = fileName
      ..style.display = 'none';

    web.document.body?.append(anchor);
    anchor.click();

    // Leave the object URL alive long enough for the browser to start the
    // download before revoking it.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return true;
  } catch (_) {
    return false;
  } finally {
    anchor?.remove();
    if (objectUrl != null) {
      web.URL.revokeObjectURL(objectUrl);
    }
  }
}
