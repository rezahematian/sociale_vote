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
  ///
  /// I parametri identity aggiuntivi sono introdotti ora per rendere
  /// la policy estendibile in futuro senza cambiare di nuovo la firma.
  bool canPerform({
    required String? userId,
    required ParticipationAction action,
    Role role = Role.user,
    ActorType actorType = ActorType.citizen,
    VerificationLevel verificationLevel = VerificationLevel.none,
    InstitutionLevel? institutionLevel,
  }) {
    // Guest NON può fare nessuna azione di partecipazione.
    if (userId == null) {
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
        return role == Role.moderator || role == Role.admin;
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
  ///
  /// Anche qui la firma è già pronta per future regole identity-aware,
  /// senza cambiare di nuovo tutti i punti di chiamata.
  bool canVoteOnPoll({
    required String? userId,
    required ParticipationRules rules,
    String? userCountryCode,
    Role role = Role.user,
    ActorType actorType = ActorType.citizen,
    VerificationLevel verificationLevel = VerificationLevel.none,
    InstitutionLevel? institutionLevel,
  }) {
    // 1) Prima passa dalla policy generale.
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

    // 2) Tutti gli utenti loggati possono votare.
    if (rules.scope == ParticipationScope.everyone) {
      return true;
    }

    // 3) Restrizione geografica.
    if (rules.scope == ParticipationScope.geoScopeOnly) {
      final requiredCountry = rules.countryCode;

      // Se non è definito il country richiesto,
      // consideriamo la regola non valida → blocchiamo.
      if (requiredCountry == null) {
        return false;
      }

      // Utente senza country → blocco.
      if (userCountryCode == null) {
        return false;
      }

      return userCountryCode == requiredCountry;
    }

    return false;
  }
}