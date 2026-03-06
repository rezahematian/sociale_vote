/// DTO per una news proveniente da GNews.
///
/// Esempio JSON GNews:
/// {
///   "id": "5080226bd17140e4443cecba90c090e4",
///   "title": "...",
///   "description": "...",
///   "content": "...",
///   "url": "...",
///   "image": "...",
///   "publishedAt": "2026-03-03T19:59:49Z",
///   "lang": "it",
///   "source": {
///     "id": "...",
///     "name": "...",
///     "url": "..."
///   }
/// }
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
    final source = json['source'] as Map<String, dynamic>?;

    return NewsDto(
      id: json['id'] as String,
      title: (json['title'] as String?) ?? '',
      description: json['description'] as String?,
      content: json['content'] as String?,
      url: (json['url'] as String?) ?? '',
      image: json['image'] as String?,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      lang: json['lang'] as String?,
      sourceId: source?['id'] as String?,
      sourceName: source?['name'] as String?,
      sourceUrl: source?['url'] as String?,
    );
  }
}