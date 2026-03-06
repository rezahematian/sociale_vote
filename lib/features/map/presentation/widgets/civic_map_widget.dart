import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as lat_lng;

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';

class CivicMapWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final String? currentScopeLabel;

  const CivicMapWidget({
    super.key,
    this.onTap,
    this.currentScopeLabel,
  });

  GeoScopeController get _geoScopeController =>
      AppDI.instance.geoScopeController;

  static const double _worldZoom = 2.0;
  static const double _countryZoom = 5.5;
  static const double _cityZoom = 11.0;

  /// Centro e zoom in base allo scope corrente.
  (lat_lng.LatLng center, double zoom) _mapViewForScope(GeoScope scope) {
    switch (scope.level) {
      case GeoScopeLevel.world:
        // Vista globale (un solo mondo).
        return (lat_lng.LatLng(20, 0), _worldZoom);
      case GeoScopeLevel.country:
        // Italy approximate center.
        return (lat_lng.LatLng(41.5, 12.5), _countryZoom);
      case GeoScopeLevel.city:
        // Torino approximate center.
        return (lat_lng.LatLng(45.07, 7.69), _cityZoom);
    }
  }

  void _handleMapTap(lat_lng.LatLng point) {
    // BBOX approssimativa per l'Italia.
    const italyMinLat = 35.0;
    const italyMaxLat = 47.5;
    const italyMinLng = 6.0;
    const italyMaxLng = 19.0;

    // BBOX molto stretta per Torino.
    const torinoMinLat = 45.02;
    const torinoMaxLat = 45.12;
    const torinoMinLng = 7.60;
    const torinoMaxLng = 7.80;

    if (point.latitude >= torinoMinLat &&
        point.latitude <= torinoMaxLat &&
        point.longitude >= torinoMinLng &&
        point.longitude <= torinoMaxLng) {
      // Tap in zona Torino → scope city.
      _geoScopeController.setCity(
        countryCode: 'IT',
        cityId: 'TORINO',
      );
    } else if (point.latitude >= italyMinLat &&
        point.latitude <= italyMaxLat &&
        point.longitude >= italyMinLng &&
        point.longitude <= italyMaxLng) {
      // Tap in zona Italia → scope country.
      _geoScopeController.setCountry('IT');
    } else {
      // Fuori da Italia → vista globale.
      _geoScopeController.setWorld();
    }

    // Se il chiamante vuole reagire al tap, lo notifichiamo comunque.
    if (onTap != null) {
      onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scope = _geoScopeController.scope;
    final (center, zoom) = _mapViewForScope(scope);

    const double minZoom = _worldZoom; // non si può andare più "fuori" del mondo
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
      child: Stack(
        children: [
          // MAPPA REALE (leggermente ingrandita per non far vedere i bordi ripetuti)
          Transform.scale(
            scale: 1.1, // il mondo "esce" appena dai bordi, niente ripetizione visibile
            child: FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: zoom,
                minZoom: minZoom,
                maxZoom: maxZoom,
                // Quando tocchi la mappa → aggiorniamo GeoScope.
                onTap: (tapPosition, point) => _handleMapTap(point),
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
          ),

          // Overlay scritta in basso
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                // leggero gradient per leggere il testo
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.0),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'World Map',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Zoom out → vedi il mondo una volta sola. Tap: fuori Italia → World, su Italia → Italy, su zona Torino → Torino.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (currentScopeLabel != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Scope attuale: $currentScopeLabel',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}