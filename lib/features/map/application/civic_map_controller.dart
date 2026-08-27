import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';

enum CivicMapStatus {
  initial,
  loading,
  loaded,
  empty,
  error,
}

enum CivicMapItemType {
  poll,
  post,
  news,
}

enum CivicMapHeatTier {
  normal,
  active,
  hot,
}

enum CivicMapMarkerSizeTier {
  small,
  medium,
  large,
}

/// Regole uniche di heat per tutta la Civic Map.
///
/// Nota importante:
/// - `heat` del contenuto = valore reale già esistente nell'app
/// - la mappa NON inventa un secondo heat
/// - la mappa deriva solo un punteggio unico per ranking/stile
class CivicMapHeatRules {
  static const double commentWeight = 1.5;

  static const double activeThreshold = 8.0;
  static const double hotThreshold = 20.0;

  const CivicMapHeatRules._();

  static double normalizeHeat(double value) {
    if (!value.isFinite || value < 0) {
      return 0;
    }
    return value;
  }

  static int normalizeCommentCount(int value) {
    if (value < 0) {
      return 0;
    }
    return value;
  }

  static double computeScore({
    required double heat,
    required int commentCount,
  }) {
    final normalizedHeat = normalizeHeat(heat);
    final normalizedComments = normalizeCommentCount(commentCount);

    return normalizedHeat + (normalizedComments * commentWeight);
  }

  static CivicMapHeatTier resolveTierFromScore(double score) {
    if (score >= hotThreshold) {
      return CivicMapHeatTier.hot;
    }
    if (score >= activeThreshold) {
      return CivicMapHeatTier.active;
    }
    return CivicMapHeatTier.normal;
  }

  static CivicMapHeatTier resolveTier({
    required double heat,
    required int commentCount,
  }) {
    return resolveTierFromScore(
      computeScore(
        heat: heat,
        commentCount: commentCount,
      ),
    );
  }

  static String? buildBadgeLabel({
    required double heat,
    required int commentCount,
  }) {
    final score = computeScore(
      heat: heat,
      commentCount: commentCount,
    );
    final tier = resolveTierFromScore(score);

    if (tier == CivicMapHeatTier.hot) {
      return 'HOT';
    }

    if (tier == CivicMapHeatTier.active) {
      final total =
          normalizeHeat(heat).toInt() + normalizeCommentCount(commentCount);
      if (total <= 0) {
        return null;
      }
      return total > 99 ? '99+' : '$total';
    }

    return null;
  }
}

/// Ranking civico dedicato alla mappa.
///
/// Non modifica Heat/Ice del prodotto: usa i segnali già disponibili
/// (reazioni, commenti, recenza e tipo contenuto) per decidere soltanto
/// priorità e dimensione visuale dei marker.
class CivicMapImportanceRules {
  static const double _recencyWindowHours = 24 * 14;

  const CivicMapImportanceRules._();

  static double computeScore({
    required CivicMapItemType type,
    required double heat,
    required int commentCount,
    required DateTime? createdAt,
    bool isBreaking = false,
    bool isFeatured = false,
    int editorialPriority = 0,
  }) {
    final normalizedHeat = CivicMapHeatRules.normalizeHeat(heat);
    final normalizedComments =
        CivicMapHeatRules.normalizeCommentCount(commentCount);

    // Crescita logaritmica: un contenuto molto popolare resta importante
    // senza schiacciare completamente tutti gli altri marker.
    final rawEngagementScore = math.log(1 + normalizedHeat) * 11.0 +
        math.log(1 + normalizedComments) * 9.0;
    final engagementScore = type == CivicMapItemType.news
        ? rawEngagementScore * 0.25
        : rawEngagementScore;

    final recencyScore = _computeRecencyScore(
      createdAt,
      windowHours: type == CivicMapItemType.news ? 24 * 7 : _recencyWindowHours,
      maxScore: type == CivicMapItemType.news ? 20.0 : 12.0,
    );
    final civicTypeBoost = _typeBoost(type);
    final normalizedEditorialPriority = editorialPriority.clamp(0, 100);
    final newsEditorialScore = type == CivicMapItemType.news
        ? (isBreaking ? 20.0 : 0.0) +
            (isFeatured ? 26.0 : 0.0) +
            (normalizedEditorialPriority * 0.5)
        : 0.0;

    return engagementScore + recencyScore + civicTypeBoost + newsEditorialScore;
  }

  static double _computeRecencyScore(
    DateTime? createdAt, {
    required double windowHours,
    required double maxScore,
  }) {
    if (createdAt == null) {
      return 0;
    }

    final ageHours = math.max(
      0,
      DateTime.now().difference(createdAt).inMinutes / 60.0,
    );

    if (ageHours >= windowHours) {
      return 0;
    }

    final remainingRatio = 1.0 - (ageHours / windowHours);

    return remainingRatio * maxScore;
  }

  static CivicMapMarkerSizeTier resolveMarkerSizeTier(double score) {
    if (score >= 58.0) {
      return CivicMapMarkerSizeTier.large;
    }
    if (score >= 28.0) {
      return CivicMapMarkerSizeTier.medium;
    }
    return CivicMapMarkerSizeTier.small;
  }

