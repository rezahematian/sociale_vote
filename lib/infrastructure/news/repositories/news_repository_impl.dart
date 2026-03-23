import 'package:flutter/foundation.dart';
import 'package:sociale_vote/core/supabase/supabase_client.dart';
import 'package:sociale_vote/domain/common/value_objects/entity_id.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/content/news/repositories/news_repository.dart';
import 'package:sociale_vote/domain/geo/repositories/geocoding_repository.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location_source.dart';

import 'package:sociale_vote/infrastructure/news/aggregator/news_aggregator.dart';
import 'package:sociale_vote/infrastructure/news/mappers/news_mapper.dart';
import 'package:sociale_vote/infrastructure/news/models/news_dto.dart';

class NewsRepositoryImpl implements NewsRepository {
  static const String _cacheTable = 'news_feed_cache';
  static const Duration _cacheTtl = Duration(minutes: 30);
  static const Duration _refreshFailureCooldown = Duration(minutes: 5);
  static const int _cachePayloadVersion = 2;

  static const int _providerWarmupBatchSize = 80;

  /// Budget più aggressivo per evitare attese troppo lunghe in mappa.
  static const int _maxArticlesToGeocodePerRefresh = 8;
  static const int _maxLocationCandidatesPerArticle = 3;
  static const int _targetResolvedLocationsPerRefresh = 8;

  static const Duration _perArticleGeocodeTimeout = Duration(seconds: 2);
  static const int _maxParallelGeocodeJobs = 6;

  static const String _locationLeadPrepositionPattern =
      r'(?:in|at|from|near|inside|outside|around|across|a|ad|da|nel|nella|nelle|nei|presso)';

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
  final Map<String, Future<List<Map<String, dynamic>>>> _inFlightRefreshes =
      <String, Future<List<Map<String, dynamic>>>>{};
  final Map<String, DateTime> _refreshCooldownUntilByCacheKey =
      <String, DateTime>{};

  NewsRepositoryImpl(
    this._aggregator,
    this._mapper,
    this._geocodingRepository,
  );

  Future<int> refreshNewsFeedCache({
    String? countryCode,
    String? cityId,
    String? topic,
    String? language,
    int? providerLimit,
  }) async {
    final requestedCountryCode = _normalize(countryCode);
    final requestedCityId = _normalize(cityId);
    final requestedTopic = _normalize(topic);
    final requestedLanguage = _normalizeLanguageCode(language);

    final candidate = _NewsFeedCandidate(
      countryCode: requestedCountryCode,
      cityId: requestedCityId,
      topic: requestedTopic,
      language: requestedLanguage,
    );

    final refreshedItems = await _refreshCacheForCandidateDeduplicated(
      candidate,
      providerLimit: _resolveProviderFetchLimit(providerLimit, 0),
      allowStalePreviousCache: _shouldAllowStaleCache(candidate.language),
    );

    return refreshedItems.length;
  }

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
    final requestedLanguage = _normalizeLanguageCode(language);

    final candidate = _NewsFeedCandidate(
      countryCode: requestedCountryCode,
      cityId: requestedCityId,
      topic: requestedTopic,
      language: requestedLanguage,
    );

    final allowStaleCache = _shouldAllowStaleCache(requestedLanguage);
    Object? lastRefreshError;

    final freshCache = await _readCache(
      cacheKey: candidate.cacheKey,
      acceptStale: false,
      requestedLanguage: candidate.language,
    );

    final hasFreshCache = freshCache != null && freshCache.items.isNotEmpty;

    if (hasFreshCache) {
      return _mapCandidatePage(
        candidate,
        freshCache.items,
        limit: limit,
        offset: offset,
      );
    }

    final staleCache = allowStaleCache
        ? await _readCache(
            cacheKey: candidate.cacheKey,
            acceptStale: true,
            requestedLanguage: candidate.language,
          )
        : null;

    final usableStaleCache =
        staleCache != null &&
                _canUseStaleFallbackCache(
                  staleCache,
                  requestedLanguage: candidate.language,
                )
            ? staleCache
            : null;

    if (staleCache != null && usableStaleCache == null && kDebugMode) {
      debugPrint(
        'NewsRepositoryImpl stale cache rejected for ${candidate.cacheKey} '
        'because language/provider coherence is not reliable.',
      );
    }

    if (usableStaleCache != null && usableStaleCache.items.isNotEmpty) {
      if (kDebugMode) {
        debugPrint(
          'NewsRepositoryImpl serving same-language stale cache for '
          '${candidate.cacheKey}.',
        );
      }

      return _mapCandidatePage(
        candidate,
        usableStaleCache.items,
        limit: limit,
        offset: offset,
      );
    }

    final sameLanguageEquivalentCandidates =
        _buildSameLanguageEquivalentCandidates(candidate);

    final sameLanguageEquivalentFreshHit =
        await _readFirstSameLanguageEquivalentCache(
      candidates: sameLanguageEquivalentCandidates,
      acceptStale: false,
      requestedLanguage: candidate.language,
    );

    if (sameLanguageEquivalentFreshHit != null &&
        sameLanguageEquivalentFreshHit.cache.items.isNotEmpty) {
      if (kDebugMode) {
        debugPrint(
          'NewsRepositoryImpl serving same-language equivalent fresh cache '
          'from ${sameLanguageEquivalentFreshHit.candidate.cacheKey} for '
          '${candidate.cacheKey}.',
        );
      }

      return _mapCandidatePage(
        candidate,
        sameLanguageEquivalentFreshHit.cache.items,
        limit: limit,
        offset: offset,
      );
    }

    final sameLanguageEquivalentStaleHit = allowStaleCache
        ? await _readFirstSameLanguageEquivalentCache(
            candidates: sameLanguageEquivalentCandidates,
            acceptStale: true,
            requestedLanguage: candidate.language,
          )
        : null;

    final usableSameLanguageEquivalentStaleHit =
        sameLanguageEquivalentStaleHit != null &&
                _canUseStaleFallbackCache(
                  sameLanguageEquivalentStaleHit.cache,
                  requestedLanguage: candidate.language,
                )
            ? sameLanguageEquivalentStaleHit
            : null;

    if (usableSameLanguageEquivalentStaleHit != null &&
        usableSameLanguageEquivalentStaleHit.cache.items.isNotEmpty) {
      if (kDebugMode) {
        debugPrint(
          'NewsRepositoryImpl serving same-language equivalent stale cache '
          'from ${usableSameLanguageEquivalentStaleHit.candidate.cacheKey} '
          'for ${candidate.cacheKey}.',
        );
      }

      return _mapCandidatePage(
        candidate,
        usableSameLanguageEquivalentStaleHit.cache.items,
        limit: limit,
        offset: offset,
      );
    }

    if (_isRefreshCooldownActive(candidate.cacheKey)) {
      if (kDebugMode) {
        debugPrint(
          'NewsRepositoryImpl skipping live refresh for ${candidate.cacheKey} '
          'because failure cooldown is active.',
        );
      }

      if (requestedLanguage != null && requestedLanguage != 'en') {
        final englishFallbackItems = await _tryEnglishFallbackPage(
          countryCode: requestedCountryCode,
          cityId: requestedCityId,
          topic: requestedTopic,
          limit: limit,
          offset: offset,
        );

        if (englishFallbackItems.isNotEmpty) {
          return englishFallbackItems;
        }
      }

      return const <NewsItem>[];
    }

