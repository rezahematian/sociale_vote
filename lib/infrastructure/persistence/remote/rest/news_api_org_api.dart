// lib/infrastructure/persistence/remote/rest/news_api_org_api.dart

import 'package:sociale_vote/core/http/api_client.dart';

/// REST API wrapper per NewsAPI.org
///
/// Base URL atteso:
///   https://newsapi.org/v2
///
/// Endpoint principali:
/// - /top-headlines
/// - /everything
class NewsApiOrgApi {
  final ApiClient _client;

  /// 🔐 INSERISCI QUI LA TUA API KEY NewsAPI.org
  static const String _apiKey = '14b527a326ee4ea0891173e331dded9e';

  NewsApiOrgApi(this._client);

  Future<Map<String, dynamic>> fetchTopHeadlines({
    String? countryCode,
    String? q,
    String? category,
    String? language,
    int? pageSize,
    int? page, // NewsAPI usa "page"
  }) async {
    final query = <String, String>{
      'apiKey': _apiKey,
      if (countryCode != null && countryCode.trim().isNotEmpty)
        'country': countryCode.toLowerCase(),
      if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
      if (category != null && category.trim().isNotEmpty)
        'category': category.trim(),
      if (language != null && language.trim().isNotEmpty)
        'language': language.trim(),
      if (pageSize != null) 'pageSize': pageSize.toString(),
      if (page != null) 'page': page.toString(),
    };

    final res = await _client.getJson(
      '/top-headlines',
      query: query,
      // NewsAPI richiede apiKey in query (qui).
      // Niente header speciali necessari.
    );

    if (res is Map<String, dynamic>) return res;
    return <String, dynamic>{};
  }
}