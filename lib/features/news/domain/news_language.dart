// lib/features/news/domain/news_language.dart

/// Selettore lingua per News (solo modulo News, non cambia la lingua dell'app).
///
/// - [auto]: usa la lingua del sistema/device quando supportata.
/// - altri valori: forzano un override esplicito verso il provider.
///
/// Nota importante:
/// questo file definisce la semantica di dominio della lingua news,
/// ma il comportamento reale dipende dal punto in cui [auto] viene
/// risolto prima della chiamata API/provider.
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

/// Risolve la lingua news a partire dalla lingua del sistema/device.
///
/// Supporta direttamente:
/// - it, en, es, fr, de, ar, fa
///
/// Per codici non supportati, il fallback sicuro è [NewsLanguage.en].
///
/// Esempi:
/// - 'it' / 'it-IT' / 'it_IT' => [NewsLanguage.it]
/// - 'fr' / 'fr-FR' => [NewsLanguage.fr]
/// - 'pt-BR' => [NewsLanguage.en]
NewsLanguage newsLanguageFromSystemLanguageCode(String? systemLanguageCode) {
  final normalized = _normalizeLanguageCode(systemLanguageCode);

  switch (normalized) {
    case 'it':
      return NewsLanguage.it;
    case 'en':
      return NewsLanguage.en;
    case 'es':
      return NewsLanguage.es;
    case 'fr':
      return NewsLanguage.fr;
    case 'de':
      return NewsLanguage.de;
    case 'ar':
      return NewsLanguage.ar;
    case 'fa':
      return NewsLanguage.fa;
    default:
      return NewsLanguage.en;
  }
}

String _normalizeLanguageCode(String? value) {
  if (value == null) return '';

  final normalized = value.trim().toLowerCase().replaceAll('_', '-');
  if (normalized.isEmpty) return '';

  return normalized.split('-').first;
}

extension NewsLanguageApi on NewsLanguage {
  /// Valore da passare all'API.
  ///
  /// - null => AUTO non ancora risolto
  /// - 'it'/'en'/'es'/'fr'/'de'/'ar'/'fa' => override esplicito
  ///
  /// Nota:
  /// per trasformare davvero [NewsLanguage.auto] nella lingua del sistema,
  /// usare [effectiveApiValue(...)].
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

  /// Restituisce la lingua effettiva da usare lato provider/API.
  ///
  /// Se la lingua è [NewsLanguage.auto], viene risolta a partire dalla
  /// lingua del sistema/device.
  String effectiveApiValue({
    required String? systemLanguageCode,
  }) {
    final effectiveLanguage = resolvedForSystemLanguage(
      systemLanguageCode: systemLanguageCode,
    );

    return effectiveLanguage.apiValue ?? 'en';
  }

  /// Risolve [NewsLanguage.auto] nella lingua supportata più corretta
  /// partendo dalla lingua del sistema/device.
  ///
  /// Se la lingua corrente non è [auto], restituisce semplicemente se stessa.
  NewsLanguage resolvedForSystemLanguage({
    required String? systemLanguageCode,
  }) {
    if (!isAuto) return this;
    return newsLanguageFromSystemLanguageCode(systemLanguageCode);
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