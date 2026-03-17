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

  static const int _providerWarmupBatchSize = 80;

  /// Budget più aggressivo per evitare attese troppo lunghe in mappa.
  static const int _maxArticlesToGeocodePerRefresh = 8;
  static const int _maxLocationCandidatesPerArticle = 3;
  static const int _targetResolvedLocationsPerRefresh = 8;

  static const Duration _perArticleGeocodeTimeout = Duration(seconds: 2);
  static const int _maxParallelGeocodeJobs = 6;

  static const Map<String, String> _countryAliases = <String, String>{
    'italy': 'IT',
    'france': 'FR',
    'germany': 'DE',
    'spain': 'ES',
    'portugal': 'PT',
    'netherlands': 'NL',
    'belgium': 'BE',
    'switzerland': 'CH',
    'austria': 'AT',
    'united states': 'US',
    'us': 'US',
    'usa': 'US',
    'u.s.': 'US',
    'u.s': 'US',
    'america': 'US',
    'united kingdom': 'GB',
    'uk': 'GB',
    'u.k.': 'GB',
    'u.k': 'GB',
    'england': 'GB',
    'canada': 'CA',
    'australia': 'AU',
    'iran': 'IR',
    'iraq': 'IQ',
    'israel': 'IL',
    'palestine': 'PS',
    'ukraine': 'UA',
    'russia': 'RU',
    'china': 'CN',
    'taiwan': 'TW',
    'japan': 'JP',
    'india': 'IN',
    'pakistan': 'PK',
    'turkey': 'TR',
    'türkiye': 'TR',
    'greece': 'GR',
    'egypt': 'EG',
    'libya': 'LY',
    'syria': 'SY',
    'lebanon': 'LB',
    'saudi arabia': 'SA',
    'qatar': 'QA',
    'united arab emirates': 'AE',
    'uae': 'AE',
    'sudan': 'SD',
    'ethiopia': 'ET',
    'somalia': 'SO',
    'kenya': 'KE',
    'nigeria': 'NG',
    'south africa': 'ZA',
    'brazil': 'BR',
    'argentina': 'AR',
    'mexico': 'MX',
  };

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
      /// 1) prova cache fresca
      final freshCache = await _readCache(
        cacheKey: candidate.cacheKey,
        acceptStale: false,
      );

      if (freshCache != null && freshCache.items.isNotEmpty) {
        if (_cacheHasResolvedLocations(freshCache.items)) {
          return _mapAndPaginate(
            jsonList: freshCache.items,
            countryCode: candidate.countryCode,
            cityId: candidate.cityId,
            limit: limit,
            offset: offset,
          );
        }

        if (kDebugMode) {
          debugPrint(
            'NewsRepositoryImpl fresh cache found for ${candidate.cacheKey} '
            'but it has no resolved locations, trying live refresh.',
          );
        }
      }

      /// 2) prova cache stale
      final staleCache = await _readCache(
        cacheKey: candidate.cacheKey,
        acceptStale: true,
      );

      if (staleCache != null && staleCache.items.isNotEmpty) {
        if (_cacheHasResolvedLocations(staleCache.items)) {
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

        if (kDebugMode) {
          debugPrint(
            'NewsRepositoryImpl stale cache found for ${candidate.cacheKey} '
            'but it has no resolved locations, trying live refresh.',
          );
        }
      }

      /// 3) se la cache non è mappa-ready, prova refresh live
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

      /// 4) fallback finale: se refresh non migliora, usa comunque la cache
      if (freshCache != null && freshCache.items.isNotEmpty) {
        if (kDebugMode) {
          debugPrint(
            'NewsRepositoryImpl fallback to fresh cache for '
            '${candidate.cacheKey} after refresh attempt.',
          );
        }

        return _mapAndPaginate(
          jsonList: freshCache.items,
          countryCode: candidate.countryCode,
          cityId: candidate.cityId,
          limit: limit,
          offset: offset,
        );
      }

      if (staleCache != null && staleCache.items.isNotEmpty) {
        if (kDebugMode) {
          debugPrint(
            'NewsRepositoryImpl fallback to stale cache for '
            '${candidate.cacheKey} after refresh attempt.',
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
        'NewsRepositoryImpl: no usable cache and refresh failed: '
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
    final previousCache = await _readCache(
      cacheKey: candidate.cacheKey,
      acceptStale: true,
    );

    final jsonList = await _aggregator.fetchNews(
      countryCode: candidate.countryCode,
      cityId: candidate.cityId,
      topic: candidate.topic,
      language: candidate.language,
      limit: providerLimit,
      offset: 0,
    );

    final normalized = _normalizeJsonList(jsonList);

    final seeded = _seedLocationsFromPreviousCache(
      normalized,
      previousCache?.items ?? const <Map<String, dynamic>>[],
    );

    final enriched = await _enrichItemsForCache(seeded);

    final stabilized = _preferStablePayload(
      refreshedItems: enriched,
      previousItems: previousCache?.items ?? const <Map<String, dynamic>>[],
    );

    await _writeCache(
      cacheKey: candidate.cacheKey,
      countryCode: candidate.countryCode,
      cityId: candidate.cityId,
      topic: candidate.topic,
      language: candidate.language,
      items: stabilized,
    );

    return stabilized;
  }

  Future<List<Map<String, dynamic>>> _enrichItemsForCache(
    List<Map<String, dynamic>> items,
  ) async {
    if (items.isEmpty) {
      return const <Map<String, dynamic>>[];
    }

    final output = items
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);

    var resolvedCount = 0;
    for (final item in output) {
      final existingLocation = _readEmbeddedContentLocation(item);
      if (existingLocation != null &&
          (existingLocation.hasExactPoint || existingLocation.hasCenter)) {
        resolvedCount += 1;
      }
    }

    if (resolvedCount >= _targetResolvedLocationsPerRefresh) {
      return List<Map<String, dynamic>>.unmodifiable(output);
    }

    final pendingJobs = <Future<void>>[];
    var scheduled = 0;
    var scheduledPotentialResolved = 0;

    Future<void> flushJobs() async {
      if (pendingJobs.isEmpty) return;
      await Future.wait(pendingJobs);
      pendingJobs.clear();
      scheduledPotentialResolved = 0;
    }

    for (int i = 0; i < output.length; i++) {
      final enriched = output[i];

      final existingLocation = _readEmbeddedContentLocation(enriched);
      if (existingLocation != null &&
          (existingLocation.hasExactPoint || existingLocation.hasCenter)) {
        continue;
      }

      if (scheduled >= _maxArticlesToGeocodePerRefresh) {
        continue;
      }

      if (resolvedCount + scheduledPotentialResolved >=
          _targetResolvedLocationsPerRefresh) {
        break;
      }

      final dto = _tryParseDto(enriched);
      if (dto == null) {
        continue;
      }

      scheduled += 1;
      scheduledPotentialResolved += 1;

      pendingJobs.add(() async {
        try {
          final detectedLocation = await _detectContentLocationForDto(dto)
              .timeout(_perArticleGeocodeTimeout);

          if (detectedLocation != null) {
            enriched['_sv_content_location'] = detectedLocation.toJson();
            resolvedCount += 1;
          }
        } catch (_) {
          // best effort
        }
      }());

      if (pendingJobs.length >= _maxParallelGeocodeJobs ||
          resolvedCount + scheduledPotentialResolved >=
              _targetResolvedLocationsPerRefresh) {
        await flushJobs();

        if (resolvedCount >= _targetResolvedLocationsPerRefresh) {
          break;
        }
      }
    }

    await flushJobs();

    return List<Map<String, dynamic>>.unmodifiable(output);
  }

  Future<ContentLocation?> _detectContentLocationForDto(NewsDto dto) async {
    final candidates = _extractLocationCandidates(dto);

    for (final candidate in candidates.take(_maxLocationCandidatesPerArticle)) {
      try {
        final seed = ContentLocation(
          source: ContentLocationSource.manual,
          countryCode: candidate.countryCode,
          cityName: candidate.isCountryOnly ? null : candidate.query,
        );

        final resolved = await _geocodingRepository.geocodeContentLocation(seed);

        if (resolved != null && (resolved.hasExactPoint || resolved.hasCenter)) {
          return resolved;
        }
      } catch (_) {
        // best effort
      }
    }

    return null;
  }

  List<_LocationCandidate> _extractLocationCandidates(NewsDto dto) {
    final scored = <String, _LocationCandidateAccumulator>{};

    void addCandidate(
      String query, {
      String? countryCode,
      required bool isCountryOnly,
      required int score,
    }) {
      final normalizedQuery = query.trim();
      if (normalizedQuery.isEmpty && countryCode == null) {
        return;
      }

      final key = isCountryOnly && countryCode != null
          ? 'country:$countryCode'
          : 'place:${normalizedQuery.toLowerCase()}|${countryCode ?? ''}';

      final existing = scored[key];
      if (existing == null) {
        scored[key] = _LocationCandidateAccumulator(
          query: normalizedQuery,
          countryCode: countryCode,
          isCountryOnly: isCountryOnly,
          score: score,
        );
        return;
      }

      existing.score += score;

      if (!existing.isCountryOnly && countryCode != null) {
        existing.countryCode ??= countryCode;
      }
    }

    void scanText(
      String? text, {
      required int phraseScore,
      required int leadPhraseBonus,
      required int countryScore,
      required int maxPhrases,
    }) {
      final cleaned = _stripHtml(text);
      if (cleaned.isEmpty) {
        return;
      }

      final countryHits = _extractCountryHits(cleaned);
      for (final hit in countryHits) {
        addCandidate(
          hit.label,
          countryCode: hit.countryCode,
          isCountryOnly: true,
          score: countryScore,
        );
      }

      final leadPhrases = _extractLeadLocationPhrases(cleaned);
      for (final phrase in leadPhrases.take(maxPhrases)) {
        final countryCode = _countryCodeForAlias(phrase);
        addCandidate(
          phrase,
          countryCode: countryCode,
          isCountryOnly: countryCode != null,
          score: phraseScore + leadPhraseBonus,
        );
      }

      final properNouns = _extractProperNounPhrases(cleaned);
      for (final phrase in properNouns.take(maxPhrases)) {
        final countryCode = _countryCodeForAlias(phrase);
        addCandidate(
          phrase,
          countryCode: countryCode,
          isCountryOnly: countryCode != null,
          score: phraseScore,
        );
      }
    }

    scanText(
      dto.title,
      phraseScore: 100,
      leadPhraseBonus: 25,
      countryScore: 110,
      maxPhrases: 8,
    );
    scanText(
      dto.description,
      phraseScore: 55,
      leadPhraseBonus: 20,
      countryScore: 70,
      maxPhrases: 5,
    );
    scanText(
      dto.content,
      phraseScore: 25,
      leadPhraseBonus: 10,
      countryScore: 35,
      maxPhrases: 4,
    );

    final blockedSources = <String>{};
    final normalizedSourceName = _normalizePhrase(dto.sourceName);
    final normalizedSourceId = _normalizePhrase(dto.sourceId);

    if (normalizedSourceName != null) {
      blockedSources.add(normalizedSourceName);
    }
    if (normalizedSourceId != null) {
      blockedSources.add(normalizedSourceId);
    }

    final candidates = scored.values
        .map(
          (item) => _LocationCandidate(
            query: item.query,
            countryCode: item.countryCode,
            isCountryOnly: item.isCountryOnly,
            score: item.score,
          ),
        )
        .where(
          (candidate) =>
              !blockedSources.contains(_normalizePhrase(candidate.query)),
        )
        .toList();

    candidates.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;

      if (a.isCountryOnly != b.isCountryOnly) {
        return a.isCountryOnly ? 1 : -1;
      }

      return a.query.length.compareTo(b.query.length);
    });

    return candidates;
  }

  List<String> _extractLeadLocationPhrases(String text) {
    final cleaned = text
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleaned.isEmpty) {
      return const <String>[];
    }

    final regex = RegExp(
      r"\b(?:in|at|from|near|inside|outside|around|across)\s+((?:[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'’\-]+|[A-Z]{2,})(?:\s+(?:[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'’\-]+|[A-Z]{2,})){0,2})\b",
    );

    final output = <String>[];
    final seen = <String>{};

    for (final match in regex.allMatches(cleaned)) {
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

  List<String> _extractProperNounPhrases(String text) {
    final cleaned = text
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleaned.isEmpty) {
      return const <String>[];
    }

    final regex = RegExp(
      r"\b((?:[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'’\-]+|[A-Z]{2,})(?:\s+(?:[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'’\-]+|[A-Z]{2,})){0,2})\b",
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

  List<_CountryHit> _extractCountryHits(String text) {
    final normalizedText = text.toLowerCase();
    final output = <_CountryHit>[];
    final seen = <String>{};

    final aliases = _countryAliases.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));

    for (final entry in aliases) {
      final pattern = RegExp(
        '(^|[^a-z])${RegExp.escape(entry.key)}([^a-z]|\$)',
      );

      if (!pattern.hasMatch(normalizedText)) {
        continue;
      }

      if (seen.add(entry.value)) {
        output.add(
          _CountryHit(
            label: entry.key,
            countryCode: entry.value,
          ),
        );
      }
    }

    return output;
  }

  String? _countryCodeForAlias(String phrase) {
    return _countryAliases[phrase.trim().toLowerCase()];
  }

  bool _looksLikeLocationPhrase(String phrase) {
    if (phrase.length < 2 || phrase.length > 50) {
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
      'Reuters',
      'Guardian',
      'Bloomberg',
      'CNN',
      'BBC',
      'Google',
      'Apple',
      'Microsoft',
      'Meta',
      'TikTok',
    };

    const blockedExactPhrases = <String>{
      'Associated Press',
      'Al Jazeera',
      'New York Times',
      'Washington Post',
      'Wall Street Journal',
      'Financial Times',
      'Fox News',
      'BBC News',
    };

    const blockedSuffixes = <String>{
      'Times',
      'News',
      'Post',
      'Journal',
      'Herald',
      'Media',
      'TV',
      'Today',
      'Online',
    };

    final parts = phrase.split(RegExp(r'\s+'));
    if (parts.length == 1 && blockedSingleWords.contains(parts.first)) {
      return false;
    }

    if (blockedExactPhrases.contains(phrase)) {
      return false;
    }

    if (parts.length >= 2 && blockedSuffixes.contains(parts.last)) {
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

  List<Map<String, dynamic>> _seedLocationsFromPreviousCache(
    List<Map<String, dynamic>> items,
    List<Map<String, dynamic>> previousItems,
  ) {
    if (items.isEmpty || previousItems.isEmpty) {
      return List<Map<String, dynamic>>.unmodifiable(
        items.map((item) => Map<String, dynamic>.from(item)).toList(),
      );
    }

    final previousLocationsByKey = <String, Map<String, dynamic>>{};

    for (final item in previousItems) {
      final key = _buildStableArticleKeyFromJson(item);
      final location = _readEmbeddedContentLocation(item);

      if (key == null || location == null) {
        continue;
      }

      if (!_hasResolvedLocation(location)) {
        continue;
      }

      previousLocationsByKey[key] = location.toJson();
    }

    final output = <Map<String, dynamic>>[];

    for (final item in items) {
      final copy = Map<String, dynamic>.from(item);
      final currentLocation = _readEmbeddedContentLocation(copy);

      if (currentLocation == null || !_hasResolvedLocation(currentLocation)) {
        final key = _buildStableArticleKeyFromJson(copy);
        final previousLocationJson =
            key == null ? null : previousLocationsByKey[key];

        if (previousLocationJson != null) {
          copy['_sv_content_location'] = previousLocationJson;
        }
      }

      output.add(copy);
    }

    return List<Map<String, dynamic>>.unmodifiable(output);
  }

  List<Map<String, dynamic>> _preferStablePayload({
    required List<Map<String, dynamic>> refreshedItems,
    required List<Map<String, dynamic>> previousItems,
  }) {
    final refreshedLocated = _countItemsWithResolvedLocation(refreshedItems);
    final previousLocated = _countItemsWithResolvedLocation(previousItems);

    if (refreshedLocated > 0) {
      return refreshedItems;
    }

    if (refreshedItems.isNotEmpty && previousLocated == 0) {
      return refreshedItems;
    }

    if (refreshedLocated == 0 && previousLocated > 0) {
      if (kDebugMode) {
        debugPrint(
          'NewsRepositoryImpl keeping previous cache payload because refreshed '
          'payload has no resolved locations.',
        );
      }

      return List<Map<String, dynamic>>.unmodifiable(
        previousItems
            .map((item) => Map<String, dynamic>.from(item))
            .toList(growable: false),
      );
    }

    return refreshedItems;
  }

  int _countItemsWithResolvedLocation(List<Map<String, dynamic>> items) {
    var count = 0;

    for (final item in items) {
      final location = _readEmbeddedContentLocation(item);
      if (location != null && _hasResolvedLocation(location)) {
        count += 1;
      }
    }

    return count;
  }

  bool _cacheHasResolvedLocations(List<Map<String, dynamic>> items) {
    return _countItemsWithResolvedLocation(items) > 0;
  }

  bool _hasResolvedLocation(ContentLocation location) {
    return location.hasExactPoint || location.hasCenter;
  }

  String? _buildStableArticleKeyFromJson(Map<String, dynamic> json) {
    final dto = _tryParseDto(json);
    if (dto == null) {
      return null;
    }

    return _buildStableArticleKeyFromDto(dto);
  }

  String _buildStableArticleKeyFromDto(NewsDto dto) {
    final url = dto.url.trim();
    if (url.isNotEmpty) {
      return 'url:${url.toLowerCase()}';
    }

    final rawId = dto.id.trim();
    if (rawId.isNotEmpty) {
      final source = (dto.sourceName ?? dto.sourceId ?? 'unknown').trim();
      return 'id:${source.toLowerCase()}:${rawId.toLowerCase()}';
    }

    final source = (dto.sourceName ?? dto.sourceId ?? 'unknown').trim();
    return 'title:${source.toLowerCase()}:${dto.title.trim().toLowerCase()}:${dto.publishedAt.toUtc().toIso8601String()}';
  }

  List<_NewsFeedCandidate> _buildCandidates({
    required String? countryCode,
    required String? cityId,
    required String? topic,
    required String? language,
  }) {
    return <_NewsFeedCandidate>[
      _NewsFeedCandidate(
        countryCode: countryCode,
        cityId: cityId,
        topic: topic,
        language: language,
      ),
    ];
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
    return trimmed.toLowerCase();
  }

  String? _normalizePhrase(String? value) {
    if (value == null) return null;
    final trimmed = value.trim().toLowerCase();
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

class _LocationCandidate {
  final String query;
  final String? countryCode;
  final bool isCountryOnly;
  final int score;

  const _LocationCandidate({
    required this.query,
    required this.countryCode,
    required this.isCountryOnly,
    required this.score,
  });
}

class _LocationCandidateAccumulator {
  final String query;
  String? countryCode;
  final bool isCountryOnly;
  int score;

  _LocationCandidateAccumulator({
    required this.query,
    required this.countryCode,
    required this.isCountryOnly,
    required this.score,
  });
}

class _CountryHit {
  final String label;
  final String countryCode;

  const _CountryHit({
    required this.label,
    required this.countryCode,
  });
}