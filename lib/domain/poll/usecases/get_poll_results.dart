import '../entities/poll.dart';
import '../entities/poll_result.dart';
import '../entities/vote.dart';
import '../repositories/vote_repository.dart';
import '../services/vote_aggregator.dart';
import '../value_objects/poll_id.dart';

/// Use case per ottenere i risultati aggregati di un poll.
///
/// Flusso:
/// - recupera tutti i voti per il poll tramite [VoteRepository]
/// - usa [VoteAggregator] per calcolare conteggi e percentuali
/// - restituisce un [PollResult] di dominio
class GetPollResults {
  final VoteRepository _voteRepository;
  final VoteAggregator _aggregator;

  GetPollResults(
    this._voteRepository,
    this._aggregator,
  );

  Future<PollResult> call(Poll poll) async {
    final PollId pollId = poll.id;

    final List<Vote> votes = await _voteRepository.getVotesForPoll(pollId);

    return _aggregator.aggregate(poll, votes);
  }
}