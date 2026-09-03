import 'package:web/web.dart' as web;

void updateWebDocumentLanguage(String languageCode) {
  final normalized = languageCode.trim().toLowerCase();
  if (normalized.isEmpty) return;
  web.document.documentElement?.setAttribute('lang', normalized);
}
