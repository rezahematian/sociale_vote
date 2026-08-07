import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';

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
/// - [scope] definisce se tutti possono votare o solo un ambito geografico.
/// - [countryCode] è opzionale e viene usato solo quando [scope] è
///   [ParticipationScope.geoScopeOnly] per vincolare la partecipazione
///   a uno specifico paese (ISO 3166-1 alpha-2).
/// - [minimumVerificationLevel] definisce il livello minimo di verifica
///   Persona richiesto per partecipare al poll.
class ParticipationRules {
  final ParticipationScope scope;

  /// Codice paese ISO 3166-1 alpha-2 a cui è vincolata la partecipazione.
  ///
  /// - `null` → nessun vincolo esplicito di paese.
  /// - non-null + [scope] == [ParticipationScope.geoScopeOnly] → il paese
  ///   di voto verificato dell'utente deve coincidere con questo valore.
  final String? countryCode;

  /// Livello minimo di verifica Persona richiesto per votare.
  ///
  /// - [VerificationLevel.none] → nessuna verifica Persona richiesta.
  /// - [VerificationLevel.level1] → Persona Livello 1 o Livello 2.
  /// - [VerificationLevel.level2] → solo Persona Livello 2.
  ///
  /// Le identità pubbliche autonome (funzionario, istituzione,
  /// organizzazione) restano separate e potranno avere regole dedicate.
  final VerificationLevel minimumVerificationLevel;

  const ParticipationRules({
    this.scope = ParticipationScope.everyone,
    this.countryCode,
    this.minimumVerificationLevel = VerificationLevel.none,
  });

  bool get isEveryoneAllowed => scope == ParticipationScope.everyone;

  bool get isRestrictedToGeoScope => scope == ParticipationScope.geoScopeOnly;

  bool get requiresVerification =>
      minimumVerificationLevel != VerificationLevel.none;

  ParticipationRules copyWith({
    ParticipationScope? scope,
    String? countryCode,
    VerificationLevel? minimumVerificationLevel,
  }) {
    return ParticipationRules(
      scope: scope ?? this.scope,
      countryCode: countryCode ?? this.countryCode,
      minimumVerificationLevel:
          minimumVerificationLevel ?? this.minimumVerificationLevel,
    );
  }
}
