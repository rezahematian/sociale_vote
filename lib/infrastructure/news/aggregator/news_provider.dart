// lib/infrastructure/news/aggregator/news_provider.dart

/// Risposta standardizzata di un provider (in forma JSON-like)
/// compatibile con il parsing esistente (NewsDto.fromJson).
class ProviderFetchResult {
  final String providerId;
  final List<Map<String, dynamic>> items;

  /// True se il provider segnala rate limit (quando rilevabile).
  final bool rateLimited;

  /// HTTP status (se disponibile)
  final int? statusCode;

  /// Errore raw (se presente)
  final Object? error;

  const ProviderFetchResult({
    required this.providerId,
    required this.items,
    this.rateLimited = false,
    this.statusCode,
    this.error,
  });

  bool get isEmpty => items.isEmpty;
}

/// Contratto per un provider news.
abstract class NewsProvider {
  String get id;

  Future<ProviderFetchResult> fetchNews({
    String? countryCode,
    String? cityId,
    String? topic,
    String? language,
    int? limit,
    int? offset,
  });

  Future<Map<String, dynamic>> fetchNewsDetail(String id);
}