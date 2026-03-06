import 'package:sociale_vote/domain/common/value_objects/entity_id.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/content/news/repositories/news_repository.dart';

import 'package:sociale_vote/infrastructure/news/aggregator/news_aggregator.dart';
import 'package:sociale_vote/infrastructure/news/models/news_dto.dart';
import 'package:sociale_vote/infrastructure/news/mappers/news_mapper.dart';

/// Implementazione HTTP di [NewsRepository] basata su aggregazione multi-provider.
class NewsRepositoryImpl implements NewsRepository {
  final NewsAggregator _aggregator;
  final NewsMapper _mapper;

  NewsRepositoryImpl(
    this._aggregator,
    this._mapper,
  );

  @override
  Future<List<NewsItem>> getNewsFeed({
    String? countryCode,
    String? cityId,
    String? topic,
    String? language, // ✅ parametro opzionale
    int? limit,
    int? offset,
  }) async {
    // Manteniamo lo scope effettivamente usato (serve per mapper/id/label coerenti)
    String? usedCountryCode = countryCode;
    String? usedCityId = cityId;

    // 1) Proviamo con lo scope richiesto (world/country/city)
    var jsonList = await _aggregator.fetchNews(
      countryCode: usedCountryCode,
      cityId: usedCityId,
      topic: topic,
      language: language, // ✅ pass-through
      limit: limit,
      offset: offset,
    );

    // 2) Empty-state intelligente (solo per city): fallback soft a country → world
    //    (non tocca UI: la UI vede "empty" solo se anche i fallback sono vuoti)
    if (jsonList.isEmpty && cityId != null) {
      // fallback a country (stesso paging)
      usedCountryCode = countryCode;
      usedCityId = null;

      jsonList = await _aggregator.fetchNews(
        countryCode: usedCountryCode,
        cityId: usedCityId,
        topic: topic,
        language: language, // ✅ pass-through anche nei fallback
        limit: limit,
        offset: offset,
      );

      // fallback a world
      if (jsonList.isEmpty) {
        usedCountryCode = null;
        usedCityId = null;

        jsonList = await _aggregator.fetchNews(
          countryCode: usedCountryCode,
          cityId: usedCityId,
          topic: topic,
          language: language, // ✅ pass-through anche nei fallback
          limit: limit,
          offset: offset,
        );
      }
    }

    // JSON → DTO → Domain
    final items = jsonList.map((json) {
      final dto = NewsDto.fromJson(json as Map<String, dynamic>);
      return _mapper.toDomain(
        dto,
        countryCode: usedCountryCode,
        cityId: usedCityId,
      );
    }).toList();

    // Garantiamo ordine per recency (publishedAt desc),
    // come si aspetta il NewsController in modalità "latest".
    items.sort(
      (a, b) => b.publishedAt.compareTo(a.publishedAt),
    );

    // Dedupe difensivo (alcuni provider possono ripetere risultati tra pagine in certe query).
    final seen = <String>{};
    final unique = <NewsItem>[];
    for (final item in items) {
      final key = item.id.value;
      if (seen.add(key)) {
        unique.add(item);
      }
    }

    return List<NewsItem>.unmodifiable(unique);
  }

  @override
  Future<NewsItem> getNewsDetail(EntityId id) async {
    final json = await _aggregator.fetchNewsDetail(id.value);
    final dto = NewsDto.fromJson(json);
    // Per il dettaglio non abbiamo più country/city dal backend,
    // li lasciamo null lato dominio.
    return _mapper.toDomain(dto);
  }
}