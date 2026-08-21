import 'package:flutter/widgets.dart';

/// Transitional helper for UI copy that historically had inline IT/EN text.
///
/// New copy should prefer AppLocalizations/ARB. This helper keeps the existing
/// Italian branch intact while providing a German branch without changing
/// application behavior for Italian or English.
String deOrEnglish(
  BuildContext context, {
  required String english,
  required String german,
}) {
  final languageCode =
      Localizations.localeOf(context).languageCode.toLowerCase();
  return languageCode == 'de' ? german : english;
}
