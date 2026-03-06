// lib/infrastructure/news/aggregator/news_api_org_provider.dart

import 'package:sociale_vote/infrastructure/news/aggregator/news_provider.dart';
import 'package:sociale_vote/infrastructure/persistence/remote/rest/news_api_org_api.dart';

class NewsApiOrgProvider implements NewsProvider {
  final NewsApiOrgApi _api;

  NewsApiOrgProvider(this._api);

  @override
  String get id => 'newsapi_org';

  @override
  Future<ProviderFetchResult> fetchNews({
    String? countryCode,
    String? cityId,
    String? topic,
    String? language,
    int? limit,
    int? offset,
  }) async {
    try {
      // Mapping paging: (limit/offset) -> (pageSize/page)
      final pageSize = (limit == null || limit <= 0) ? 10 : limit;
      final page = (offset == null || offset < 0) ? 1 : (offset ~/ pageSize) + 1;

      // Query strategy (minimal):
      // - se cityId presente: q=cityId
      // - altrimenti topic come category (se compatibile), altrimenti null
      final q = (cityId != null && cityId.trim().isNotEmpty) ? cityId : null;
      final category = (topic != null && topic.trim().isNotEmpty) ? topic : null;

      final json = await _api.fetchTopHeadlines(
        countryCode: countryCode,
        q: q,
        category: category,
        language: language,
        pageSize: pageSize,
        page: page,
      );

      // Rate limit best-effort (NewsAPI: status=error + code)
      final status = (json['status'] ?? '').toString();
      final code = (json['code'] ?? '').toString();
      final rateLimited =
          status == 'error' && code.toLowerCase().contains('rate');

      final articles = (json['articles'] is List) ? (json['articles'] as List) : const [];

      final items = <Map<String, dynamic>>[];
      for (final a in articles) {
        if (a is! Map) continue;
        final m = Map<String, dynamic>.from(a as Map);

        final url = (m['url'] as String?) ?? '';
        if (url.isEmpty) {
          // Senza url non abbiamo un id stabile -> skippiamo
          continue;
        }

        final publishedAtRaw = (m['publishedAt'] as String?);
        final publishedAt = (publishedAtRaw != null && publishedAtRaw.isNotEmpty)
            ? publishedAtRaw
            : DateTime.now().toUtc().toIso8601String();

        final source = (m['source'] is Map)
            ? Map<String, dynamic>.from(m['source'] as Map)
            : <String, dynamic>{};

        // Normalizzazione compatibile con NewsDto.fromJson (schema GNews-like)
        items.add(<String, dynamic>{
          'id': url, // ✅ richiesto da NewsDto
          'title': m['title'],
          'description': m['description'],
          'content': m['content'],
          'url': url,
          'image': m['urlToImage'],
          'publishedAt': publishedAt, // ✅ richiesto da NewsDto
          'lang': language, // best-effort fallback
          'source': <String, dynamic>{
            'id': source['id'], // spesso null in NewsAPI
            'name': source['name'],
            'url': null, // NewsAPI non fornisce source url in modo consistente
          },
        });
      }

      return ProviderFetchResult(
        providerId: id,
        items: items,
        rateLimited: rateLimited,
      );
    } catch (e) {
      return ProviderFetchResult(
        providerId: id,
        items: const [],
        error: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> fetchNewsDetail(String id) async {
    // NewsAPI non ha "detail by id" standard.
    throw UnsupportedError('NewsApiOrgProvider: fetchNewsDetail not supported');
  }
}