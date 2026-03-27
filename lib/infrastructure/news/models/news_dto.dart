/// DTO news normalizzato per provider multipli e cache interna.
///
/// Supporta input con shape diverse:
/// - GNews
/// - NewsAPI.org
/// - payload cache già salvati
/// - payload normalizzati con campi flat o nested
class NewsDto {
  final String id;
  final String title;
  final String? description;
  final String? content;
  final String url;
  final String? image;
  final DateTime publishedAt;
  final String? lang;
  final String? sourceId;
  final String? sourceName;
  final String? sourceUrl;

  NewsDto({
    required this.id,
    required this.title,
    this.description,
    this.content,
    required this.url,
    this.image,
    required this.publishedAt,
    this.lang,
    this.sourceId,
    this.sourceName,
    this.sourceUrl,
  });

  factory NewsDto.fromJson(Map<String, dynamic> json) {
    final source = _readNestedMap(json, const [
      'source',
      'provider',
      'publisher',
    ]);

    final title = _readFirstString(json, const [
          'title',
          'headline',
          'webTitle',
          'name',
        ]) ??
        '';

    final description = _readFirstString(json, const [
      'description',
      'summary',
      'excerpt',
      'subtitle',
    ]);

    final content = _readFirstString(json, const [
      'content',
      'body',
      'text',
    ]);

    final url = _readFirstString(json, const [
          'url',
          'link',
          'webUrl',
          'article_url',
          'articleUrl',
          'canonical_url',
          'canonicalUrl',
        ]) ??
        '';

    final image = _readFirstString(json, const [
      'image',
      'urlToImage',
      'imageUrl',
      'thumbnail',
      'thumbnailUrl',
    ]);

    final publishedAt = _readFirstDateTime(json, const [
          'publishedAt',
          'published_at',
          'webPublicationDate',
          'pubDate',
          'date',
          'created_at',
          'createdAt',
        ]) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

    final lang = _normalizeLanguage(
      _readFirstString(json, const [
            'lang',
            'language',
            'locale',
            'content_language',
            'contentLanguage',
            'feed_language',
            'feedLanguage',
          ]) ??
          _readFirstString(source, const [
            'lang',
            'language',
            'locale',
          ]),
    );

    final sourceId = _readFirstString(source, const [
          'id',
          'sourceId',
          'source_id',
          'providerId',
          'provider_id',
        ]) ??
        _readFirstString(json, const [
          'source_id',
          'sourceId',
          'provider_id',
          'providerId',
        ]);

    final sourceName = _readFirstString(source, const [
          'name',
          'sourceName',
          'source_name',
          'providerName',
          'provider_name',
        ]) ??
        _readFirstString(json, const [
          'source_name',
          'sourceName',
          'provider_name',
          'providerName',
          'publisher',
          'author',
        ]);

    final sourceUrl = _readFirstString(source, const [
          'url',
          'link',
          'homepage',
        ]) ??
        _readFirstString(json, const [
          'source_url',
          'sourceUrl',
          'provider_url',
          'providerUrl',
        ]);

    final id = _resolveId(
      json: json,
      url: url,
      title: title,
      publishedAt: publishedAt,
      sourceId: sourceId,
      sourceName: sourceName,
    );

    return NewsDto(
      id: id,
      title: title,
      description: description,
      content: content,
      url: url,
      image: image,
      publishedAt: publishedAt,
      lang: lang,
      sourceId: sourceId,
      sourceName: sourceName,
      sourceUrl: sourceUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'url': url,
      'image': image,
      'publishedAt': publishedAt.toUtc().toIso8601String(),
      'lang': lang,
      'source': <String, dynamic>{
        'id': sourceId,
        'name': sourceName,
        'url': sourceUrl,
      },
      'source_id': sourceId,
      'source_name': sourceName,
      'source_url': sourceUrl,
    };
  }

  static String _resolveId({
    required Map<String, dynamic> json,
    required String url,
    required String title,
    required DateTime publishedAt,
    required String? sourceId,
    required String? sourceName,
  }) {
    final explicitId = _readFirstString(json, const [
      'id',
      'external_id',
      'externalId',
      'guid',
      'uuid',
      'article_id',
      'articleId',
      'provider_article_id',
      'providerArticleId',
    ]);

    if (explicitId != null && explicitId.trim().isNotEmpty) {
      return explicitId.trim();
    }

    final normalizedUrl = _normalizeUrl(url);
    if (normalizedUrl != null) {
      return normalizedUrl;
    }

    final sourceHint = (sourceId ?? sourceName ?? 'unknown').trim().toLowerCase();
    final safeTitle = title.trim().toLowerCase();
    final safeDate = publishedAt.toUtc().toIso8601String();

    return '$sourceHint|$safeTitle|$safeDate';
  }

  static Map<String, dynamic>? _readNestedMap(
    Map<String, dynamic>? json,
    List<String> keys,
  ) {
    if (json == null) {
      return null;
    }

    for (final key in keys) {
      final value = json[key];

      if (value is Map<String, dynamic>) {
        return value;
      }

      if (value is Map) {
        return value.map(
          (k, v) => MapEntry(k.toString(), v),
        );
      }
    }

    return null;
  }

  static String? _readFirstString(
    Map<String, dynamic>? json,
    List<String> keys,
  ) {
    if (json == null) {
      return null;
    }

    for (final key in keys) {
      final value = json[key];
      if (value == null) {
        continue;
      }

      final text = value.toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }

    return null;
  }

  static DateTime? _readFirstDateTime(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) {
        continue;
      }

      if (value is DateTime) {
        return value.toUtc();
      }

      final parsed = DateTime.tryParse(value.toString());
      if (parsed != null) {
        return parsed.toUtc();
      }
    }

    return null;
  }

  static String? _normalizeLanguage(String? value) {
    if (value == null) {
      return null;
    }

    final normalized = value.trim().toLowerCase().replaceAll('_', '-');
    if (normalized.isEmpty) {
      return null;
    }

    return normalized.split('-').first;
  }

  static String? _normalizeUrl(String? rawUrl) {
    if (rawUrl == null) {
      return null;
    }

    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return trimmed.toLowerCase();
    }

    final normalizedPath = uri.path.replaceFirst(RegExp(r'/$'), '');

    return Uri(
      scheme: uri.scheme.toLowerCase(),
      host: uri.host.toLowerCase(),
      port: uri.hasPort ? uri.port : null,
      path: normalizedPath.isEmpty ? '/' : normalizedPath,
      query: null,
      fragment: null,
    ).toString().toLowerCase();
  }
}