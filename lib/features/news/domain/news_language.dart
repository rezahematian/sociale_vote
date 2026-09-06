/// Language selector for News. It does not change the app language.
enum NewsLanguage {
  auto,
  it,
  en,
  de,
  fa,
  es,
  pt,
  fr,
  ar,
  ro,
  ru,
  zh,
}

String _normalizeLanguageCode(String? value) {
  if (value == null) return '';
  final normalized = value.trim().toLowerCase().replaceAll('_', '-');
  if (normalized.isEmpty) return '';
  return normalized.split('-').first;
}

NewsLanguage newsLanguageFromAppLanguageCode(String? appLanguageCode) {
  switch (_normalizeLanguageCode(appLanguageCode)) {
    case 'it': return NewsLanguage.it;
    case 'en': return NewsLanguage.en;
    case 'de': return NewsLanguage.de;
    case 'fa': return NewsLanguage.fa;
    case 'es': return NewsLanguage.es;
    case 'pt': return NewsLanguage.pt;
    case 'fr': return NewsLanguage.fr;
    case 'ar': return NewsLanguage.ar;
    case 'ro': return NewsLanguage.ro;
    case 'ru': return NewsLanguage.ru;
    case 'zh': return NewsLanguage.zh;
    default: return NewsLanguage.en;
  }
}

/// Kept for compatibility with older targeted tests/callers. AUTO semantics in
/// the product now use the Social Vote app locale, not this helper directly.
NewsLanguage newsLanguageFromSystemLanguageCode(String? systemLanguageCode) =>
    newsLanguageFromAppLanguageCode(systemLanguageCode);

extension NewsLanguageApi on NewsLanguage {
  String? get apiValue {
    switch (this) {
      case NewsLanguage.auto: return null;
      case NewsLanguage.it: return 'it';
      case NewsLanguage.en: return 'en';
      case NewsLanguage.de: return 'de';
      case NewsLanguage.fa: return 'fa';
      case NewsLanguage.es: return 'es';
      case NewsLanguage.pt: return 'pt';
      case NewsLanguage.fr: return 'fr';
      case NewsLanguage.ar: return 'ar';
      case NewsLanguage.ro: return 'ro';
      case NewsLanguage.ru: return 'ru';
      case NewsLanguage.zh: return 'zh';
    }
  }

  String effectiveApiValue({
    String? appLanguageCode,
    String? systemLanguageCode,
  }) {
    final source = appLanguageCode ?? systemLanguageCode;
    final effectiveLanguage = resolvedForAppLanguage(
      appLanguageCode: source,
    );
    return effectiveLanguage.apiValue ?? 'en';
  }

  NewsLanguage resolvedForAppLanguage({required String? appLanguageCode}) {
    if (!isAuto) return this;
    return newsLanguageFromAppLanguageCode(appLanguageCode);
  }

  /// Backward-compatible name used by older tests.
  NewsLanguage resolvedForSystemLanguage({required String? systemLanguageCode}) {
    return resolvedForAppLanguage(appLanguageCode: systemLanguageCode);
  }

  String get label => isAuto ? 'AUTO' : name.toUpperCase();
  bool get isAuto => this == NewsLanguage.auto;
}