    try {
      final refreshedItems = await _refreshCacheForCandidateDeduplicated(
        candidate,
        providerLimit: _resolveProviderFetchLimit(limit, offset),
        allowStalePreviousCache: allowStaleCache,
      );

      if (refreshedItems.isNotEmpty) {
        return _mapCandidatePage(
          candidate,
          refreshedItems,
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

    if (requestedLanguage != null && requestedLanguage != 'en') {
      final englishFallbackItems = await _tryEnglishFallbackPage(
        countryCode: requestedCountryCode,
        cityId: requestedCityId,
        topic: requestedTopic,
        limit: limit,
        offset: offset,
      );

      if (englishFallbackItems.isNotEmpty) {
        return englishFallbackItems;
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

  Future<List<NewsItem>> _tryEnglishFallbackPage({
    required String? countryCode,
    required String? cityId,
    required String? topic,
    int? limit,
    int? offset,
  }) async {
    final fallbackCandidate = _NewsFeedCandidate(
      countryCode: countryCode,
      cityId: cityId,
      topic: topic,
      language: 'en',
    );

    if (kDebugMode) {
      debugPrint(
        'NewsRepositoryImpl trying explicit English fallback via '
        '${fallbackCandidate.cacheKey}.',
      );
    }

    final freshCache = await _readCache(
      cacheKey: fallbackCandidate.cacheKey,
      acceptStale: false,
      requestedLanguage: fallbackCandidate.language,
    );

    if (freshCache != null && freshCache.items.isNotEmpty) {
      if (kDebugMode) {
        debugPrint(
          'NewsRepositoryImpl serving explicit English fallback from fresh '
          'cache for ${fallbackCandidate.cacheKey}.',
        );
      }

      return _mapCandidatePage(
        fallbackCandidate,
        freshCache.items,
        limit: limit,
        offset: offset,
      );
    }

    final staleCache = await _readCache(
      cacheKey: fallbackCandidate.cacheKey,
      acceptStale: true,
      requestedLanguage: fallbackCandidate.language,
    );

    final usableStaleCache =
        staleCache != null &&
                _canUseStaleFallbackCache(
                  staleCache,
                  requestedLanguage: fallbackCandidate.language,
                )
            ? staleCache
            : null;

    if (usableStaleCache != null && usableStaleCache.items.isNotEmpty) {
      if (kDebugMode) {
        debugPrint(
          'NewsRepositoryImpl serving explicit English fallback from stale '
          'cache for ${fallbackCandidate.cacheKey}.',
        );
      }

      return _mapCandidatePage(
        fallbackCandidate,
        usableStaleCache.items,
        limit: limit,
        offset: offset,
      );
    }

    return const <NewsItem>[];
  }

  Future<List<Map<String, dynamic>>> _refreshCacheForCandidateDeduplicated(
    _NewsFeedCandidate candidate, {
    required int providerLimit,
    required bool allowStalePreviousCache,
  }) {
    final existing = _inFlightRefreshes[candidate.cacheKey];
    if (existing != null) {
      if (kDebugMode) {
        debugPrint(
          'NewsRepositoryImpl joining in-flight refresh for '
          '${candidate.cacheKey}.',
        );
      }
      return existing;
    }

    final future = _refreshCacheForCandidate(
      candidate,
      providerLimit: providerLimit,
      allowStalePreviousCache: allowStalePreviousCache,
    );

    _inFlightRefreshes[candidate.cacheKey] = future;

    future.whenComplete(() {
      final current = _inFlightRefreshes[candidate.cacheKey];
      if (identical(current, future)) {
        _inFlightRefreshes.remove(candidate.cacheKey);
      }
    });

    return future;
  }

  Future<List<Map<String, dynamic>>> _refreshCacheForCandidate(
    _NewsFeedCandidate candidate, {
    required int providerLimit,
    required bool allowStalePreviousCache,
  }) async {
    final previousCache = await _readCache(
      cacheKey: candidate.cacheKey,
      acceptStale: allowStalePreviousCache,
      requestedLanguage: candidate.language,
    );

    List<dynamic> jsonList;
    try {
      jsonList = await _aggregator.fetchNews(
        countryCode: candidate.countryCode,
        cityId: candidate.cityId,
        topic: candidate.topic,
        language: candidate.language,
        limit: providerLimit,
        offset: 0,
      );
    } catch (e) {
      _markRefreshCooldown(
        candidate.cacheKey,
        reason: 'live refresh threw an exception',
      );
      rethrow;
    }

    final rawNormalized = _normalizeJsonList(jsonList);
    final languageFiltered = _filterItemsForRequestedLanguage(
      rawNormalized,
      candidate.language,
    );
    final livePayloadRejectedByLanguage =
        candidate.language != null &&
        rawNormalized.isNotEmpty &&
        languageFiltered.isEmpty;

    if (kDebugMode && livePayloadRejectedByLanguage) {
      debugPrint(
        'NewsRepositoryImpl live payload rejected for ${candidate.cacheKey} '
        'because no items passed the language coherence filter.',
      );
    }

    final normalized = _deduplicateJsonListByStableIdentity(languageFiltered);

    final previousItems = previousCache?.items ?? const <Map<String, dynamic>>[];

    final seeded = _seedLocationsFromPreviousCache(
      normalized,
      previousItems,
    );

    final enriched = await _enrichItemsForCache(seeded);

    final stabilized = _preferStablePayload(
      refreshedItems: enriched,
      previousItems: previousItems,
    );

    final refreshedLocated = _countItemsWithResolvedLocation(enriched);
    final previousLocated = _countItemsWithResolvedLocation(previousItems);

    final shouldPersistRefresh =
        !livePayloadRejectedByLanguage &&
        enriched.isNotEmpty &&
        (refreshedLocated > 0 || previousLocated == 0);

    if (shouldPersistRefresh) {
      await _writeCache(
        cacheKey: candidate.cacheKey,
        countryCode: candidate.countryCode,
        cityId: candidate.cityId,
        topic: candidate.topic,
        language: candidate.language,
        items: stabilized,
      );

      await _writeCanonicalGlobalAllAliasIfNeeded(
        sourceCandidate: candidate,
        items: stabilized,
      );

      if (refreshedLocated > 0) {
        _clearRefreshCooldown(candidate.cacheKey);
      } else {
        _markRefreshCooldown(
          candidate.cacheKey,
          reason: 'live payload persisted without resolved locations',
        );
      }
    } else {
      final reason = livePayloadRejectedByLanguage
          ? 'live payload rejected by language coherence filter'
          : enriched.isEmpty
              ? 'live payload empty after normalization'
              : 'live payload lost resolved locations compared with previous cache';

      _markRefreshCooldown(candidate.cacheKey, reason: reason);
    }

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
    var hasReevaluationCandidates = false;

    for (final item in output) {
      final existingLocation = _readEmbeddedContentLocation(item);
      if (existingLocation != null &&
          (existingLocation.hasExactPoint || existingLocation.hasCenter)) {
        resolvedCount += 1;

        final dto = _tryParseDto(item);
        if (dto != null &&
            _shouldReevaluateExistingLocation(dto, existingLocation)) {
          hasReevaluationCandidates = true;
        }
      }
    }

    if (resolvedCount >= _targetResolvedLocationsPerRefresh &&
        !hasReevaluationCandidates) {
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
      final dto = _tryParseDto(enriched);
      if (dto == null) {
        continue;
      }

      final existingLocation = _readEmbeddedContentLocation(enriched);
      final hasResolvedLocation = existingLocation != null &&
          (existingLocation.hasExactPoint || existingLocation.hasCenter);

      final shouldReevaluate = hasResolvedLocation &&
          _shouldReevaluateExistingLocation(dto, existingLocation);

      if (hasResolvedLocation && !shouldReevaluate) {
        continue;
      }

      if (scheduled >= _maxArticlesToGeocodePerRefresh) {
        continue;
      }

      if (!hasResolvedLocation &&
          resolvedCount + scheduledPotentialResolved >=
              _targetResolvedLocationsPerRefresh) {
        break;
      }

      scheduled += 1;
      if (!hasResolvedLocation) {
        scheduledPotentialResolved += 1;
      }

      pendingJobs.add(() async {
        try {
          final detectedLocation = await _detectContentLocationForDto(
            dto,
            rawJson: enriched,
            ignorePreferredSeed: shouldReevaluate,
          ).timeout(_perArticleGeocodeTimeout);

          if (detectedLocation != null) {
            enriched['_sv_content_location'] = detectedLocation.toJson();

            if (!hasResolvedLocation) {
              resolvedCount += 1;
            }
          }
        } catch (_) {
          // best effort
        }
      }());

      if (pendingJobs.length >= _maxParallelGeocodeJobs ||
          resolvedCount + scheduledPotentialResolved >=
              _targetResolvedLocationsPerRefresh) {
        await flushJobs();
      }
    }

    await flushJobs();

    return List<Map<String, dynamic>>.unmodifiable(output);
  }

  Future<ContentLocation?> _detectContentLocationForDto(
    NewsDto dto, {
    Map<String, dynamic>? rawJson,
    bool ignorePreferredSeed = false,
  }) async {
    final preferredSeed = ignorePreferredSeed || rawJson == null
        ? null
        : _buildPreferredSeedContentLocationFromJson(rawJson);

    if (preferredSeed != null) {
      final resolvedFromSeed = await _tryResolveContentLocationSeed(
        preferredSeed,
      );
      if (resolvedFromSeed != null) {
        return resolvedFromSeed;
      }
    }

    final candidates = _extractLocationCandidates(dto);

    for (final candidate in candidates.take(_maxLocationCandidatesPerArticle)) {
      final cityOrCountrySeed = ContentLocation(
        source: ContentLocationSource.manual,
        countryCode: candidate.countryCode,
        cityName: candidate.isCountryOnly ? null : candidate.query,
      );

      final resolvedCandidate = await _tryResolveContentLocationSeed(
        cityOrCountrySeed,
      );

      if (resolvedCandidate != null) {
        return resolvedCandidate;
      }

      if (!candidate.isCountryOnly && candidate.countryCode != null) {
        final countryFallback = ContentLocation(
          source: ContentLocationSource.manual,
          countryCode: candidate.countryCode,
          cityName: null,
        );

        final resolvedCountryFallback = await _tryResolveContentLocationSeed(
          countryFallback,
        );

        if (resolvedCountryFallback != null) {
          return resolvedCountryFallback;
        }
      }
    }

    return null;
  }

  Future<ContentLocation?> _tryResolveContentLocationSeed(
    ContentLocation seed,
  ) async {
    try {
      final resolved = await _geocodingRepository.geocodeContentLocation(seed);

      if (resolved != null && (resolved.hasExactPoint || resolved.hasCenter)) {
        return resolved;
      }
    } catch (_) {
      // best effort
    }

    return null;
  }

  ContentLocation? _buildPreferredSeedContentLocationFromJson(
    Map<String, dynamic> json,
  ) {
    final embedded = _readKnownContentLocation(json);
    if (embedded != null) {
      return embedded;
    }

    return _buildFlatSeedContentLocationFromJson(json);
  }

  ContentLocation? _buildFlatSeedContentLocationFromJson(
    Map<String, dynamic> json,
  ) {
    final countryCode = _firstNonEmptyString(
      json,
      const <String>[
        'country_code',
        'countryCode',
        'country',
        'country_name',
        'countryName',
      ],
    );

    final cityName = _firstNonEmptyString(
      json,
      const <String>[
        'city',
        'city_name',
        'cityName',
        'location_name',
        'locationName',
      ],
    );

    final normalizedCountryCode = countryCode == null
        ? null
        : (_countryCodeForAlias(countryCode) ?? countryCode.toUpperCase());

    final normalizedCityName = cityName?.trim();

    if ((normalizedCountryCode == null || normalizedCountryCode.isEmpty) &&
        (normalizedCityName == null || normalizedCityName.isEmpty)) {
      return null;
    }

    return ContentLocation(
      source: ContentLocationSource.manual,
      countryCode: normalizedCountryCode,
      cityName: normalizedCityName,
    );
  }

  String? _firstNonEmptyString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) {
        continue;
      }

      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
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
      required bool prioritizePrimaryLead,
    }) {
      final cleaned = _stripHtml(text);
      if (cleaned.isEmpty) {
        return;
      }

      final openingWindow = _extractPrimaryLocationWindow(
        cleaned,
        maxLength: prioritizePrimaryLead ? 180 : 220,
      );

      final analysisText = openingWindow.isEmpty ? cleaned : openingWindow;

      final datelinePair = _extractDatelineLocationPair(analysisText);
      if (datelinePair != null) {
        addCandidate(
          datelinePair.cityName,
          countryCode: datelinePair.countryCode,
          isCountryOnly: false,
          score: prioritizePrimaryLead ? phraseScore + 120 : phraseScore + 70,
        );

        addCandidate(
          datelinePair.countryName,
          countryCode: datelinePair.countryCode,
          isCountryOnly: true,
          score: prioritizePrimaryLead ? countryScore + 20 : countryScore,
        );
      }

      final pairedLocations = _extractCityCountryPairs(analysisText);
      for (final pair in pairedLocations.take(prioritizePrimaryLead ? 3 : 2)) {
        addCandidate(
          pair.cityName,
          countryCode: pair.countryCode,
          isCountryOnly: false,
          score: prioritizePrimaryLead
              ? phraseScore + leadPhraseBonus + 70
              : phraseScore + leadPhraseBonus + 30,
        );

        addCandidate(
          pair.countryName,
          countryCode: pair.countryCode,
          isCountryOnly: true,
          score: prioritizePrimaryLead ? countryScore + 20 : countryScore,
        );
      }

      final primaryLeadPhrases = _extractPrimaryLocationPhrases(analysisText);
      for (final phrase in primaryLeadPhrases.take(3)) {
        final countryCode = _countryCodeForAlias(phrase);
        addCandidate(
          phrase,
          countryCode: countryCode,
          isCountryOnly: countryCode != null,
          score: prioritizePrimaryLead
              ? phraseScore + leadPhraseBonus + 80
              : phraseScore + leadPhraseBonus + 35,
        );
      }

      final countryHits = _extractCountryHits(analysisText);
      for (final hit in countryHits) {
        addCandidate(
          hit.label,
          countryCode: hit.countryCode,
          isCountryOnly: true,
          score: countryScore,
        );
      }

      final leadPhrases = _extractLeadLocationPhrases(analysisText);
      for (final phrase in leadPhrases.take(maxPhrases)) {
        final countryCode = _countryCodeForAlias(phrase);
        addCandidate(
          phrase,
          countryCode: countryCode,
          isCountryOnly: countryCode != null,
          score: phraseScore + leadPhraseBonus,
        );
      }

      final properNouns = _extractProperNounPhrases(analysisText);
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
      prioritizePrimaryLead: true,
    );
    scanText(
      dto.description,
      phraseScore: 55,
      leadPhraseBonus: 20,
      countryScore: 70,
      maxPhrases: 5,
      prioritizePrimaryLead: false,
    );
    scanText(
      dto.content,
      phraseScore: 25,
      leadPhraseBonus: 10,
      countryScore: 35,
      maxPhrases: 4,
      prioritizePrimaryLead: false,
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

    var candidates = scored.values
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

    candidates = _rebalanceCountryVsCityCandidates(candidates);

    candidates.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;

      if (a.isCountryOnly != b.isCountryOnly) {
        return a.isCountryOnly ? 1 : -1;
      }

      final aHasCountryHint = a.countryCode != null && !a.isCountryOnly;
      final bHasCountryHint = b.countryCode != null && !b.isCountryOnly;
      if (aHasCountryHint != bHasCountryHint) {
        return aHasCountryHint ? -1 : 1;
      }

      return a.query.length.compareTo(b.query.length);
    });

    return candidates;
  }