  static double _typeBoost(CivicMapItemType type) {
    switch (type) {
      case CivicMapItemType.poll:
        return 10.0;
      case CivicMapItemType.post:
        return 5.0;
      case CivicMapItemType.news:
        return 0.0;
    }
  }
}

/// Selezione unica dei contenuti da consegnare ai renderer Globe.
///
/// Mantiene il ranking esistente ma impedisce che Poll/Post occupino tutti i
/// posti disponibili quando esistono News con coordinate valide. Il limite
/// News resta esplicito per evitare che il Globe diventi un secondo feed.
class CivicMapMarkerSelectionRules {
  const CivicMapMarkerSelectionRules._();

  static List<CivicMapItem> select({
    required Iterable<CivicMapItem> items,
    required int totalLimit,
    required int newsLimit,
  }) {
    if (totalLimit <= 0) {
      return const <CivicMapItem>[];
    }

    final sorted = items.toList(growable: false)
      ..sort(
        (a, b) => b.mapImportanceScore.compareTo(a.mapImportanceScore),
      );

    if (sorted.isEmpty) {
      return const <CivicMapItem>[];
    }

    final byType = <CivicMapItemType, List<CivicMapItem>>{
      for (final type in CivicMapItemType.values)
        type: sorted.where((item) => item.type == type).toList(growable: false),
    };
    final nonEmptyTypes = byType.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => entry.key)
        .toList(growable: false);

    // A single active Civic Map filter must be able to use the whole marker
    // budget. The News cap only applies to mixed-content views.
    if (nonEmptyTypes.length == 1) {
      return byType[nonEmptyTypes.single]!
          .take(totalLimit)
          .toList(growable: false);
    }

    final effectiveNewsLimit = math.min(totalLimit, math.max(0, newsLimit));
    final remainingAfterNews = math.max(0, totalLimit - effectiveNewsLimit);
    final civicBaseLimit = remainingAfterNews ~/ 2;

    final selected = <CivicMapItem>[];
    final selectedKeys = <String>{};

    void takeType(CivicMapItemType type, int limit) {
      for (final item in byType[type]!.take(limit)) {
        final key = '${item.type.name}:${item.id}';
        if (selectedKeys.add(key)) {
          selected.add(item);
        }
      }
    }

    takeType(CivicMapItemType.news, effectiveNewsLimit);
    takeType(CivicMapItemType.poll, civicBaseLimit);
    takeType(CivicMapItemType.post, civicBaseLimit);

    // Fill unused slots from the global ranking. News remains capped while
    // Vote/Voce can use spare capacity if the other civic type is scarce.
    for (final item in sorted) {
      if (selected.length >= totalLimit) break;
      final key = '${item.type.name}:${item.id}';
      if (selectedKeys.contains(key)) continue;
      if (item.type == CivicMapItemType.news &&
          selected
                  .where((entry) => entry.type == CivicMapItemType.news)
                  .length >=
              effectiveNewsLimit) {
        continue;
      }
      selectedKeys.add(key);
      selected.add(item);
    }

    selected.sort(
      (a, b) => b.mapImportanceScore.compareTo(a.mapImportanceScore),
    );
    return selected.take(totalLimit).toList(growable: false);
  }
}

class CivicMapItem {
  final String id;
  final TargetRef targetRef;
  final CivicMapItemType type;
  final String title;
  final String? subtitle;
  final NewsItem? newsItem;
  final GeoScope? geoScope;
  final ContentLocation? contentLocation;
  final double latitude;
  final double longitude;

  /// Heat reale del contenuto già esistente nel sistema.
  final double heat;

  final int commentCount;
  final DateTime? createdAt;
  final bool isBreaking;
  final bool isFeatured;
  final int editorialPriority;

  const CivicMapItem({
    required this.id,
    required this.targetRef,
    required this.type,
    required this.title,
    this.subtitle,
    this.newsItem,
    this.geoScope,
    this.contentLocation,
    required this.latitude,
    required this.longitude,
    this.heat = 0,
    this.commentCount = 0,
    this.createdAt,
    this.isBreaking = false,
    this.isFeatured = false,
    this.editorialPriority = 0,
  });

  double get normalizedHeat => CivicMapHeatRules.normalizeHeat(heat);

  int get normalizedCommentCount =>
      CivicMapHeatRules.normalizeCommentCount(commentCount);

  /// Punteggio unico usato dalla mappa per:
  /// - ordinamento
  /// - styling
  /// - badge/hot marker
  double get mapHeatScore {
    return CivicMapHeatRules.computeScore(
      heat: normalizedHeat,
      commentCount: normalizedCommentCount,
    );
  }

  /// Punteggio di importanza dedicato esclusivamente alla Civic Map.
  ///
  /// Tiene conto di:
  /// - Heat/reazioni;
  /// - commenti;
  /// - recenza;
  /// - rilevanza civica del tipo contenuto.
  double get mapImportanceScore {
    return CivicMapImportanceRules.computeScore(
      type: type,
      heat: normalizedHeat,
      commentCount: normalizedCommentCount,
      createdAt: createdAt,
      isBreaking: isBreaking,
      isFeatured: isFeatured,
      editorialPriority: editorialPriority,
    );
  }

