// lib/infrastructure/news/aggregator/gnews_provider.dart

import 'package:sociale_vote/infrastructure/news/aggregator/news_provider.dart';
import 'package:sociale_vote/infrastructure/persistence/remote/rest/news_api.dart';

class GNewsProvider implements NewsProvider {
  final NewsApi _api;

  GNewsProvider(this._api);

  @override
  String get id => 'gnews';

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
      final list = await _api.fetchNews(
        countryCode: countryCode,
        cityId: cityId,
        topic: topic,
        language: language,
        limit: limit,
        offset: offset,
      );

      final items = list
          .whereType<Map<String, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(growable: false);

      return ProviderFetchResult(
        providerId: id,
        items: items,
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
    return _api.fetchNewsDetail(id);
  }
}