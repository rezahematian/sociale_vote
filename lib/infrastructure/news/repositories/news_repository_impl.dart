import 'package:flutter/foundation.dart';
import 'package:sociale_vote/core/supabase/supabase_client.dart';
import 'package:sociale_vote/domain/common/value_objects/entity_id.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/content/news/repositories/news_repository.dart';
import 'package:sociale_vote/domain/geo/repositories/geocoding_repository.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location_source.dart';

import 'package:sociale_vote/infrastructure/news/aggregator/news_aggregator.dart';
import 'package:sociale_vote/infrastructure/news/models/news_dto.dart';
import 'package:sociale_vote/infrastructure/news/mappers/news_mapper.dart';

class NewsRepositoryImpl implements NewsRepository {
  static const String _cacheTable = 'news_feed_cache';
  static const Duration _cacheTtl = Duration(minutes: 30);

  static const int _providerWarmupBatchSize = 50;

  /// Non geocodifichiamo tutti gli articoli di ogni refresh,
  /// per evitare costi/lentezza eccessivi.
  static const int _maxArticlesToGeocodePerRefresh = 15;
  static const int _maxLocationCandidatesPerArticle = 3;

  final NewsAggregator _aggregator;
  final NewsMapper _mapper;
  final GeocodingRepository _geocodingRepository;

  NewsRepositoryImpl(
    this._aggregator,
    this._mapper,
    this._geocodingRepository,
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

    // Fallback legacy: può funzionare solo se l'id coincide con quello provider.
    // Nella pratica il path migliore resta la cache.
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
    final enriched = await _enrichItemsForCache(normalized);

    await _writeCache(
      cacheKey: candidate.cacheKey,
      countryCode: candidate.countryCode,
      cityId: candidate.cityId,
      topic: candidate.topic,
      language: candidate.language,
      items: enriched,
    );

    return enriched;
  }

  Future<List<Map<String, dynamic>>> _enrichItemsForCache(
    List<Map<String, dynamic>> items,
  ) async {
    if (items.isEmpty) {
      return const <Map<String, dynamic>>[];
    }

    final output = <Map<String, dynamic>>[];
    var geocodedArticles = 0;

    for (final item in items) {
      final enriched = Map<String, dynamic>.from(item);

      final existingLocation = _readEmbeddedContentLocation(enriched);
      if (existingLocation != null) {
        output.add(enriched);
        continue;
      }

      if (geocodedArticles >= _maxArticlesToGeocodePerRefresh) {
        output.add(enriched);
        continue;
      }

      final dto = _tryParseDto(enriched);
      if (dto == null) {
        output.add(enriched);
        continue;
      }

      final detectedLocation = await _detectContentLocationForDto(dto);
      if (detectedLocation != null) {
        enriched['_sv_content_location'] = detectedLocation.toJson();
        geocodedArticles += 1;
      }

      output.add(enriched);
    }

    return List<Map<String, dynamic>>.unmodifiable(output);
  }

  Future<ContentLocation?> _detectContentLocationForDto(NewsDto dto) async {
    final candidates = _extractLocationCandidates(dto);

    for (final candidate in candidates.take(_maxLocationCandidatesPerArticle)) {
      try {
        final resolved = await _geocodingRepository.geocodeContentLocation(
          ContentLocation(
            source: ContentLocationSource.manual,
            cityName: candidate,
          ),
        );

        if (resolved != null && (resolved.hasExactPoint || resolved.hasCenter)) {
          return resolved;
        }
      } catch (_) {
        // best effort: ignoriamo singolo fallimento geocoding
      }
    }

    return null;
  }

  List<String> _extractLocationCandidates(NewsDto dto) {
    final ordered = <String>[];
    final seen = <String>{};

    void addCandidate(String value) {
      final normalized = value.trim();
      if (normalized.isEmpty) {
        return;
      }

      final signature = normalized.toLowerCase();
      if (seen.add(signature)) {
        ordered.add(normalized);
      }
    }

    void addFromText(String? text, {required int maxItems}) {
      if (text == null || text.trim().isEmpty) {
        return;
      }

      final phrases = _extractProperNounPhrases(text);
      for (final phrase in phrases.take(maxItems)) {
        addCandidate(phrase);
      }
    }

    addFromText(dto.title, maxItems: 6);
    addFromText(dto.description, maxItems: 4);
    addFromText(_stripHtml(dto.content), maxItems: 3);

    return ordered;
  }

  List<String> _extractProperNounPhrases(String text) {
    final cleaned = text
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleaned.isEmpty) {
      return const <String>[];
    }

    final regex = RegExp(
      r'\b([A-Z][a-z]+(?:\s+[A-Z][a-z]+){0,2})\b',
    );

    final matches = regex.allMatches(cleaned);
    final output = <String>[];
    final seen = <String>{};

    for (final match in matches) {
      final phrase = match.group(1);
      if (phrase == null) continue;

      final candidate = phrase.trim();
      if (!_looksLikeLocationPhrase(candidate)) {
        continue;
      }

      final signature = candidate.toLowerCase();
      if (seen.add(signature)) {
        output.add(candidate);
      }
    }

    return output;
  }

  bool _looksLikeLocationPhrase(String phrase) {
    if (phrase.length < 3 || phrase.length > 40) {
      return false;
    }

    if (RegExp(r'\d').hasMatch(phrase)) {
      return false;
    }

    const blockedSingleWords = <String>{
      'The',
      'Breaking',
      'Live',
      'Watch',
      'Video',
      'Opinion',
      'Analysis',
      'Explainer',
      'Update',
      'Updated',
      'Review',
      'News',
      'World',
      'Business',
      'Technology',
      'Sport',
      'Sports',
      'Politics',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
      'How',
      'Why',
      'What',
      'When',
      'Where',
      'Who',
      'This',
      'That',
      'These',
      'Those',
    };

    final parts = phrase.split(RegExp(r'\s+'));
    if (parts.length == 1 && blockedSingleWords.contains(parts.first)) {
      return false;
    }

    return true;
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
      final contentLocation = _readEmbeddedContentLocation(json);

      return _mapper.toDomain(
        dto,
        countryCode: countryCode,
        cityId: cityId,
        contentLocation: contentLocation,
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

  ContentLocation? _readEmbeddedContentLocation(Map<String, dynamic> json) {
    final raw = json['_sv_content_location'];

    if (raw is Map<String, dynamic>) {
      return ContentLocation.fromJson(raw);
    }

    if (raw is Map) {
      return ContentLocation.fromJson(
        raw.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      );
    }

    return null;
  }

  NewsDto? _tryParseDto(Map<String, dynamic> json) {
    try {
      return NewsDto.fromJson(json);
    } catch (_) {
      return null;
    }
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

  String _stripHtml(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }

    return value
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
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
