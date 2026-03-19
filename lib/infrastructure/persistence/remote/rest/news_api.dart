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
    String? language, // ✅ NEW: override lingua (it/en/es/fr/de/ar). null => AUTO
    int? limit,
    int? offset,
  }) async {
    final int rawLimit = limit ?? 10;
    final int effectiveLimit = rawLimit.clamp(1, 100).toInt();

    final int? effectiveOffset =
        (offset != null && limit != null && limit > 0)
            ? (offset - (offset % limit))
            : offset;

    // AUTO language: IT => it, else en
    final String autoLang =
        (countryCode?.toUpperCase() == 'IT') ? 'it' : 'en';

    final String? requestedLanguage = _extractLanguageCode(language);
    final bool hasExplicitLanguage = requestedLanguage != null;

    // GNews non supporta tutte le lingue dell'app.
    // Se l'utente chiede una lingua esplicita non supportata (es. fa),
    // NON facciamo fallback silenzioso a en/it: meglio risposta vuota,
    // così l'aggregator può tentare altri provider senza mostrare lingua sbagliata.
    if (hasExplicitLanguage && !_isSupportedLanguageByGNews(requestedLanguage)) {
      return const <dynamic>[];
    }

    final String? effectiveLanguage = requestedLanguage;

    final query = <String, String>{
      'apikey': _apiKey,
      'max': effectiveLimit.toString(),
      'sortby': 'publishedAt',
      'lang': effectiveLanguage ?? autoLang,
    };

    if (countryCode != null) {
      query['country'] = countryCode.toLowerCase();
    }

    final effectiveTopic = topic?.trim();
    if (effectiveTopic != null && effectiveTopic.isNotEmpty) {
      query['topic'] = effectiveTopic;
    }

    if (cityId != null) {
      query['q'] = _buildCityQuery(cityId: cityId, countryCode: countryCode);
      query['in'] = 'title,description';
    }

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
        final normalizedArticles = articles
            .whereType<Map>()
            .map(
              (article) => article.map(
                (key, value) => MapEntry(key.toString(), value),
              ),
            )
            .toList(growable: false);

        // Se la lingua è stata chiesta esplicitamente e GNews la supporta,
        // teniamo solo articoli che dichiarano davvero quella lingua.
        // Questo evita che contenuti inglesi passino come "ar".
        if (effectiveLanguage != null) {
          return normalizedArticles.where((article) {
            final rawArticleLang = article['lang'];
            final articleLanguage = _extractLanguageCode(
              rawArticleLang?.toString(),
            );
            return articleLanguage == effectiveLanguage;
          }).toList(growable: false);
        }

        return normalizedArticles;
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

  /// Estrae e normalizza un language code in formato ISO-639-1.
  ///
  /// Gestisce anche stringhe tipo "NewsLanguage.fa" nel caso qualcuno
  /// passi .toString() di un enum.
  String? _extractLanguageCode(String? language) {
    if (language == null) return null;

    var v = language.trim();
    if (v.isEmpty) return null;

    v = v.toLowerCase();

    final dotIndex = v.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < v.length - 1) {
      v = v.substring(dotIndex + 1);
    }

    return v;
  }

  /// Sottoinsieme delle lingue app supportate che GNews supporta davvero.
  bool _isSupportedLanguageByGNews(String? language) {
    if (language == null || language.isEmpty) {
      return false;
    }

    const allowed = <String>{
      'it',
      'en',
      'es',
      'fr',
      'de',
      'ar',
    };

    return allowed.contains(language);
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

        final canRetry = (kind == NewsApiErrorKind.rateLimited ||
                kind == NewsApiErrorKind.serverError ||
                kind == NewsApiErrorKind.timeout ||
                kind == NewsApiErrorKind.network) &&
            attempt < _maxRetryAttempts;

        if (canRetry) {
          attempt += 1;
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