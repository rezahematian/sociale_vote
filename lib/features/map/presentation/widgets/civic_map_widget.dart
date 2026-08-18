import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart' as lat_lng;

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/features/map/application/civic_map_controller.dart';

class CivicMapGlobeHandoff {
  final double latitude;
  final double longitude;
  final double globeZoom;

  const CivicMapGlobeHandoff({
    required this.latitude,
    required this.longitude,
    required this.globeZoom,
  });
}

class CivicMapWidget extends StatefulWidget {
  final VoidCallback? onTap;
  final String? currentScopeLabel;
  final CivicMapController? controller;
  final ValueChanged<CivicMapItem>? onItemTap;
  final bool interactive;
  final GeoScope? initialScope;
  final double? handoffLatitude;
  final double? handoffLongitude;
  final double? handoffZoom;
  final ValueChanged<CivicMapGlobeHandoff>? onZoomOutToGlobe;

  const CivicMapWidget({
    super.key,
    this.onTap,
    this.currentScopeLabel,
    this.controller,
    this.onItemTap,
    this.interactive = true,
    this.initialScope,
    this.handoffLatitude,
    this.handoffLongitude,
    this.handoffZoom,
    this.onZoomOutToGlobe,
  });

  @override
  State<CivicMapWidget> createState() => _CivicMapWidgetState();
}

class _CivicMapWidgetState extends State<CivicMapWidget> {
  final MapController _mapController = MapController();

  static const lat_lng.LatLng _defaultCenter = lat_lng.LatLng(20.0, 0.0);
  static const double _defaultZoom = 2.0;

  // Reverse World handoff is deliberately armed only after the user has
  // entered the 2D map. Opening explicit 2D at zoom 2.0 must NOT bounce
  // immediately back to the globe.
  static const double _globeReturnArmZoom = 2.70;
  static const double _globeReturnTriggerZoom = 2.12;
  static const double _globeReturnZoom = 0.0;

  bool _initialLoadTriggered = false;
  late double _currentZoom;
  bool _mapReady = false;
  bool _initialViewportRefreshScheduled = false;
  bool _globeReturnArmed = false;
  bool _globeReturnTriggered = false;
  String? _lastAppliedViewportScopeKey;
  String? _pendingViewportScopeKey;

  @override
  void initState() {
    super.initState();

    _currentZoom = _initialMapZoom();
    _globeReturnArmed = _currentZoom >= _globeReturnArmZoom;

    final activeScope = AppDI.instance.geoScopeController.scope;
    final initialScope = widget.initialScope;
    if (_hasValidHandoffViewport) {
      // The handoff is already the viewport for the current navigation scope.
      // Mark that scope as applied so the post-frame scope synchronizer cannot
      // immediately overwrite the exact geographic center received from 3D.
      _lastAppliedViewportScopeKey = _viewportScopeKey(activeScope);
    } else if (_hasValidInitialScopeViewport && initialScope != null) {
      _lastAppliedViewportScopeKey = _viewportScopeKey(initialScope);
    } else if (_hasValidScopeViewport(activeScope)) {
      // CivicMapPage owns the navigation scope through GeoScopeController.
      // When no explicit widget scope was supplied, FlutterMap already starts
      // from that active scope and must not receive a second startup move.
      _lastAppliedViewportScopeKey = _viewportScopeKey(activeScope);
    }

    if (_hasValidHandoffViewport && kDebugMode) {
      debugPrint(
        '[CivicMap] 3D->2D initial viewport: '
        'center=(${widget.handoffLatitude}, ${widget.handoffLongitude}) '
        'zoom=${_currentZoom.toStringAsFixed(2)}',
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadInitialDataIfNeeded();
    });
  }

  bool get _hasValidHandoffViewport {
    return _isValidLatLng(
          widget.handoffLatitude,
          widget.handoffLongitude,
        ) &&
        widget.handoffZoom != null &&
        widget.handoffZoom!.isFinite;
  }

  bool get _hasValidInitialScopeViewport {
    final scope = widget.initialScope;
    return _hasValidScopeViewport(scope);
  }

  bool _hasValidScopeViewport(GeoScope? scope) {
    return scope != null && _isValidLatLng(scope.centerLat, scope.centerLng);
  }

