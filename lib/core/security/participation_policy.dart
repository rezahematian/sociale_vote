import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/institution_level.dart';
import 'package:sociale_vote/domain/identity/value_objects/role.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';
import 'package:sociale_vote/domain/poll/value_objects/participation_rules.dart';

/// Azioni di partecipazione dell'utente nell'app.
///
/// Tutto ciò che NON è semplice lettura dovrebbe passare da qui.
enum ParticipationAction {
  vote, // Votare un poll
  createPoll, // Creare una nuova votazione
  react, // Reagire con 🔥 / ❄
  comment, // Aggiungere un commento
  createPost, // Creare un post nel social feed
  followScope, // Seguire / smettere di seguire uno scope geografico
  reportContent, // Segnalare un contenuto
  reviewVerificationRequests, // Review richieste verifica lato moderator/admin
}

/// Policy centralizzata per decidere se un utente
/// può eseguire una certa azione di partecipazione.
///
/// Questo è il punto unico dove modificare le regole
/// guest vs logged-in, ruoli, livelli di trust, ecc.
class ParticipationPolicy {
  const ParticipationPolicy();

  /// Ritorna `true` se l'azione è permessa per questo utente.
  ///
  /// [userId] è null se l'utente è guest (non loggato).
  bool canPerform({
    required String? userId,
    required ParticipationAction action,
    Role role = Role.user,
    ActorType actorType = ActorType.citizen,
    VerificationLevel verificationLevel = VerificationLevel.none,
    InstitutionLevel? institutionLevel,
  }) {
    if (!isAuthenticated(userId)) {
      return false;
    }

    switch (action) {
      case ParticipationAction.vote:
      case ParticipationAction.createPoll:
      case ParticipationAction.react:
      case ParticipationAction.comment:
      case ParticipationAction.createPost:
      case ParticipationAction.followScope:
      case ParticipationAction.reportContent:
        return true;

      case ParticipationAction.reviewVerificationRequests:
        return canReviewVerificationRequests(role: role);
    }
  }

  /// Regola specifica per votare un poll, che tiene conto
  /// delle [ParticipationRules] di quel poll.
  ///
  /// Regole attuali:
  /// - utente deve essere loggato
  /// - se scope == everyone → consentito
  /// - se scope == geoScopeOnly → userCountryCode deve combaciare
  ///   con rules.countryCode
  bool canVoteOnPoll({
    required String? userId,
    required ParticipationRules rules,
    String? userCountryCode,
    Role role = Role.user,
    ActorType actorType = ActorType.citizen,
    VerificationLevel verificationLevel = VerificationLevel.none,
    InstitutionLevel? institutionLevel,
  }) {
    if (!canPerform(
      userId: userId,
      action: ParticipationAction.vote,
      role: role,
      actorType: actorType,
      verificationLevel: verificationLevel,
      institutionLevel: institutionLevel,
    )) {
      return false;
    }

    if (rules.scope == ParticipationScope.everyone) {
      return true;
    }

    if (rules.scope == ParticipationScope.geoScopeOnly) {
      final requiredCountry = rules.countryCode;

      if (requiredCountry == null) {
        return false;
      }

      if (userCountryCode == null) {
        return false;
      }

      return userCountryCode == requiredCountry;
    }

    return false;
  }

  /// Utente autenticato reale.
  bool isAuthenticated(String? userId) {
    return userId != null && userId.trim().isNotEmpty;
  }

  /// Ruolo tecnico reviewer/admin.
  bool hasReviewerRole(Role role) {
    return role == Role.moderator || role == Role.admin;
  }

  /// Accesso agli strumenti reviewer delle verification requests.
  bool canReviewVerificationRequests({
    required Role role,
  }) {
    return hasReviewerRole(role);
  }

  /// Citizen standard senza verifica.
  bool isStandardCitizen({
    required ActorType actorType,
    required VerificationLevel verificationLevel,
  }) {
    return actorType == ActorType.citizen &&
        verificationLevel == VerificationLevel.none;
  }