  String _extractPrimaryLocationWindow(
    String text, {
    required int maxLength,
  }) {
    final cleaned = _stripHtml(text);
    if (cleaned.isEmpty) {
      return '';
    }

    final window = cleaned.length <= maxLength
        ? cleaned
        : cleaned.substring(0, maxLength);

    for (final match in RegExp(r'[.!?;]').allMatches(window)) {
      if (match.start >= 40) {
        return window.substring(0, match.start).trim();
      }
    }

    return window.trim();
  }

  List<_LocationCandidate> _rebalanceCountryVsCityCandidates(
    List<_LocationCandidate> candidates,
  ) {
    if (candidates.isEmpty) {
      return const <_LocationCandidate>[];
    }

    final bestCityScoreByCountry = <String, int>{};

    for (final candidate in candidates) {
      if (candidate.isCountryOnly || candidate.countryCode == null) {
        continue;
      }

      final countryCode = candidate.countryCode!;
      final currentBest = bestCityScoreByCountry[countryCode];

      if (currentBest == null || candidate.score > currentBest) {
        bestCityScoreByCountry[countryCode] = candidate.score;
      }
    }

    return candidates.map((candidate) {
      if (!candidate.isCountryOnly || candidate.countryCode == null) {
        return candidate;
      }

      final bestCityScore = bestCityScoreByCountry[candidate.countryCode!];
      if (bestCityScore == null) {
        return candidate;
      }

      var adjustedScore = candidate.score - 40;

      if (bestCityScore >= candidate.score - 10) {
        adjustedScore -= 20;
      }

      return _LocationCandidate(
        query: candidate.query,
        countryCode: candidate.countryCode,
        isCountryOnly: candidate.isCountryOnly,
        score: adjustedScore,
      );
    }).toList(growable: false);
  }

