import '../entities/poll_entity.dart';
import '../repositories/i_vote_repository.dart';
import '../services/vote_aggregator.dart';
import '../entities/poll_result_entity.dart';

class GetPollResultsUseCase {
  final IVoteRepository voteRepository;
  final VoteAggregator aggregator;

  GetPollResultsUseCase({
    required this.voteRepository,
    required this.aggregator,
  });

  Future<PollResultEntity> execute(PollEntity poll) async {
    final votes = await voteRepository.getVotesForPoll(poll.id);

    final raw = aggregator.aggregate(
      poll: poll,
      votes: votes,
    );

    return PollResultEntity.fromRaw(
      rawResults: raw,
      totalVotes: votes.length,
    );
  }
}
