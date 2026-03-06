// lib/infrastructure/persistence/remote/rest/mediastack_api.dart

import 'package:sociale_vote/core/http/api_client.dart';

/// REST API wrapper per mediastack
///
/// Base URL atteso:
///   http://api.mediastack.com/v1
///
/// Endpoint:
/// - /news
class MediaStackApi {
  final ApiClient _client;

  /// 🔐 INSERISCI QUI LA TUA API KEY mediastack
  static const String _apiKey = 'PUT_YOUR_MEDIASTACK_KEY_HERE';

  MediaStackApi(this._client);

  Future<Map<String, dynamic>> fetchNews({
    String? countries,
    String? keywords,
    String? categories,
    String? languages,
    int? limit,
    int? offset,
  }) async {
    final query = <String, String>{
      'access_key': _apiKey,
      if (countries != null && countries.trim().isNotEmpty)
        'countries': countries.toLowerCase(),
      if (keywords != null && keywords.trim().isNotEmpty)
        'keywords': keywords.trim(),
      if (categories != null && categories.trim().isNotEmpty)
        'categories': categories.trim(),
      if (languages != null && languages.trim().isNotEmpty)
        'languages': languages.trim(),
      if (limit != null) 'limit': limit.toString(),
      if (offset != null) 'offset': offset.toString(),
    };

    final res = await _client.getJson(
      '/news',
      query: query,
    );

    if (res is Map<String, dynamic>) return res;
    return <String, dynamic>{};
  }
}