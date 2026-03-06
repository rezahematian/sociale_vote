import 'package:sociale_vote/domain/common/value_objects/entity_id.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';

/// Repository astratto per il feed News.
///
/// Fase 4.3 – paginazione:
/// - [limit]  → massimo numero di elementi da restituire
/// - [offset] → numero di elementi da saltare (per paging offset-based)
///
/// Filtro opzionale:
/// - [topic] → categoria news (world, nation, business, technology, ecc.)
/// - [language] → override lingua news (it/en/es/fr/de/ar/fa). Se null → AUTO.
///
/// Implementazioni:
/// - in-memory: possono simulare la paginazione con uno slice sulla lista.
/// - HTTP: possono tradurre [limit]/[offset] in query parameter.
abstract class NewsRepository {
  Future<List<NewsItem>> getNewsFeed({
    String? countryCode,
    String? cityId,
    String? topic,
    String? language, // ✅ NUOVO parametro opzionale
    int? limit,
    int? offset,
  });

  Future<NewsItem> getNewsDetail(EntityId id);
}