  _DatelineLocationPair? _extractDatelineLocationPair(String text) {
    final cleaned = text
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleaned.isEmpty) {
      return null;
    }

    final openingWindow = cleaned.length <= 120
        ? cleaned
        : cleaned.substring(0, 120);

    final regex = RegExp(
      r"^\s*((?:[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'’\-]+|[A-Z]{2,})(?:\s+(?:[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'’\-]+|[A-Z]{2,})){0,2})\s*,\s*((?:[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'’\-]+|[A-Z]{2,})(?:\s+(?:[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'’\-]+|[A-Z]{2,})){0,2})\s*(?:-|—|:)",
    );

    final match = regex.firstMatch(openingWindow);
    if (match == null) {
      return null;
    }

    final cityName = match.group(1)?.trim();
    final countryName = match.group(2)?.trim();

    if (cityName == null ||
        countryName == null ||
        !_looksLikeLocationPhrase(cityName) ||
        !_looksLikeLocationPhrase(countryName)) {
      return null;
    }

    final countryCode = _countryCodeForAlias(countryName);
    if (countryCode == null) {
      return null;
    }

    return _DatelineLocationPair(
      cityName: cityName,
      countryName: countryName,
      countryCode: countryCode,
    );
  }

  List<_DatelineLocationPair> _extractCityCountryPairs(String text) {
    final cleaned = text
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleaned.isEmpty) {
      return const <_DatelineLocationPair>[];
    }

    final regex = RegExp(
      r"\b((?:[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'’\-]+|[A-Z]{2,})(?:\s+(?:[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'’\-]+|[A-Z]{2,})){0,2})\s*,\s*((?:[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'’\-]+|[A-Z]{2,})(?:\s+(?:[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'’\\-]+|[A-Z]{2,})){0,2})\b",
    );

    final output = <_DatelineLocationPair>[];
    final seen = <String>{};

    for (final match in regex.allMatches(cleaned)) {
      final cityName = match.group(1)?.trim();
      final countryName = match.group(2)?.trim();

      if (cityName == null ||
          countryName == null ||
          !_looksLikeLocationPhrase(cityName) ||
          !_looksLikeLocationPhrase(countryName)) {
        continue;
      }

      final countryCode = _countryCodeForAlias(countryName);
      if (countryCode == null) {
        continue;
      }

      if (_countryCodeForAlias(cityName) != null) {
        continue;
      }

      final signature = '${cityName.toLowerCase()}|$countryCode';
      if (!seen.add(signature)) {
        continue;
      }

      output.add(
        _DatelineLocationPair(
          cityName: cityName,
          countryName: countryName,
          countryCode: countryCode,
        ),
      );
    }

    return output;
  }

  List<String> _extractPrimaryLocationPhrases(String text) {
    final cleaned = text
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleaned.isEmpty) {
      return const <String>[];
    }

    final output = <String>[];
    final seen = <String>{};

    void addIfValid(String? phrase) {
      if (phrase == null) return;
      final candidate = phrase.trim();
      if (!_looksLikeLocationPhrase(candidate)) {
        return;
      }

      final signature = candidate.toLowerCase();
      if (seen.add(signature)) {
        output.add(candidate);
      }
    }

    final openingWindow = cleaned.length <= 160
        ? cleaned
        : cleaned.substring(0, 160);

    final datelineRegex = RegExp(
      r"^\s*((?:[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'’\-]+|[A-Z]{2,})(?:\s+(?:[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'’\-]+|[A-Z]{2,})){0,2})(?:,\s*((?:[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'’\-]+|[A-Z]{2,})(?:\s+(?:[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'’\-]+|[A-Z]{2,})){0,2}))?\s*(?:-|—|:)",
    );

    final datelineMatch = datelineRegex.firstMatch(openingWindow);
    if (datelineMatch != null) {
      addIfValid(datelineMatch.group(1));
      addIfValid(datelineMatch.group(2));
    }

    final segmentRegex = RegExp(r'^(.{0,80}?)(?:\s[-—:]\s|,\s)');
    final segmentMatch = segmentRegex.firstMatch(openingWindow);
    if (segmentMatch != null) {
      final segment = segmentMatch.group(1)?.trim();
      if (segment != null && segment.isNotEmpty) {
        for (final phrase in _extractLeadLocationPhrases(segment)) {
          addIfValid(phrase);
        }
        for (final phrase in _extractProperNounPhrases(segment).take(2)) {
          addIfValid(phrase);
        }
      }
    }

    final openingPrepositionRegex = RegExp(
      '^(?:$_locationLeadPrepositionPattern)\\s+((?:[A-Z][A-Za-zÀ-ÖØ-öø-ÿ\'’\\-]+|[A-Z]{2,})(?:\\s+(?:[A-Z][A-Za-zÀ-ÖØ-öø-ÿ\'’\\-]+|[A-Z]{2,})){0,2})\\b',
    );

    final openingPrepositionMatch =
        openingPrepositionRegex.firstMatch(openingWindow);
    if (openingPrepositionMatch != null) {
      addIfValid(openingPrepositionMatch.group(1));
    }

    return output;
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
      '\\b$_locationLeadPrepositionPattern\\s+((?:[A-Z][A-Za-zÀ-ÖØ-öø-ÿ\'’\\-]+|[A-Z]{2,})(?:\\s+(?:[A-Z][A-Za-zÀ-ÖØ-öø-ÿ\'’\\-]+|[A-Z]{2,})){0,2})\\b',
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
      if (_hasStreetLikePrefixBeforeMatch(cleaned, match.start)) {
        continue;
      }

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

  bool _hasStreetLikePrefixBeforeMatch(String text, int matchStart) {
    if (matchStart <= 0) {
      return false;
    }

    final prefix = text.substring(0, matchStart).trimRight();
    if (prefix.isEmpty) {
      return false;
    }

    final parts = prefix.split(RegExp(r'\s+'));
    if (parts.isEmpty) {
      return false;
    }

    final lastToken = parts.last.toLowerCase();

    const streetPrefixes = <String>{
      'via',
      'viale',
      'piazza',
      'corso',
      'largo',
      'vicolo',
      'strada',
      'street',
      'st',
      'road',
      'rd',
      'avenue',
      'ave',
      'boulevard',
      'blvd',
      'rue',
      'calle',
      'avenida',
      'av',
      'praca',
      'praça',
      'platz',
    };

    return streetPrefixes.contains(lastToken);
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

    final normalized = phrase.trim().toLowerCase();
    if (_countryAliases.containsKey(normalized)) {
      return true;
    }

    if (RegExp(r'^[A-Z]{2,4}$').hasMatch(phrase)) {
      return false;
    }

    const blockedSingleWords = <String>{
      'the',
      'breaking',
      'live',
      'watch',
      'video',
      'opinion',
      'analysis',
      'explainer',
      'update',
      'updated',
      'review',
      'news',
      'world',
      'business',
      'technology',
      'sport',
      'sports',
      'politics',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
      'january',
      'february',
      'march',
      'april',
      'may',
      'june',
      'july',
      'august',
      'september',
      'october',
      'november',
      'december',
      'how',
      'why',
      'what',
      'when',
      'where',
      'who',
      'this',
      'that',
      'these',
      'those',
      'reuters',
      'guardian',
      'bloomberg',
      'cnn',
      'bbc',
      'google',
      'apple',
      'microsoft',
      'meta',
      'tiktok',
      'president',
      'prime',
      'minister',
      'government',
      'officials',
      'official',
      'police',
      'army',
      'military',
      'border',
      'market',
      'court',
      'congress',
      'parliament',
      'senate',
      'house',
      'state',
      'nation',
      'regional',
      'global',
      'international',
      'exclusive',
      'editorial',
      'podcast',
      'newsletter',
      'photo',
      'photos',
      'image',
      'images',
      'gallery',
      'commentary',
      'interview',
      'briefing',
      'report',
      'reports',
      'alert',
      'alerts',
      'latest',
      'homepage',
    };

    const blockedExactPhrases = <String>{
      'associated press',
      'al jazeera',
      'new york times',
      'washington post',
      'wall street journal',
      'financial times',
      'fox news',
      'bbc news',
      'prime minister',
      'white house',
      'european union',
      'united nations',
      'breaking news',
      'live updates',
    };

    const blockedSuffixes = <String>{
      'times',
      'news',
      'post',
      'journal',
      'herald',
      'media',
      'tv',
      'today',
      'online',
      'group',
      'agency',
      'committee',
      'office',
      'ministry',
      'department',
      'network',
      'official',
      'officials',
      'president',
      'minister',
      'government',
      'leader',
      'leaders',
      'police',
      'army',
      'military',
    };

    final parts = phrase.split(RegExp(r'\s+'));
    final normalizedParts = parts.map((part) => part.toLowerCase()).toList();

    if (parts.length == 1 &&
        blockedSingleWords.contains(normalizedParts.first)) {
      return false;
    }

    if (blockedExactPhrases.contains(normalized)) {
      return false;
    }

    if (parts.length >= 2 && blockedSuffixes.contains(normalizedParts.last)) {
      return false;
    }

    if (parts.length >= 2 &&
        !_countryAliases.containsKey(normalized) &&
        (blockedSingleWords.contains(normalizedParts.first) ||
            blockedSingleWords.contains(normalizedParts.last))) {
      return false;
    }

    if (normalizedParts.every(blockedSingleWords.contains)) {
      return false;
    }

    final isAllCapsPhrase = phrase == phrase.toUpperCase();
    if (isAllCapsPhrase &&
        !_countryAliases.containsKey(normalized) &&
        normalizedParts.any(blockedSingleWords.contains)) {
      return false;
    }

    return true;
  }

  bool _shouldReevaluateExistingLocation(
    NewsDto dto,
    ContentLocation existingLocation,
  ) {
    final candidates = _extractLocationCandidates(dto);
    if (candidates.isEmpty) {
      return false;
    }

    final topCandidate = candidates.first;
    if (!_isStrongPrimaryLocationCandidate(topCandidate)) {
      return false;
    }

    if (_candidateMatchesExistingLocation(topCandidate, existingLocation)) {
      return false;
    }

    if (candidates.length >= 2) {
      final secondCandidate = candidates[1];
      if (secondCandidate.score >= topCandidate.score - 15 &&
          _candidateMatchesExistingLocation(
            secondCandidate,
            existingLocation,
          )) {
        return false;
      }
    }

    return true;
  }

  bool _isStrongPrimaryLocationCandidate(_LocationCandidate candidate) {
    final minimumScore = candidate.isCountryOnly ? 160 : 170;
    return candidate.score >= minimumScore;
  }

  bool _candidateMatchesExistingLocation(
    _LocationCandidate candidate,
    ContentLocation existingLocation,
  ) {
    final normalizedExistingCity = _normalizePhrase(existingLocation.cityName);
    final normalizedExistingCountry = _normalize(existingLocation.countryCode);

    if (!candidate.isCountryOnly) {
      final normalizedCandidateQuery = _normalizePhrase(candidate.query);
      return normalizedCandidateQuery != null &&
          normalizedExistingCity != null &&
          normalizedCandidateQuery == normalizedExistingCity;
    }

    if (candidate.countryCode == null || normalizedExistingCountry == null) {
      return false;
    }

    return candidate.countryCode!.toLowerCase() == normalizedExistingCountry;
  }

  Future<_CachedNewsFeed?> _readCache({
    required String cacheKey,
    required bool acceptStale,
    required String? requestedLanguage,
  }) async {
    try {
      final rows = await AppSupabase.client
          .from(_cacheTable)
          .select(
            'cache_key, payload, refreshed_at, item_count, '
            'resolved_location_count, provider_signatures, '
            'languages_present, payload_version',
          )
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
      final items = _filterItemsForRequestedLanguage(
        _normalizeJsonList(payload is List ? payload : const []),
        requestedLanguage,
      );

      if (items.isEmpty) {
        return null;
      }

      final metadata = _readCacheMetadataFromRow(
        row,
        fallbackItems: items,
      );

      final cache = _CachedNewsFeed(
        items: items,
        refreshedAt: refreshedAt,
        metadata: metadata,
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
      final metadata = _buildCacheMetadata(items);

      await AppSupabase.client.from(_cacheTable).upsert(
        {
          'cache_key': cacheKey,
          'country_code': countryCode,
          'city_id': cityId,
          'topic': topic,
          'language': language,
          'payload': items,
          'item_count': metadata.itemCount,
          'resolved_location_count': metadata.resolvedLocationCount,
          'provider_signatures': metadata.providerSignatures,
          'languages_present': metadata.languagesPresent,
          'payload_version': metadata.payloadVersion,
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
        final normalizedPayload = _normalizeJsonList(payload);

        for (final json in normalizedPayload) {
          if (!_matchesRequestedNewsId(json, newsId)) {
            continue;
          }

          final dto = _tryParseDto(json);
          if (dto == null) {
            continue;
          }

          final contentLocation = _readEmbeddedContentLocation(json);

          return _mapper.toDomain(
            dto,
            countryCode: countryCode,
            cityId: cityId,
            contentLocation: contentLocation,
          );
        }

        final mapped = _mapJsonToDomainList(
          normalizedPayload,
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

  List<NewsItem> _mapCandidatePage(
    _NewsFeedCandidate candidate,
    List<Map<String, dynamic>> jsonList, {
    int? limit,
    int? offset,
  }) {
    return _mapAndPaginate(
      jsonList: jsonList,
      countryCode: candidate.countryCode,
      cityId: candidate.cityId,
      limit: limit,
      offset: offset,
    );
  }

  List<NewsItem> _mapJsonToDomainList(
    List<Map<String, dynamic>> jsonList, {
    required String? countryCode,
    required String? cityId,
  }) {
    final stableJsonList = _deduplicateJsonListByStableIdentity(jsonList);

    final items = stableJsonList.map((json) {
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
    return _readKnownContentLocation(json) ??
        _buildFlatSeedContentLocationFromJson(json);
  }

  ContentLocation? _readKnownContentLocation(Map<String, dynamic> json) {
    for (final key in const <String>[
      '_sv_content_location',
      'content_location',
      'contentLocation',
      '_content_location',
    ]) {
      final location = _contentLocationFromRaw(json[key]);
      if (location != null) {
        return location;
      }
    }

    return null;
  }

  ContentLocation? _contentLocationFromRaw(dynamic raw) {
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

  List<Map<String, dynamic>> _filterItemsForRequestedLanguage(
    List<Map<String, dynamic>> items,
    String? requestedLanguage,
  ) {
    final normalizedRequestedLanguage = _normalizeLanguageCode(
      requestedLanguage,
    );
    if (normalizedRequestedLanguage == null || items.isEmpty) {
      return List<Map<String, dynamic>>.unmodifiable(
        items.map((item) => Map<String, dynamic>.from(item)).toList(),
      );
    }

    final explicitMatches = <Map<String, dynamic>>[];
    final compatibleUnknownLanguage = <Map<String, dynamic>>[];

    for (final item in items) {
      final copy = Map<String, dynamic>.from(item);
      final itemLanguage = _extractItemLanguage(copy);

      if (itemLanguage != null) {
        if (itemLanguage == normalizedRequestedLanguage) {
          explicitMatches.add(copy);
        }
        continue;
      }

      if (_shouldKeepUnknownLanguageItemForRequestedLanguage(
        copy,
        normalizedRequestedLanguage,
      )) {
        compatibleUnknownLanguage.add(copy);
      }
    }

    if (explicitMatches.isNotEmpty) {
      return List<Map<String, dynamic>>.unmodifiable(
        <Map<String, dynamic>>[
          ...explicitMatches,
          ...compatibleUnknownLanguage,
        ],
      );
    }

    return List<Map<String, dynamic>>.unmodifiable(
      compatibleUnknownLanguage,
    );
  }

  bool _shouldKeepUnknownLanguageItemForRequestedLanguage(
    Map<String, dynamic> item,
    String requestedLanguage,
  ) {
    if (requestedLanguage == 'en') {
      return true;
    }

    return false;
  }

  bool _isGuardianProviderSignature(String? value) {
    final normalized = _normalizePhrase(value);
    if (normalized == null) {
      return false;
    }

    return normalized == 'guardian' ||
        normalized == 'the guardian' ||
        normalized.contains('guardian');
  }

  String? _extractItemLanguage(Map<String, dynamic> json) {
    final rawLanguage = _firstNonEmptyString(
      json,
      const <String>[
        'language',
        'lang',
        'locale',
        'content_language',
        'contentLanguage',
        'feed_language',
        'feedLanguage',
      ],
    );

    return _normalizeLanguageCode(rawLanguage);
  }

  bool _canUseStaleFallbackCache(
    _CachedNewsFeed cache, {
    required String? requestedLanguage,
  }) {
    if (cache.items.isEmpty) {
      return false;
    }

    final normalizedRequestedLanguage = _normalizeLanguageCode(
      requestedLanguage,
    );
    if (normalizedRequestedLanguage == null) {
      return true;
    }

    final filtered = _filterItemsForRequestedLanguage(
      cache.items,
      normalizedRequestedLanguage,
    );

    if (filtered.isEmpty) {
      return false;
    }

    if (cache.metadata.languagesPresent.isNotEmpty) {
      return cache.metadata.languagesPresent.contains(
        normalizedRequestedLanguage,
      );
    }

    return filtered.any((item) => _extractProviderSignature(item) != null);
  }

  List<_NewsFeedCandidate> _buildSameLanguageEquivalentCandidates(
    _NewsFeedCandidate candidate,
  ) {
    final isGlobalAllRequest = candidate.countryCode == null &&
        candidate.cityId == null &&
        candidate.topic == null &&
        candidate.language != null;

    if (!isGlobalAllRequest) {
      return const <_NewsFeedCandidate>[];
    }

    return <_NewsFeedCandidate>[
      _NewsFeedCandidate(
        countryCode: null,
        cityId: null,
        topic: 'world',
        language: candidate.language,
      ),
      _NewsFeedCandidate(
        countryCode: null,
        cityId: null,
        topic: 'nation',
        language: candidate.language,
      ),
    ];
  }

  Future<_EquivalentCacheHit?> _readFirstSameLanguageEquivalentCache({
    required List<_NewsFeedCandidate> candidates,
    required bool acceptStale,
    required String? requestedLanguage,
  }) async {
    for (final equivalentCandidate in candidates) {
      final cache = await _readCache(
        cacheKey: equivalentCandidate.cacheKey,
        acceptStale: acceptStale,
        requestedLanguage: requestedLanguage,
      );

      if (cache == null || cache.items.isEmpty) {
        continue;
      }

      return _EquivalentCacheHit(
        candidate: equivalentCandidate,
        cache: cache,
      );
    }

    return null;
  }

  Future<void> _writeCanonicalGlobalAllAliasIfNeeded({
    required _NewsFeedCandidate sourceCandidate,
    required List<Map<String, dynamic>> items,
  }) async {
    final isGlobalScoped =
        sourceCandidate.countryCode == null && sourceCandidate.cityId == null;
    final isCompatibleTopic =
        sourceCandidate.topic == 'world' || sourceCandidate.topic == 'nation';
    final hasLanguage =
        sourceCandidate.language != null && sourceCandidate.language!.isNotEmpty;

    if (!isGlobalScoped || !isCompatibleTopic || !hasLanguage || items.isEmpty) {
      return;
    }

    final aliasCandidate = _NewsFeedCandidate(
      countryCode: null,
      cityId: null,
      topic: null,
      language: sourceCandidate.language,
    );

    await _writeCache(
      cacheKey: aliasCandidate.cacheKey,
      countryCode: aliasCandidate.countryCode,
      cityId: aliasCandidate.cityId,
      topic: aliasCandidate.topic,
      language: aliasCandidate.language,
      items: items,
    );

    _clearRefreshCooldown(aliasCandidate.cacheKey);

    if (kDebugMode) {
      debugPrint(
        'NewsRepositoryImpl mirrored ${sourceCandidate.cacheKey} into '
        '${aliasCandidate.cacheKey} to keep canonical global cache warm.',
      );
    }
  }

  String? _extractProviderSignature(Map<String, dynamic> json) {
    final rawProvider = _firstNonEmptyString(
      json,
      const <String>[
        'provider',
        'provider_id',
        'providerId',
        'provider_name',
        'providerName',
        'source',
        'source_id',
        'sourceId',
        'source_name',
        'sourceName',
      ],
    );

    if (rawProvider != null) {
      return _normalizePhrase(rawProvider);
    }

    final dto = _tryParseDto(json);
    return _normalizePhrase(dto?.sourceId) ?? _normalizePhrase(dto?.sourceName);
  }

  _CachePayloadMetadata _buildCacheMetadata(
    List<Map<String, dynamic>> items,
  ) {
    final providerSignatures = <String>{};
    final languagesPresent = <String>{};

    for (final item in items) {
      final providerSignature = _extractProviderSignature(item);
      if (providerSignature != null) {
        providerSignatures.add(providerSignature);
      }

      final language = _extractItemLanguage(item);
      if (language != null) {
        languagesPresent.add(language);
      }
    }

    return _CachePayloadMetadata(
      itemCount: items.length,
      resolvedLocationCount: _countItemsWithResolvedLocation(items),
      providerSignatures: providerSignatures.toList()..sort(),
      languagesPresent: languagesPresent.toList()..sort(),
      payloadVersion: _cachePayloadVersion,
    );
  }

  _CachePayloadMetadata _readCacheMetadataFromRow(
    Map<String, dynamic> row, {
    required List<Map<String, dynamic>> fallbackItems,
  }) {
    final fallback = _buildCacheMetadata(fallbackItems);

    return _CachePayloadMetadata(
      itemCount: _readInt(row['item_count']) ?? fallback.itemCount,
      resolvedLocationCount:
          _readInt(row['resolved_location_count']) ??
              fallback.resolvedLocationCount,
      providerSignatures:
          _readStringList(row['provider_signatures']) ??
              fallback.providerSignatures,
      languagesPresent:
          _readStringList(row['languages_present']) ?? fallback.languagesPresent,
      payloadVersion:
          _readInt(row['payload_version']) ?? fallback.payloadVersion,
    );
  }

  int? _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '');
  }

  List<String>? _readStringList(dynamic value) {
    if (value is! List) {
      return null;
    }

    final output = <String>{};

    for (final item in value) {
      final normalized = _normalizePhrase(item?.toString());
      if (normalized != null) {
        output.add(normalized);
      }
    }

    return output.toList()..sort();
  }

  List<String> _buildStableArticleKeysFromJson(Map<String, dynamic> json) {
    final dto = _tryParseDto(json);
    final keys = <String>{};

    void addKey(String? value) {
      if (value == null) return;
      final trimmed = value.trim();
      if (trimmed.isEmpty) return;
      keys.add(trimmed);
    }

    final sourceHint = _normalizeIdentitySource(
      _firstNonEmptyString(
            json,
            const <String>[
              'source_id',
              'sourceId',
              'source_name',
              'sourceName',
              'provider',
              'provider_id',
              'providerId',
              'provider_name',
              'providerName',
            ],
          ) ??
          dto?.sourceId ??
          dto?.sourceName,
    );

    final normalizedUrl = _normalizeArticleUrl(
      _firstNonEmptyString(
            json,
            const <String>[
              'url',
              'link',
              'article_url',
              'articleUrl',
              'canonical_url',
              'canonicalUrl',
            ],
          ) ??
          dto?.url,
    );

    if (normalizedUrl != null) {
      addKey('url:$normalizedUrl');
    }

    final externalId = _firstNonEmptyString(
      json,
      const <String>[
        'external_id',
        'externalId',
        'guid',
        'uuid',
        'provider_article_id',
        'providerArticleId',
        'article_id',
        'articleId',
      ],
    );

    if (externalId != null) {
      addKey('external:$sourceHint:${externalId.toLowerCase()}');
    }

    final rawId =
        dto?.id.trim() ??
        _firstNonEmptyString(json, const <String>['id'])?.trim() ??
        '';

    if (rawId.isNotEmpty) {
      addKey('id:$sourceHint:${rawId.toLowerCase()}');
    }

    final title =
        (dto?.title ??
                _firstNonEmptyString(json, const <String>['title', 'headline']))
            ?.trim();

    final publishedAt = dto?.publishedAt ?? _extractPublishedAtFromJson(json);

    if (title != null && title.isNotEmpty && publishedAt != null) {
      addKey(
        'title:$sourceHint:${title.toLowerCase()}:${publishedAt.toUtc().toIso8601String()}',
      );
    }

    return keys.toList(growable: false);
  }

  DateTime? _extractPublishedAtFromJson(Map<String, dynamic> json) {
    return _parseDateTime(
      json['published_at'] ??
          json['publishedAt'] ??
          json['pubDate'] ??
          json['date'] ??
          json['created_at'] ??
          json['createdAt'],
    );
  }

  List<Map<String, dynamic>> _deduplicateJsonListByStableIdentity(
    List<Map<String, dynamic>> items,
  ) {
    if (items.length <= 1) {
      return List<Map<String, dynamic>>.unmodifiable(
        items.map((item) => Map<String, dynamic>.from(item)).toList(),
      );
    }

    final seenKeys = <String>{};
    final output = <Map<String, dynamic>>[];

    for (final item in items) {
      final copy = Map<String, dynamic>.from(item);
      final identityKeys = _buildStableArticleKeysFromJson(copy);

      if (identityKeys.isNotEmpty &&
          identityKeys.any((key) => seenKeys.contains(key))) {
        continue;
      }

      output.add(copy);
      seenKeys.addAll(identityKeys);
    }

    return List<Map<String, dynamic>>.unmodifiable(output);
  }

  bool _matchesRequestedNewsId(
    Map<String, dynamic> json,
    String requestedId,
  ) {
    final normalizedRequestedId = requestedId.trim();
    if (normalizedRequestedId.isEmpty) {
      return false;
    }

    final requestedIdLower = normalizedRequestedId.toLowerCase();
    final requestedUrl = _normalizeArticleUrl(normalizedRequestedId);

    final dto = _tryParseDto(json);
    if (dto != null && dto.id.trim().toLowerCase() == requestedIdLower) {
      return true;
    }

    for (final key in const <String>[
      'id',
      'external_id',
      'externalId',
      'guid',
      'uuid',
      'article_id',
      'articleId',
    ]) {
      final rawValue = json[key]?.toString().trim();
      if (rawValue != null &&
          rawValue.isNotEmpty &&
          rawValue.toLowerCase() == requestedIdLower) {
        return true;
      }
    }

    final itemUrl = _normalizeArticleUrl(
      _firstNonEmptyString(
            json,
            const <String>[
              'url',
              'link',
              'article_url',
              'articleUrl',
              'canonical_url',
              'canonicalUrl',
            ],
          ) ??
          dto?.url,
    );

    return requestedUrl != null &&
        itemUrl != null &&
        requestedUrl == itemUrl;
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
      final keys = _buildStableArticleKeysFromJson(item);
      final location = _readEmbeddedContentLocation(item);

      if (keys.isEmpty || location == null) {
        continue;
      }

      if (!_hasResolvedLocation(location)) {
        continue;
      }

      final locationJson = location.toJson();
      for (final key in keys) {
        previousLocationsByKey[key] = locationJson;
      }
    }

    final output = <Map<String, dynamic>>[];

    for (final item in items) {
      final copy = Map<String, dynamic>.from(item);
      final currentLocation = _readEmbeddedContentLocation(copy);

      if (currentLocation == null || !_hasResolvedLocation(currentLocation)) {
        final keys = _buildStableArticleKeysFromJson(copy);
        Map<String, dynamic>? previousLocationJson;

        for (final key in keys) {
          final matched = previousLocationsByKey[key];
          if (matched != null) {
            previousLocationJson = matched;
            break;
          }
        }

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

    if (refreshedItems.isEmpty && previousItems.isNotEmpty) {
      if (kDebugMode) {
        debugPrint(
          'NewsRepositoryImpl keeping previous cache payload because refreshed '
          'payload is empty.',
        );
      }

      return List<Map<String, dynamic>>.unmodifiable(
        previousItems
            .map((item) => Map<String, dynamic>.from(item))
            .toList(growable: false),
      );
    }

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

  bool _isRefreshCooldownActive(String cacheKey) {
    final until = _refreshCooldownUntilByCacheKey[cacheKey];
    if (until == null) {
      return false;
    }

    final now = DateTime.now().toUtc();
    if (!until.isAfter(now)) {
      _refreshCooldownUntilByCacheKey.remove(cacheKey);
      return false;
    }

    return true;
  }

  void _markRefreshCooldown(
    String cacheKey, {
    required String reason,
  }) {
    final until = DateTime.now().toUtc().add(_refreshFailureCooldown);
    _refreshCooldownUntilByCacheKey[cacheKey] = until;

    if (kDebugMode) {
      debugPrint(
        'NewsRepositoryImpl live refresh cooldown active for $cacheKey until '
        '${until.toIso8601String()} because $reason.',
      );
    }
  }

  void _clearRefreshCooldown(String cacheKey) {
    final removed = _refreshCooldownUntilByCacheKey.remove(cacheKey);
    if (removed != null && kDebugMode) {
      debugPrint(
        'NewsRepositoryImpl cleared live refresh cooldown for $cacheKey '
        'after successful refresh.',
      );
    }
  }

  String? _buildStableArticleKeyFromJson(Map<String, dynamic> json) {
    final keys = _buildStableArticleKeysFromJson(json);
    if (keys.isNotEmpty) {
      return keys.first;
    }

    final dto = _tryParseDto(json);
    if (dto == null) {
      return null;
    }

    return _buildStableArticleKeyFromDto(dto);
  }

  String _buildStableArticleKeyFromDto(NewsDto dto) {
    final normalizedUrl = _normalizeArticleUrl(dto.url);
    if (normalizedUrl != null) {
      return 'url:$normalizedUrl';
    }

    final rawId = dto.id.trim();
    if (rawId.isNotEmpty) {
      final source = _normalizeIdentitySource(dto.sourceName ?? dto.sourceId);
      return 'id:$source:${rawId.toLowerCase()}';
    }

    final source = _normalizeIdentitySource(dto.sourceName ?? dto.sourceId);
    return 'title:$source:${dto.title.trim().toLowerCase()}:${dto.publishedAt.toUtc().toIso8601String()}';
  }

  String _normalizeIdentitySource(String? value) {
    return _normalizePhrase(value) ?? 'unknown';
  }

  String? _normalizeArticleUrl(String? rawUrl) {
    if (rawUrl == null) {
      return null;
    }

    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final parsed = Uri.tryParse(trimmed);
    if (parsed == null || !parsed.hasScheme || parsed.host.isEmpty) {
      return trimmed.toLowerCase();
    }

    final normalizedPath = parsed.path.isEmpty
        ? '/'
        : parsed.path.replaceFirst(RegExp(r'/$'), '');

    return Uri(
      scheme: parsed.scheme.toLowerCase(),
      host: parsed.host.toLowerCase(),
      port: parsed.hasPort ? parsed.port : null,
      path: normalizedPath.isEmpty ? '/' : normalizedPath,
    ).toString().toLowerCase();
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

  bool _shouldAllowStaleCache(String? language) {
    return true;
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

  String? _normalizeLanguageCode(String? value) {
    final normalized = _normalize(value);
    if (normalized == null) {
      return null;
    }

    final compact = normalized.replaceAll('_', '-');
    final primary = compact.split('-').first.trim();

    if (primary.isEmpty) {
      return null;
    }

    return primary;
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
  final _CachePayloadMetadata metadata;

  const _CachedNewsFeed({
    required this.items,
    required this.refreshedAt,
    required this.metadata,
  });

  bool get isFresh {
    final now = DateTime.now().toUtc();
    return now.difference(refreshedAt) < NewsRepositoryImpl._cacheTtl;
  }
}

class _CachePayloadMetadata {
  final int itemCount;
  final int resolvedLocationCount;
  final List<String> providerSignatures;
  final List<String> languagesPresent;
  final int payloadVersion;

  const _CachePayloadMetadata({
    required this.itemCount,
    required this.resolvedLocationCount,
    required this.providerSignatures,
    required this.languagesPresent,
    required this.payloadVersion,
  });
}

class _EquivalentCacheHit {
  final _NewsFeedCandidate candidate;
  final _CachedNewsFeed cache;

  const _EquivalentCacheHit({
    required this.candidate,
    required this.cache,
  });
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

class _DatelineLocationPair {
  final String cityName;
  final String countryName;
  final String countryCode;

  const _DatelineLocationPair({
    required this.cityName,
    required this.countryName,
    required this.countryCode,
  });
}