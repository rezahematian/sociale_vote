import '../entities/poll.dart';
import '../entities/poll_result.dart';
import '../repositories/i_vote_repository.dart';
import '../services/vote_aggregator.dart';

class GetPollResultsUseCase {
  final IVoteRepository voteRepository;
  final VoteAggregator aggregator;

  GetPollResultsUseCase({
    required this.voteRepository,
    required this.aggregator,
  });

  Future<PollResult> execute(Poll poll) async {
    final votes = await voteRepository.getVotesForPoll(poll.id.value);
    return aggregator.aggregate(poll, votes);
  }
}