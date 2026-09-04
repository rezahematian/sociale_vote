import 'package:flutter/foundation.dart';
import 'package:sociale_vote/core/supabase/supabase_client.dart';
import 'package:sociale_vote/domain/common/value_objects/entity_id.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/content/news/entities/world_brief.dart';
import 'package:sociale_vote/domain/content/news/repositories/news_repository.dart';
import 'package:sociale_vote/domain/content/news/repositories/world_brief_repository.dart';
import 'package:sociale_vote/domain/geo/repositories/geocoding_repository.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location_source.dart';

import 'package:sociale_vote/infrastructure/news/aggregator/news_aggregator.dart';
import 'package:sociale_vote/infrastructure/news/mappers/news_mapper.dart';
import 'package:sociale_vote/infrastructure/news/models/news_dto.dart';
import 'package:sociale_vote/infrastructure/moderation/services/content_visibility_filter.dart';
import 'package:sociale_vote/shared/services/egress_policy_service.dart';

class NewsRepositoryImpl implements NewsRepository {
  static const String _cacheTable = 'news_feed_cache';
  static const int _cachePayloadVersion = 3;
  static const int _defaultRefreshFetchLimit = 50;
  static const Duration _cacheTtl = Duration(minutes: 30);

  static const int _maxArticlesToGeocodePerRefresh = 8;
  static const int _maxLocationCandidatesPerArticle = 3;
  static const int _targetResolvedLocationsPerRefresh = 8;
  static const Duration _perArticleGeocodeTimeout = Duration(seconds: 2);
  static const Duration _maxPreservedLocatedArticleAge = Duration(days: 7);
  static const Duration _maxPreservedLocatedLagFromNewestRefresh =
      Duration(days: 3);

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
  final WorldBriefRepository _worldBriefRepository;
  late final ContentVisibilityFilter _contentVisibilityFilter =
      ContentVisibilityFilter(AppSupabase.client);

  final Map<String, Future<List<Map<String, dynamic>>>> _inFlightRefreshes =
      <String, Future<List<Map<String, dynamic>>>>{};

  final Map<String, _MemoryCachedNewsFeedEntry> _exactMemoryCache =
      <String, _MemoryCachedNewsFeedEntry>{};
  final Map<String, Future<_CachedNewsFeed?>> _exactCacheReadsInFlight =
      <String, Future<_CachedNewsFeed?>>{};
  final Map<String, _MemoryCachedNewsFeedEntry> _fallbackMemoryCache =
      <String, _MemoryCachedNewsFeedEntry>{};
  final Map<String, Future<_CachedNewsFeed?>> _fallbackReadsInFlight =
      <String, Future<_CachedNewsFeed?>>{};

  Set<String> _removedNewsIdentityKeys = <String>{};
  DateTime? _removedNewsIdentityKeysLoadedAt;
  Future<Set<String>>? _removedNewsIdentityKeysLoad;

  NewsRepositoryImpl(
    this._aggregator,
    this._mapper,
    this._geocodingRepository,
    this._worldBriefRepository,
  );

  Future<int> refreshNewsFeedCache({
    String? countryCode,
    String? cityId,
    String? topic,
    String? language,
    int? providerLimit,
  }) async {
    final candidate = _NewsFeedCandidate(
      countryCode: _normalize(countryCode),
      cityId: _normalize(cityId),
      topic: _normalize(topic),
      language: _normalizeLanguageCode(language),
    );

    final refreshedItems = await _refreshCacheForCandidateDeduplicated(
      candidate,
      providerLimit: providerLimit ?? _defaultRefreshFetchLimit,
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
    bool allowProviderRefresh = false,
    bool allowFallbackCache = true,
  }) async {
    final candidate = _NewsFeedCandidate(
      countryCode: _normalize(countryCode),
      cityId: _normalize(cityId),
      topic: _normalize(topic),
      language: _normalizeLanguageCode(language),
    );

    List<NewsItem> worldBriefs = const <NewsItem>[];
    try {
      worldBriefs = await _loadVisibleWorldBriefs(
        languageCode: candidate.language,
        countryCode: candidate.countryCode,
        cityId: candidate.cityId,
        limit: limit == null ? 50 : (limit * 2).clamp(10, 100).toInt(),
      );
    } catch (error, stackTrace) {
      // World Brief and provider news are independent sources. A temporary
      // Supabase/RLS/network failure in one source must not blank the entire
      // News surface on Android or Web.
      if (kDebugMode) {
        debugPrint(
            'World Briefs unavailable; provider news remains usable: $error');
        debugPrint('$stackTrace');
      }
    }

    List<NewsItem> providerNews = const <NewsItem>[];
    try {
      final cache = await _resolveBestAvailableCache(
        candidate,
        providerLimit: _defaultRefreshFetchLimit,
        allowProviderRefresh: allowProviderRefresh,
        allowFallbackCache: allowFallbackCache,
      );
      if (cache != null && cache.items.isNotEmpty) {
        providerNews = await _mapFilterAndPaginate(
          jsonList: cache.items,
          countryCode: cache.countryCode ?? candidate.countryCode,
          cityId: cache.cityId ?? candidate.cityId,
        );
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          'Provider news unavailable; World Briefs remain usable: $error',
        );
        debugPrint('$stackTrace');
      }
    }

    return _mergeAndPaginate(
      worldBriefs,
      providerNews,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<NewsItem>> getTrendingCandidates({
    String? countryCode,
    String? cityId,
    String? topic,
    String? language,
    int? limit,
  }) async {
    final candidate = _NewsFeedCandidate(
      countryCode: _normalize(countryCode),
      cityId: _normalize(cityId),
      topic: _normalize(topic),
      language: _normalizeLanguageCode(language),
    );

    List<NewsItem> worldBriefs = const <NewsItem>[];
    try {
      worldBriefs = await _loadVisibleWorldBriefs(
        languageCode: candidate.language,
        countryCode: candidate.countryCode,
        cityId: candidate.cityId,
        limit: limit == null ? 30 : (limit * 2).clamp(10, 100).toInt(),
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
            'World Brief trending unavailable; provider news remains usable: $error');
        debugPrint('$stackTrace');
      }
    }

    List<NewsItem> providerNews = const <NewsItem>[];
    try {
      final cache = await _resolveBestAvailableCache(
        candidate,
        providerLimit: _defaultRefreshFetchLimit,
        allowProviderRefresh: false,
      );
      if (cache != null && cache.items.isNotEmpty) {
        providerNews = await _mapFilterAndPaginate(
          jsonList: cache.items,
          countryCode: cache.countryCode ?? candidate.countryCode,
          cityId: cache.cityId ?? candidate.cityId,
        );
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          'Provider trending unavailable; World Briefs remain usable: $error',
        );
        debugPrint('$stackTrace');
      }
    }

