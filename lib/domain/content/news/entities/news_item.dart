import 'package:sociale_vote/domain/common/value_objects/entity_id.dart';

class NewsItem {
  final EntityId id;
  final String title;
  final String content;
  final String? summary;
  final String? imageUrl;

  final String? countryCode;
  final String? cityId;

  final String authorId;
  final DateTime publishedAt;
  final bool isBreaking;

  const NewsItem({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.publishedAt,
    this.summary,
    this.imageUrl,
    this.countryCode,
    this.cityId,
    this.isBreaking = false,
  });

  bool get isGlobal => countryCode == null && cityId == null;

  bool get isCountryLevel =>
      countryCode != null && cityId == null;

  bool get isCityLevel =>
      countryCode != null && cityId != null;
}