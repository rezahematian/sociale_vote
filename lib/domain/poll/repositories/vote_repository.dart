import '../entities/vote.dart';
import '../value_objects/poll_id.dart';

class PollVoteAggregate {
  final int totalVotes;
  final Map<String, int> optionCounts;

  const PollVoteAggregate({
    required this.totalVotes,
    required this.optionCounts,
  });
}

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
  /// Manteniamo questo metodo per compatibilità / fallback.
  Future<List<Vote>> getVotesForPoll(PollId pollId);

  /// Restituisce il tally aggregato del poll senza scaricare tutti i voti.
  ///
  /// `totalVotes` = numero di righe voto del poll
  /// `optionCounts` = conteggi aggregati per optionId
  Future<PollVoteAggregate> getVoteAggregateForPoll(PollId pollId);

  /// 🔴 Stream realtime per notificare nuovi voti su un poll.
  ///
  /// Non restituisce i voti direttamente: serve solo come trigger
  /// per ricaricare i risultati.
  Stream<void> watchVotesForPoll(PollId pollId);
}