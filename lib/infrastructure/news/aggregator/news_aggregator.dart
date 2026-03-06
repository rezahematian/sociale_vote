// lib/infrastructure/news/aggregator/news_aggregator.dart

import 'package:sociale_vote/infrastructure/news/aggregator/news_provider.dart';

/// NewsAggregator (Phase 2)
///
/// - combina più provider
/// - fallback automatico se errore / rate limit / zero risultati
/// - normalizza l'output in "json-like" compatibile con NewsDto.fromJson
class NewsAggregator {
  final List<NewsProvider> _providers;

  NewsAggregator({
    required List<NewsProvider> providers,
  }) : _providers = List<NewsProvider>.unmodifiable(providers);

  /// Recupera il feed news con fallback tra provider.
  Future<List<dynamic>> fetchNews({
    String? countryCode,
    String? cityId,
    String? topic,
    String? language,
    int? limit,
    int? offset,
  }) async {
    ProviderFetchResult? last;

    for (final p in _providers) {
      final res = await p.fetchNews(
        countryCode: countryCode,
        cityId: cityId,
        topic: topic,
        language: language,
        limit: limit,
        offset: offset,
      );

      last = res;

      // SUCCESS: risultati non vuoti
      if (!res.isEmpty) {
        return res.items;
      }

      // FALLBACK: rate limit
      if (res.rateLimited) {
        continue;
      }

      // FALLBACK: errore
      if (res.error != null) {
        continue;
      }

      // FALLBACK: zero risultati (Phase 2 rule: fallback always)
      // Se in futuro vuoi: fallback su zero risultati solo per world/country, non city.
      continue;
    }

    // Se siamo qui, nessun provider ha dato risultati.
    // Manteniamo comportamento "safe": ritorna empty list (UI gestisce empty state)
    // oppure rilancia errore se l'ultimo provider ha error.
    if (last?.error != null) {
      // Non imponiamo un tipo di eccezione nuovo: rilanciamo raw.
      throw last!.error!;
    }

    return const <dynamic>[];
  }

  /// Dettaglio news:
  /// - per ora delega SOLO al primo provider che supporta fetchNewsDetail
  /// - se un provider non lo supporta -> prova il successivo
  Future<Map<String, dynamic>> fetchNewsDetail(String id) async {
    Object? lastError;

    for (final p in _providers) {
      try {
        return await p.fetchNewsDetail(id);
      } catch (e) {
        lastError = e;
        continue;
      }
    }

    throw lastError ?? UnsupportedError('No provider supports fetchNewsDetail');
  }
}