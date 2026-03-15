import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as lat_lng;

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/geo/entities/geo_point.dart';
import 'package:sociale_vote/features/map/application/civic_map_controller.dart';

class CivicMapWidget extends StatefulWidget {
  final VoidCallback? onTap;
  final String? currentScopeLabel;
  final CivicMapController? controller;
  final ValueChanged<CivicMapItem>? onItemTap;
  final bool interactive;

  const CivicMapWidget({
    super.key,
    this.onTap,
    this.currentScopeLabel,
    this.controller,
    this.onItemTap,
    this.interactive = true,
  });

  @override
  State<CivicMapWidget> createState() => _CivicMapWidgetState();
}

class _CivicMapWidgetState extends State<CivicMapWidget> {
  final MapController _mapController = MapController();

  static const lat_lng.LatLng _defaultCenter =
      lat_lng.LatLng(20.0, 0.0);
  static const double _defaultZoom = 2.0;
  static const double _focusZoom = 7.0;

  bool _initialLoadTriggered = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadInitialDataIfNeeded();
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

  Future<void> _handleMapTap(lat_lng.LatLng point) async {
    if (!widget.interactive) return;

    try {
      final result = await AppDI.instance.resolveScopeFromPoint(
        GeoPoint(
          latitude: point.latitude,
          longitude: point.longitude,
        ),
      );

      AppDI.instance.geoScopeController.setScope(result.scope);
    } catch (_) {}

    widget.onTap?.call();
  }

  void _handleMarkerTap(CivicMapItem item) {
    widget.controller?.selectItem(item);

    try {
      _mapController.move(_pointForItem(item), _focusZoom);
    } catch (_) {}

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

  List<Marker> _buildMarkers() {
    final controller = widget.controller;
    if (controller == null) return const <Marker>[];

    return controller.visibleItems.map((item) {
      final selected = controller.selectedItemId == item.id;
      final point = _pointForItem(item);
      final color = _colorForType(item.type);

      return Marker(
        point: point,
        width: selected ? 56 : 44,
        height: selected ? 56 : 44,
        child: GestureDetector(
          onTap: () => _handleMarkerTap(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: selected ? 48 : 38,
            height: selected ? 48 : 38,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: selected ? 3 : 2,
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
              _iconForType(item.type),
              color: Colors.white,
              size: selected ? 22 : 18,
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

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
              initialCenter: _defaultCenter,
              initialZoom: _defaultZoom,
              minZoom: 2.0,
              maxZoom: 18.0,
              interactionOptions: InteractionOptions(
                flags: widget.interactive
                    ? InteractiveFlag.all
                    : InteractiveFlag.none,
              ),
              onTap: (tapPosition, point) {
                controller?.clearSelection();
                _handleMapTap(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.sociale_vote.app',
                tileProvider: NetworkTileProvider(),
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
