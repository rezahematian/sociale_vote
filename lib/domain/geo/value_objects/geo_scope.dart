/// Livello dello scope geografico corrente.
enum GeoScopeLevel {
  world,
  country,
  city,
}

/// Value object che rappresenta lo scope geografico attivo nell'app.
///
/// - [level]: world / country / city
/// - [countryCode]: richiesto per country e city
/// - [cityId]: richiesto per city
///
/// Esempi:
/// - GeoScope.world()
/// - GeoScope.country('IT')
/// - GeoScope.city(countryCode: 'IT', cityId: 'TORINO')
class GeoScope {
  final GeoScopeLevel level;
  final String? countryCode;
  final String? cityId;

  const GeoScope._({
    required this.level,
    this.countryCode,
    this.cityId,
  });

  /// Scope globale (mondo intero).
  factory GeoScope.world() {
    return const GeoScope._(
      level: GeoScopeLevel.world,
    );
  }

  /// Scope a livello di paese.
  factory GeoScope.country(String countryCode) {
    return GeoScope._(
      level: GeoScopeLevel.country,
      countryCode: countryCode,
    );
  }

  /// Scope a livello di città.
  factory GeoScope.city({
    required String countryCode,
    required String cityId,
  }) {
    return GeoScope._(
      level: GeoScopeLevel.city,
      countryCode: countryCode,
      cityId: cityId,
    );
  }

  bool get isWorld => level == GeoScopeLevel.world;
  bool get isCountry => level == GeoScopeLevel.country;
  bool get isCity => level == GeoScopeLevel.city;

  @override
  String toString() {
    switch (level) {
      case GeoScopeLevel.world:
        return 'GeoScope(world)';
      case GeoScopeLevel.country:
        return 'GeoScope(country: $countryCode)';
      case GeoScopeLevel.city:
        return 'GeoScope(city: $countryCode / $cityId)';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeoScope &&
        other.level == level &&
        other.countryCode == countryCode &&
        other.cityId == cityId;
  }

  @override
  int get hashCode => Object.hash(level, countryCode, cityId);
}