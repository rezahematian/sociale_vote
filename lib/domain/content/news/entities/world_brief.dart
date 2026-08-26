enum WorldBriefStatus { draft, published, withdrawn }

extension WorldBriefStatusX on WorldBriefStatus {
  String get storageKey => switch (this) {
        WorldBriefStatus.draft => 'draft',
        WorldBriefStatus.published => 'published',
        WorldBriefStatus.withdrawn => 'withdrawn',
      };

  static WorldBriefStatus fromStorageKey(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'published' => WorldBriefStatus.published,
      'withdrawn' => WorldBriefStatus.withdrawn,
      _ => WorldBriefStatus.draft,
    };
  }
}

class WorldBrief {
  final String id;
  final WorldBriefStatus status;
  final String languageCode;
  final String title;
  final String whatHappened;
  final String whyItMatters;
  final String? whatIsUncertain;
  final String? socialVoteView;
  final List<String> sourceUrls;
  final String? countryCode;
  final String? cityId;
  final String? locationLabel;
  final double? latitude;
  final double? longitude;
  final bool mapVisible;
  final bool featured;
  final bool breaking;
  final int priority;
  final DateTime? publishedAt;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorldBrief({
    required this.id,
    required this.status,
    required this.languageCode,
    required this.title,
    required this.whatHappened,
    required this.whyItMatters,
    required this.whatIsUncertain,
    required this.socialVoteView,
    required this.sourceUrls,
    required this.countryCode,
    required this.cityId,
    required this.locationLabel,
    required this.latitude,
    required this.longitude,
    required this.mapVisible,
    required this.featured,
    required this.breaking,
    required this.priority,
    required this.publishedAt,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasMapPoint => latitude != null && longitude != null;
}

class WorldBriefDraft {
  final String? id;
  final String languageCode;
  final String title;
  final String whatHappened;
  final String whyItMatters;
  final String? whatIsUncertain;
  final String? socialVoteView;
  final List<String> sourceUrls;
  final String? countryCode;
  final String? cityId;
  final String? locationLabel;
  final double? latitude;
  final double? longitude;
  final bool mapVisible;
  final bool featured;
  final bool breaking;
  final int priority;
  final DateTime? expiresAt;

  const WorldBriefDraft({
    this.id,
    required this.languageCode,
    required this.title,
    required this.whatHappened,
    required this.whyItMatters,
    required this.whatIsUncertain,
    required this.socialVoteView,
    required this.sourceUrls,
    required this.countryCode,
    required this.cityId,
    required this.locationLabel,
    required this.latitude,
    required this.longitude,
    required this.mapVisible,
    required this.featured,
    required this.breaking,
    required this.priority,
    required this.expiresAt,
  });
}
