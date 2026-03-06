import 'dart:async';

import 'package:sociale_vote/core/http/api_client.dart';
import 'package:sociale_vote/core/http/api_exception.dart';

/// API REST per il modulo News basata su GNews.
///
/// Base URL (in AppDI):
///   https://gnews.io/api/v4
class NewsApi {
  final ApiClient _client;

  /// 🔐 INSERISCI QUI LA TUA API KEY GNEWS
  static const String _apiKey = '2f8b7290a201170c1da83f3c6c4ac60d';

  NewsApi(this._client);

  /// Recupera il feed di news da GNews.
  ///
  /// Mapping:
  /// - world       → nessun country, nessun q
  /// - country     → country=<countryCode>
  /// - city (pro)  → q="<cityId> <countryCode?>" + country=<countryCode?>
  ///
  /// Dominio usa limit/offset.
  /// GNews usa max/page.
  Future<List<dynamic>> fetchNews({
    String? countryCode,
    String? cityId,
    String? topic, // ✅ NEW: GNews topic (world/nation/business/...)
    String? language, // ✅ NEW: override lingua (it/en/es/fr/de/ar/fa). null => AUTO
    int? limit,
    int? offset,
  }) async {
    // clamp ritorna num → gestiamo in due step per rimanere type-safe
    final int rawLimit = limit ?? 10;
    final int effectiveLimit =
        rawLimit.clamp(1, 100).toInt(); // (min 1, max 100)

    // offset → page (normalizzazione: evitiamo salti se offset non è multiplo di limit)
    final int? effectiveOffset =
        (offset != null && limit != null && limit > 0)
            ? (offset - (offset % limit))
            : offset;

    // AUTO language: IT => it, else en
    final String autoLang =
        (countryCode?.toUpperCase() == 'IT') ? 'it' : 'en';

    // language override (se valorizzato) + normalizzazione safe
    final String? effectiveLanguage = _normalizeLanguage(language);

    final query = <String, String>{
      'apikey': _apiKey,
      'max': effectiveLimit.toString(),
      'sortby': 'publishedAt',
      'lang': effectiveLanguage ?? autoLang,
    };

    if (countryCode != null) {
      query['country'] = countryCode.toLowerCase();
    }

    // ✅ Topic filter (solo se diverso da null/vuoto)
    final effectiveTopic = topic?.trim();
    if (effectiveTopic != null && effectiveTopic.isNotEmpty) {
      query['topic'] = effectiveTopic;
    }

    // City-level (PRO): query più robusta rispetto a q=<cityId>
    if (cityId != null) {
      query['q'] = _buildCityQuery(cityId: cityId, countryCode: countryCode);
      query['in'] = 'title,description';
    }

    // effectiveOffset → page
    if (effectiveOffset != null && limit != null && limit > 0) {
      final page = (effectiveOffset ~/ limit) + 1;
      query['page'] = page.toString();
    }

    final result = await _getJsonWithRetry(
      '/top-headlines',
      query: query,
    );

    if (result is Map<String, dynamic>) {
      final articles = result['articles'];
      if (articles is List) {
        // ✅ NO strict filter: lasciamo al provider il best-effort sul parametro lang.
        // In particolare FA/AR possono avere dataset ridotto: meglio non svuotare il feed.
        return articles;
      }
    }

    throw StateError(
      'Expected "articles" list from GNews but got ${result.runtimeType}',
    );
  }

  /// GNews non ha un vero endpoint /news/{id}
  /// Usiamo search per recuperare l'articolo tramite id.
  Future<Map<String, dynamic>> fetchNewsDetail(String id) async {
    final query = <String, String>{
      'apikey': _apiKey,
      'q': id,
      'max': '1',
      'sortby': 'publishedAt',
    };

    final result = await _getJsonWithRetry(
      '/search',
      query: query,
    );

    if (result is Map<String, dynamic>) {
      final articles = result['articles'];
      if (articles is List && articles.isNotEmpty) {
        final first = articles.first;
        if (first is Map<String, dynamic>) {
          return first;
        }
      }
    }

    throw StateError('News detail not found for id=$id');
  }

  // ============================================================
  // Helpers
  // ============================================================

  /// Normalizza e valida la lingua per GNews.
  ///
  /// Gestisce anche stringhe tipo "NewsLanguage.fa" (capita se qualcuno passa .toString()).
  /// Se non riconosciuta → null (quindi AUTO a valle).
  String? _normalizeLanguage(String? language) {
    if (language == null) return null;

    var v = language.trim();
    if (v.isEmpty) return null;

    v = v.toLowerCase();

    // caso: "NewsLanguage.fa" → "fa"
    final dotIndex = v.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < v.length - 1) {
      v = v.substring(dotIndex + 1);
    }

