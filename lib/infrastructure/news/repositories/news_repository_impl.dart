import 'package:flutter/foundation.dart';
import 'package:sociale_vote/core/supabase/supabase_client.dart';
import 'package:sociale_vote/domain/common/value_objects/entity_id.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/content/news/repositories/news_repository.dart';

import 'package:sociale_vote/infrastructure/news/aggregator/news_aggregator.dart';
import 'package:sociale_vote/infrastructure/news/models/news_dto.dart';
import 'package:sociale_vote/infrastructure/news/mappers/news_mapper.dart';

/// Implementazione di [NewsRepository] con:
/// - aggregazione multi-provider
/// - cache Supabase
/// - TTL fisso a 30 minuti
/// - fallback a cache stale se i provider esterni falliscono
class NewsRepositoryImpl implements NewsRepository {
  static const String _cacheTable = 'news_feed_cache';
  static const Duration _cacheTtl = Duration(minutes: 30);

  /// Quanti articoli proviamo a salvare in cache per una singola fetch esterna.
  /// Serve a non richiamare le API ad ogni scroll/pagina.
  static const int _providerWarmupBatchSize = 50;

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
    String? language,
    int? limit,
    int? offset,
  }) async {
    final requestedCountryCode = _normalize(countryCode);
    final requestedCityId = _normalize(cityId);
    final requestedTopic = _normalize(topic);
    final requestedLanguage = _normalize(language);

    final candidates = _buildCandidates(
      countryCode: requestedCountryCode,
      cityId: requestedCityId,
      topic: requestedTopic,
      language: requestedLanguage,
    );

    Object? lastRefreshError;

    for (final candidate in candidates) {
      // 1) Cache fresca
      final freshCache = await _readCache(
        cacheKey: candidate.cacheKey,
        acceptStale: false,
      );

      if (freshCache != null && freshCache.items.isNotEmpty) {
        return _mapAndPaginate(
          jsonList: freshCache.items,
          countryCode: candidate.countryCode,
          cityId: candidate.cityId,
          limit: limit,
          offset: offset,
        );
      }

      // 2) Refresh esterno se cache non fresca / assente
      try {
        final refreshedItems = await _refreshCacheForCandidate(
          candidate,
          providerLimit: _resolveProviderFetchLimit(limit, offset),
        );

        if (refreshedItems.isNotEmpty) {
          return _mapAndPaginate(
            jsonList: refreshedItems,
            countryCode: candidate.countryCode,
            cityId: candidate.cityId,
            limit: limit,
            offset: offset,
          );
        }
      } catch (e, st) {
        lastRefreshError = e;

        if (kDebugMode) {
          debugPrint(
            'NewsRepositoryImpl refresh failed for ${candidate.cacheKey}: $e',
          );
          debugPrint('$st');
        }
      }

      // 3) Se refresh fallisce, prova cache stale
      final staleCache = await _readCache(
        cacheKey: candidate.cacheKey,
        acceptStale: true,
      );

      if (staleCache != null && staleCache.items.isNotEmpty) {
        if (kDebugMode) {
          debugPrint(
            'NewsRepositoryImpl using stale cache for ${candidate.cacheKey}',
          );
        }

        return _mapAndPaginate(
          jsonList: staleCache.items,
          countryCode: candidate.countryCode,
          cityId: candidate.cityId,
          limit: limit,
          offset: offset,
        );
      }
    }

    if (kDebugMode && lastRefreshError != null) {
      debugPrint(
        'NewsRepositoryImpl: no usable cache and all refresh attempts failed: '
        '$lastRefreshError',
      );
    }

    return const <NewsItem>[];
  }

  @override
  Future<NewsItem> getNewsDetail(EntityId id) async {
    final cached = await _findCachedNewsById(id.value);
    if (cached != null) {
      return cached;
    }

    final json = await _aggregator.fetchNewsDetail(id.value);
    final dto = NewsDto.fromJson(json);
    return _mapper.toDomain(dto);
  }

  Future<List<Map<String, dynamic>>> _refreshCacheForCandidate(
    _NewsFeedCandidate candidate, {
    required int providerLimit,
  }) async {
    final jsonList = await _aggregator.fetchNews(
      countryCode: candidate.countryCode,
      cityId: candidate.cityId,
      topic: candidate.topic,
      language: candidate.language,
      limit: providerLimit,
      offset: 0,
    );

    final normalized = _normalizeJsonList(jsonList);

    await _writeCache(
      cacheKey: candidate.cacheKey,
      countryCode: candidate.countryCode,
      cityId: candidate.cityId,
      topic: candidate.topic,
      language: candidate.language,
      items: normalized,
    );

    return normalized;
  }

  Future<_CachedNewsFeed?> _readCache({
    required String cacheKey,
    required bool acceptStale,
  }) async {
    try {
      final rows = await AppSupabase.client
          .from(_cacheTable)
          .select('cache_key, payload, refreshed_at')
          .eq('cache_key', cacheKey)
          .limit(1);

      if (rows.isEmpty) {
        return null;
      }

      final row = rows.first;
      if (row is! Map<String, dynamic>) {
        return null;
      }

      final refreshedAt = _parseDateTime(row['refreshed_at']);
      if (refreshedAt == null) {
        return null;
      }

      final payload = row['payload'];
      final items = _normalizeJsonList(payload is List ? payload : const []);

      final cache = _CachedNewsFeed(
        items: items,
        refreshedAt: refreshedAt,
      );

      if (!acceptStale && !cache.isFresh) {
        return null;
      }

      return cache;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('NewsRepositoryImpl cache read failed: $e');
        debugPrint('$st');
      }
      return null;
    }
  }

  Future<void> _writeCache({
    required String cacheKey,
    required String? countryCode,
    required String? cityId,
    required String? topic,
    required String? language,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      await AppSupabase.client.from(_cacheTable).upsert(
        {
          'cache_key': cacheKey,
          'country_code': countryCode,
          'city_id': cityId,
          'topic': topic,
          'language': language,
          'payload': items,
          'refreshed_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'cache_key',
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('NewsRepositoryImpl cache write failed: $e');
        debugPrint('$st');
      }
    }
  }

  Future<NewsItem?> _findCachedNewsById(String newsId) async {
    try {
      final rows = await AppSupabase.client
          .from(_cacheTable)
          .select('payload, country_code, city_id, refreshed_at')
          .order('refreshed_at', ascending: false)
          .limit(20);

      for (final row in rows) {
        if (row is! Map<String, dynamic>) {
          continue;
        }

        final payload = row['payload'];
        if (payload is! List) {
          continue;
        }

        final countryCode = _normalize(row['country_code']?.toString());
        final cityId = _normalize(row['city_id']?.toString());

        final mapped = _mapJsonToDomainList(
          _normalizeJsonList(payload),
          countryCode: countryCode,
          cityId: cityId,
        );

        for (final item in mapped) {
          if (item.id.value == newsId) {
            return item;
          }
        }
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('NewsRepositoryImpl detail cache lookup failed: $e');
        debugPrint('$st');
      }
    }

    return null;
  }

  List<NewsItem> _mapAndPaginate({
    required List<Map<String, dynamic>> jsonList,
    required String? countryCode,
    required String? cityId,
    int? limit,
    int? offset,
  }) {
    final mapped = _mapJsonToDomainList(
      jsonList,
      countryCode: countryCode,
      cityId: cityId,
    );

    if (mapped.isEmpty) {
      return const <NewsItem>[];
    }

    final safeOffset = offset ?? 0;
    final safeLimit = limit ?? mapped.length;

    if (safeOffset >= mapped.length) {
      return const <NewsItem>[];
    }

    final end = (safeOffset + safeLimit) > mapped.length
        ? mapped.length
        : (safeOffset + safeLimit);

    return List<NewsItem>.unmodifiable(mapped.sublist(safeOffset, end));
  }

  List<NewsItem> _mapJsonToDomainList(
    List<Map<String, dynamic>> jsonList, {
    required String? countryCode,
    required String? cityId,
  }) {
    final items = jsonList.map((json) {
      final dto = NewsDto.fromJson(json);
      return _mapper.toDomain(
        dto,
        countryCode: countryCode,
        cityId: cityId,
      );
    }).toList();

    items.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    final seen = <String>{};
    final unique = <NewsItem>[];

    for (final item in items) {
      final key = item.id.value;
      if (seen.add(key)) {
        unique.add(item);
      }
    }

    return unique;
  }

  List<Map<String, dynamic>> _normalizeJsonList(List<dynamic> rawList) {
    return rawList
        .whereType<Map>()
        .map(
          (json) => json.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        )
        .toList(growable: false);
  }

  List<_NewsFeedCandidate> _buildCandidates({
    required String? countryCode,
    required String? cityId,
    required String? topic,
    required String? language,
  }) {
    final candidates = <_NewsFeedCandidate>[
      _NewsFeedCandidate(
        countryCode: countryCode,
        cityId: cityId,
        topic: topic,
        language: language,
      ),
    ];

    // Manteniamo il comportamento esistente:
    // fallback soft solo per city -> country -> world.
    if (cityId != null) {
      candidates.add(
        _NewsFeedCandidate(
          countryCode: countryCode,
          cityId: null,
          topic: topic,
          language: language,
        ),
      );

      candidates.add(
        _NewsFeedCandidate(
          countryCode: null,
          cityId: null,
          topic: topic,
          language: language,
        ),
      );
    }

    return candidates;
  }

  int _resolveProviderFetchLimit(int? limit, int? offset) {
    final requestedLimit = limit ?? 20;
    final requestedOffset = offset ?? 0;
    final requestedSpan = requestedLimit + requestedOffset;

    if (requestedSpan > _providerWarmupBatchSize) {
      return requestedSpan;
    }

    return _providerWarmupBatchSize;
  }

  String? _normalize(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value.toUtc();
    }
    return DateTime.tryParse(value.toString())?.toUtc();
  }
}

class _NewsFeedCandidate {
  final String? countryCode;
  final String? cityId;
  final String? topic;
  final String? language;

  const _NewsFeedCandidate({
    required this.countryCode,
    required this.cityId,
    required this.topic,
    required this.language,
  });

  String get cacheKey {
    return [
      'country=${countryCode ?? '*'}',
      'city=${cityId ?? '*'}',
      'topic=${topic ?? '*'}',
      'language=${language ?? '*'}',
    ].join('|');
  }
}

class _CachedNewsFeed {
  final List<Map<String, dynamic>> items;
  final DateTime refreshedAt;

  const _CachedNewsFeed({
    required this.items,
    required this.refreshedAt,
  });

  bool get isFresh {
    final now = DateTime.now().toUtc();
    return now.difference(refreshedAt) < NewsRepositoryImpl._cacheTtl;
  }
}
