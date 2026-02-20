class NewsDTO {
  final String id;
  final String title;
  final String content;
  final String language;
  final String countryCode;
  final DateTime publishedAt;

  /// 🔥 / ❄️ heat counters
  final int hotCount;
  final int coldCount;

  const NewsDTO({
    required this.id,
    required this.title,
    required this.content,
    required this.language,
    required this.countryCode,
    required this.publishedAt,
    this.hotCount = 0,
    this.coldCount = 0,
  });

  factory NewsDTO.fromJson(Map<String, dynamic> json) {
    return NewsDTO(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      language: json['language'],
      countryCode: json['country_code'],
      publishedAt: DateTime.parse(json['published_at']),
      hotCount: json['hot_count'] ?? 0,
      coldCount: json['cold_count'] ?? 0,
    );
  }

  NewsDTO copyWith({
    int? hotCount,
    int? coldCount,
  }) {
    return NewsDTO(
      id: id,
      title: title,
      content: content,
      language: language,
      countryCode: countryCode,
      publishedAt: publishedAt,
      hotCount: hotCount ?? this.hotCount,
      coldCount: coldCount ?? this.coldCount,
    );
  }
}
