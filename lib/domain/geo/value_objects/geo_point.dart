/// Value object che rappresenta un punto geografico.
///
/// Usa latitudine e longitudine in gradi decimali:
/// - [latitude] deve essere compresa tra -90 e 90
/// - [longitude] deve essere compresa tra -180 e 180
class GeoPoint {
  final double latitude;
  final double longitude;

  const GeoPoint({
    required this.latitude,
    required this.longitude,
  })  : assert(latitude >= -90.0 && latitude <= 90.0),
        assert(longitude >= -180.0 && longitude <= 180.0);

  /// Crea un [GeoPoint] da una coppia (lat, lon).
  factory GeoPoint.fromLatLon(double lat, double lon) {
    return GeoPoint(latitude: lat, longitude: lon);
  }

  /// Comodo per debug/log.
  @override
  String toString() => 'GeoPoint(lat: $latitude, lon: $longitude)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeoPoint &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude);
}