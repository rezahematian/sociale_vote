// lib/infrastructure/news/aggregator/mediastack_provider.dart

import 'package:sociale_vote/infrastructure/news/aggregator/news_provider.dart';
import 'package:sociale_vote/infrastructure/persistence/remote/rest/mediastack_api.dart';

class MediaStackProvider implements NewsProvider {
  final MediaStackApi _api;

  MediaStackProvider(this._api);

  @override
  String get id => 'mediastack';

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
      final keywords =
          (cityId != null && cityId.trim().isNotEmpty) ? cityId : null;

      final json = await _api.fetchNews(
        countries: countryCode,
        keywords: keywords,
        categories: topic,
        languages: language,
        limit: limit,
        offset: offset,
      );

      // mediastack error format: { "error": { "code": "...", ... } }
      final err = json['error'];
      final rateLimited = (err is Map) &&
          ((err['code'] ?? '').toString().toLowerCase().contains('rate'));

      final data = (json['data'] is List) ? (json['data'] as List) : const [];

      final items = <Map<String, dynamic>>[];
      for (final a in data) {
        if (a is! Map) continue;
        final m = Map<String, dynamic>.from(a);

        final url = (m['url'] as String?) ?? '';
        if (url.isEmpty) {
          // Senza url non abbiamo un id stabile -> skippiamo
          continue;
        }

        final publishedAtRaw = (m['published_at'] as String?);
        final publishedAt =
            (publishedAtRaw != null && publishedAtRaw.isNotEmpty)
                ? publishedAtRaw
                : DateTime.now().toUtc().toIso8601String();

        // Normalizzazione compatibile con NewsDto.fromJson (schema GNews-like)
        items.add(<String, dynamic>{
          'id': url, // ✅ richiesto da NewsDto
          'title': m['title'],
          'description': m['description'],
          'content': m['description'], // mediastack spesso non ha content pieno
          'url': url,
          'image': m['image'],
          'publishedAt': publishedAt, // ✅ richiesto da NewsDto
          'lang': language, // best-effort fallback
          'source': <String, dynamic>{
            'id': null,
            'name': m['source'], // mediastack source è spesso string
            'url': null,
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
    throw UnsupportedError('MediaStackProvider: fetchNewsDetail not supported');
  }
}
