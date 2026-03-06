/// Livello dello scope geografico corrente.
enum GeoScopeLevel {
  world,
  country,
  city,
}

/// Value object che rappresenta lo scope geografico attivo nell'app.
///
/// Supporta sia:
/// - modello amministrativo (world / country / city)
/// - modello geografico puro (area centrata su una lat/lng con un raggio)
///
/// - [level]: world / country / city
/// - [countryCode]: usato per country e city
/// - [cityId]: usato per city
/// - [centerLat], [centerLng], [radiusKm]:
///     opzionali, usati per rappresentare un'area geografica pura.
///
/// Esempi:
/// - GeoScope.world()
/// - GeoScope.country('IT')
/// - GeoScope.city(countryCode: 'IT', cityId: 'TORINO')
/// - GeoScope.area(centerLat: 46.50, centerLng: 11.35, radiusKm: 25)
class GeoScope {
  final GeoScopeLevel level;

  /// Codice paese (es. "IT", "UK").
  final String? countryCode;

  /// Identificativo città (es. "TORINO", "BOLZANO").
  final String? cityId;

  /// Centro geografico (latitudine) dello scope.
  final double? centerLat;

  /// Centro geografico (longitudine) dello scope.
  final double? centerLng;

  /// Raggio approssimativo in chilometri dell'area coperta dallo scope.
  final double? radiusKm;

  const GeoScope._({
    required this.level,
    this.countryCode,
    this.cityId,
    this.centerLat,
    this.centerLng,
    this.radiusKm,
  });

  /// Scope globale (mondo intero).
  ///
  /// Per il modello geografico puro associamo un raggio molto grande.
  factory GeoScope.world() {
    return const GeoScope._(
      level: GeoScopeLevel.world,
      centerLat: 0, // centro approssimativo del globo
      centerLng: 0,
      radiusKm: 20000, // copre praticamente tutto il pianeta
    );
  }

  /// Scope a livello di paese.
  ///
  /// Ora può avere anche un centro geografico e un raggio,
  /// in modo che la mappa possa centrare correttamente il paese.
  factory GeoScope.country(
    String countryCode, {
    double? centerLat,
    double? centerLng,
    double? radiusKm,
  }) {
    return GeoScope._(
      level: GeoScopeLevel.country,
      countryCode: countryCode,
      centerLat: centerLat,
      centerLng: centerLng,
      radiusKm: radiusKm,
    );
  }

  /// Scope a livello di città.
  ///
  /// Può essere arricchito con centerLat/centerLng/radiusKm.
  factory GeoScope.city({
    required String countryCode,
    required String cityId,
    double? centerLat,
    double? centerLng,
    double? radiusKm,
  }) {
    return GeoScope._(
      level: GeoScopeLevel.city,
      countryCode: countryCode,
      cityId: cityId,
      centerLat: centerLat,
      centerLng: centerLng,
      radiusKm: radiusKm,
    );
  }

  /// Scope geografico puro basato su un'area attorno a un punto.
  factory GeoScope.area({
    required double centerLat,
    required double centerLng,
    required double radiusKm,
  }) {
    // Usiamo `GeoScopeLevel.city` come livello logico per non rompere
    // switch/if esistenti che si basano su isCity.
    return GeoScope._(
      level: GeoScopeLevel.city,
      centerLat: centerLat,
      centerLng: centerLng,
      radiusKm: radiusKm,
    );
  }

  bool get isWorld => level == GeoScopeLevel.world;
  bool get isCountry => level == GeoScopeLevel.country;
  bool get isCity => level == GeoScopeLevel.city;

  /// True se lo scope rappresenta un'area geografica pura
  /// (ovvero se centro e raggio sono definiti).
  bool get hasGeoArea =>
      centerLat != null && centerLng != null && radiusKm != null;

  @override
  String toString() {
    final buffer = StringBuffer('GeoScope(');

    buffer.write(level.toString().split('.').last);

    if (countryCode != null) {
      buffer.write(', country: $countryCode');
    }
    if (cityId != null) {
      buffer.write(', city: $cityId');
    }
    if (hasGeoArea) {
      buffer.write(
          ', center=(${centerLat!.toStringAsFixed(4)}, ${centerLng!.toStringAsFixed(4)}), radiusKm=${radiusKm!.toStringAsFixed(1)}');
    }

    buffer.write(')');
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeoScope &&
        other.level == level &&
        other.countryCode == countryCode &&
        other.cityId == cityId &&
        other.centerLat == centerLat &&
        other.centerLng == centerLng &&
        other.radiusKm == radiusKm;
  }

  @override
  int get hashCode =>
      Object.hash(level, countryCode, cityId, centerLat, centerLng, radiusKm);
}