import 'package:sociale_vote/domain/common/value_objects/entity_id.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';

import '../models/news_dto.dart';

class NewsMapper {
  /// Converte un [NewsDto] (GNews) in [NewsItem] di dominio.
  ///
  /// [countryCode] e [cityId] arrivano dal contesto (GeoScope),
  /// non da GNews.
  NewsItem toDomain(
    NewsDto dto, {
    String? countryCode,
    String? cityId,
  }) {
    final effectiveContent = dto.content ?? dto.description ?? '';

    final effectiveAuthor =
        dto.sourceName ?? dto.sourceId ?? 'gnews';

    final breaking = _computeBreaking(dto);

    return NewsItem(
      id: EntityId(dto.id),
      title: dto.title,
      content: effectiveContent,
      summary: dto.description,
      imageUrl: dto.image,
      countryCode: countryCode,
      cityId: cityId,
      authorId: effectiveAuthor,
      publishedAt: dto.publishedAt,
      isBreaking: breaking,
    );
  }

  /// Heuristica semplice e deterministica per "breaking news".
  ///
  /// Regole:
  /// - pubblicata nelle ultime 2 ore
  /// - oppure titolo contiene keyword tipiche
  bool _computeBreaking(NewsDto dto) {
    final now = DateTime.now().toUtc();
    final published = dto.publishedAt.toUtc();

    final age = now.difference(published);

    if (age.inHours <= 2) {
      return true;
    }

    final title = dto.title.toLowerCase();

    const keywords = [
      'breaking',
      'urgent',
      'alert',
      'ultim',
      'ultima ora',
    ];

    for (final k in keywords) {
      if (title.contains(k)) {
        return true;
      }
    }

    return false;
  }
}