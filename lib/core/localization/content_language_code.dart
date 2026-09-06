import 'package:flutter/widgets.dart';

const Set<String> socialVotePrimaryLanguageCodes = <String>{
  'en',
  'it',
  'de',
  'fa',
  'es',
  'pt',
  'fr',
  'ar',
  'ro',
  'ru',
  'zh',
};

String normalizeContentLanguageCode(
  String? value, {
  String fallback = 'und',
}) {
  final normalized = value?.trim().toLowerCase().replaceAll('_', '-');
  if (normalized == null || normalized.isEmpty) {
    return fallback;
  }

  final valid = RegExp(r'^[a-z]{2,3}(-[a-z0-9]{2,8})*$');
  if (normalized == 'und' || valid.hasMatch(normalized)) {
    return normalized;
  }

  return fallback;
}

/// Maps a Social Vote UI locale to the default language for newly-authored
/// content. Existing content never changes when the UI locale changes.
///
/// `zh` is the Social Vote Simplified Chinese contract for this release.
/// An explicitly Traditional locale is intentionally not coerced to Simplified.
String defaultContentLanguageCodeForLocale(Locale locale) {
  final language = locale.languageCode.toLowerCase();
  if (language == 'zh') {
    final script = locale.scriptCode?.toLowerCase();
    final country = locale.countryCode?.toUpperCase();
    final isExplicitTraditional = script == 'hant' ||
        country == 'TW' ||
        country == 'HK' ||
        country == 'MO';
    return isExplicitTraditional ? 'und' : 'zh';
  }

  return socialVotePrimaryLanguageCodes.contains(language) ? language : 'und';
}

bool isExplicitTraditionalChineseLocale(Locale locale) {
  if (locale.languageCode.toLowerCase() != 'zh') return false;
  final script = locale.scriptCode?.toLowerCase();
  final country = locale.countryCode?.toUpperCase();
  return script == 'hant' || country == 'TW' || country == 'HK' || country == 'MO';
}