  /// Citizen con verifica identity almeno level1.
  bool isVerifiedCitizen({
    required ActorType actorType,
    required VerificationLevel verificationLevel,
  }) {
    return actorType == ActorType.citizen &&
        verificationLevel != VerificationLevel.none;
  }

  /// Citizen con verifica level2 piena.
  bool isLevel2Citizen({
    required ActorType actorType,
    required VerificationLevel verificationLevel,
  }) {
    return actorType == ActorType.citizen &&
        verificationLevel == VerificationLevel.level2;
  }

  /// Identity prodotto valida come public official.
  bool canActAsPublicOfficial({
    required ActorType actorType,
    required VerificationLevel verificationLevel,
  }) {
    return actorType == ActorType.publicOfficial &&
        verificationLevel == VerificationLevel.level2;
  }

  /// Identity prodotto valida come institution.
  ///
  /// Richiede actor type institution, livello verifica 2
  /// e livello istituzionale valorizzato.
  bool canActAsInstitution({
    required ActorType actorType,
    required VerificationLevel verificationLevel,
    required InstitutionLevel? institutionLevel,
  }) {
    return actorType == ActorType.institution &&
        verificationLevel == VerificationLevel.level2 &&
        institutionLevel != null;
  }

  /// Identity prodotto valida per superfici "verified".
  ///
  /// Include:
  /// - citizen level1
  /// - citizen level2
  /// - public official
  /// - institution
  bool canUseVerifiedIdentityFeatures({
    required ActorType actorType,
    required VerificationLevel verificationLevel,
    required InstitutionLevel? institutionLevel,
  }) {
    return isVerifiedCitizen(
          actorType: actorType,
          verificationLevel: verificationLevel,
        ) ||
        canActAsPublicOfficial(
          actorType: actorType,
          verificationLevel: verificationLevel,
        ) ||
        canActAsInstitution(
          actorType: actorType,
          verificationLevel: verificationLevel,
          institutionLevel: institutionLevel,
        );
  }

  /// Identity prodotto valida per feature che richiedono level2 pieno.
  ///
  /// Include:
  /// - citizen level2
  /// - public official
  /// - institution
  bool canUseLevel2IdentityFeatures({
    required ActorType actorType,
    required VerificationLevel verificationLevel,
    required InstitutionLevel? institutionLevel,
  }) {
    return isLevel2Citizen(
          actorType: actorType,
          verificationLevel: verificationLevel,
        ) ||
        canActAsPublicOfficial(
          actorType: actorType,
          verificationLevel: verificationLevel,
        ) ||
        canActAsInstitution(
          actorType: actorType,
          verificationLevel: verificationLevel,
          institutionLevel: institutionLevel,
        );
  }

  /// Capability prodotto per rappresentanza come attore istituzionale o ufficiale.
  ///
  /// Esclude i citizen verificati.
  bool canUseRepresentativeIdentityFeatures({
    required ActorType actorType,
    required VerificationLevel verificationLevel,
    required InstitutionLevel? institutionLevel,
  }) {
    return canActAsPublicOfficial(
          actorType: actorType,
          verificationLevel: verificationLevel,
        ) ||
        canActAsInstitution(
          actorType: actorType,
          verificationLevel: verificationLevel,
          institutionLevel: institutionLevel,
        );
  }

  /// Capability prodotto strettamente limitata alle institution validate.
  bool canUseInstitutionIdentityFeatures({
    required ActorType actorType,
    required VerificationLevel verificationLevel,
    required InstitutionLevel? institutionLevel,
  }) {
    return canActAsInstitution(
      actorType: actorType,
      verificationLevel: verificationLevel,
      institutionLevel: institutionLevel,
    );
  }

  /// Helper comodo per capire se l'utente ha una identity prodotto
  /// "elevata" oltre il citizen standard.
  bool hasElevatedProductIdentity({
    required ActorType actorType,
    required VerificationLevel verificationLevel,
    required InstitutionLevel? institutionLevel,
  }) {
    return canUseVerifiedIdentityFeatures(
      actorType: actorType,
      verificationLevel: verificationLevel,
      institutionLevel: institutionLevel,
    );
  }
}