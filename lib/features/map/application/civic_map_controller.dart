import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
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

class CivicMapItem {
  final String id;
  final TargetRef targetRef;
  final CivicMapItemType type;
  final String title;
  final String? subtitle;
  final GeoScope? geoScope;
  final ContentLocation? contentLocation;
  final double latitude;
  final double longitude;

  /// Heat reale del contenuto già esistente nel sistema.
  final double heat;

  final int commentCount;
  final DateTime? createdAt;

  const CivicMapItem({
    required this.id,
    required this.targetRef,
    required this.type,
    required this.title,
    this.subtitle,
    this.geoScope,
    this.contentLocation,
    required this.latitude,
    required this.longitude,
    this.heat = 0,
    this.commentCount = 0,
    this.createdAt,
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

  CivicMapHeatTier get heatTier {
    return CivicMapHeatRules.resolveTierFromScore(mapHeatScore);
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
    GeoScope? geoScope,
    ContentLocation? contentLocation,
    double? latitude,
    double? longitude,
    double? heat,
    int? commentCount,
    DateTime? createdAt,
  }) {
    return CivicMapItem(
      id: id ?? this.id,
      targetRef: targetRef ?? this.targetRef,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      geoScope: geoScope ?? this.geoScope,
      contentLocation: contentLocation ?? this.contentLocation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      heat: heat ?? this.heat,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
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
    super.dispose();
  }

  Future<void> syncScope(
    GeoScope? scope, {
    bool forceReload = false,
    bool clearSelection = true,
  }) async {
    if (scope == null) return;

    final sameScope = _isSameScope(_currentScope, scope);
    final shouldSkip =
        !forceReload &&
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
    final scopeKey = _scopeKey(scope);

    if (!explicitRefresh &&
        _activeLoadFuture != null &&
        _activeLoadScopeKey == scopeKey) {
      return _activeLoadFuture!;
    }

    final future = _performLoadForScope(
      scope,
      clearSelection: clearSelection,
      explicitRefresh: explicitRefresh,
    );

    _activeLoadFuture = future;
    _activeLoadScopeKey = scopeKey;

    future.whenComplete(() {
      final current = _activeLoadFuture;
      if (identical(current, future)) {
        _activeLoadFuture = null;
        _activeLoadScopeKey = null;
      }
    });

    return future;
  }

  Future<void> _performLoadForScope(
    GeoScope scope, {
    required bool clearSelection,
    required bool explicitRefresh,
  }) async {
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

      final storeChanged = _applySourceResult(
        store: store,
        result: result,
        preservePreviousOnError: sameScope && !explicitRefresh,
        preservePreviousOnEmpty: sameScope && !explicitRefresh,
      );

      upsertError(result);

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

    final sanitized = items
        .map(_sanitizeItemMetrics)
        .toList(growable: false);

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
    GeoScope scope,
  ) {
    if (items.isEmpty) {
      return const <CivicMapItem>[];
    }

    final normalized = items.map((item) {
      if (_isValidLatLng(item.latitude, item.longitude)) {
        return item;
      }

      final fallback = _resolveBestPoint(
        item: item,
        fallbackScope: scope,
      );

      return item.copyWith(
        latitude: fallback.$1,
        longitude: fallback.$2,
        geoScope: item.geoScope ?? scope,
      );
    }).toList(growable: false);

    final Map<String, List<CivicMapItem>> groups =
        <String, List<CivicMapItem>>{};

    for (final item in normalized) {
      final key =
          '${item.latitude.toStringAsFixed(5)}|${item.longitude.toStringAsFixed(5)}';
      groups.putIfAbsent(key, () => <CivicMapItem>[]).add(item);
    }

    final output = <CivicMapItem>[];

    for (final entry in groups.entries) {
      final group = entry.value;

      if (group.length == 1) {
        output.add(group.first);
        continue;
      }

      final baseLat = group.first.latitude;
      final baseLng = group.first.longitude;

      for (int i = 0; i < group.length; i++) {
        final item = group[i];
        final spread = _spreadPoint(
          baseLat: baseLat,
          baseLng: baseLng,
          index: i,
          type: item.type,
        );

        output.add(
          item.copyWith(
            latitude: spread.$1,
            longitude: spread.$2,
          ),
        );
      }
    }

    return output;
  }

  (double, double) _resolveBestPoint({
    required CivicMapItem item,
    required GeoScope fallbackScope,
  }) {
    if (_isValidLatLng(item.latitude, item.longitude)) {
      return (item.latitude, item.longitude);
    }

    final location = item.contentLocation;
    if (location != null) {
      if (_isValidLatLng(location.latitude, location.longitude)) {
        return (location.latitude!, location.longitude!);
      }

      if (_isValidLatLng(location.centerLat, location.centerLng)) {
        return (location.centerLat!, location.centerLng!);
      }
    }

    final itemScope = item.geoScope;
    if (itemScope != null &&
        _isValidLatLng(itemScope.centerLat, itemScope.centerLng)) {
      return (itemScope.centerLat!, itemScope.centerLng!);
    }

    return _fallbackCenterForScope(fallbackScope);
  }

  (double, double) _fallbackCenterForScope(GeoScope scope) {
    if (_isValidLatLng(scope.centerLat, scope.centerLng)) {
      return (scope.centerLat!, scope.centerLng!);
    }

    switch (scope.level) {
      case GeoScopeLevel.world:
        return (20.0, 0.0);
      case GeoScopeLevel.country:
        return (45.0, 10.0);
      case GeoScopeLevel.city:
        return (45.4642, 9.1900);
    }
  }

  (double, double) _spreadPoint({
    required double baseLat,
    required double baseLng,
    required int index,
    required CivicMapItemType type,
  }) {
    if (index == 0) {
      return (baseLat, baseLng);
    }

    final ring = ((index - 1) ~/ 8) + 1;
    final slot = (index - 1) % 8;
    final angle = (math.pi * 2 / 8) * slot;

    double radiusDeg;
    switch (type) {
      case CivicMapItemType.poll:
        radiusDeg = 0.08 * ring;
        break;
      case CivicMapItemType.post:
        radiusDeg = 0.12 * ring;
        break;
      case CivicMapItemType.news:
        radiusDeg = 0.16 * ring;
        break;
    }

    final lat = (baseLat + math.sin(angle) * radiusDeg).clamp(-85.0, 85.0);
    final lng = (baseLng + math.cos(angle) * radiusDeg).clamp(-180.0, 180.0);

    return (lat.toDouble(), lng.toDouble());
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