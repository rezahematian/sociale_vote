enum NewsScope {
  global,
  country,
  city,
}

enum HeatVote {
  none,
  hot,
  cold,
}

class NewsItem {
  final String id;
  final String title;
  final String summary;

  /// ✅ NUOVO — Contenuto completo articolo
  final String? fullContent;

  /// ✅ NUOVO — URL sorgente esterna
  final String? sourceUrl;

  final String languageCode;
  final String countryCode;
  final DateTime publishedAt;
  final String? imageUrl;
  final String? locationId;
  final NewsScope scope;

  final int hotCount;
  final int coldCount;
  final HeatVote userVote;

  const NewsItem({
    required this.id,
    required this.title,
    required this.summary,
    this.fullContent,
    this.sourceUrl,
    required this.languageCode,
    required this.countryCode,
    required this.publishedAt,
    this.imageUrl,
    this.locationId,
    this.scope = NewsScope.global,
    this.hotCount = 0,
    this.coldCount = 0,
    this.userVote = HeatVote.none,
  });

  NewsItem copyWith({
    String? id,
    String? title,
    String? summary,
    String? fullContent,
    String? sourceUrl,
    String? languageCode,
    String? countryCode,
    DateTime? publishedAt,
    String? imageUrl,
    String? locationId,
    NewsScope? scope,
    int? hotCount,
    int? coldCount,
    HeatVote? userVote,
  }) {
    return NewsItem(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      fullContent: fullContent ?? this.fullContent,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      languageCode: languageCode ?? this.languageCode,
      countryCode: countryCode ?? this.countryCode,
      publishedAt: publishedAt ?? this.publishedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      locationId: locationId ?? this.locationId,
      scope: scope ?? this.scope,
      hotCount: hotCount ?? this.hotCount,
      coldCount: coldCount ?? this.coldCount,
      userVote: userVote ?? this.userVote,
    );
  }

  String get scopeLabel {
    switch (scope) {
      case NewsScope.city:
        return 'Città';
      case NewsScope.country:
        return 'Paese';
      case NewsScope.global:
      default:
        return 'Mondo';
    }
  }

  String get locationLabel {
    if (scope == NewsScope.global) {
      return 'Mondo';
    }

    if (scope == NewsScope.country) {
      return countryCode.toUpperCase();
    }

    if (scope == NewsScope.city && locationId != null) {
      return _prettyLocation(locationId!);
    }

    return '—';
  }

  String _prettyLocation(String raw) {
    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (w) => w.isEmpty
              ? w
              : '${w[0].toUpperCase()}${w.substring(1)}',
        )
        .join(' ');
  }
}