  CivicMapHeatTier get heatTier {
    return CivicMapHeatRules.resolveTierFromScore(mapHeatScore);
  }

  CivicMapMarkerSizeTier get markerSizeTier {
    return CivicMapImportanceRules.resolveMarkerSizeTier(mapImportanceScore);
  }

  bool get isHot => heatTier == CivicMapHeatTier.hot;

  bool get isActive => heatTier != CivicMapHeatTier.normal;

  String? get heatBadgeLabel {
    return CivicMapHeatRules.buildBadgeLabel(
      heat: normalizedHeat,
      commentCount: normalizedCommentCount,
    );
  }

  CivicMapItem copyWith({
    String? id,
    TargetRef? targetRef,
    CivicMapItemType? type,
    String? title,
    String? subtitle,
    NewsItem? newsItem,
    GeoScope? geoScope,
    ContentLocation? contentLocation,
    double? latitude,
    double? longitude,
    double? heat,
    int? commentCount,
    DateTime? createdAt,
    bool? isBreaking,
    bool? isFeatured,
    int? editorialPriority,
  }) {
    return CivicMapItem(
      id: id ?? this.id,
      targetRef: targetRef ?? this.targetRef,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      newsItem: newsItem ?? this.newsItem,
      geoScope: geoScope ?? this.geoScope,
      contentLocation: contentLocation ?? this.contentLocation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      heat: heat ?? this.heat,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      isBreaking: isBreaking ?? this.isBreaking,
      isFeatured: isFeatured ?? this.isFeatured,
      editorialPriority: editorialPriority ?? this.editorialPriority,
    );
  }
}

typedef CivicMapItemsLoader = Future<List<CivicMapItem>> Function(
  GeoScope scope,
);

typedef CivicMapRefreshHook = Future<void> Function(
  GeoScope scope,
);

class _CivicMapLoadResult {
  final String sourceName;
  final List<CivicMapItem> items;
  final String? error;
  final int elapsedMs;

  const _CivicMapLoadResult({
    required this.sourceName,
    required this.items,
    required this.error,
    required this.elapsedMs,
  });

  bool get hasError => error != null && error!.trim().isNotEmpty;
}

class CivicMapController extends ChangeNotifier {
  final CivicMapItemsLoader? loadPollItems;
  final CivicMapItemsLoader? loadPostItems;
  final CivicMapItemsLoader? loadNewsItems;
  final CivicMapRefreshHook? beforeRefresh;

  CivicMapController({
    this.loadPollItems,
    this.loadPostItems,
    this.loadNewsItems,
    this.beforeRefresh,
  });

  bool _isDisposed = false;

  CivicMapStatus _status = CivicMapStatus.initial;
  CivicMapStatus get status => _status;

  GeoScope? _currentScope;
  GeoScope? get currentScope => _currentScope;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  Map<String, int> _lastLoadMetricsMs = <String, int>{};
  Map<String, int> get lastLoadMetricsMs =>
      Map.unmodifiable(_lastLoadMetricsMs);

  Map<String, int> _lastLoadItemCounts = <String, int>{};
  Map<String, int> get lastLoadItemCounts =>
      Map.unmodifiable(_lastLoadItemCounts);

  String? _lastLoadMetricsSummary;
  String? get lastLoadMetricsSummary => _lastLoadMetricsSummary;

  final List<CivicMapItem> _allItems = <CivicMapItem>[];
  final List<CivicMapItem> _visibleItems = <CivicMapItem>[];
  final List<CivicMapItem> _pollItems = <CivicMapItem>[];
  final List<CivicMapItem> _postItems = <CivicMapItem>[];
  final List<CivicMapItem> _newsItems = <CivicMapItem>[];

  List<CivicMapItem> get allItems => List.unmodifiable(_allItems);
  List<CivicMapItem> get visibleItems => List.unmodifiable(_visibleItems);

  Set<CivicMapItemType> _visibleTypes = <CivicMapItemType>{
    CivicMapItemType.poll,
    CivicMapItemType.post,
    CivicMapItemType.news,
  };
  Set<CivicMapItemType> get visibleTypes => Set.unmodifiable(_visibleTypes);

  String? _selectedItemId;
  String? get selectedItemId => _selectedItemId;

  String? _selectedTargetRefKey;
  String? get selectedTargetRefKey => _selectedTargetRefKey;

  int _loadRequestId = 0;
  Future<void>? _activeLoadFuture;
  String? _activeLoadScopeKey;
  bool _activeLoadIsExplicitRefresh = false;

  CivicMapItem? get selectedItem {
    if (_selectedItemId == null && _selectedTargetRefKey == null) {
      return null;
    }

    for (final item in _visibleItems) {
      if (_selectedItemId != null && item.id == _selectedItemId) {
        return item;
      }
    }

    if (_selectedTargetRefKey != null) {
      for (final item in _visibleItems) {
        if (_targetRefKey(item.targetRef) == _selectedTargetRefKey) {
          return item;
        }
      }
    }

    return null;
  }

