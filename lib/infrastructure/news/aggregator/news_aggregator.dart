import 'package:flutter/foundation.dart';
import 'package:sociale_vote/infrastructure/news/aggregator/news_provider.dart';

/// NewsAggregator (Phase 2)
///
/// - combina più provider
/// - fallback automatico se errore / rate limit / zero risultati
/// - tollera provider che lanciano eccezioni runtime
/// - normalizza l'output in "json-like" compatibile con NewsDto.fromJson
///
/// F7.9:
/// - priorità provider language-aware
/// - Guardian primo solo per AUTO/EN
/// - per IT/FR/ES/DE si preferiscono provider più adatti a contenuti locali
/// - per AR:
///   - filtro "tutte" / topic assente => GNews prima
///   - categoria specifica => NewsAPI prima
/// - per FA si mantiene GNews prima, poi NewsAPI, Guardian in coda
class NewsAggregator {
  final List<NewsProvider> _providers;

  NewsAggregator({
    required List<NewsProvider> providers,
  }) : _providers = List<NewsProvider>.unmodifiable(providers);

  /// Recupera il feed news con fallback tra provider.
  ///
  /// Regole:
  /// - ordina i provider in base alla lingua richiesta
  /// - se un provider ritorna risultati -> usiamo quelli
  /// - se un provider ritorna empty / rate limited / errore -> fallback
  /// - se un provider lancia eccezione -> fallback
  /// - se nessun provider funziona -> ritorna lista vuota
  ///
  /// Questo evita che una API key rotta mandi in errore tutta la UI.
  Future<List<dynamic>> fetchNews({
    String? countryCode,
    String? cityId,
    String? topic,
    String? language,
    int? limit,
    int? offset,
  }) async {
    ProviderFetchResult? lastResult;
    Object? lastThrownError;

    final orderedProviders = _orderProvidersForRequest(
      language: language,
      topic: topic,
    );

    if (kDebugMode) {
      debugPrint(
        'NewsAggregator language=${_normalizeLanguage(language) ?? 'auto'} '
        'topic=${_normalizeTopic(topic) ?? 'all'} '
        'providerOrder=${orderedProviders.map((p) => p.id).join(' > ')}',
      );
    }

    for (final provider in orderedProviders) {
      try {
        final res = await provider.fetchNews(
          countryCode: countryCode,
          cityId: cityId,
          topic: topic,
          language: language,
          limit: limit,
          offset: offset,
        );

        lastResult = res;

        if (kDebugMode) {
          debugPrint(
            'NewsAggregator provider ${provider.runtimeType} (${provider.id}): '
            'items=${res.items.length}, '
            'empty=${res.isEmpty}, '
            'rateLimited=${res.rateLimited}, '
            'error=${res.error}',
          );
        }

        // SUCCESS: risultati non vuoti
        if (!res.isEmpty) {
          return res.items;
        }

        // FALLBACK: rate limit / errore / zero risultati
        continue;
      } catch (e, st) {
        lastThrownError = e;

        if (kDebugMode) {
          debugPrint(
            'NewsAggregator provider ${provider.runtimeType} (${provider.id}) '
            'threw: $e',
          );
          debugPrint('$st');
        }

        continue;
      }
    }

    // Nessun provider ha dato risultati utili.
    // Comportamento safe: non rompiamo la UI, ritorniamo lista vuota.
    if (kDebugMode) {
      debugPrint(
        'NewsAggregator: no provider returned usable news. '
        'lastResultError=${lastResult?.error}, '
        'lastThrownError=$lastThrownError',
      );
    }

    return const <dynamic>[];
  }

  /// Dettaglio news:
  /// - prova i provider in sequenza
  /// - se uno lancia eccezione -> fallback al successivo
  /// - se nessuno riesce -> rilancia ultimo errore
  Future<Map<String, dynamic>> fetchNewsDetail(String id) async {
    Object? lastError;

    for (final provider in _providers) {
      try {
        return await provider.fetchNewsDetail(id);
      } catch (e, st) {
        lastError = e;

        if (kDebugMode) {
          debugPrint(
            'NewsAggregator detail provider ${provider.runtimeType} failed: $e',
          );
          debugPrint('$st');
        }

        continue;
      }
    }

    throw lastError ?? UnsupportedError('No provider supports fetchNewsDetail');
  }

  List<NewsProvider> _orderProvidersForRequest({
    required String? language,
    required String? topic,
  }) {
    final normalizedLanguage = _normalizeLanguage(language);
    final normalizedTopic = _normalizeTopic(topic);
    final indexedProviders = _providers.asMap().entries.toList(growable: false);

    indexedProviders.sort((a, b) {
      final aPriority = _providerPriorityForRequest(
        providerId: a.value.id,
        language: normalizedLanguage,
        topic: normalizedTopic,
      );
      final bPriority = _providerPriorityForRequest(
        providerId: b.value.id,
        language: normalizedLanguage,
        topic: normalizedTopic,
      );

      final byPriority = aPriority.compareTo(bPriority);
      if (byPriority != 0) {
        return byPriority;
      }

      return a.key.compareTo(b.key);
    });

    return indexedProviders
        .map((entry) => entry.value)
        .toList(growable: false);
  }

  int _providerPriorityForRequest({
    required String providerId,
    required String? language,
    required String? topic,
  }) {
    final normalizedProviderId = providerId.trim().toLowerCase();

    // AUTO / EN -> Guardian prima, poi NewsAPI, poi GNews
    if (language == null || language == 'auto' || language == 'en') {
      switch (normalizedProviderId) {
        case 'guardian':
          return 0;
        case 'newsapi':
          return 1;
        case 'gnews':
          return 2;
        default:
          return 100;
      }
    }

    // IT / FR / ES / DE -> NewsAPI prima, poi GNews, Guardian in coda
    if (language == 'it' ||
        language == 'fr' ||
        language == 'es' ||
        language == 'de') {
      switch (normalizedProviderId) {
        case 'newsapi':
          return 0;
        case 'gnews':
          return 1;
        case 'guardian':
          return 2;
        default:
          return 100;
      }
    }

    // AR:
    // - "tutte"/topic assente -> GNews prima
    // - categoria specifica -> NewsAPI prima
    if (language == 'ar') {
      final isAllTopic = topic == null || topic == 'all' || topic == 'tutte';

      if (isAllTopic) {
        switch (normalizedProviderId) {
          case 'gnews':
            return 0;
          case 'newsapi':
            return 1;
          case 'guardian':
            return 2;
          default:
            return 100;
        }
      }

      switch (normalizedProviderId) {
        case 'newsapi':
          return 0;
        case 'gnews':
          return 1;
        case 'guardian':
          return 2;
        default:
          return 100;
      }
    }

    // FA -> GNews prima, poi NewsAPI, Guardian in coda
    if (language == 'fa') {
      switch (normalizedProviderId) {
        case 'gnews':
          return 0;
        case 'newsapi':
          return 1;
        case 'guardian':
          return 2;
        default:
          return 100;
      }
    }

    // Default per lingua esplicita non inglese:
    // evitiamo di dare priorità a Guardian.
    switch (normalizedProviderId) {
      case 'newsapi':
        return 0;
      case 'gnews':
        return 1;
      case 'guardian':
        return 2;
      default:
        return 100;
    }
  }

  String? _normalizeLanguage(String? language) {
    if (language == null) {
      return null;
    }

    final normalized = language.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  String? _normalizeTopic(String? topic) {
    if (topic == null) {
      return null;
    }

    final normalized = topic.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }

    return normalized;
  }
}