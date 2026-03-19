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
    final normalizedCountryCode = _normalize(countryCode);
    final normalizedQuery = _normalize(q);
    final normalizedCategory = _normalize(category);
    final normalizedLanguage = _normalize(language);

    // Fix mirato F7.9:
    // per AR + "Tutte" (quindi senza q e senza category),
    // usiamo /everything con filtro lingua invece di /top-headlines.
    // Non tocchiamo gli altri casi per non rompere i filtri che già funzionano.
    if (_shouldUseEverythingForGeneralLanguageFeed(
      q: normalizedQuery,
      category: normalizedCategory,
      language: normalizedLanguage,
    )) {
      final effectiveLanguage = normalizedLanguage!;
      return _fetchEverything(
        q: _defaultEverythingQueryForLanguage(effectiveLanguage),
        language: effectiveLanguage,
        pageSize: pageSize,
        page: page,
      );
    }

    final query = <String, String>{
      'apiKey': _apiKey,
      if (normalizedCountryCode != null) 'country': normalizedCountryCode,
      if (normalizedQuery != null) 'q': normalizedQuery,
      if (normalizedCategory != null) 'category': normalizedCategory,
      // Manteniamo il comportamento esistente per i casi non speciali,
      // così non tocchiamo i filtri che oggi ti funzionano già.
      if (normalizedLanguage != null) 'language': normalizedLanguage,
      if (pageSize != null) 'pageSize': pageSize.toString(),
      if (page != null) 'page': page.toString(),
    };

    final res = await _client.getJson(
      '/top-headlines',
      query: query,
    );

    if (res is Map<String, dynamic>) return res;
    return <String, dynamic>{};
  }

  Future<Map<String, dynamic>> _fetchEverything({
    required String q,
    required String language,
    int? pageSize,
    int? page,
  }) async {
    final query = <String, String>{
      'apiKey': _apiKey,
      'q': q,
      'language': language,
      'sortBy': 'publishedAt',
      if (pageSize != null) 'pageSize': pageSize.toString(),
      if (page != null) 'page': page.toString(),
    };

    final res = await _client.getJson(
      '/everything',
      query: query,
    );

    if (res is Map<String, dynamic>) return res;
    return <String, dynamic>{};
  }

  bool _shouldUseEverythingForGeneralLanguageFeed({
    required String? q,
    required String? category,
    required String? language,
  }) {
    if (language != 'ar') {
      return false;
    }

    final hasQuery = q != null && q.isNotEmpty;
    final hasCategory = category != null && category.isNotEmpty;

    return !hasQuery && !hasCategory;
  }

  String _defaultEverythingQueryForLanguage(String language) {
    switch (language) {
      case 'ar':
        return 'أخبار';
      default:
        return 'news';
    }
  }

  String? _normalize(String? value) {
    if (value == null) return null;
    final trimmed = value.trim().toLowerCase();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }
}