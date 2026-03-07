import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

import 'package:sociale_vote/domain/geo/entities/geo_point.dart';
import 'package:sociale_vote/domain/geo/entities/resolved_scope.dart';
import 'package:sociale_vote/domain/geo/repositories/geo_resolver.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';

// File generato da Natural Earth
import 'package:sociale_vote/infrastructure/geo/country_region.dart';

class GeoResolverImpl implements GeoResolver {
  static const _userAgent =
      'sociale_vote_app/1.0 (contact: your-email@example.com)';

  @override
  Future<ResolvedScope> resolveScopeFromPoint(GeoPoint point) async {
    final lat = point.latitude;
    final lng = point.longitude;

    // =====================================================
    // 1) CITY SPECIAL CASES
    // =====================================================

    // Torino
    if (_inBox(lat, lng, 45.02, 45.12, 7.60, 7.80)) {
      return ResolvedScope(
        scope: GeoScope.city(
          countryCode: 'IT',
          cityId: 'TORINO',
          centerLat: 45.07,
          centerLng: 7.69,
          radiusKm: 25,
        ),
        displayName: 'Torino, Italy',
      );
    }

    // Bolzano
    if (_inBox(lat, lng, 46.45, 46.55, 11.30, 11.45)) {
      return ResolvedScope(
        scope: GeoScope.city(
          countryCode: 'IT',
          cityId: 'BOLZANO',
          centerLat: 46.50,
          centerLng: 11.35,
          radiusKm: 25,
        ),
        displayName: 'Bolzano, Italy',
      );
    }

    // =====================================================
    // 2) REVERSE GEOCODING ONLINE (Nominatim) - BEST EFFORT
    // =====================================================

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=jsonv2'
        '&lat=$lat'
        '&lon=$lng'
        '&zoom=5'
        '&addressdetails=1',
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': _userAgent,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final address = (data['address'] ?? {}) as Map<String, dynamic>;

        final countryName = address['country'] as String?;
        final countryCode = address['country_code'] as String?;

        if (countryName != null && countryCode != null) {
          final iso = countryCode.toUpperCase();

          // Proviamo a trovare il CountryRegion corrispondente al codice ISO
          final region = countryRegions.cast<CountryRegion?>().firstWhere(
                (c) => c!.isoCode == iso,
                orElse: () => null,
              );

          if (region != null) {
            // Branch "felice": ISO presente nel dataset → usiamo i suoi dati
            return ResolvedScope(
              scope: GeoScope.country(
                region.isoCode,
                centerLat: region.centerLat,
                centerLng: region.centerLng,
                radiusKm: region.radiusKm,
              ),
              displayName: region.name,
            );
          } else {
            // ISO non presente nella lista, ma il country_code esiste:
            // usiamo comunque uno scope country generico centrato sul punto.
            return ResolvedScope(
              scope: GeoScope.country(
                iso,
                centerLat: lat,
                centerLng: lng,
                radiusKm: 800,
              ),
              displayName: countryName,
            );
          }
        }
      }
    } catch (_) {
      // Problemi di rete/parsing → passiamo al fallback offline.
    }

    // =====================================================
    // 3) FALLBACK OFFLINE: nearest country SEMPRE
    // =====================================================
    //
    // Prima filtravi con:
    //   if (bestDistanceKm <= bestCountry.radiusKm * 2.0)
    // ma questo faceva "bucare" alcuni paesi (soprattutto piccoli o con radiusKm basso),
    // che finivano in AREA pura e la mappa non reagiva bene.
    //
    // Ora: scegliamo SEMPRE il paese più vicino nel dataset.

    CountryRegion? bestCountry;
    double bestDistanceKm = double.infinity;

    for (final country in countryRegions) {
      final d = _haversineKm(
        lat,
        lng,
        country.centerLat,
        country.centerLng,
      );

      if (d < bestDistanceKm) {
        bestDistanceKm = d;
        bestCountry = country;
      }
    }

    if (bestCountry != null) {
      return ResolvedScope(
        scope: GeoScope.country(
          bestCountry.isoCode,
          centerLat: bestCountry.centerLat,
          centerLng: bestCountry.centerLng,
          radiusKm: bestCountry.radiusKm,
        ),
        displayName: bestCountry.name,
      );
    }

    // =====================================================
    // 4) FALLBACK FINALE: area pura (ultimo paracadute)
    // =====================================================

    return ResolvedScope(
      scope: GeoScope.area(
        centerLat: lat,
        centerLng: lng,
        radiusKm: 100,
      ),
      displayName:
          'Area around (${lat.toStringAsFixed(2)}, ${lng.toStringAsFixed(2)})',
    );
  }

  bool _inBox(
    double lat,
    double lng,
    double minLat,
    double maxLat,
    double minLng,
    double maxLng,
  ) {
    return lat >= minLat &&
        lat <= maxLat &&
        lng >= minLng &&
        lng <= maxLng;
  }

  double _haversineKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371.0;

    final phi1 = lat1 * math.pi / 180.0;
    final phi2 = lat2 * math.pi / 180.0;
    final dphi = (lat2 - lat1) * math.pi / 180.0;
    final dlambda = (lon2 - lon1) * math.pi / 180.0;

    final a = math.sin(dphi / 2) * math.sin(dphi / 2) +
        math.cos(phi1) *
            math.cos(phi2) *
            math.sin(dlambda / 2) *
            math.sin(dlambda / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }
}