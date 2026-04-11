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
  /// Invia il primo voto dell'utente corrente per un poll.
  ///
  /// L'implementazione concreta (infrastructure) si occuperà di:
  /// - validare a livello tecnico la richiesta (HTTP, DB, ecc.)
  /// - propagare eventuali errori di rete/persistenza
  Future<void> submitVote(Vote vote);

  /// Aggiorna il voto già esistente dell'utente corrente per un poll.
  ///
  /// Questo serve quando il poll consente la modifica del voto.
  Future<void> updateVote(Vote vote);

  /// Verifica se l'utente corrente ha già votato su questo poll.
  ///
  /// Serve al use case per distinguere:
  /// - primo voto
  /// - voto già esistente modificabile
  /// - voto già esistente non modificabile
  Future<bool> hasCurrentUserVoted(PollId pollId);

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

  /// 🔴 Stream realtime per notificare cambiamenti ai voti su un poll.
  ///
  /// Non restituisce i voti direttamente: serve solo come trigger
  /// per ricaricare i risultati.
  Stream<void> watchVotesForPoll(PollId pollId);
}