    return _mergeAndPaginate(
      worldBriefs,
      providerNews,
      limit: limit,
      offset: 0,
    );
  }

  @override
  Future<NewsItem> getNewsDetail(EntityId id) async {
    final requestedId = id.value.trim();
    final worldBrief =
        await _worldBriefRepository.getPublishedById(requestedId);
    if (worldBrief != null) {
      if (!await _isNewsAvailable(requestedId)) {
        throw StateError('News content has been permanently removed.');
      }
      return _worldBriefToNewsItem(worldBrief);
    }

    if (!await _isNewsAvailable(requestedId)) {
      throw StateError('News content has been permanently removed.');
    }

    final cached = await _findCachedNewsById(requestedId);
    if (cached != null) {
      return cached;
    }

    throw StateError('News content is not available in the shared cache.');
  }

  Future<List<NewsItem>> _loadVisibleWorldBriefs({
    required String? languageCode,
    required String? countryCode,
    required String? cityId,
    required int limit,
  }) async {
    final briefs = await _worldBriefRepository.listPublished(
      languageCode: languageCode,
      countryCode: countryCode,
      cityId: cityId,
      limit: limit,
    );
    if (briefs.isEmpty) return const <NewsItem>[];

    final items = briefs.map(_worldBriefToNewsItem).toList(growable: false);
    final visibleIds = await _contentVisibilityFilter.filterVisibleIds(
      targetType: 'news',
      targetIds: items.map((item) => item.id.value),
    );
    return items
        .where((item) => visibleIds.contains(item.id.value))
        .toList(growable: false);
  }

  List<NewsItem> _mergeAndPaginate(
    List<NewsItem> worldBriefs,
    List<NewsItem> providerNews, {
    required int? limit,
    required int? offset,
  }) {
    final byId = <String, NewsItem>{};
    for (final item in <NewsItem>[...worldBriefs, ...providerNews]) {
      byId.putIfAbsent(item.id.value, () => item);
    }

    final merged = byId.values.toList(growable: false)
      ..sort((a, b) {
        if (a.editorialFeatured != b.editorialFeatured) {
          return b.editorialFeatured ? 1 : -1;
        }
        final priority = b.editorialPriority.compareTo(a.editorialPriority);
        if (priority != 0) return priority;
        return b.publishedAt.compareTo(a.publishedAt);
      });

    final safeOffset = (offset ?? 0).clamp(0, merged.length).toInt();
    final safeLimit = limit == null || limit <= 0 ? merged.length : limit;
    final end =
        (safeOffset + safeLimit).clamp(safeOffset, merged.length).toInt();
    return List<NewsItem>.unmodifiable(merged.sublist(safeOffset, end));
  }

  NewsItem _worldBriefToNewsItem(WorldBrief brief) {
    final labels = switch (brief.languageCode) {
      'it' => const <String>[
          'Che cosa è successo',
          'Perché conta',
          'Che cosa non è ancora certo',
          'Lettura Social Vote',
          'Fonti',
        ],
      'de' => const <String>[
          'Was passiert ist',
          'Warum es wichtig ist',
          'Was noch unklar ist',
          'Social Vote Einordnung',
          'Quellen',
        ],
      'fa' => const <String>[
          'چه اتفاقی افتاده است',
          'چرا اهمیت دارد',
          'چه چیزی هنوز قطعی نیست',
          'دیدگاه تحلیلی Social Vote',
          'منابع',
        ],
      _ => const <String>[
          'What happened',
          'Why it matters',
          'What is still uncertain',
          'Social Vote view',
          'Sources',
        ],
    };
    final sections = <String>[
      '${labels[0]}\n${brief.whatHappened}',
      '${labels[1]}\n${brief.whyItMatters}',
      if (brief.whatIsUncertain?.trim().isNotEmpty == true)
        '${labels[2]}\n${brief.whatIsUncertain!.trim()}',
      if (brief.socialVoteView?.trim().isNotEmpty == true)
        '${labels[3]}\n${brief.socialVoteView!.trim()}',
      '${labels[4]}\n${brief.sourceUrls.join('\n')}',
    ];
    final hasPoint = brief.latitude != null &&
        brief.longitude != null &&
        brief.latitude!.isFinite &&
        brief.longitude!.isFinite;

    return NewsItem(
      id: EntityId(brief.id),
      title: brief.title,
      content: sections.join('\n\n'),
      summary: brief.whatHappened,
      countryCode: brief.countryCode,
      cityId: brief.cityId,
      contentLocation: hasPoint
          ? ContentLocation(
              source: ContentLocationSource.manual,
              countryCode: brief.countryCode,
              cityId: brief.cityId,
              cityName: brief.locationLabel,
              latitude: brief.latitude!,
              longitude: brief.longitude!,
            )
          : null,
      authorId: 'Social Vote',
      sourceId: 'social-vote-editorial',
      sourceName: 'Social Vote',
      sourceUrl: 'https://socialevote.com',
      language: brief.languageCode,
      publishedAt: brief.publishedAt ?? brief.updatedAt,
      isBreaking: brief.breaking,
      isSocialVoteBrief: true,
      editorialMapVisible: brief.mapVisible,
      editorialFeatured: brief.featured,
      editorialPriority: brief.priority,
      worldBrief: brief,
    );
  }

  Future<_CachedNewsFeed?> _resolveBestAvailableCache(
    _NewsFeedCandidate candidate, {
    required int providerLimit,
    bool allowProviderRefresh = false,
    bool allowFallbackCache = true,
  }) async {
    final exactCache = await _readExactCache(
      cacheKey: candidate.cacheKey,
      requestedLanguage: candidate.language,
    );

    if (exactCache != null &&
        exactCache.items.isNotEmpty &&
        (!allowProviderRefresh || !_isCacheExpired(exactCache))) {
      return exactCache;
    }

    if (!allowProviderRefresh) {
      if (!allowFallbackCache) {
        return null;
      }

      return _readBestFallbackCache(
        candidate: candidate,
        requestedLanguage: candidate.language,
      );
    }

    final refreshedItems = await _refreshCacheForCandidateDeduplicated(
      candidate,
      providerLimit: providerLimit,
    );

    if (refreshedItems.isNotEmpty) {
      final refreshedCache = await _readExactCache(
        cacheKey: candidate.cacheKey,
        requestedLanguage: candidate.language,
      );

      if (refreshedCache != null && refreshedCache.items.isNotEmpty) {
        return refreshedCache;
      }

      return _buildEphemeralCacheFromItems(
        candidate: candidate,
        items: refreshedItems,
        baseCache: exactCache,
      );
    }

    if (exactCache != null && exactCache.items.isNotEmpty) {
      return exactCache;
    }

    if (!allowFallbackCache) {
      return null;
    }

    return _readBestFallbackCache(
      candidate: candidate,
      requestedLanguage: candidate.language,
    );
  }

  _CachedNewsFeed _buildEphemeralCacheFromItems({
    required _NewsFeedCandidate candidate,
    required List<Map<String, dynamic>> items,
    _CachedNewsFeed? baseCache,
  }) {
    final sortedItems = _sortJsonListByPublishedAtDesc(items);

    return _CachedNewsFeed(
      cacheKey: candidate.cacheKey,
      countryCode: baseCache?.countryCode ?? candidate.countryCode,
      cityId: baseCache?.cityId ?? candidate.cityId,
      topic: baseCache?.topic ?? candidate.topic,
      language: baseCache?.language ?? candidate.language,
      items: sortedItems,
      refreshedAt: DateTime.now().toUtc(),
      metadata: _buildCacheMetadata(sortedItems),
    );
  }

  bool _isCacheExpired(_CachedNewsFeed cache) {
    final now = DateTime.now().toUtc();
    return now.difference(cache.refreshedAt) > _cacheTtl;
  }

  Future<List<Map<String, dynamic>>> _refreshCacheForCandidateDeduplicated(
    _NewsFeedCandidate candidate, {
    required int providerLimit,
  }) {
    final existing = _inFlightRefreshes[candidate.cacheKey];
    if (existing != null) {
      return existing;
    }

    final future = _refreshCacheForCandidate(
      candidate,
      providerLimit: providerLimit,
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
  }) async {
    final previousCache = await _readExactCache(
      cacheKey: candidate.cacheKey,
      requestedLanguage: candidate.language,
    );

    List<Map<String, dynamic>> fallbackItems() {
      return previousCache?.items ?? const <Map<String, dynamic>>[];
    }

    List<dynamic> rawList;
    try {
      rawList = await _aggregator.fetchNews(
        countryCode: candidate.countryCode,
        cityId: candidate.cityId,
        topic: candidate.topic,
        language: candidate.language,
        limit: providerLimit,
        offset: 0,
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('NewsRepositoryImpl live refresh failed: $e');
        debugPrint('$st');
      }
      return fallbackItems();
    }

    final normalized = _normalizeFetchedJsonList(
      rawList,
      defaultLanguage: candidate.language,
    );

    final filteredByLanguage = _filterItemsForRequestedLanguage(
      normalized,
      candidate.language,
    );

    final usableItems = _retainCacheUsableItems(filteredByLanguage);
    final deduplicated = _deduplicateJsonListByStableIdentity(usableItems);
    final sorted = _sortJsonListByPublishedAtDesc(deduplicated);

    if (sorted.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          'NewsRepositoryImpl live refresh produced no usable items '
          'for ${candidate.cacheKey}, preserving previous cache.',
        );
      }
      return fallbackItems();
    }

    final previousResolvedCount = _countItemsWithResolvedLocation(
      previousCache?.items ?? const <Map<String, dynamic>>[],
    );

    final targetResolvedCountForRefresh =
        previousResolvedCount >= _targetResolvedLocationsPerRefresh
            ? 0
            : (_targetResolvedLocationsPerRefresh - previousResolvedCount);

    final enriched = await _enrichItemsForCache(
      sorted,
      targetResolvedCount: targetResolvedCountForRefresh,
    );
    final stablePayload = _retainCacheUsableItems(enriched);

    if (stablePayload.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          'NewsRepositoryImpl enriched refresh became unusable '
          'for ${candidate.cacheKey}, preserving previous cache.',
        );
      }
      return fallbackItems();
    }

    final protectedPayload = _preservePreviousLocatedItems(
      previousItems: previousCache?.items ?? const <Map<String, dynamic>>[],
      refreshedItems: stablePayload,
      candidate: candidate,
    );
    final availablePayload = await _filterAvailableNewsJson(
      protectedPayload,
      countryCode: candidate.countryCode,
      cityId: candidate.cityId,
    );

    await _writeCache(
      cacheKey: candidate.cacheKey,
      countryCode: candidate.countryCode,
      cityId: candidate.cityId,
      topic: candidate.topic,
      language: candidate.language,
      items: availablePayload,
    );

    return availablePayload;
  }

  List<Map<String, dynamic>> _preservePreviousLocatedItems({
    required List<Map<String, dynamic>> previousItems,
    required List<Map<String, dynamic>> refreshedItems,
    required _NewsFeedCandidate candidate,
  }) {
    if (previousItems.isEmpty || refreshedItems.isEmpty) {
      return List<Map<String, dynamic>>.unmodifiable(
        refreshedItems.map((item) => Map<String, dynamic>.from(item)).toList(),
      );
    }

    final stabilizedRefreshedItems = _seedStablePreviousArticleMetadata(
      previousItems: previousItems,
      refreshedItems: refreshedItems,
    );

    final previousResolved = _countItemsWithResolvedLocation(previousItems);
    final refreshedResolved =
        _countItemsWithResolvedLocation(stabilizedRefreshedItems);

    if (previousResolved <= refreshedResolved) {
      return List<Map<String, dynamic>>.unmodifiable(
        stabilizedRefreshedItems
            .map((item) => Map<String, dynamic>.from(item))
            .toList(),
      );
    }

    final merged = stabilizedRefreshedItems
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: true);

    final seenKeys = <String>{};
    for (final item in merged) {
      seenKeys.addAll(_buildStableArticleKeysFromJson(item));
    }

    var mergedResolved = refreshedResolved;
    final newestRefreshedPublishedAt =
        _findNewestPublishedAt(stabilizedRefreshedItems);

    for (final previous in previousItems) {
      if (!_hasResolvedLocation(previous)) {
        continue;
      }

      final copy = Map<String, dynamic>.from(previous);

      if (!_isPreservablePreviousLocatedItem(
        copy,
        newestRefreshedPublishedAt: newestRefreshedPublishedAt,
      )) {
        continue;
      }

      final keys = _buildStableArticleKeysFromJson(copy);

      final isDuplicate = keys.isNotEmpty && keys.any(seenKeys.contains);
      if (isDuplicate) {
        continue;
      }

      merged.add(copy);
      seenKeys.addAll(keys);
      mergedResolved += 1;

      if (mergedResolved >= previousResolved) {
        break;
      }
    }

    final sortedMerged = _sortJsonListByPublishedAtDesc(merged);

    if (kDebugMode && mergedResolved > refreshedResolved) {
      debugPrint(
        'NewsRepositoryImpl preserved previous located items for '
        '${candidate.cacheKey}: refreshedResolved=$refreshedResolved '
        'previousResolved=$previousResolved mergedResolved=$mergedResolved',
      );
    }

    return List<Map<String, dynamic>>.unmodifiable(sortedMerged);
  }

  List<Map<String, dynamic>> _seedStablePreviousArticleMetadata({
    required List<Map<String, dynamic>> previousItems,
    required List<Map<String, dynamic>> refreshedItems,
  }) {
    final previousByStableKey = <String, Map<String, dynamic>>{};

    for (final previous in previousItems) {
      for (final key in _buildStableArticleKeysFromJson(previous)) {
        previousByStableKey.putIfAbsent(key, () => previous);
      }
    }

    return refreshedItems.map((refreshed) {
      final copy = Map<String, dynamic>.from(refreshed);
      Map<String, dynamic>? matchedPrevious;

      for (final key in _buildStableArticleKeysFromJson(copy)) {
        matchedPrevious = previousByStableKey[key];
        if (matchedPrevious != null) {
          break;
        }
      }

      if (matchedPrevious == null) {
        return copy;
      }

      final currentCanonicalId = copy['news_id']?.toString().trim() ?? '';
      final previousCanonicalId =
          matchedPrevious['news_id']?.toString().trim() ?? '';

      if (currentCanonicalId.isEmpty && previousCanonicalId.isNotEmpty) {
        copy['news_id'] = previousCanonicalId;
      }

      final currentLocation = _readEmbeddedContentLocation(copy);
      final previousLocation = _readEmbeddedContentLocation(matchedPrevious);

      if ((currentLocation == null ||
              (!currentLocation.hasExactPoint && !currentLocation.hasCenter)) &&
          previousLocation != null &&
          (previousLocation.hasExactPoint || previousLocation.hasCenter)) {
        copy['_sv_content_location'] = previousLocation.toJson();
      }

      return copy;
    }).toList(growable: false);
  }

  bool _hasResolvedLocation(Map<String, dynamic> item) {
    final location = _readEmbeddedContentLocation(item);
    return location != null && (location.hasExactPoint || location.hasCenter);
  }

  DateTime? _findNewestPublishedAt(List<Map<String, dynamic>> items) {
    DateTime? newest;

    for (final item in items) {
      final publishedAt = _extractPublishedAtFromJson(item);
      if (publishedAt == null) {
        continue;
      }

      if (newest == null || publishedAt.isAfter(newest)) {
        newest = publishedAt;
      }
    }

    return newest;
  }

  bool _isPreservablePreviousLocatedItem(
    Map<String, dynamic> item, {
    required DateTime? newestRefreshedPublishedAt,
  }) {
    final publishedAt = _extractPublishedAtFromJson(item);
    if (publishedAt == null) {
      return false;
    }

    final now = DateTime.now().toUtc();
    if (now.difference(publishedAt) > _maxPreservedLocatedArticleAge) {
      return false;
    }

    if (newestRefreshedPublishedAt != null &&
        publishedAt.isBefore(
          newestRefreshedPublishedAt.subtract(
            _maxPreservedLocatedLagFromNewestRefresh,
          ),
        )) {
      return false;
    }

    return true;
  }

  Future<_CachedNewsFeed?> _readExactCache({
    required String cacheKey,
    required String? requestedLanguage,
  }) async {
    final memoryKey = '$cacheKey|${requestedLanguage ?? ''}';
    final cachedEntry = _exactMemoryCache[memoryKey];
    if (cachedEntry != null &&
        !cachedEntry.isExpired(
          EgressPolicyService.instance.newsMemoryCacheTtl,
        )) {
      return cachedEntry.feed;
    }

    final inFlight = _exactCacheReadsInFlight[memoryKey];
    if (inFlight != null) {
      return inFlight;
    }

    final load = _readExactCacheRemote(
      cacheKey: cacheKey,
      requestedLanguage: requestedLanguage,
    );
    _exactCacheReadsInFlight[memoryKey] = load;

    try {
      final feed = await load;
      if (feed != null) {
        _exactMemoryCache[memoryKey] = _MemoryCachedNewsFeedEntry(
          feed: feed,
          storedAt: DateTime.now().toUtc(),
        );
      }
      return feed;
    } finally {
      if (identical(_exactCacheReadsInFlight[memoryKey], load)) {
        _exactCacheReadsInFlight.remove(memoryKey);
      }
    }
  }

  Future<_CachedNewsFeed?> _readExactCacheRemote({
    required String cacheKey,
    required String? requestedLanguage,
  }) async {
    try {
      final rows = await AppSupabase.client
          .from(_cacheTable)
          .select(
            'cache_key, country_code, city_id, topic, language, '
            'payload, refreshed_at, item_count, '
            'resolved_location_count, provider_signatures, '
            'languages_present, payload_version',
          )
          .eq('cache_key', cacheKey)
          .limit(1);

      if (rows.isEmpty) {
        return null;
      }

      final row = rows.first;

      return _buildCachedNewsFeedFromRow(
        row,
        requestedLanguage: requestedLanguage,
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('NewsRepositoryImpl cache read failed: $e');
        debugPrint('$st');
      }
      return null;
    }
  }

  Future<_CachedNewsFeed?> _readBestFallbackCache({
    required _NewsFeedCandidate candidate,
    required String? requestedLanguage,
  }) async {
    final memoryKey = '${candidate.cacheKey}|${requestedLanguage ?? ''}';
    final cachedEntry = _fallbackMemoryCache[memoryKey];
    if (cachedEntry != null &&
        !cachedEntry.isExpired(
          EgressPolicyService.instance.newsMemoryCacheTtl,
        )) {
      return cachedEntry.feed;
    }

    final inFlight = _fallbackReadsInFlight[memoryKey];
    if (inFlight != null) {
      return inFlight;
    }

    final load = _readBestFallbackCacheRemote(
      candidate: candidate,
      requestedLanguage: requestedLanguage,
    );
    _fallbackReadsInFlight[memoryKey] = load;

    try {
      final feed = await load;
      if (feed != null) {
        _fallbackMemoryCache[memoryKey] = _MemoryCachedNewsFeedEntry(
          feed: feed,
          storedAt: DateTime.now().toUtc(),
        );
      }
      return feed;
    } finally {
      if (identical(_fallbackReadsInFlight[memoryKey], load)) {
        _fallbackReadsInFlight.remove(memoryKey);
      }
    }
  }

  Future<_CachedNewsFeed?> _readBestFallbackCacheRemote({
    required _NewsFeedCandidate candidate,
    required String? requestedLanguage,
  }) async {
    try {
      // NEWS_EGRESS_V1_METADATA_SCAN_START
      // Rank fallbacks using metadata only. The previous implementation loaded
      // multiple full payload JSON arrays just to decide which cache row to use.
      // Country/city views now resolve a lightweight descriptor first and then
      // reuse the exact worldwide payload cache for the selected row.
      final baseQuery = AppSupabase.client.from(_cacheTable).select(
            'cache_key, country_code, city_id, topic, language, '
            'refreshed_at, item_count, resolved_location_count',
          );

      final rows = requestedLanguage == null
          ? await baseQuery
              .order('refreshed_at', ascending: false)
              .limit(EgressPolicyService.instance.newsFallbackScanLimit)
          : await baseQuery
              .eq('language', requestedLanguage)
              .order('refreshed_at', ascending: false)
              .limit(EgressPolicyService.instance.newsFallbackScanLimit);
      // NEWS_EGRESS_V1_METADATA_SCAN_END

      Map<String, dynamic>? bestRow;
      var bestScore = -1;

      for (final rawRow in rows) {
        final row = Map<String, dynamic>.from(rawRow);
        final score = _scoreFallbackCacheMetadata(
          candidate: candidate,
          row: row,
        );
        if (score > bestScore) {
          bestScore = score;
          bestRow = row;
        }
      }

      if (bestRow == null || bestScore < 0) {
        return null;
      }

      final selectedCacheKey = bestRow['cache_key']?.toString().trim() ?? '';
      if (selectedCacheKey.isEmpty) {
        return null;
      }

      // The exact-cache layer deduplicates concurrent reads and shares the
      // selected worldwide payload across Home, News and Civic Map scopes.
      return _readExactCache(
        cacheKey: selectedCacheKey,
        requestedLanguage: requestedLanguage,
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('NewsRepositoryImpl fallback cache read failed: $e');
        debugPrint('$st');
      }
      return null;
    }
  }

  _CachedNewsFeed? _buildCachedNewsFeedFromRow(
    Map<String, dynamic> row, {
    required String? requestedLanguage,
  }) {
    final refreshedAt = _parseDateTime(row['refreshed_at']);
    if (refreshedAt == null) {
      return null;
    }

    final rowLanguage = _normalizeLanguageCode(row['language']?.toString());
    final effectiveDefaultLanguage = requestedLanguage ?? rowLanguage;

    final payload = row['payload'];
    final normalizedPayload = _normalizeFetchedJsonList(
      payload is List ? payload : const <dynamic>[],
      defaultLanguage: effectiveDefaultLanguage,
    );

    final items = _filterItemsForRequestedLanguage(
      normalizedPayload,
      requestedLanguage,
    );

    if (items.isEmpty) {
      return null;
    }

    final metadata = _readCacheMetadataFromRow(
      row,
      fallbackItems: items,
    );

    return _CachedNewsFeed(
      cacheKey: row['cache_key']?.toString() ?? '',
      countryCode: _normalize(row['country_code']?.toString()),
      cityId: _normalize(row['city_id']?.toString()),
      topic: _normalize(row['topic']?.toString()),
      language: rowLanguage,
      items: _sortJsonListByPublishedAtDesc(items),
      refreshedAt: refreshedAt,
      metadata: metadata,
    );
  }

  int _scoreFallbackCacheMetadata({
    required _NewsFeedCandidate candidate,
    required Map<String, dynamic> row,
  }) {
    final language = _normalizeLanguageCode(row['language']?.toString());
    final countryCode = _normalize(row['country_code']?.toString());
    final cityId = _normalize(row['city_id']?.toString());
    final topic = _normalize(row['topic']?.toString());

    if (candidate.language != null &&
        language != null &&
        language != candidate.language) {
      return -1;
    }

    if (candidate.countryCode != null &&
        countryCode != null &&
        countryCode != candidate.countryCode) {
      return -1;
    }

    if (candidate.cityId != null &&
        cityId != null &&
        cityId != candidate.cityId) {
      return -1;
    }

    if (candidate.topic != null && topic != null && topic != candidate.topic) {
      return -1;
    }

    var score = 0;

    if (candidate.language != null && language == candidate.language) {
      score += 200;
    }

    if (candidate.countryCode != null) {
      score += countryCode == candidate.countryCode ? 80 : 20;
    } else if (countryCode == null) {
      score += 10;
    }

    if (candidate.cityId != null) {
      score += cityId == candidate.cityId ? 160 : 10;
    } else if (cityId == null) {
      score += 10;
    }

    if (candidate.topic != null) {
      score += topic == candidate.topic ? 60 : 10;
    } else if (topic == null) {
      score += 10;
    }

    final refreshedAt = _parseDateTime(row['refreshed_at']);
    if (refreshedAt != null &&
        DateTime.now().toUtc().difference(refreshedAt) <= _cacheTtl) {
      score += 40;
    }

    score += (_readInt(row['item_count']) ?? 0).clamp(0, 25);
    score += (_readInt(row['resolved_location_count']) ?? 0).clamp(0, 10);

    return score;
  }

  Future<void> _writeCache({
    required String cacheKey,
    required String? countryCode,
    required String? cityId,
    required String? topic,
    required String? language,
    required List<Map<String, dynamic>> items,
  }) async {
    if (items.isEmpty) {
      return;
    }

    try {
      final metadata = _buildCacheMetadata(items);

      await AppSupabase.client.from(_cacheTable).upsert(
        <String, dynamic>{
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
      _exactMemoryCache.clear();
      _fallbackMemoryCache.clear();
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('NewsRepositoryImpl cache write failed: $e');
        debugPrint('$st');
      }
    }
  }

  Future<NewsItem?> _findCachedNewsById(String newsId) async {
    final requestedId = newsId.trim();
    if (requestedId.isEmpty) {
      return null;
    }

    final requestedIdLower = requestedId.toLowerCase();

    try {
      final rows = await AppSupabase.client
          .from(_cacheTable)
          .select('payload, country_code, city_id, refreshed_at')
          .order('refreshed_at', ascending: false)
          .limit(EgressPolicyService.instance.newsFallbackScanLimit);

      for (final row in rows) {
        final payload = row['payload'];
        if (payload is! List) {
          continue;
        }

        final countryCode = _normalize(row['country_code']?.toString());
        final cityId = _normalize(row['city_id']?.toString());

        final normalizedPayload = _normalizeFetchedJsonList(
          payload,
          defaultLanguage: null,
        );

        for (final json in normalizedPayload) {
          final dto = _tryParseDto(json);
          if (dto == null) {
            continue;
          }

          final contentLocation = _readEmbeddedContentLocation(json);
          final news = _mapper.toDomain(
            dto,
            countryCode: countryCode,
            cityId: cityId,
            contentLocation: contentLocation,
          );

          if (news.id.value.trim().toLowerCase() == requestedIdLower ||
              _matchesRequestedNewsId(json, requestedId)) {
            return news;
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

  Future<List<NewsItem>> _mapFilterAndPaginate({
    required List<Map<String, dynamic>> jsonList,
    required String? countryCode,
    required String? cityId,
    int? limit,
    int? offset,
  }) async {
    final availableJson = await _filterAvailableNewsJson(
      jsonList,
      countryCode: countryCode,
      cityId: cityId,
    );
    final available = _mapJsonToDomainList(
      availableJson,
      countryCode: countryCode,
      cityId: cityId,
      sortByPublishedAt: true,
    );

    if (available.isEmpty) {
      return const <NewsItem>[];
    }

    final safeOffset = offset ?? 0;
    final safeLimit = limit ?? available.length;

    if (safeOffset >= available.length) {
      return const <NewsItem>[];
    }

    final end = (safeOffset + safeLimit) > available.length
        ? available.length
        : (safeOffset + safeLimit);

    return List<NewsItem>.unmodifiable(available.sublist(safeOffset, end));
  }

  Future<bool> _isNewsAvailable(String newsId) async {
    final normalizedId = newsId.trim();
    if (normalizedId.isEmpty) {
      return false;
    }

    final availableIds = await _contentVisibilityFilter.filterVisibleIds(
      targetType: 'news',
      targetIds: <String>[normalizedId],
    );

    return availableIds.contains(normalizedId);
  }

  Future<List<Map<String, dynamic>>> _filterAvailableNewsJson(
    List<Map<String, dynamic>> jsonList, {
    required String? countryCode,
    required String? cityId,
  }) async {
    if (jsonList.isEmpty) {
      return const <Map<String, dynamic>>[];
    }

    final candidates = <_NewsJsonVisibilityCandidate>[];

    for (final json in jsonList) {
      final dto = _tryParseDto(json);
      if (dto == null) {
        continue;
      }

      final contentLocation = _readEmbeddedContentLocation(json);
      final news = _mapper.toDomain(
        dto,
        countryCode: countryCode,
        cityId: cityId,
        contentLocation: contentLocation,
      );
      final id = news.id.value.trim();
      if (id.isEmpty) {
        continue;
      }

      candidates.add(
        _NewsJsonVisibilityCandidate(
          id: id,
          json: Map<String, dynamic>.from(json),
          identityKeys: _buildStableArticleKeysFromJson(json).toSet(),
        ),
      );
    }

    if (candidates.isEmpty) {
      return const <Map<String, dynamic>>[];
    }

    final availableIds = await _contentVisibilityFilter.filterVisibleIds(
      targetType: 'news',
      targetIds: candidates.map((candidate) => candidate.id),
    );

    final locallyRemovedIdentityKeys = <String>{};

    // A hidden UUID may have aliases in the same payload. Capture the stable
    // identity of the blocked item immediately, then reject every alias that
    // points to the same article.
    for (final candidate in candidates) {
      if (!availableIds.contains(candidate.id)) {
        locallyRemovedIdentityKeys.addAll(candidate.identityKeys);
      }
    }

    final removedIdentityKeys = <String>{
      ..._removedNewsIdentityKeys,
      ...locallyRemovedIdentityKeys,
    };

    // The common moderation path is resolved locally without scanning every
    // cache. A global scan is needed only when the current payload contains
    // an alias but not the exact UUID stored by the report.
    if (locallyRemovedIdentityKeys.isEmpty) {
      removedIdentityKeys.addAll(await _loadRemovedNewsIdentityKeys());
    } else {
      _removedNewsIdentityKeys.addAll(locallyRemovedIdentityKeys);
    }

    final output = <Map<String, dynamic>>[];
    final seenIdentityKeys = <String>{};

    for (final candidate in candidates) {
      if (!availableIds.contains(candidate.id)) {
        continue;
      }

      if (candidate.identityKeys.any(removedIdentityKeys.contains)) {
        continue;
      }

      if (candidate.identityKeys.isNotEmpty &&
          candidate.identityKeys.any(seenIdentityKeys.contains)) {
        continue;
      }

      output.add(candidate.json);
      seenIdentityKeys.addAll(candidate.identityKeys);
    }

    return List<Map<String, dynamic>>.unmodifiable(output);
  }

  Future<Set<String>> _loadRemovedNewsIdentityKeys() async {
    final now = DateTime.now().toUtc();
    final loadedAt = _removedNewsIdentityKeysLoadedAt;

    if (loadedAt != null &&
        now.difference(loadedAt) <=
            EgressPolicyService.instance.removedNewsIdentityCacheTtl) {
      return Set<String>.unmodifiable(_removedNewsIdentityKeys);
    }

    final inFlight = _removedNewsIdentityKeysLoad;
    if (inFlight != null) {
      return inFlight;
    }

    final load = _scanRemovedNewsIdentityKeys();
    _removedNewsIdentityKeysLoad = load;

    try {
      final keys = await load;
      _removedNewsIdentityKeys = Set<String>.from(keys);
      _removedNewsIdentityKeysLoadedAt = DateTime.now().toUtc();
      return Set<String>.unmodifiable(_removedNewsIdentityKeys);
    } finally {
      if (identical(_removedNewsIdentityKeysLoad, load)) {
        _removedNewsIdentityKeysLoad = null;
      }
    }
  }

  Future<Set<String>> _scanRemovedNewsIdentityKeys() async {
    try {
      final rows = await AppSupabase.client
          .from(_cacheTable)
          .select('payload, country_code, city_id, refreshed_at')
          .order('refreshed_at', ascending: false)
          .limit(EgressPolicyService.instance.newsFallbackScanLimit);

      final identityKeysByMappedId = <String, Set<String>>{};

      for (final row in rows) {
        final payload = row['payload'];
        if (payload is! List) {
          continue;
        }

        final rowCountryCode = _normalize(row['country_code']?.toString());
        final rowCityId = _normalize(row['city_id']?.toString());
        final normalizedPayload = _normalizeFetchedJsonList(
          payload,
          defaultLanguage: null,
        );

        for (final json in normalizedPayload) {
          final dto = _tryParseDto(json);
          if (dto == null) {
            continue;
          }

          final contentLocation = _readEmbeddedContentLocation(json);
          final news = _mapper.toDomain(
            dto,
            countryCode: rowCountryCode,
            cityId: rowCityId,
            contentLocation: contentLocation,
          );
          final mappedId = news.id.value.trim();
          if (mappedId.isEmpty) {
            continue;
          }

          identityKeysByMappedId
              .putIfAbsent(mappedId, () => <String>{})
              .addAll(_buildStableArticleKeysFromJson(json));
        }
      }

      if (identityKeysByMappedId.isEmpty) {
        return <String>{};
      }

      final availableIds = await _contentVisibilityFilter.filterVisibleIds(
        targetType: 'news',
        targetIds: identityKeysByMappedId.keys,
      );

      final removedKeys = <String>{};
      for (final entry in identityKeysByMappedId.entries) {
        if (!availableIds.contains(entry.key)) {
          removedKeys.addAll(entry.value);
        }
      }

      return Set<String>.unmodifiable(removedKeys);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint(
          'NewsRepositoryImpl removed-news identity scan failed: $e',
        );
        debugPrint('$st');
      }

      return Set<String>.unmodifiable(_removedNewsIdentityKeys);
    }
  }

  List<NewsItem> _mapJsonToDomainList(
    List<Map<String, dynamic>> jsonList, {
    required String? countryCode,
    required String? cityId,
    bool sortByPublishedAt = true,
  }) {
    final items = <NewsItem>[];

    for (final json in jsonList) {
      final dto = _tryParseDto(json);
      if (dto == null) {
        continue;
      }

      final contentLocation = _readEmbeddedContentLocation(json);

      items.add(
        _mapper.toDomain(
          dto,
          countryCode: countryCode,
          cityId: cityId,
          contentLocation: contentLocation,
        ),
      );
    }

    if (sortByPublishedAt) {
      items.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    }

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

  List<Map<String, dynamic>> _normalizeFetchedJsonList(
    List<dynamic> rawList, {
    required String? defaultLanguage,
  }) {
    final output = <Map<String, dynamic>>[];

    for (final raw in rawList) {
      if (raw is! Map) {
        continue;
      }

      final json = raw.map(
        (key, value) => MapEntry(key.toString(), value),
      );

      _flattenSourceFields(json);
      _normalizePublishedAtField(json);
      _normalizeUrlFields(json);

      final existingLanguage = _extractItemLanguage(json);
      if (existingLanguage == null &&
          defaultLanguage != null &&
          defaultLanguage.trim().isNotEmpty) {
        json['language'] = defaultLanguage;
      }

      output.add(json);
    }

    return List<Map<String, dynamic>>.unmodifiable(output);
  }

  void _flattenSourceFields(Map<String, dynamic> json) {
    final source = json['source'];
    if (source is Map) {
      final sourceName = source['name'];
      final sourceId = source['id'];
      final sourceUrl = source['url'];

      if (!_hasNonEmptyScalar(json['sourceName']) && sourceName != null) {
        json['sourceName'] = sourceName.toString();
      }
      if (!_hasNonEmptyScalar(json['sourceId']) && sourceId != null) {
        json['sourceId'] = sourceId.toString();
      }
      if (!_hasNonEmptyScalar(json['sourceUrl']) && sourceUrl != null) {
        json['sourceUrl'] = sourceUrl.toString();
      }
    }

    final provider = json['provider'];
    if (provider is Map) {
      final providerName = provider['name'];
      final providerId = provider['id'];
      final providerUrl = provider['url'];

      if (!_hasNonEmptyScalar(json['providerName']) && providerName != null) {
        json['providerName'] = providerName.toString();
      }
      if (!_hasNonEmptyScalar(json['providerId']) && providerId != null) {
        json['providerId'] = providerId.toString();
      }
      if (!_hasNonEmptyScalar(json['providerUrl']) && providerUrl != null) {
        json['providerUrl'] = providerUrl.toString();
      }
    }

    json['sourceName'] ??= json['source_name'];
    json['sourceId'] ??= json['source_id'];
    json['sourceUrl'] ??= json['source_url'];
    json['providerName'] ??= json['provider_name'];
    json['providerId'] ??= json['provider_id'];
    json['providerUrl'] ??= json['provider_url'];
  }

  void _normalizePublishedAtField(Map<String, dynamic> json) {
    final publishedAt = _extractPublishedAtFromJson(json);
    if (publishedAt != null) {
      json['publishedAt'] = publishedAt.toUtc().toIso8601String();
    }
  }

  void _normalizeUrlFields(Map<String, dynamic> json) {
    final articleUrl = _firstNonEmptyString(
      json,
      const <String>[
        'articleUrl',
        'article_url',
        'url',
        'link',
        'canonical_url',
        'canonicalUrl',
      ],
    );

    if (articleUrl != null) {
      json['url'] ??= articleUrl;
      json['articleUrl'] ??= articleUrl;
      json['article_url'] ??= articleUrl;
    }

    final sourceUrl = _firstNonEmptyString(
      json,
      const <String>[
        'sourceUrl',
        'source_url',
        'providerUrl',
        'provider_url',
      ],
    );

    if (sourceUrl != null) {
      json['sourceUrl'] ??= sourceUrl;
      json['source_url'] ??= sourceUrl;
    }
  }

  bool _hasNonEmptyScalar(dynamic value) {
    if (value == null) {
      return false;
    }

    if (value is Map || value is List) {
      return false;
    }

    final text = value.toString().trim();
    return text.isNotEmpty;
  }

  List<Map<String, dynamic>> _retainCacheUsableItems(
    List<Map<String, dynamic>> items,
  ) {
    final output = <Map<String, dynamic>>[];

    for (final item in items) {
      final copy = Map<String, dynamic>.from(item);
      final dto = _tryParseDto(copy);
      if (dto == null) {
        continue;
      }

      if (dto.id.trim().isEmpty) {
        continue;
      }

      if (dto.title.trim().isEmpty) {
        continue;
      }

      _normalizeUrlFields(copy);
      output.add(copy);
    }

    return List<Map<String, dynamic>>.unmodifiable(output);
  }

  List<Map<String, dynamic>> _filterItemsForRequestedLanguage(
    List<Map<String, dynamic>> items,
    String? requestedLanguage,
  ) {
    final normalizedRequestedLanguage = _normalizeLanguageCode(
      requestedLanguage,
    );

    if (normalizedRequestedLanguage == null) {
      return List<Map<String, dynamic>>.unmodifiable(
        items.map((item) => Map<String, dynamic>.from(item)).toList(),
      );
    }

    final filtered = items.where((item) {
      final itemLanguage = _extractItemLanguage(item);
      return itemLanguage == normalizedRequestedLanguage;
    }).map((item) {
      return Map<String, dynamic>.from(item);
    }).toList(growable: false);

    return List<Map<String, dynamic>>.unmodifiable(filtered);
  }

  List<Map<String, dynamic>> _sortJsonListByPublishedAtDesc(
    List<Map<String, dynamic>> items,
  ) {
    final sorted = items
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);

    sorted.sort((a, b) {
      final aDate = _extractPublishedAtFromJson(a);
      final bDate = _extractPublishedAtFromJson(b);

      if (aDate == null && bDate == null) {
        return 0;
      }
      if (aDate == null) {
        return 1;
      }
      if (bDate == null) {
        return -1;
      }

      return bDate.compareTo(aDate);
    });

    return List<Map<String, dynamic>>.unmodifiable(sorted);
  }

  Future<List<Map<String, dynamic>>> _enrichItemsForCache(
    List<Map<String, dynamic>> items, {
    required int targetResolvedCount,
  }) async {
    if (items.isEmpty) {
      return const <Map<String, dynamic>>[];
    }

    final output = items
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);

    if (targetResolvedCount <= 0) {
      return List<Map<String, dynamic>>.unmodifiable(output);
    }

    final maxGeocodeAttempts =
        (targetResolvedCount * 2) > _maxArticlesToGeocodePerRefresh
            ? _maxArticlesToGeocodePerRefresh
            : (targetResolvedCount * 2);

    var resolvedCount = 0;
    var geocodeAttempts = 0;

    for (final item in output) {
      final existingLocation = _readEmbeddedContentLocation(item);
      if (existingLocation != null &&
          (existingLocation.hasExactPoint || existingLocation.hasCenter)) {
        resolvedCount += 1;
      }
    }

    for (final item in output) {
      if (resolvedCount >= targetResolvedCount) {
        break;
      }

      if (geocodeAttempts >= maxGeocodeAttempts) {
        break;
      }

      final existingLocation = _readEmbeddedContentLocation(item);
      if (existingLocation != null &&
          (existingLocation.hasExactPoint || existingLocation.hasCenter)) {
        continue;
      }

      final dto = _tryParseDto(item);
      if (dto == null) {
        continue;
      }

      geocodeAttempts += 1;

      try {
        final detectedLocation = await _detectContentLocationForDto(
          dto,
          rawJson: item,
        ).timeout(_perArticleGeocodeTimeout);

        if (detectedLocation != null) {
          item['_sv_content_location'] = detectedLocation.toJson();
          resolvedCount += 1;
        }
      } catch (_) {
        // best effort
      }
    }

    return List<Map<String, dynamic>>.unmodifiable(output);
  }

  Future<ContentLocation?> _detectContentLocationForDto(
    NewsDto dto, {
    Map<String, dynamic>? rawJson,
  }) async {
    final preferredSeed = rawJson == null
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
      if (value == null || value is Map || value is List) {
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
        .toList(growable: false);

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

  String _extractPrimaryLocationWindow(
    String text, {
    required int maxLength,
  }) {
    final cleaned = _stripHtml(text);
    if (cleaned.isEmpty) {
      return '';
    }

    final window =
        cleaned.length <= maxLength ? cleaned : cleaned.substring(0, maxLength);

    for (final match in RegExp(r'[.!?;]').allMatches(window)) {
      if (match.start >= 40) {
        return window.substring(0, match.start).trim();
      }
    }

    return window.trim();
  }

  _DatelineLocationPair? _extractDatelineLocationPair(String text) {
    final cleaned = text
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleaned.isEmpty) {
      return null;
    }

    final openingWindow =
        cleaned.length <= 120 ? cleaned : cleaned.substring(0, 120);

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
      r"\b((?:[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'’\-]+|[A-Z]{2,})(?:\s+(?:[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'’\-]+|[A-Z]{2,})){0,2})\s*,\s*((?:[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'’\-]+|[A-Z]{2,})(?:\s+(?:[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'’\-]+|[A-Z]{2,})){0,2})\b",
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

    final openingWindow =
        cleaned.length <= 160 ? cleaned : cleaned.substring(0, 160);

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
      resolvedLocationCount: _readInt(row['resolved_location_count']) ??
          fallback.resolvedLocationCount,
      providerSignatures: _readStringList(row['provider_signatures']) ??
          fallback.providerSignatures,
      languagesPresent: _readStringList(row['languages_present']) ??
          fallback.languagesPresent,
      payloadVersion:
          _readInt(row['payload_version']) ?? fallback.payloadVersion,
    );
  }

  String? _extractProviderSignature(Map<String, dynamic> json) {
    final sourceName = _normalizeMetadataToken(
      _firstNonEmptyString(
            json,
            const <String>[
              'sourceId',
              'source_id',
              'sourceName',
              'source_name',
              'providerSignature',
              'provider_signature',
              'providerName',
              'provider_name',
              'providerId',
              'provider_id',
            ],
          ) ??
          _tryParseDto(json)?.sourceId ??
          _tryParseDto(json)?.sourceName,
    );

    if (sourceName != null) {
      return sourceName;
    }

    final source = json['source'];
    if (source is Map) {
      final sourceMap = source.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      final fromSource = _normalizeMetadataToken(
        _firstNonEmptyString(
          sourceMap,
          const <String>['name', 'id'],
        ),
      );
      if (fromSource != null) {
        return fromSource;
      }
    }

    final provider = json['provider'];
    if (provider is Map) {
      final providerMap = provider.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      final fromProvider = _normalizeMetadataToken(
        _firstNonEmptyString(
          providerMap,
          const <String>['name', 'id'],
        ),
      );
      if (fromProvider != null) {
        return fromProvider;
      }
    }

    final dto = _tryParseDto(json);
    return _normalizeMetadataToken(dto?.sourceId) ??
        _normalizeMetadataToken(dto?.sourceName);
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
      final normalized = _normalizeMetadataToken(item?.toString());
      if (normalized != null) {
        output.add(normalized);
      }
    }

    return output.toList()..sort();
  }

  String? _normalizeMetadataToken(String? value) {
    final normalized = _normalizePhrase(value);
    if (normalized == null) {
      return null;
    }

    if (normalized == '[object object]' ||
        normalized == 'object object' ||
        normalized.startsWith('{') ||
        normalized.startsWith('instance of')) {
      return null;
    }

    return normalized;
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
              'sourceId',
              'source_id',
              'sourceName',
              'source_name',
              'providerId',
              'provider_id',
              'providerName',
              'provider_name',
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

    final rawId = dto?.id.trim() ??
        _firstNonEmptyString(json, const <String>['id'])?.trim() ??
        '';

    if (rawId.isNotEmpty) {
      addKey('id:$sourceHint:${rawId.toLowerCase()}');
    }

    final title = (dto?.title ??
            _firstNonEmptyString(json, const <String>['title', 'headline']))
        ?.trim();

    final publishedAt = dto?.publishedAt ?? _extractPublishedAtFromJson(json);

    if (title != null && title.isNotEmpty) {
      final normalizedTitle = title.toLowerCase();

      // Provider/cache aliases of the same article can expose different IDs,
      // URLs or publication timestamps. Source + title remains stable across
      // those copies and lets a hidden report suppress every matching alias.
      addKey('title:$sourceHint:$normalizedTitle');

      if (publishedAt != null) {
        addKey(
          'title:$sourceHint:$normalizedTitle:${publishedAt.toUtc().toIso8601String()}',
        );
      }
    }

    return keys.toList(growable: false);
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

    return requestedUrl != null && itemUrl != null && requestedUrl == itemUrl;
  }

  int _countItemsWithResolvedLocation(List<Map<String, dynamic>> items) {
    var count = 0;

    for (final item in items) {
      final location = _readEmbeddedContentLocation(item);
      if (location != null && (location.hasExactPoint || location.hasCenter)) {
        count += 1;
      }
    }

    return count;
  }

  DateTime? _extractPublishedAtFromJson(Map<String, dynamic> json) {
    return _parseDateTime(
      json['publishedAt'] ??
          json['published_at'] ??
          json['pubDate'] ??
          json['date'] ??
          json['created_at'] ??
          json['createdAt'],
    );
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

    final normalizedPath =
        parsed.path.isEmpty ? '/' : parsed.path.replaceFirst(RegExp(r'/$'), '');

    return Uri(
      scheme: parsed.scheme.toLowerCase(),
      host: parsed.host.toLowerCase(),
      port: parsed.hasPort ? parsed.port : null,
      path: normalizedPath.isEmpty ? '/' : normalizedPath,
    ).toString().toLowerCase();
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

class _NewsJsonVisibilityCandidate {
  final String id;
  final Map<String, dynamic> json;
  final Set<String> identityKeys;

  const _NewsJsonVisibilityCandidate({
    required this.id,
    required this.json,
    required this.identityKeys,
  });
}

class _MemoryCachedNewsFeedEntry {
  final _CachedNewsFeed feed;
  final DateTime storedAt;

  const _MemoryCachedNewsFeedEntry({
    required this.feed,
    required this.storedAt,
  });

  bool isExpired(Duration ttl) {
    return DateTime.now().toUtc().difference(storedAt) > ttl;
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
  final String cacheKey;
  final String? countryCode;
  final String? cityId;
  final String? topic;
  final String? language;
  final List<Map<String, dynamic>> items;
  final DateTime refreshedAt;
  final _CachePayloadMetadata metadata;

  const _CachedNewsFeed({
    required this.cacheKey,
    required this.countryCode,
    required this.cityId,
    required this.topic,
    required this.language,
    required this.items,
    required this.refreshedAt,
    required this.metadata,
  });
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
