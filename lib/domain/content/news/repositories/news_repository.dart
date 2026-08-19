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
/// - [allowProviderRefresh] → se false legge solo cache già disponibile e
///   non chiama i provider esterni.
/// - [allowFallbackCache] → se false richiede la cache esatta dello scope.
///   Utile per il catalogo geografico centrale Globe/Civic Map.
///
/// Nota:
/// - [getNewsFeed] resta il percorso del feed cronologico
/// - [getTrendingCandidates] serve al ranking Trending e non deve applicare
///   ordinamento/paginazione cronologica anticipata
abstract class NewsRepository {
  Future<List<NewsItem>> getNewsFeed({
    String? countryCode,
    String? cityId,
    String? topic,
    String? language,
    int? limit,
    int? offset,
    bool allowProviderRefresh = false,
    bool allowFallbackCache = true,
  });

  Future<List<NewsItem>> getTrendingCandidates({
    String? countryCode,
    String? cityId,
    String? topic,
    String? language,
    int? limit,
  });

  Future<NewsItem> getNewsDetail(EntityId id);
}
