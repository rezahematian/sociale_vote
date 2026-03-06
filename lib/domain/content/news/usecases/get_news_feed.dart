import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/content/news/repositories/news_repository.dart';

/// Use case per ottenere il feed news.
///
/// v1:
/// - filtra per [countryCode] / [cityId].
///
/// v2 (Fase 4.3 – paginazione):
/// - espone anche [limit] e [offset] per supportare la paginazione lato dominio.
///
/// v3:
/// - supporta anche il filtro opzionale [topic] (world, nation, business, ecc.).
///
/// v4:
/// - supporta anche il filtro opzionale [language] per le news.
class GetNewsFeed {
  final NewsRepository _repository;

  const GetNewsFeed(this._repository);

  Future<List<NewsItem>> call({
    String? countryCode,
    String? cityId,
    String? topic,
    String? language, // ✅ NUOVO
    int? limit,
    int? offset,
  }) {
    return _repository.getNewsFeed(
      countryCode: countryCode,
      cityId: cityId,
      topic: topic,
      language: language, // ✅ passato al repository
      limit: limit,
      offset: offset,
    );
  }
}