  bool get isLoading => _status == CivicMapStatus.loading;
  bool get hasError => _status == CivicMapStatus.error;
  bool get isEmpty => _status == CivicMapStatus.empty;
  bool get hasData => _status == CivicMapStatus.loaded;
  bool get hasSelection => selectedItem != null;

  @override
  void dispose() {
    _isDisposed = true;
    _loadRequestId++;
    _activeLoadFuture = null;
    _activeLoadScopeKey = null;
    _activeLoadIsExplicitRefresh = false;
    super.dispose();
  }

  Future<void> syncScope(
    GeoScope? scope, {
    bool forceReload = false,
    bool clearSelection = true,
  }) async {
    if (scope == null) return;

    final sameScope = _isSameScope(_currentScope, scope);
    final shouldSkip = !forceReload &&
        sameScope &&
        _status != CivicMapStatus.initial &&
        !_shouldRetryCurrentScope();

    if (shouldSkip) {
      return;
    }

    await _queueLoadForScope(
      scope,
      clearSelection: clearSelection && !sameScope,
      explicitRefresh: forceReload,
    );
  }

  Future<void> loadForScope(
    GeoScope scope, {
    bool clearSelection = true,
  }) {
    return _queueLoadForScope(
      scope,
      clearSelection: clearSelection,
      explicitRefresh: false,
    );
  }

  Future<void> refresh() async {
    final scope = _currentScope;
    if (scope == null) return;

    await _queueLoadForScope(
      scope,
      clearSelection: false,
      explicitRefresh: true,
    );
  }

  Future<void> refreshMetrics() async {
    await refresh();
  }

  void patchItemMetrics({
    required TargetRef targetRef,
    double? heat,
    int? commentCount,
  }) {
    if (_isDisposed) return;

    final targetKey = _targetRefKey(targetRef);
    if (targetKey == null) return;

    var changed = false;

    bool patchList(List<CivicMapItem> items) {
      var localChanged = false;

      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        if (_targetRefKey(item.targetRef) != targetKey) {
          continue;
        }

        final nextHeat =
            heat == null ? item.heat : CivicMapHeatRules.normalizeHeat(heat);
        final nextCommentCount = commentCount == null
            ? item.commentCount
            : CivicMapHeatRules.normalizeCommentCount(commentCount);

        if (nextHeat == item.heat && nextCommentCount == item.commentCount) {
          continue;
        }

        items[i] = item.copyWith(
          heat: nextHeat,
          commentCount: nextCommentCount,
        );
        localChanged = true;
      }

      return localChanged;
    }

    changed = patchList(_pollItems) || changed;
    changed = patchList(_postItems) || changed;
    changed = patchList(_newsItems) || changed;

    if (!changed) {
      return;
    }

