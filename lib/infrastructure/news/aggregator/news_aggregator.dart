import 'package:flutter/foundation.dart';
import 'package:sociale_vote/infrastructure/news/aggregator/news_provider.dart';

/// NewsAggregator (Phase 2)
///
/// - combina più provider
/// - fallback automatico se errore / rate limit / zero risultati
/// - tollera provider che lanciano eccezioni runtime
/// - normalizza l'output in "json-like" compatibile con NewsDto.fromJson
class NewsAggregator {
  final List<NewsProvider> _providers;

  NewsAggregator({
    required List<NewsProvider> providers,
  }) : _providers = List<NewsProvider>.unmodifiable(providers);

  /// Recupera il feed news con fallback tra provider.
  ///
  /// Regole:
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

    for (final provider in _providers) {
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
            'NewsAggregator provider ${provider.runtimeType}: '
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
            'NewsAggregator provider ${provider.runtimeType} threw: $e',
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
}
