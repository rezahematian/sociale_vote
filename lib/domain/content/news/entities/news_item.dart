import 'package:sociale_vote/domain/common/value_objects/entity_id.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';

class NewsItem {
  final EntityId id;
  final String title;
  final String content;
  final String? summary;
  final String? imageUrl;

  /// Scope del feed / contesto da cui è stata caricata la news.
  /// Serve ancora per filtri e fallback.
  final String? countryCode;
  final String? cityId;

  /// Località reale di cui parla l'articolo.
  /// Questa è quella che la mappa deve usare per il marker.
  final ContentLocation? contentLocation;

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
    this.contentLocation,
    this.isBreaking = false,
  });

  bool get isGlobal => countryCode == null && cityId == null;

  bool get isCountryLevel => countryCode != null && cityId == null;

  bool get isCityLevel => countryCode != null && cityId != null;
}