    _rebuildMergedItems();
    _reconcileSelectionAfterDataChange();
    _notifySafely();
  }

  void patchSelectedItemMetrics({
    double? heat,
    int? commentCount,
  }) {
    final item = selectedItem;
    if (item == null) return;

    patchItemMetrics(
      targetRef: item.targetRef,
      heat: heat,
      commentCount: commentCount,
    );
  }

  Future<void> _queueLoadForScope(
    GeoScope scope, {
    required bool clearSelection,
    required bool explicitRefresh,
  }) {
    if (_isDisposed) {
      return Future<void>.value();
    }

    final scopeKey = _scopeKey(scope);
    final activeLoad = _activeLoadFuture;

    if (activeLoad != null &&
        _activeLoadScopeKey == scopeKey &&
        (!explicitRefresh || _activeLoadIsExplicitRefresh)) {
      return activeLoad;
    }

    late final Future<void> future;
    future = _performLoadForScope(
      scope,
      clearSelection: clearSelection,
      explicitRefresh: explicitRefresh,
    ).catchError((Object error, StackTrace stackTrace) {
      if (_isDisposed || !identical(_activeLoadFuture, future)) {
        return;
      }

      if (kDebugMode) {
        debugPrint('CivicMap unexpected load failure: $error');
        debugPrint('$stackTrace');
      }

      _isRefreshing = false;
      _errorMessage = error.toString();
      _setStatus(
        _allItems.isNotEmpty ? CivicMapStatus.loaded : CivicMapStatus.error,
      );
      _notifySafely();
    }).whenComplete(() {
      if (_isDisposed || !identical(_activeLoadFuture, future)) {
        return;
      }

      _activeLoadFuture = null;
      _activeLoadScopeKey = null;
      _activeLoadIsExplicitRefresh = false;
    });

    _activeLoadFuture = future;
    _activeLoadScopeKey = scopeKey;
    _activeLoadIsExplicitRefresh = explicitRefresh;

    return future;
  }

  Future<void> _performLoadForScope(
    GeoScope scope, {
    required bool clearSelection,
    required bool explicitRefresh,
  }) async {
    if (_isDisposed) return;

    final totalStopwatch = Stopwatch()..start();
    final requestId = ++_loadRequestId;
    final scopeChanged = !_isSameScope(_currentScope, scope);
    final sameScope = !scopeChanged;
    final hasExistingData = _allItems.isNotEmpty;
    final isBackgroundRefresh =
        sameScope && hasExistingData && !explicitRefresh;
    final loadMode = explicitRefresh
        ? 'manual_refresh'
        : (isBackgroundRefresh ? 'background' : 'open');

    _currentScope = scope;
    _errorMessage = null;
    _isRefreshing = isBackgroundRefresh || explicitRefresh;

    if (isBackgroundRefresh) {
      if (_status != CivicMapStatus.loaded) {
        _setStatus(CivicMapStatus.loaded);
      }
    } else {
      _setStatus(CivicMapStatus.loading);
    }

    if (clearSelection || scopeChanged) {
      _selectedItemId = null;
      _selectedTargetRefKey = null;
    }

    if (scopeChanged) {
      _allItems.clear();
      _visibleItems.clear();
      _pollItems.clear();
      _postItems.clear();
      _newsItems.clear();
    }

    _notifySafely();

    if (explicitRefresh && beforeRefresh != null) {
      try {
        await beforeRefresh!(scope);
      } catch (e, st) {
        if (kDebugMode) {
          debugPrint('CivicMap pre-refresh failed: $e');
          debugPrint('$st');
        }
      }
    }

    if (!_isLatestRequest(requestId, scope)) {
      totalStopwatch.stop();
      return;
    }

    _CivicMapLoadResult pollResult = const _CivicMapLoadResult(
      sourceName: 'poll',
      items: <CivicMapItem>[],
      error: null,
      elapsedMs: 0,
    );
    _CivicMapLoadResult postResult = const _CivicMapLoadResult(
      sourceName: 'post',
      items: <CivicMapItem>[],
      error: null,
      elapsedMs: 0,
    );
    _CivicMapLoadResult newsResult = const _CivicMapLoadResult(
      sourceName: 'news',
      items: <CivicMapItem>[],
      error: null,
      elapsedMs: 0,
    );

    final errors = <String>[];

    void upsertError(_CivicMapLoadResult result) {
      errors.removeWhere(
        (entry) => entry.startsWith('${result.sourceName}:'),
      );

      if (result.hasError) {
        errors.add('${result.sourceName}: ${result.error}');
      }
    }

    void applyIntermediateResult({
      required List<CivicMapItem> store,
      required _CivicMapLoadResult result,
    }) {
      if (!_isLatestRequest(requestId, scope)) {
        return;
      }

      upsertError(result);

      // A manual refresh is committed atomically after every source has
      // completed. Keeping the previous stable snapshot here prevents live
      // Globe markers from disappearing while Poll/Post/News refresh at
      // slightly different speeds.
      if (sameScope && explicitRefresh) {
        return;
      }

      final storeChanged = _applySourceResult(
        store: store,
        result: result,
        preservePreviousOnError: sameScope,
        preservePreviousOnEmpty: isBackgroundRefresh,
        mergeWithPrevious: isBackgroundRefresh,
      );

      if (!storeChanged) {
        return;
      }

      _rebuildMergedItems();
      _reconcileSelectionAfterReload();

      final hasItems = _allItems.isNotEmpty;

      if (!isBackgroundRefresh &&
          _status == CivicMapStatus.loading &&
          hasItems) {
        _setStatus(CivicMapStatus.loaded);
        _isRefreshing = true;
      }

      if (_status == CivicMapStatus.loaded) {
        _errorMessage = errors.isEmpty ? null : errors.join(' | ');
        _notifySafely();
      }
    }

    final pollFuture = _safeLoadWithResult(
      loader: loadPollItems,
      scope: scope,
      sourceName: 'poll',
    ).then((result) {
      pollResult = result;
      applyIntermediateResult(
        store: _pollItems,
        result: result,
      );
    });

    final postFuture = _safeLoadWithResult(
      loader: loadPostItems,
      scope: scope,
      sourceName: 'post',
    ).then((result) {
      postResult = result;
      applyIntermediateResult(
        store: _postItems,
        result: result,
      );
    });

    final newsFuture = _safeLoadWithResult(
      loader: loadNewsItems,
      scope: scope,
      sourceName: 'news',
    ).then((result) {
      newsResult = result;
      applyIntermediateResult(
        store: _newsItems,
        result: result,
      );
    });

    await Future.wait<void>([
      pollFuture,
      postFuture,
      newsFuture,
    ]);

    if (!_isLatestRequest(requestId, scope)) {
      totalStopwatch.stop();
      return;
    }

    // Final source results are committed together. Empty successful results
    // are authoritative only here, after loading has settled. Errors on the
    // same scope remain fail-soft for presentation and preserve the last good
    // marker snapshot.
    // A settled manual refresh is authoritative: if a source really returns
    // fewer or zero items, stale markers may disappear. Automatic same-scope
    // background reloads are fail-soft: empty *or partial* transient payloads
    // are merged into the last stable source snapshot so Poll/Voce cannot
    // vanish a few seconds after opening the map. A manual refresh remains the
    // explicit cleanup path for content that is genuinely gone.
    final preserveBackgroundSnapshot = isBackgroundRefresh;

    final finalPollChanged = _applySourceResult(
      store: _pollItems,
      result: pollResult,
      preservePreviousOnError: sameScope,
      preservePreviousOnEmpty: preserveBackgroundSnapshot,
      mergeWithPrevious: preserveBackgroundSnapshot,
    );
    final finalPostChanged = _applySourceResult(
      store: _postItems,
      result: postResult,
      preservePreviousOnError: sameScope,
      preservePreviousOnEmpty: preserveBackgroundSnapshot,
      mergeWithPrevious: preserveBackgroundSnapshot,
    );
    final finalNewsChanged = _applySourceResult(
      store: _newsItems,
      result: newsResult,
      preservePreviousOnError: sameScope,
      preservePreviousOnEmpty: preserveBackgroundSnapshot,
      mergeWithPrevious: preserveBackgroundSnapshot,
    );

    if (finalPollChanged || finalPostChanged || finalNewsChanged) {
      _rebuildMergedItems();
      _reconcileSelectionAfterReload();
    }

    const rebuildMs = 0;
    const selectionMs = 0;

    final CivicMapStatus finalStatus;
    final String? finalErrorMessage;

    if (_allItems.isNotEmpty) {
      finalStatus = CivicMapStatus.loaded;
      finalErrorMessage = errors.isEmpty ? null : errors.join(' | ');
    } else if (errors.isNotEmpty) {
      finalStatus = CivicMapStatus.error;
      finalErrorMessage = errors.join(' | ');
    } else {
      finalStatus = CivicMapStatus.empty;
      finalErrorMessage = null;
    }

    _isRefreshing = false;
    _setStatus(finalStatus);
    _errorMessage = finalErrorMessage;

    totalStopwatch.stop();

    _storeLastLoadMetrics(
      scope: scope,
      pollResult: pollResult,
      postResult: postResult,
      newsResult: newsResult,
      rebuildMs: rebuildMs,
      selectionMs: selectionMs,
      totalMs: totalStopwatch.elapsedMilliseconds,
      finalStatus: finalStatus,
      errors: errors,
      loadMode: loadMode,
    );

    _notifySafely();
  }

  bool _applySourceResult({
    required List<CivicMapItem> store,
    required _CivicMapLoadResult result,
    required bool preservePreviousOnError,
    required bool preservePreviousOnEmpty,
    bool mergeWithPrevious = false,
  }) {
    if (result.hasError && preservePreviousOnError) {
      return false;
    }

    final hasPreviousData = store.isNotEmpty;
    final incomingIsEmpty = result.items.isEmpty;

    if (preservePreviousOnEmpty && hasPreviousData && incomingIsEmpty) {
      return false;
    }

    if (!hasPreviousData && incomingIsEmpty) {
      return false;
    }

    if (mergeWithPrevious && hasPreviousData && !incomingIsEmpty) {
      final merged = <String, CivicMapItem>{
        for (final item in store) item.id: item,
      };
      for (final item in result.items) {
        merged[item.id] = item;
      }

      final next = merged.values.toList(growable: false);
      final changed = next.length != store.length ||
          result.items.any((incoming) {
            final previous = store.where((item) => item.id == incoming.id);
            if (previous.isEmpty) return true;
            final old = previous.first;
            return old.latitude != incoming.latitude ||
                old.longitude != incoming.longitude ||
                old.title != incoming.title ||
                old.heat != incoming.heat ||
                old.commentCount != incoming.commentCount;
          });

      if (!changed) {
        return false;
      }

      store
        ..clear()
        ..addAll(next);
      return true;
    }

    store
      ..clear()
      ..addAll(result.items);

    return true;
  }

  void _rebuildMergedItems() {
    _allItems
      ..clear()
      ..addAll(_pollItems)
      ..addAll(_postItems)
      ..addAll(_newsItems);

    _allItems.sort(_sortItems);
    _rebuildVisibleItems();
  }

  void _rebuildVisibleItems() {
    _visibleItems
      ..clear()
      ..addAll(
        _allItems.where((item) => _visibleTypes.contains(item.type)),
      );
  }

  void setVisibleTypes(Set<CivicMapItemType> types) {
    if (_isDisposed) return;

    final nextVisibleTypes = types.isEmpty
        ? <CivicMapItemType>{
            CivicMapItemType.poll,
            CivicMapItemType.post,
            CivicMapItemType.news,
          }
        : Set<CivicMapItemType>.from(types);

    if (setEquals(_visibleTypes, nextVisibleTypes)) {
      return;
    }

    _visibleTypes = nextVisibleTypes;

    _rebuildVisibleItems();

    if (_selectedItemId != null &&
        !_visibleItems.any((item) => item.id == _selectedItemId)) {
      final selected = selectedItem;
      if (selected == null) {
        _selectedItemId = null;
        _selectedTargetRefKey = null;
      }
    }

    _notifySafely();
  }

  void toggleType(CivicMapItemType type) {
    final next = Set<CivicMapItemType>.from(_visibleTypes);

    if (next.contains(type)) {
      next.remove(type);
    } else {
      next.add(type);
    }

    setVisibleTypes(next);
  }

  bool isTypeVisible(CivicMapItemType type) {
    return _visibleTypes.contains(type);
  }

  void selectMarker(String itemId) {
    if (_isDisposed) return;

    CivicMapItem? matchedItem;

    for (final item in _allItems) {
      if (item.id == itemId) {
        matchedItem = item;
        break;
      }
    }

    if (_selectedItemId == itemId &&
        (matchedItem == null ||
            _selectedTargetRefKey == _targetRefKey(matchedItem.targetRef))) {
      return;
    }

    _selectedItemId = itemId;
    _selectedTargetRefKey =
        matchedItem == null ? null : _targetRefKey(matchedItem.targetRef);
    _notifySafely();
  }

  void selectItem(CivicMapItem item) {
    if (_isDisposed) return;

    final nextTargetRefKey = _targetRefKey(item.targetRef);

    if (_selectedItemId == item.id &&
        _selectedTargetRefKey == nextTargetRefKey) {
      return;
    }

    _selectedItemId = item.id;
    _selectedTargetRefKey = nextTargetRefKey;
    _notifySafely();
  }

  void clearSelection() {
    if (_isDisposed) return;

    if (_selectedItemId == null && _selectedTargetRefKey == null) return;
    _selectedItemId = null;
    _selectedTargetRefKey = null;
    _notifySafely();
  }

  Future<_CivicMapLoadResult> _safeLoadWithResult({
    required CivicMapItemsLoader? loader,
    required GeoScope scope,
    required String sourceName,
  }) async {
    if (loader == null) {
      return _CivicMapLoadResult(
        sourceName: sourceName,
        items: const <CivicMapItem>[],
        error: null,
        elapsedMs: 0,
      );
    }

    final stopwatch = Stopwatch()..start();

    try {
      final items = await _safeLoad(loader, scope);
      stopwatch.stop();

      return _CivicMapLoadResult(
        sourceName: sourceName,
        items: items,
        error: null,
        elapsedMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e, st) {
      stopwatch.stop();

      if (kDebugMode) {
        debugPrint('CivicMap load failed [$sourceName]: $e');
        debugPrint('$st');
      }

      return _CivicMapLoadResult(
        sourceName: sourceName,
        items: const <CivicMapItem>[],
        error: e.toString(),
        elapsedMs: stopwatch.elapsedMilliseconds,
      );
    }
  }

  Future<List<CivicMapItem>> _safeLoad(
    CivicMapItemsLoader? loader,
    GeoScope scope,
  ) async {
    if (loader == null) {
      return const <CivicMapItem>[];
    }

    final items = await loader(scope);

    final sanitized = items.map(_sanitizeItemMetrics).toList(growable: false);

    final normalized = _normalizeAndSpreadItems(sanitized, scope)
        .where((item) => _isValidLatLng(item.latitude, item.longitude))
        .map(_sanitizeItemMetrics)
        .toList(growable: false);

    normalized.sort(_sortItems);
    return normalized;
  }

  CivicMapItem _sanitizeItemMetrics(CivicMapItem item) {
    final normalizedHeat = CivicMapHeatRules.normalizeHeat(item.heat);
    final normalizedCommentCount =
        CivicMapHeatRules.normalizeCommentCount(item.commentCount);

    if (normalizedHeat == item.heat &&
        normalizedCommentCount == item.commentCount) {
      return item;
    }

    return item.copyWith(
      heat: normalizedHeat,
      commentCount: normalizedCommentCount,
    );
  }

  List<CivicMapItem> _normalizeAndSpreadItems(
    List<CivicMapItem> items,
    GeoScope _,
  ) {
    if (items.isEmpty) {
      return const <CivicMapItem>[];
    }

    // Persisted content coordinates are authoritative. Invalid coordinates
    // are not replaced with scope/world/city centers: doing so would fabricate
    // a geographic position and can place markers in another country or
    // hemisphere. Visual overlap is handled only by the renderer.
    return items
        .where((item) => _isValidLatLng(item.latitude, item.longitude))
        .toList(growable: false);
  }

  void _reconcileSelectionAfterReload() {
    if (_selectedItemId == null && _selectedTargetRefKey == null) {
      return;
    }

    CivicMapItem? matched;

    if (_selectedItemId != null) {
      for (final item in _allItems) {
        if (item.id == _selectedItemId) {
          matched = item;
          break;
        }
      }
    }

    if (matched == null && _selectedTargetRefKey != null) {
      for (final item in _allItems) {
        if (_targetRefKey(item.targetRef) == _selectedTargetRefKey) {
          matched = item;
          break;
        }
      }
    }

    if (matched == null) {
      _selectedItemId = null;
      _selectedTargetRefKey = null;
      return;
    }

    _selectedItemId = matched.id;
    _selectedTargetRefKey = _targetRefKey(matched.targetRef);
  }

  void _reconcileSelectionAfterDataChange() {
    _reconcileSelectionAfterReload();
  }

  bool _shouldRetryCurrentScope() {
    return _status == CivicMapStatus.error || _status == CivicMapStatus.empty;
  }

  bool _isLatestRequest(int requestId, GeoScope scope) {
    return !_isDisposed &&
        requestId == _loadRequestId &&
        _isSameScope(_currentScope, scope);
  }

  bool _isSameScope(GeoScope? a, GeoScope? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    if (a == b) return true;

    return _scopeKey(a) == _scopeKey(b);
  }

  String _scopeKey(GeoScope scope) {
    final dynamic dynamicScope = scope;

    Object? readSafely(Object? Function() reader) {
      try {
        return reader();
      } catch (_) {
        return null;
      }
    }

    String normalizeText(Object? value) {
      return (value ?? '').toString().trim().toLowerCase();
    }

    String normalizeNum(Object? value) {
      if (value is num && value.isFinite) {
        return value.toStringAsFixed(6);
      }
      return '';
    }

    return <String>[
      normalizeText(readSafely(() => dynamicScope.level) ?? scope.level),
      normalizeText(readSafely(() => dynamicScope.id)),
      normalizeText(readSafely(() => dynamicScope.code)),
      normalizeText(readSafely(() => dynamicScope.slug)),
      normalizeText(readSafely(() => dynamicScope.name)),
      normalizeText(readSafely(() => dynamicScope.countryCode)),
      normalizeText(readSafely(() => dynamicScope.countryName)),
      normalizeText(readSafely(() => dynamicScope.cityId)),
      normalizeText(readSafely(() => dynamicScope.cityName)),
      normalizeNum(readSafely(() => dynamicScope.centerLat) ?? scope.centerLat),
      normalizeNum(readSafely(() => dynamicScope.centerLng) ?? scope.centerLng),
      normalizeNum(readSafely(() => dynamicScope.radiusKm) ?? scope.radiusKm),
    ].join('|');
  }

  String? _targetRefKey(TargetRef targetRef) {
    final id = _readTargetRefId(targetRef);
    if (id == null || id.trim().isEmpty) {
      return null;
    }

    return '${targetRef.type.name}|${id.trim()}';
  }

  String? _readTargetRefId(TargetRef targetRef) {
    try {
      final dynamic value = (targetRef as dynamic).targetId;
      if (value != null) {
        return value.toString();
      }
    } catch (_) {}

    try {
      final dynamic value = (targetRef as dynamic).id;
      if (value != null) {
        return value.toString();
      }
    } catch (_) {}

    try {
      final dynamic value = (targetRef as dynamic).value;
      if (value != null) {
        return value.toString();
      }
    } catch (_) {}

    try {
      final dynamic value = (targetRef as dynamic).target;
      if (value != null) {
        return value.toString();
      }
    } catch (_) {}

    return null;
  }

  void _storeLastLoadMetrics({
    required GeoScope scope,
    required _CivicMapLoadResult pollResult,
    required _CivicMapLoadResult postResult,
    required _CivicMapLoadResult newsResult,
    required int rebuildMs,
    required int selectionMs,
    required int totalMs,
    required CivicMapStatus finalStatus,
    required List<String> errors,
    required String loadMode,
  }) {
    _lastLoadMetricsMs = <String, int>{
      'pollLoadMs': pollResult.elapsedMs,
      'postLoadMs': postResult.elapsedMs,
      'newsLoadMs': newsResult.elapsedMs,
      'rebuildMergedItemsMs': rebuildMs,
      'reconcileSelectionMs': selectionMs,
      'totalLoadMs': totalMs,
    };

    _lastLoadItemCounts = <String, int>{
      'pollCount': pollResult.items.length,
      'postCount': postResult.items.length,
      'newsCount': newsResult.items.length,
      'totalCount': _allItems.length,
    };

    _lastLoadMetricsSummary = <String>[
      'scope=${_scopeKey(scope)}',
      'status=${finalStatus.name}',
      'mode=$loadMode',
      'poll=${pollResult.elapsedMs}ms/${pollResult.items.length}',
      'post=${postResult.elapsedMs}ms/${postResult.items.length}',
      'news=${newsResult.elapsedMs}ms/${newsResult.items.length}',
      'merge=${rebuildMs}ms',
      'selection=${selectionMs}ms',
      'total=${totalMs}ms',
      if (errors.isNotEmpty) 'errors=${errors.length}',
    ].join(' | ');

    if (kDebugMode) {
      debugPrint('CivicMap metrics -> $_lastLoadMetricsSummary');
    }
  }

  bool _isFinite(double? value) {
    return value != null && value.isFinite;
  }

  bool _isValidLatLng(double? lat, double? lng) {
    if (!_isFinite(lat) || !_isFinite(lng)) return false;
    if (lat! < -90 || lat > 90) return false;
    if (lng! < -180 || lng > 180) return false;
    return true;
  }

  int _sortItems(CivicMapItem a, CivicMapItem b) {
    final importanceCompare =
        b.mapImportanceScore.compareTo(a.mapImportanceScore);
    if (importanceCompare != 0) return importanceCompare;

    final scoreCompare = b.mapHeatScore.compareTo(a.mapHeatScore);
    if (scoreCompare != 0) return scoreCompare;

    final heatCompare = b.normalizedHeat.compareTo(a.normalizedHeat);
    if (heatCompare != 0) return heatCompare;

    final commentsCompare =
        b.normalizedCommentCount.compareTo(a.normalizedCommentCount);
    if (commentsCompare != 0) return commentsCompare;

    final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
    final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
    return bTime.compareTo(aTime);
  }

  void _setStatus(CivicMapStatus value) {
    _status = value;
  }

  void _notifySafely() {
    if (_isDisposed) {
      return;
    }
    notifyListeners();
  }
}
