import '../entities/vote.dart';
import '../value_objects/poll_id.dart';

abstract class VoteRepository {
  /// Invia un voto per un poll.
  ///
  /// L'implementazione concreta (infrastructure) si occuperà di:
  /// - validare a livello tecnico la richiesta (HTTP, ecc.)
  /// - propagare eventuali errori di rete
  ///
  /// Le regole di business (chi può votare, quando, quante volte, ecc.)
  /// stanno nei servizi di dominio (es. VoteValidator, PollPolicyService),
  /// non qui.
  Future<void> submitVote(Vote vote);

  /// Restituisce tutti i voti associati a un poll.
  ///
  /// Usato per calcolare risultati aggregati (percentuali, conteggi, ecc.).
  Future<List<Vote>> getVotesForPoll(PollId pollId);

  /// 🔴 Stream realtime per notificare nuovi voti su un poll.
  ///
  /// Non restituisce i voti direttamente: serve solo come trigger
  /// per ricaricare i risultati tramite [getVotesForPoll].
  Stream<void> watchVotesForPoll(PollId pollId);
}