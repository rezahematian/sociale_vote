import '../entities/poll.dart';
import '../value_objects/poll_id.dart';

abstract class PollRepository {
  /// Restituisce la lista di poll per uno scope geografico.
  ///
  /// - [countryCode], [cityId] seguono la stessa logica usata in tutta l’app:
  ///   - entrambi null  → scope "world"
  ///   - solo [countryCode] → scope paese
  ///   - [countryCode] + [cityId] → scope città
  ///
  /// Fase 4.3 – paginazione:
  /// - [limit]  → numero massimo di elementi da restituire
  /// - [offset] → skip iniziale (es. pagina 2 = limit * 1, ecc.)
  ///
  /// Implementazioni:
  /// - in-memory: possono simulare la paginazione con uno slice sulla lista.
  /// - HTTP: possono tradurre [limit]/[offset] in query parameter.
  Future<List<Poll>> getPolls({
    String? countryCode,
    String? cityId,
    int? limit,
    int? offset,
  });

  Future<Poll?> getPollDetail(PollId pollId);

  /// Crea una nuova votazione.
  ///
  /// In questa versione mock:
  /// - il repository può sostituire l'eventuale `PollId` passato
  ///   con uno generato internamente;
  /// - restituisce il `Poll` effettivamente creato/persistito.
  Future<Poll> createPoll(Poll poll);

  /// Elimina una votazione esistente.
  ///
  /// La policy owner-only viene gestita dal backend / RLS e dal wiring UI.
  Future<void> deletePoll(String pollId);

  /// Aggiorna solo i campi testuali minimi del poll.
  ///
  /// Non deve toccare:
  /// - opzioni
  /// - regole/configurazione
  /// - status
  /// - scope/location
  /// - risultati/voti
  Future<Poll> updatePollText({
    required String pollId,
    required String title,
    String? description,
  });
}