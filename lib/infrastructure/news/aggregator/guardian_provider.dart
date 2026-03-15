import 'package:sociale_vote/infrastructure/news/aggregator/news_provider.dart';
import 'package:sociale_vote/infrastructure/persistence/remote/rest/guardian_api.dart';

class GuardianProvider implements NewsProvider {
  final GuardianApi _api;

  GuardianProvider(this._api);

  @override
  String get id => 'guardian';

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
      final pageSize = (limit == null || limit <= 0) ? 20 : limit;
      final page = (offset == null || offset < 0) ? 1 : (offset ~/ pageSize) + 1;

      final json = await _api.fetchSearch(
        countryCode: countryCode,
        cityId: cityId,
        topic: topic,
        language: language,
        pageSize: pageSize,
        page: page,
      );

      final response = json['response'];
      if (response is! Map<String, dynamic>) {
        return ProviderFetchResult(
          providerId: id,
          items: const [],
        );
      }

      final status = (response['status'] ?? '').toString().toLowerCase();
      final results =
          (response['results'] is List) ? (response['results'] as List) : const [];

      if (status != 'ok') {
        return ProviderFetchResult(
          providerId: id,
          items: const [],
          error: StateError('Guardian response status is not ok: $status'),
        );
      }

      final items = <Map<String, dynamic>>[];

      for (final raw in results) {
        if (raw is! Map) continue;

        final article = Map<String, dynamic>.from(raw as Map);
        final fields = (article['fields'] is Map)
            ? Map<String, dynamic>.from(article['fields'] as Map)
            : <String, dynamic>{};

        final tags = (article['tags'] is List) ? (article['tags'] as List) : const [];

        String? contributorName;
        for (final tag in tags) {
          if (tag is! Map) continue;
          final typedTag = Map<String, dynamic>.from(tag as Map);
          final type = (typedTag['type'] ?? '').toString().toLowerCase();
          if (type == 'contributor') {
            final webTitle = typedTag['webTitle']?.toString();
            if (webTitle != null && webTitle.trim().isNotEmpty) {
              contributorName = webTitle.trim();
              break;
            }
          }
        }

        final articleId = article['id']?.toString();
        final webUrl = article['webUrl']?.toString();
        final title = (fields['headline'] ?? article['webTitle'])?.toString() ?? '';
        final publishedAt =
            article['webPublicationDate']?.toString() ?? DateTime.now().toUtc().toIso8601String();

        if (articleId == null || articleId.trim().isEmpty) {
          continue;
        }

        items.add(<String, dynamic>{
          'id': articleId,
          'title': title,
          'description': fields['trailText']?.toString(),
          'content': fields['body']?.toString(),
          'url': webUrl ?? '',
          'image': fields['thumbnail']?.toString(),
          'publishedAt': publishedAt,
          'lang': language,
          'source': <String, dynamic>{
            'id': 'the-guardian',
            'name': 'The Guardian',
            'url': 'https://www.theguardian.com',
          },
          'authorName': contributorName ?? fields['byline']?.toString(),
        });
      }

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
    final json = await _api.fetchNewsDetail(id);

    final response = json['response'];
    if (response is! Map<String, dynamic>) {
      throw StateError('Guardian detail response is invalid');
    }

    final content = response['content'];
    if (content is! Map<String, dynamic>) {
      throw StateError('Guardian detail content not found');
    }

    final fields = (content['fields'] is Map)
        ? Map<String, dynamic>.from(content['fields'] as Map)
        : <String, dynamic>{};

    final tags = (content['tags'] is List) ? (content['tags'] as List) : const [];

    String? contributorName;
    for (final tag in tags) {
      if (tag is! Map) continue;
      final typedTag = Map<String, dynamic>.from(tag as Map);
      final type = (typedTag['type'] ?? '').toString().toLowerCase();
      if (type == 'contributor') {
        final webTitle = typedTag['webTitle']?.toString();
        if (webTitle != null && webTitle.trim().isNotEmpty) {
          contributorName = webTitle.trim();
          break;
        }
      }
    }

    return <String, dynamic>{
      'id': content['id']?.toString() ?? id,
      'title': (fields['headline'] ?? content['webTitle'])?.toString() ?? '',
      'description': fields['trailText']?.toString(),
      'content': fields['body']?.toString(),
      'url': content['webUrl']?.toString() ?? '',
      'image': fields['thumbnail']?.toString(),
      'publishedAt': content['webPublicationDate']?.toString() ??
          DateTime.now().toUtc().toIso8601String(),
      'lang': null,
      'source': <String, dynamic>{
        'id': 'the-guardian',
        'name': 'The Guardian',
        'url': 'https://www.theguardian.com',
      },
      'authorName': contributorName ?? fields['byline']?.toString(),
    };
  }
}
