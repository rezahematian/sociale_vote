import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';

abstract class GeocodingRepository {
  /// Prova a trasformare una località contenuto testuale
  /// (paese, città, ecc.) in una località con coordinate.
  ///
  /// Esempi:
  /// - cityName + countryCode -> latitude/longitude
  /// - solo countryCode -> centerLat/centerLng
  ///
  /// Può restituire:
  /// - una ContentLocation arricchita con coordinate
  /// - null se non riesce a geocodificare
  Future<ContentLocation?> geocodeContentLocation(
    ContentLocation location,
  );
}
