/// A chi è permesso partecipare a questo poll.
///
/// Per ora lo teniamo semplice: tutti oppure solo utenti
/// all'interno dello stesso ambito geografico (GeoScope).
enum ParticipationScope {
  /// Tutti gli utenti registrati possono votare.
  everyone,

  /// Solo utenti che appartengono all'ambito geografico del poll
  /// (world/country/city in base a countryCode/cityId del poll).
  geoScopeOnly,
}

class ParticipationRules {
  final ParticipationScope scope;

  const ParticipationRules({
    this.scope = ParticipationScope.everyone,
  });

  bool get isEveryoneAllowed => scope == ParticipationScope.everyone;

  bool get isRestrictedToGeoScope =>
      scope == ParticipationScope.geoScopeOnly;

  ParticipationRules copyWith({
    ParticipationScope? scope,
  }) {
    return ParticipationRules(
      scope: scope ?? this.scope,
    );
  }
}