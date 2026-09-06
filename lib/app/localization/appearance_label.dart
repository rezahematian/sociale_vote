import 'package:flutter/widgets.dart';

/// Localized label for the Space visual appearance preset.
///
/// This is ordinary UI copy, not a Social Vote product name, so it follows
/// the active app language across all eleven supported locales.
String socialVoteSpaceAppearanceLabel(BuildContext context) {
  final languageCode =
      Localizations.localeOf(context).languageCode.toLowerCase();

  return switch (languageCode) {
    'it' => 'Spazio',
    'de' => 'Weltraum',
    'fa' => 'فضا',
    'es' => 'Espacio',
    'pt' => 'Espaço',
    'fr' => 'Espace',
    'ar' => 'الفضاء',
    'ro' => 'Spațiu',
    'ru' => 'Космос',
    'zh' => '太空',
    _ => 'Space',
  };
}