  lat_lng.LatLng _initialMapCenter() {
    if (_hasValidHandoffViewport) {
      return lat_lng.LatLng(
        widget.handoffLatitude!,
        widget.handoffLongitude!,
      );
    }

    final initialScope = widget.initialScope;
    if (_hasValidInitialScopeViewport && initialScope != null) {
      return lat_lng.LatLng(
        initialScope.centerLat!,
        initialScope.centerLng!,
      );
    }

    final activeScope = AppDI.instance.geoScopeController.scope;
    if (_hasValidScopeViewport(activeScope)) {
      return lat_lng.LatLng(
        activeScope.centerLat!,
        activeScope.centerLng!,
      );
    }

    return _defaultCenter;
  }

  double _initialMapZoom() {
    final zoom = widget.handoffZoom;
    if (_hasValidHandoffViewport && zoom != null) {
      return zoom.clamp(2.0, 18.0).toDouble();
    }

    final initialScope = widget.initialScope;
    if (_hasValidInitialScopeViewport && initialScope != null) {
      return _zoomForScope(initialScope);
    }

    final activeScope = AppDI.instance.geoScopeController.scope;
    if (_hasValidScopeViewport(activeScope)) {
      return _zoomForScope(activeScope);
    }

    return _defaultZoom;
  }

  void _handleMapReady() {
    if (_mapReady) {
      return;
    }

    _mapReady = true;

    if (_initialViewportRefreshScheduled) {
      return;
    }

    _initialViewportRefreshScheduled = true;
    _scheduleViewportSyncForScope(AppDI.instance.geoScopeController.scope);
    final center = _initialMapCenter();
    final zoom = _initialMapZoom();
    _currentZoom = zoom;

    // FlutterMap can be created immediately after the WebGL platform view is
    // removed. Re-emit the initial camera after layout so TileLayer receives a
    // real camera event instead of waiting for the user's first manual zoom.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_mapReady) {
        return;
      }

      try {
        final refreshZoom = zoom >= 18.0 ? zoom - 0.0001 : zoom + 0.0001;
        _mapController.move(center, refreshZoom);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !_mapReady) {
            return;
          }

