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

class PublicPollVoteEntry {
  final String userId;
  final String? username;
  final String? displayName;
  final List<String> optionIds;
  final DateTime votedAt;

  const PublicPollVoteEntry({
    required this.userId,
    required this.optionIds,
    required this.votedAt,
    this.username,
    this.displayName,
  });
}

class PublicPollVotePage {
  final List<PublicPollVoteEntry> items;
  final bool hasMore;

  const PublicPollVotePage({
    required this.items,
    required this.hasMore,
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

  /// Restituisce la lista dei voti pubblici per un poll, pronta per UI/detail.
  ///
  /// Uso previsto:
  /// - solo quando il poll è a voto pubblico
  /// - solo quando i risultati sono visibili per l’utente corrente
  ///
  /// Supporta:
  /// - ricerca per username/displayName
  /// - paginazione base
  /// - poll multi-voto tramite `optionIds`
  Future<PublicPollVotePage> getPublicVotesForPoll(
    PollId pollId, {
    String? query,
    int limit = 50,
    int offset = 0,
  });

  /// 🔴 Stream realtime per notificare cambiamenti ai voti su un poll.
  ///
  /// Non restituisce i voti direttamente: serve solo come trigger
  /// per ricaricare i risultati.
  Stream<void> watchVotesForPoll(PollId pollId);
}