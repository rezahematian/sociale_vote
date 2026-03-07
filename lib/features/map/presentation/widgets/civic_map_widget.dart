import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as lat_lng;

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';
import 'package:sociale_vote/domain/geo/entities/geo_point.dart';
import 'package:sociale_vote/infrastructure/geo/country_region.dart';

class CivicMapWidget extends StatefulWidget {
  final VoidCallback? onTap;
  final String? currentScopeLabel;

  const CivicMapWidget({
    super.key,
    this.onTap,
    this.currentScopeLabel,
  });

  @override
  State<CivicMapWidget> createState() => _CivicMapWidgetState();
}

class _CivicMapWidgetState extends State<CivicMapWidget> {
  GeoScopeController get _geoScopeController =>
      AppDI.instance.geoScopeController;

  final MapController _mapController = MapController();

  static const double _worldZoom = 2.0;
  static const double _countryZoom = 5.5;
  static const double _cityZoom = 11.0;

  /// Fallback generico: se non riusciamo a usare bounds o center geografici.
  (lat_lng.LatLng center, double zoom) _mapViewForScope(GeoScope scope) {
    // Se lo scope ha comunque un centro geografico, usiamo quello.
    if (scope.centerLat != null && scope.centerLng != null) {
      final center =
          lat_lng.LatLng(scope.centerLat!, scope.centerLng!);

      switch (scope.level) {
        case GeoScopeLevel.world:
          return (center, _worldZoom);
        case GeoScopeLevel.country:
          return (center, _countryZoom);
        case GeoScopeLevel.city:
          return (center, _cityZoom);
      }
    }

    // Fallback finale se non abbiamo centerLat/centerLng.
    switch (scope.level) {
      case GeoScopeLevel.world:
        return (const lat_lng.LatLng(20, 0), _worldZoom);
      case GeoScopeLevel.country:
        // Default: centro Europa
        return (const lat_lng.LatLng(50, 10), _countryZoom);
      case GeoScopeLevel.city:
        // Default neutro, NON Torino.
        return (const lat_lng.LatLng(0, 0), _cityZoom);
    }
  }

  /// Per gli scope country usiamo il dataset CountryRegion (center + radiusKm).
  LatLngBounds? _boundsForScope(GeoScope scope) {
    if (scope.level != GeoScopeLevel.country) {
      return null;
    }

    final countryCode = scope.countryCode;
    if (countryCode == null) {
      return null;
    }

    CountryRegion region;
    try {
      region = countryRegions.firstWhere(
        (r) => r.isoCode.toUpperCase() == countryCode.toUpperCase(),
      );
    } catch (_) {
      return null;
    }

    final centerLat = region.centerLat;
    final centerLng = region.centerLng;

    // Clamp radius per evitare zoom assurdi.
    double radiusKm = region.radiusKm;
    if (radiusKm < 300) radiusKm = 300;
    if (radiusKm > 3000) radiusKm = 3000;

    const earthKmPerDeg = 111.0;
    final latRad = centerLat * pi / 180.0;

    final deltaLat = radiusKm / earthKmPerDeg;
    final deltaLng = radiusKm / (earthKmPerDeg * cos(latRad));

    final south = centerLat - deltaLat;
    final north = centerLat + deltaLat;
    final west = centerLng - deltaLng;
    final east = centerLng + deltaLng;

    return LatLngBounds(
      lat_lng.LatLng(south, west),
      lat_lng.LatLng(north, east),
    );
  }

  void _syncMapToScope() {
    final scope = _geoScopeController.scope;

    // 🔍 DEBUG (puoi toglierlo quando ti stufi)
    print(
      'SCOPE → level=${scope.level} '
      'countryCode=${scope.countryCode} '
      'center=${scope.centerLat}/${scope.centerLng} '
      'radius=${scope.radiusKm}',
    );

    // 1️⃣ Se è country e lo troviamo nel dataset → fitCamera(bounds)
    final bounds = _boundsForScope(scope);
    if (bounds != null) {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(32),
        ),
      );
      return;
    }

    // 2️⃣ Tutti gli altri casi → center+zoom (usando centerLat/centerLng se presenti)
    final (center, zoom) = _mapViewForScope(scope);
    _mapController.move(center, zoom);
  }

  @override
  void initState() {
    super.initState();

    _geoScopeController.addListener(_syncMapToScope);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncMapToScope();
    });
  }

  @override
  void dispose() {
    _geoScopeController.removeListener(_syncMapToScope);
    super.dispose();
  }

  Future<void> _handleMapTap(lat_lng.LatLng point) async {
    final resolver = AppDI.instance.resolveScopeFromPoint;

    final result = await resolver(
      GeoPoint(
        latitude: point.latitude,
        longitude: point.longitude,
      ),
    );

    _geoScopeController.setScope(result.scope);

    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const double minZoom = _worldZoom;
    const double maxZoom = 18.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.15),
            theme.colorScheme.primary.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.25),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: const lat_lng.LatLng(20, 0),
          initialZoom: _worldZoom,
          minZoom: minZoom,
          maxZoom: maxZoom,
          onTap: (tapPosition, point) {
            _handleMapTap(point);
          },
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'sociale_vote',
            minZoom: minZoom,
            maxZoom: maxZoom,
          ),
        ],
      ),
    );
  }
}