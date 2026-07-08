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

  /// Campo legacy già usato nella UI attuale.
  /// Lo manteniamo per non rompere il codice esistente.
  final String authorId;

  /// URL articolo originale.
  final String? articleUrl;

  /// Metadati sorgente reali.
  final String? sourceId;
  final String? sourceName;
  final String? sourceUrl;

  /// Lingua contenuto normalizzata (es. it, en, fr...).
  final String? language;

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
    this.articleUrl,
    this.sourceId,
    this.sourceName,
    this.sourceUrl,
    this.language,
    this.isBreaking = false,
  });

  bool get isGlobal => countryCode == null && cityId == null;

  bool get isCountryLevel => countryCode != null && cityId == null;

  bool get isCityLevel => countryCode != null && cityId != null;

  String? get effectiveSourceLabel {
    final sourceNameTrimmed = sourceName?.trim();
    if (sourceNameTrimmed != null && sourceNameTrimmed.isNotEmpty) {
      return sourceNameTrimmed;
    }

    final sourceIdTrimmed = sourceId?.trim();
    if (sourceIdTrimmed != null && sourceIdTrimmed.isNotEmpty) {
      return sourceIdTrimmed;
    }

    final authorIdTrimmed = authorId.trim();
    if (authorIdTrimmed.isNotEmpty) {
      return authorIdTrimmed;
    }

    return null;
  }

  bool get hasOriginalArticleUrl {
    final value = articleUrl?.trim();
    return value != null && value.isNotEmpty;
  }
}