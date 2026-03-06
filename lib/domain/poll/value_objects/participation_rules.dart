/// A chi è permesso partecipare a questo poll.
///
/// Per ora lo teniamo semplice: tutti oppure solo utenti
/// all'interno dello stesso ambito geografico (GeoScope).
enum ParticipationScope {
  /// Tutti gli utenti registrati possono votare.
  everyone,

  /// Solo utenti che appartengono all'ambito geografico del poll
  /// (world/country/city in base al countryCode/cityId associato).
  geoScopeOnly,
}

/// Regole di partecipazione al poll.
///
/// In questa fase:
/// - [scope] definisce se tutti possono votare o solo un ambito geografico.
/// - [countryCode] è opzionale e viene usato solo quando [scope] è
///   [ParticipationScope.geoScopeOnly] per vincolare la partecipazione
///   a uno specifico paese (ISO 3166-1 alpha-2).
class ParticipationRules {
  final ParticipationScope scope;

  /// Codice paese ISO 3166-1 alpha-2 a cui è vincolata la partecipazione.
  ///
  /// - `null` → nessun vincolo esplicito di paese.
  /// - non-null + [scope] == [ParticipationScope.geoScopeOnly] → solo
  ///   utenti appartenenti a questo paese potranno votare (logica futura).
  final String? countryCode;

  const ParticipationRules({
    this.scope = ParticipationScope.everyone,
    this.countryCode,
  });

  bool get isEveryoneAllowed => scope == ParticipationScope.everyone;

  bool get isRestrictedToGeoScope =>
      scope == ParticipationScope.geoScopeOnly;

  ParticipationRules copyWith({
    ParticipationScope? scope,
    String? countryCode,
  }) {
    return ParticipationRules(
      scope: scope ?? this.scope,
      countryCode: countryCode ?? this.countryCode,
    );
  }
}