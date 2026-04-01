import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart' as lat_lng;

import 'package:sociale_vote/app/di.dart';
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

  static const lat_lng.LatLng _defaultCenter = lat_lng.LatLng(20.0, 0.0);
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

  void _handleMapTap() {
    if (!widget.interactive) return;
    widget.controller?.clearSelection();
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

  double _markerDiameter({
    required CivicMapItem item,
    required bool selected,
  }) {
    double size;
    switch (item.heatTier) {
      case CivicMapHeatTier.normal:
        size = 38;
        break;
      case CivicMapHeatTier.active:
        size = 46;
        break;
      case CivicMapHeatTier.hot:
        size = 54;
        break;
    }

    if (selected) {
      size += 10;
    }

    return size;
  }

  List<Marker> _buildMarkers() {
    final controller = widget.controller;
    if (controller == null) return const <Marker>[];

    return controller.visibleItems.map((item) {
      final selected = controller.selectedItemId == item.id;
      final point = _pointForItem(item);
      final color = _colorForType(item.type);
      final markerSize = _markerDiameter(
        item: item,
        selected: selected,
      );
      final badgeText = item.heatBadgeLabel;

      final markerBoxSize =
          markerSize + (selected ? 34 : 20) + (badgeText != null ? 24 : 8);

      return Marker(
        point: point,
        width: markerBoxSize,
        height: markerBoxSize,
        child: GestureDetector(
          onTap: () => _handleMarkerTap(item),
          child: _MapMarkerVisual(
            size: markerSize,
            color: color,
            icon: _iconForType(item.type),
            selected: selected,
            tier: item.heatTier,
            badgeText: badgeText,
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
                      color: const Color(0xFF111827).withOpacity(0.24),
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
        return Colors.amber.shade700.withOpacity(0.78);
      case CivicMapHeatTier.hot:
        return Colors.deepOrangeAccent.withOpacity(0.90);
    }
  }

  Color _glowColor() {
    switch (tier) {
      case CivicMapHeatTier.normal:
        return color.withOpacity(selected ? 0.26 : 0.16);
      case CivicMapHeatTier.active:
        return Colors.amber.withOpacity(selected ? 0.42 : 0.30);
      case CivicMapHeatTier.hot:
        return Colors.deepOrange.withOpacity(selected ? 0.52 : 0.40);
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