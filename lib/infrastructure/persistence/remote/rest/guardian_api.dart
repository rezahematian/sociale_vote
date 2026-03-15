import 'package:sociale_vote/core/http/api_client.dart';

/// REST API wrapper per The Guardian Open Platform.
///
/// Base URL atteso:
///   https://content.guardianapis.com
///
/// Endpoint principali:
/// - /search
/// - /{id}
class GuardianApi {
  final ApiClient _client;

  /// 🔐 INSERISCI QUI LA TUA API KEY THE GUARDIAN
  static const String _apiKey = 'e34161b5-337b-4ae8-af13-e7c4cb990958';

  GuardianApi(this._client);

  Future<Map<String, dynamic>> fetchSearch({
    String? countryCode,
    String? cityId,
    String? topic,
    String? language,
    int? pageSize,
    int? page,
  }) async {
    final effectivePageSize = (pageSize ?? 20).clamp(1, 50).toInt();
    final effectivePage = (page == null || page <= 0) ? 1 : page;

    final section = _mapTopicToSection(topic);
    final q = _buildQueryText(
      countryCode: countryCode,
      cityId: cityId,
      topic: topic,
      sectionWasMapped: section != null,
    );

    final query = <String, String>{
      'api-key': _apiKey,
      'page-size': effectivePageSize.toString(),
      'page': effectivePage.toString(),
      'order-by': 'newest',
      'show-fields': 'headline,trailText,body,thumbnail,byline',
      'show-tags': 'contributor',
    };

    if (section != null) {
      query['section'] = section;
    }

    if (q != null && q.isNotEmpty) {
      query['q'] = q;
    }

    // The Guardian non espone un filtro lingua semplice come GNews/NewsAPI
    // nel nostro uso corrente, quindi language viene ignorato qui.

    final res = await _client.getJson('/search', query: query);

    if (res is Map<String, dynamic>) {
      return res;
    }

    return <String, dynamic>{};
  }

  Future<Map<String, dynamic>> fetchNewsDetail(String id) async {
    final normalizedId = _normalizeItemId(id);

    final query = <String, String>{
      'api-key': _apiKey,
      'show-fields': 'headline,trailText,body,thumbnail,byline',
      'show-tags': 'contributor',
    };

    final res = await _client.getJson('/$normalizedId', query: query);

    if (res is Map<String, dynamic>) {
      return res;
    }

    return <String, dynamic>{};
  }

  String _normalizeItemId(String id) {
    var value = id.trim();

    while (value.startsWith('/')) {
      value = value.substring(1);
    }

    return value;
  }

  String? _buildQueryText({
    required String? countryCode,
    required String? cityId,
    required String? topic,
    required bool sectionWasMapped,
  }) {
    final parts = <String>[];

    final normalizedCity = _normalize(cityId);
    if (normalizedCity != null) {
      parts.add(normalizedCity);
    }

    final countryName = _countryNameFromCode(countryCode);
    if (countryName != null) {
      parts.add(countryName);
    }

    final normalizedTopic = _normalize(topic);
    if (!sectionWasMapped && normalizedTopic != null) {
      parts.add(normalizedTopic);
    }

    if (parts.isEmpty) {
      return null;
    }

    return parts.join(' ');
  }

  String? _mapTopicToSection(String? topic) {
    final value = _normalize(topic)?.toLowerCase();
    if (value == null) return null;

    switch (value) {
      case 'world':
      case 'international':
        return 'world';
      case 'politics':
        return 'politics';
      case 'business':
      case 'economy':
        return 'business';
      case 'technology':
      case 'tech':
        return 'technology';
      case 'science':
        return 'science';
      case 'environment':
        return 'environment';
      case 'sport':
      case 'sports':
        return 'sport';
      case 'culture':
        return 'culture';
      case 'media':
        return 'media';
      default:
        return null;
    }
  }

  String? _countryNameFromCode(String? countryCode) {
    final code = _normalize(countryCode)?.toUpperCase();
    if (code == null) return null;

    switch (code) {
      case 'IT':
        return 'Italy';
      case 'US':
        return 'United States';
      case 'GB':
      case 'UK':
        return 'United Kingdom';
      case 'FR':
        return 'France';
      case 'DE':
        return 'Germany';
      case 'ES':
        return 'Spain';
      default:
        return null;
    }
  }

  String? _normalize(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }
}