          try {
            _mapController.move(center, zoom);
          } catch (_) {}
        });
      } catch (_) {}
    });
  }

  Future<void> _loadInitialDataIfNeeded() async {
    if (_initialLoadTriggered) return;

    final controller = widget.controller;
    if (controller == null) return;

    _initialLoadTriggered = true;

    try {
      await controller.loadForScope(AppDI.instance.geoScopeController.scope);
    } catch (_) {}
  }

  bool _isValidLatLng(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    if (!lat.isFinite || !lng.isFinite) return false;
    if (lat < -90 || lat > 90) return false;
    if (lng < -180 || lng > 180) return false;
    return true;
  }

  String _viewportScopeKey(GeoScope scope) {
    return <String>[
      scope.level.name,
      scope.countryCode ?? '',
      scope.cityId ?? '',
      scope.centerLat?.toStringAsFixed(6) ?? '',
      scope.centerLng?.toStringAsFixed(6) ?? '',
      scope.radiusKm?.toStringAsFixed(2) ?? '',
    ].join('|');
  }

  double _zoomForScope(GeoScope scope) {
    if (scope.level == GeoScopeLevel.world) {
      return _defaultZoom;
    }

    final radiusKm = scope.radiusKm;
    if (radiusKm != null && radiusKm.isFinite && radiusKm > 0) {
      final calculated = math.log(20000.0 / radiusKm) / math.ln2;

      if (scope.level == GeoScopeLevel.country) {
        return calculated.clamp(3.0, 7.5).toDouble();
      }

      return calculated.clamp(5.0, 15.0).toDouble();
    }

    return scope.level == GeoScopeLevel.country ? 4.5 : 11.0;
  }

  void _scheduleViewportSyncForScope(GeoScope scope) {
    if (!_mapReady || !_isValidLatLng(scope.centerLat, scope.centerLng)) {
      return;
    }

    final scopeKey = _viewportScopeKey(scope);
    if (_lastAppliedViewportScopeKey == scopeKey ||
        _pendingViewportScopeKey == scopeKey) {
      return;
    }

    _pendingViewportScopeKey = scopeKey;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _pendingViewportScopeKey != scopeKey) {
        return;
      }

      try {
        final center = lat_lng.LatLng(
          scope.centerLat!,
          scope.centerLng!,
        );
        final zoom = _zoomForScope(scope);

        _mapController.move(center, zoom);
        _lastAppliedViewportScopeKey = scopeKey;

        if (kDebugMode) {
          debugPrint(
            '[CivicMap] viewport synced: '
            '${scope.level.name} '
            '${scope.countryCode ?? ''} '
            'center=(${scope.centerLat}, ${scope.centerLng}) '
            'zoom=${zoom.toStringAsFixed(2)}',
          );
        }
      } catch (error) {
        if (kDebugMode) {
          debugPrint('[CivicMap] viewport sync failed: $error');
        }
      } finally {
        if (_pendingViewportScopeKey == scopeKey) {
          _pendingViewportScopeKey = null;
        }
      }
    });
  }

  lat_lng.LatLng _pointForItem(CivicMapItem item) {
    if (_isValidLatLng(item.latitude, item.longitude)) {
      return lat_lng.LatLng(item.latitude, item.longitude);
    }

    final location = item.contentLocation;
    if (location != null) {
      if (_isValidLatLng(location.latitude, location.longitude)) {
        return lat_lng.LatLng(location.latitude!, location.longitude!);
      }

      if (_isValidLatLng(location.centerLat, location.centerLng)) {
        return lat_lng.LatLng(location.centerLat!, location.centerLng!);
      }
    }

    final scope = item.geoScope;
    if (scope != null && _isValidLatLng(scope.centerLat, scope.centerLng)) {
      return lat_lng.LatLng(scope.centerLat!, scope.centerLng!);
    }

    return _defaultCenter;
  }

  void _handlePossibleGlobeReturn({
    required double latitude,
    required double longitude,
    required double zoom,
    required bool hasGesture,
  }) {
    if (widget.onZoomOutToGlobe == null ||
        !widget.interactive ||
        !hasGesture ||
        _globeReturnTriggered) {
      return;
    }

    if (zoom >= _globeReturnArmZoom) {
      _globeReturnArmed = true;
      return;
    }

    if (!_globeReturnArmed || zoom > _globeReturnTriggerZoom) {
      return;
    }

    if (!_isValidLatLng(latitude, longitude)) {
      return;
    }

    _globeReturnTriggered = true;
    widget.controller?.clearSelection();

    debugPrint(
      '[CivicMap] 2D->3D handoff: '
      'center=($latitude, $longitude) '
      'mapZoom=${zoom.toStringAsFixed(2)}',
    );

    widget.onZoomOutToGlobe!(
      CivicMapGlobeHandoff(
        latitude: latitude,
        longitude: longitude,
        globeZoom: _globeReturnZoom,
      ),
    );
  }

  void _handleMapTap() {
    if (!widget.interactive) return;
    widget.controller?.clearSelection();
    widget.onTap?.call();
  }

  void _handleMarkerTap(CivicMapItem item) {
    if (!widget.interactive) {
      widget.onTap?.call();
      return;
    }

    // Un marker singolo viene soltanto selezionato.
    // La mappa resta esattamente nella posizione/zoom scelti dall'utente;
    // il contenuto si apre dalla preview card della Civic Map.
    widget.controller?.selectItem(item);
    widget.onItemTap?.call(item);
  }

  IconData _iconForType(CivicMapItemType type) {
    switch (type) {
      case CivicMapItemType.poll:
        return Icons.poll_outlined;
      case CivicMapItemType.post:
        return Icons.forum_outlined;
      case CivicMapItemType.news:
        return Icons.newspaper_outlined;
    }
  }

  Color _colorForType(CivicMapItemType type) {
    switch (type) {
      case CivicMapItemType.poll:
        return Colors.green;
      case CivicMapItemType.post:
        return Colors.blue;
      case CivicMapItemType.news:
        return Colors.red;
    }
  }

  double _markerDiameter({
    required CivicMapItem item,
    required bool selected,
    int clusterSize = 1,
  }) {
    // Scala continua basata sul ranking civico:
    // 34px minimo, 64px massimo prima dell'evidenza di selezione/cluster.
    final normalized =
        (item.mapImportanceScore / 70.0).clamp(0.0, 1.0).toDouble();
    var size = 34.0 + (normalized * 30.0);

    if (clusterSize > 1) {
      size += math.min(
        8.0,
        math.log(clusterSize + 1) * 2.5,
      );
    }

    if (selected) {
      size += 8.0;
    }

    return size.clamp(34.0, 72.0).toDouble();
  }

  int _maxMarkersForZoom(double zoom) {
    if (zoom < 4.0) return 24;
    if (zoom < 6.5) return 50;
    if (zoom < 9.0) return 100;
    if (zoom < 12.0) return 180;
    return 500;
  }

  double _clusterCellDegrees(double zoom) {
    if (zoom < 4.0) return 4.0;
    if (zoom < 6.5) return 1.5;
    if (zoom < 9.0) return 0.45;
    if (zoom < 12.0) return 0.10;
    if (zoom < 15.0) return 0.025;
    return 0.0;
  }

  List<_CivicMarkerGroup> _markerGroups() {
    final controller = widget.controller;
    if (controller == null || controller.visibleItems.isEmpty) {
      return const <_CivicMarkerGroup>[];
    }

    final sorted = controller.visibleItems.toList(growable: false);
    final selected = controller.selectedItem;

    final maxMarkers = _maxMarkersForZoom(_currentZoom);
    final candidates = <CivicMapItem>[
      ...sorted.take(maxMarkers),
    ];

    if (selected != null && !candidates.any((item) => item.id == selected.id)) {
      candidates.add(selected);
    }

    final cellSize = _clusterCellDegrees(_currentZoom);
    if (cellSize <= 0) {
      return candidates
          .map(
            (item) => _CivicMarkerGroup(
              representative: item,
              items: [item],
            ),
          )
          .toList(growable: false);
    }

    final groups = <String, List<CivicMapItem>>{};

    for (final item in candidates) {
      final point = _pointForItem(item);
      final latCell = (point.latitude / cellSize).floor();
      final lngCell = (point.longitude / cellSize).floor();
      final key = '$latCell|$lngCell';

      groups.putIfAbsent(key, () => <CivicMapItem>[]).add(item);
    }

    final output = <_CivicMarkerGroup>[];

    for (final items in groups.values) {
      // visibleItems è già ordinato per importanza; il rappresentante
      // mantiene quindi il contenuto più importante del cluster.
      final representative = items.first;

      output.add(
        _CivicMarkerGroup(
          representative: representative,
          items: List<CivicMapItem>.unmodifiable(items),
        ),
      );
    }

    output.sort(
      (a, b) => b.representative.mapImportanceScore.compareTo(
        a.representative.mapImportanceScore,
      ),
    );

    return output;
  }

  List<Marker> _buildMarkers() {
    final controller = widget.controller;
    if (controller == null) return const <Marker>[];

    return _markerGroups().map((group) {
      final item = group.representative;
      final isCluster = group.items.length > 1;
      final selected = !isCluster && controller.selectedItemId == item.id;
      final point = _pointForItem(item);

      final color = isCluster ? Colors.deepPurple : _colorForType(item.type);

      final markerSize = _markerDiameter(
        item: item,
        selected: selected,
        clusterSize: group.items.length,
      );

      final badgeText = isCluster
          ? (group.items.length > 99 ? '99+' : '${group.items.length}')
          : item.heatBadgeLabel;

      final markerBoxSize =
          markerSize + (selected ? 34 : 20) + (badgeText != null ? 24 : 8);

      return Marker(
        point: point,
        width: markerBoxSize,
        height: markerBoxSize,
        child: GestureDetector(
          onTap: () {
            if (!widget.interactive) {
              widget.onTap?.call();
              return;
            }

            if (isCluster) {
              final nextZoom = math.min(18.0, _currentZoom + 2.2);
              try {
                _mapController.move(point, nextZoom);
              } catch (_) {}
              return;
            }

            _handleMarkerTap(item);
          },
          child: _MapMarkerVisual(
            size: markerSize,
            color: color,
            icon: isCluster ? Icons.layers_outlined : _iconForType(item.type),
            selected: selected,
            tier: item.heatTier,
            badgeText: badgeText,
          ),
        ),
      );
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final activeScope = AppDI.instance.geoScopeController.scope;
    _scheduleViewportSyncForScope(activeScope);

    return AnimatedBuilder(
      animation: Listenable.merge([
        if (controller != null) controller,
      ]),
      builder: (context, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialMapCenter(),
              initialZoom: _initialMapZoom(),
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerLowest,
              minZoom: 2.0,
              maxZoom: 18.0,
              onMapReady: _handleMapReady,
              interactionOptions: InteractionOptions(
                flags: widget.interactive
                    ? (InteractiveFlag.all & ~InteractiveFlag.rotate)
                    : InteractiveFlag.none,
              ),
              onPositionChanged: (camera, hasGesture) {
                final zoom = camera.zoom;

                _handlePossibleGlobeReturn(
                  latitude: camera.center.latitude,
                  longitude: camera.center.longitude,
                  zoom: zoom,
                  hasGesture: hasGesture,
                );

                if ((_currentZoom - zoom).abs() < 0.05) {
                  return;
                }

                setState(() {
                  _currentZoom = zoom;
                });
              },
              onTap: (tapPosition, point) {
                _handleMapTap();
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.sociale_vote.app',
                tileProvider: kIsWeb
                    ? CancellableNetworkTileProvider()
                    : NetworkTileProvider(),
              ),
              if (controller != null)
                MarkerLayer(
                  markers: _buildMarkers(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CivicMarkerGroup {
  final CivicMapItem representative;
  final List<CivicMapItem> items;

  const _CivicMarkerGroup({
    required this.representative,
    required this.items,
  });
}

class _MapMarkerVisual extends StatelessWidget {
  final double size;
  final Color color;
  final IconData icon;
  final bool selected;
  final CivicMapHeatTier tier;
  final String? badgeText;

  const _MapMarkerVisual({
    required this.size,
    required this.color,
    required this.icon,
    required this.selected,
    required this.tier,
    required this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final accentRingSize = size + _accentRingExtraSize();
    final selectedRingSize = size + 20;

    return Center(
      child: SizedBox(
        width: selected ? size + 36 : size + 18,
        height: selected ? size + 36 : size + 18,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (selected)
              Container(
                width: selectedRingSize,
                height: selectedRingSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF111827),
                    width: 3.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF111827).withValues(alpha: 0.24),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            if (tier != CivicMapHeatTier.normal)
              Container(
                width: accentRingSize,
                height: accentRingSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _accentRingColor(),
                    width: _accentRingWidth(),
                  ),
                ),
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _glowColor(),
                    blurRadius: _glowBlurRadius(),
                    spreadRadius: _glowSpreadRadius(),
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: selected ? 4.5 : _borderWidth(),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: _iconSize(),
              ),
            ),
            if (badgeText != null)
              Positioned(
                top: -6,
                right: -8,
                child: _MarkerBadge(
                  text: badgeText!,
                  tier: tier,
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _borderWidth() {
    switch (tier) {
      case CivicMapHeatTier.normal:
        return 2;
      case CivicMapHeatTier.active:
        return 3;
      case CivicMapHeatTier.hot:
        return 3.5;
    }
  }

  double _iconSize() {
    if (size >= 62) return 25;
    if (size >= 54) return 23;
    if (size >= 46) return 21;
    return 18;
  }

  double _accentRingExtraSize() {
    switch (tier) {
      case CivicMapHeatTier.normal:
        return 0;
      case CivicMapHeatTier.active:
        return 10;
      case CivicMapHeatTier.hot:
        return 14;
    }
  }

  double _accentRingWidth() {
    switch (tier) {
      case CivicMapHeatTier.normal:
        return 0;
      case CivicMapHeatTier.active:
        return 2.2;
      case CivicMapHeatTier.hot:
        return 3;
    }
  }

  Color _accentRingColor() {
    switch (tier) {
      case CivicMapHeatTier.normal:
        return Colors.transparent;
      case CivicMapHeatTier.active:
        return Colors.amber.shade700.withValues(alpha: 0.78);
      case CivicMapHeatTier.hot:
        return Colors.deepOrangeAccent.withValues(alpha: 0.90);
    }
  }

  Color _glowColor() {
    switch (tier) {
      case CivicMapHeatTier.normal:
        return color.withValues(alpha: selected ? 0.26 : 0.16);
      case CivicMapHeatTier.active:
        return Colors.amber.withValues(alpha: selected ? 0.42 : 0.30);
      case CivicMapHeatTier.hot:
        return Colors.deepOrange.withValues(alpha: selected ? 0.52 : 0.40);
    }
  }

  double _glowBlurRadius() {
    switch (tier) {
      case CivicMapHeatTier.normal:
        return selected ? 16 : 11;
      case CivicMapHeatTier.active:
        return selected ? 22 : 16;
      case CivicMapHeatTier.hot:
        return selected ? 28 : 21;
    }
  }

  double _glowSpreadRadius() {
    switch (tier) {
      case CivicMapHeatTier.normal:
        return selected ? 2 : 1;
      case CivicMapHeatTier.active:
        return selected ? 3 : 2;
      case CivicMapHeatTier.hot:
        return selected ? 4 : 3;
    }
  }
}

class _MarkerBadge extends StatelessWidget {
  final String text;
  final CivicMapHeatTier tier;

  const _MarkerBadge({
    required this.text,
    required this.tier,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _backgroundColor();
    const foregroundColor = Colors.white;

    return Container(
      constraints: const BoxConstraints(
        minWidth: 22,
        minHeight: 22,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w800,
              fontSize: text == 'HOT' ? 9 : 10,
              height: 1,
            ),
      ),
    );
  }

  Color _backgroundColor() {
    switch (tier) {
      case CivicMapHeatTier.normal:
        return Colors.grey;
      case CivicMapHeatTier.active:
        return Colors.amber.shade800;
      case CivicMapHeatTier.hot:
        return Colors.deepOrange;
    }
  }
}