    // whitelist (solo quelle che supportiamo in app)
    const allowed = <String>{
      'it',
      'en',
      'es',
      'fr',
      'de',
      'ar',
      'fa',
    };

    if (!allowed.contains(v)) return null;
    return v;
  }

  // ============================================================
  // City query helpers
  // ============================================================

  String _buildCityQuery({
    required String cityId,
    required String? countryCode,
  }) {
    final cleanedCity = cityId.trim();
    if (cleanedCity.isEmpty) return cityId;

    // Esempio: "Bologna IT" / "Paris FR"
    // Se in futuro avremo countryName, potremo usare "Bologna Italy" qui senza toccare altro.
    final suffix = (countryCode != null && countryCode.trim().isNotEmpty)
        ? ' ${countryCode.trim().toUpperCase()}'
        : '';

    return '$cleanedCity$suffix';
  }

  // ============================================================
  // Error handling / retry (minimo, news-specific)
  // ============================================================

  static const int _maxRetryAttempts = 1;

  Future<dynamic> _getJsonWithRetry(
    String path, {
    required Map<String, String> query,
  }) async {
    int attempt = 0;

    while (true) {
      try {
        return await _client.getJson(path, query: query);
      } on ApiException catch (e) {
        final kind = _mapErrorKind(e);

        // Retry minimo: 429 (rate-limit) e 5xx (transienti)
        final canRetry = (kind == NewsApiErrorKind.rateLimited ||
                kind == NewsApiErrorKind.serverError ||
                kind == NewsApiErrorKind.timeout ||
                kind == NewsApiErrorKind.network) &&
            attempt < _maxRetryAttempts;

        if (canRetry) {
          attempt += 1;
          // Backoff leggero e deterministico (senza refactor)
          final delayMs = kind == NewsApiErrorKind.rateLimited ? 900 : 450;
          await Future.delayed(Duration(milliseconds: delayMs));
          continue;
        }

        throw NewsApiException(
          kind: kind,
          statusCode: e.statusCode,
          message: _defaultUserMessageFor(kind),
          debugMessage: e.message,
        );
      } catch (e) {
        // Qualsiasi altro errore non previsto: normalizziamo comunque
        throw NewsApiException(
          kind: NewsApiErrorKind.unknown,
          statusCode: null,
          message: _defaultUserMessageFor(NewsApiErrorKind.unknown),
          debugMessage: e.toString(),
        );
      }
    }
  }

  NewsApiErrorKind _mapErrorKind(ApiException e) {
    final status = e.statusCode;

    if (status == 401 || status == 403) {
      return NewsApiErrorKind.unauthorized;
    }
    if (status == 429) {
      return NewsApiErrorKind.rateLimited;
    }
    if (status != null && status >= 500) {
      return NewsApiErrorKind.serverError;
    }

    // ApiException spesso copre anche rete/timeout; se ApiException espone
    // dettagli migliori in futuro, possiamo migliorare qui senza toccare altro.
    final msg = (e.message ?? '').toLowerCase();
    if (msg.contains('timeout')) return NewsApiErrorKind.timeout;
    if (msg.contains('socket') || msg.contains('network')) {
      return NewsApiErrorKind.network;
    }

    return NewsApiErrorKind.unknown;
  }

  String _defaultUserMessageFor(NewsApiErrorKind kind) {
    switch (kind) {
      case NewsApiErrorKind.unauthorized:
        return 'News service authentication failed.';
      case NewsApiErrorKind.rateLimited:
        return 'Too many requests. Please try again shortly.';
      case NewsApiErrorKind.serverError:
        return 'News service is temporarily unavailable.';
      case NewsApiErrorKind.timeout:
        return 'Request timed out. Please try again.';
      case NewsApiErrorKind.network:
        return 'Network error. Please check your connection.';
      case NewsApiErrorKind.unknown:
        return 'Unexpected error while loading news.';
    }
  }
}

/// Classificazione “pulita” degli errori lato News.
/// (UI/Controller potranno mappare questo a testi IT/EN senza usare HTTP codes)
enum NewsApiErrorKind {
  unauthorized,
  rateLimited,
  serverError,
  timeout,
  network,
  unknown,
}

/// Eccezione normalizzata per il modulo News.
/// Non porta HTML/body completi: solo info utili + debugMessage.
class NewsApiException implements Exception {
  final NewsApiErrorKind kind;
  final int? statusCode;

  /// Messaggio neutro (EN) da usare come fallback.
  /// La localizzazione IT/EN verrà fatta più sopra.
  final String message;

  /// Dettagli tecnici per log/debug (non per UI).
  final String? debugMessage;

  NewsApiException({
    required this.kind,
    required this.statusCode,
    required this.message,
    this.debugMessage,
  });

  @override
  String toString() =>
      'NewsApiException(kind=$kind, statusCode=$statusCode, message=$message)';
}