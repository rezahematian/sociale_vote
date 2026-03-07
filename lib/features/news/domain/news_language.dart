// lib/features/news/domain/news_language.dart

/// Selettore lingua per News (solo modulo News, non cambia la lingua dell'app).
///
/// - [auto]: comportamento default (deciso da NewsApi in base a countryCode).
/// - altri valori: forzano un override esplicito verso il provider (es. GNews).
enum NewsLanguage {
  auto,
  it,
  en,
  es,
  fr,
  de,
  ar,
  fa,
}

extension NewsLanguageApi on NewsLanguage {
  /// Valore da passare all'API.
  /// - null => AUTO (nessun override)
  /// - 'it'/'en'/'es'/'fr'/'de'/'ar'/'fa' => override esplicito
  String? get apiValue {
    switch (this) {
      case NewsLanguage.auto:
        return null;
      case NewsLanguage.it:
        return 'it';
      case NewsLanguage.en:
        return 'en';
      case NewsLanguage.es:
        return 'es';
      case NewsLanguage.fr:
        return 'fr';
      case NewsLanguage.de:
        return 'de';
      case NewsLanguage.ar:
        return 'ar';
      case NewsLanguage.fa:
        return 'fa';
    }
  }

  /// Label UI di base (senza l10n).
  /// Nota: in UI useremo comunque l10n per etichette/localizzazione.
  String get label {
    switch (this) {
      case NewsLanguage.auto:
        return 'AUTO';
      case NewsLanguage.it:
        return 'IT';
      case NewsLanguage.en:
        return 'EN';
      case NewsLanguage.es:
        return 'ES';
      case NewsLanguage.fr:
        return 'FR';
      case NewsLanguage.de:
        return 'DE';
      case NewsLanguage.ar:
        return 'AR';
      case NewsLanguage.fa:
        return 'FA';
    }
  }

  bool get isAuto => this == NewsLanguage.auto;
}