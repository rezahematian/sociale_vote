import 'package:web/web.dart' as web;

Uri? _bootstrapLocationUri;

void captureCurrentLocationUriForBootstrap() {
  _bootstrapLocationUri = Uri.tryParse(web.window.location.href);
}

Uri currentLocationUri() {
  final captured = _bootstrapLocationUri;
  _bootstrapLocationUri = null;
  return captured ?? Uri.parse(web.window.location.href);
}
