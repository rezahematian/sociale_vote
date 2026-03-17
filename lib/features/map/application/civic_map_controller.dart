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

class _CivicMapLoadResult {
  final String sourceName;
  final List<CivicMapItem> items;
  final String? error;

  const _CivicMapLoadResult({
    required this.sourceName,
    required this.items,
    required this.error,
  });

  bool get hasError => error != null && error!.trim().isNotEmpty;
}

class CivicMapController extends ChangeNotifier {
  final CivicMapItemsLoader? loadPollItems;
  final CivicMapItemsLoader? loadPostItems;
  final CivicMapItemsLoader? loadNewsItems;

  CivicMapController({
    this.loadPollItems,
    this.loadPostItems,
    this.loadNewsItems,
  });

  CivicMapStatus _status = CivicMapStatus.initial;
  CivicMapStatus get status => _status;

  GeoScope? _currentScope;
  GeoScope? get currentScope => _currentScope;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final List<CivicMapItem> _allItems = <CivicMapItem>[];
  List<CivicMapItem> get allItems => List.unmodifiable(_allItems);

  Set<CivicMapItemType> _visibleTypes = <CivicMapItemType>{
    CivicMapItemType.poll,
    CivicMapItemType.post,
    CivicMapItemType.news,
  };
  Set<CivicMapItemType> get visibleTypes => Set.unmodifiable(_visibleTypes);

  String? _selectedItemId;
  String? get selectedItemId => _selectedItemId;

  int _loadRequestId = 0;
  Future<void>? _activeLoadFuture;
  String? _activeLoadScopeKey;

  CivicMapItem? get selectedItem {
    if (_selectedItemId == null) return null;

    for (final item in visibleItems) {
      if (item.id == _selectedItemId) {
        return item;
      }
    }
    return null;
  }

  List<CivicMapItem> get visibleItems {
    final filtered = _allItems
        .where((item) => _visibleTypes.contains(item.type))
        .toList();

    filtered.sort(_sortItems);
    return List.unmodifiable(filtered);
  }

  bool get isLoading => _status == CivicMapStatus.loading;
  bool get hasError => _status == CivicMapStatus.error;
  bool get isEmpty => _status == CivicMapStatus.empty;
  bool get hasData => _status == CivicMapStatus.loaded;
  bool get hasSelection => selectedItem != null;

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
    );
  }

  Future<void> loadForScope(
    GeoScope scope, {
    bool clearSelection = true,
  }) {
    return _queueLoadForScope(
      scope,
      clearSelection: clearSelection,
    );
  }

  Future<void> refresh() async {
    final scope = _currentScope;
    if (scope == null) return;

    await _queueLoadForScope(
      scope,
      clearSelection: false,
    );
  }

  Future<void> _queueLoadForScope(
    GeoScope scope, {
    required bool clearSelection,
  }) {
    final scopeKey = _scopeKey(scope);

    if (_activeLoadFuture != null && _activeLoadScopeKey == scopeKey) {
      return _activeLoadFuture!;
    }

    final future = _performLoadForScope(
      scope,
      clearSelection: clearSelection,
    );

    _activeLoadFuture = future;
    _activeLoadScopeKey = scopeKey;

    future.whenComplete(() {
      if (identical(_activeLoadFuture, future)) {
        _activeLoadFuture = null;
        _activeLoadScopeKey = null;
      }
    });

    return future;
  }

  Future<void> _performLoadForScope(
    GeoScope scope, {
    required bool clearSelection,
  }) async {
    final requestId = ++_loadRequestId;
    final scopeChanged = !_isSameScope(_currentScope, scope);

    _currentScope = scope;
    _setStatus(CivicMapStatus.loading);
    _errorMessage = null;

    if (clearSelection || scopeChanged) {
      _selectedItemId = null;
    }

    if (scopeChanged) {
      _allItems.clear();
    }

    notifyListeners();

    final results = await Future.wait<_CivicMapLoadResult>([
      _safeLoadWithResult(
        loader: loadPollItems,
        scope: scope,
        sourceName: 'poll',
      ),
      _safeLoadWithResult(
        loader: loadPostItems,
        scope: scope,
        sourceName: 'post',
      ),
      _safeLoadWithResult(
        loader: loadNewsItems,
        scope: scope,
        sourceName: 'news',
      ),
    ]);

    if (!_isLatestRequest(requestId, scope)) {
      return;
    }

    final merged = <CivicMapItem>[];
    final errors = <String>[];

    for (final result in results) {
      merged.addAll(result.items);
      if (result.hasError) {
        errors.add('${result.sourceName}: ${result.error}');
      }
    }

    final normalized = _normalizeAndSpreadItems(merged, scope);

    if (!_isLatestRequest(requestId, scope)) {
      return;
    }

    _allItems
      ..clear()
      ..addAll(normalized);

    if (_allItems.isNotEmpty) {
      _setStatus(CivicMapStatus.loaded);
      _errorMessage = errors.isEmpty ? null : errors.join(' | ');
      notifyListeners();
      return;
    }

    if (errors.isNotEmpty) {
      _setStatus(CivicMapStatus.error);
      _errorMessage = errors.join(' | ');
      notifyListeners();
      return;
    }

    _setStatus(CivicMapStatus.empty);
    _errorMessage = null;
    notifyListeners();
  }

  void setVisibleTypes(Set<CivicMapItemType> types) {
    _visibleTypes = types.isEmpty
        ? <CivicMapItemType>{
            CivicMapItemType.poll,
            CivicMapItemType.post,
            CivicMapItemType.news,
          }
        : Set<CivicMapItemType>.from(types);

    if (_selectedItemId != null &&
        !visibleItems.any((item) => item.id == _selectedItemId)) {
      _selectedItemId = null;
    }

    notifyListeners();
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
    if (_selectedItemId == itemId) return;
    _selectedItemId = itemId;
    notifyListeners();
  }

  void selectItem(CivicMapItem item) {
    selectMarker(item.id);
  }

  void clearSelection() {
    if (_selectedItemId == null) return;
    _selectedItemId = null;
    notifyListeners();
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
      );
    }

    try {
      final items = await _safeLoad(loader, scope);
      return _CivicMapLoadResult(
        sourceName: sourceName,
        items: items,
        error: null,
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('CivicMap load failed [$sourceName]: $e');
        debugPrint('$st');
      }

      return _CivicMapLoadResult(
        sourceName: sourceName,
        items: const <CivicMapItem>[],
        error: e.toString(),
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
        .where((item) => _isFinite(item.latitude) && _isFinite(item.longitude))
        .toList();

    sanitized.sort(_sortItems);
    return sanitized;
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
    }).toList();

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

  bool _shouldRetryCurrentScope() {
    return _status == CivicMapStatus.error || _status == CivicMapStatus.empty;
  }

  bool _isLatestRequest(int requestId, GeoScope scope) {
    return requestId == _loadRequestId && _isSameScope(_currentScope, scope);
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
      if (value is num) {
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
      normalizeNum(readSafely(() => dynamicScope.radiusKm)),
    ].join('|');
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
    final heatCompare = b.heat.compareTo(a.heat);
    if (heatCompare != 0) return heatCompare;

    final commentsCompare = b.commentCount.compareTo(a.commentCount);
    if (commentsCompare != 0) return commentsCompare;

    final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
    final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
    return bTime.compareTo(aTime);
  }

  void _setStatus(CivicMapStatus value) {
    _status = value;
  }
}