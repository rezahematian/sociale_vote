import 'package:sociale_vote/domain/poll/value_objects/participation_rules.dart';

/// Azioni di partecipazione dell'utente nell'app.
///
/// Tutto ciò che NON è semplice lettura dovrebbe passare da qui.
enum ParticipationAction {
  vote,          // Votare un poll
  createPoll,    // Creare una nuova votazione
  react,         // Reagire con 🔥 / ❄
  comment,       // Aggiungere un commento
  createPost,    // Creare un post nel social feed
  followScope,   // Seguire / smettere di seguire uno scope geografico
  reportContent, // Segnalare un contenuto
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
  }) {
    // Guest NON può fare nessuna azione di partecipazione.
    if (userId == null) {
      return false;
    }

    // V1: utente loggato può fare tutte le azioni.
    return true;
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
  }) {
    // 1️⃣ Senza utente loggato non si vota.
    if (userId == null) {
      return false;
    }

    // 2️⃣ Tutti possono votare.
    if (rules.scope == ParticipationScope.everyone) {
      return true;
    }

    // 3️⃣ Restrizione geografica.
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