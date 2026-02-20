import '../entities/vote_entity.dart';
import '../value_objects/vote_request.dart';

abstract class IVoteRepository {
  Future<VoteEntity> submitVote(VoteRequest request);

  Future<bool> hasUserAlreadyVoted({
    required String pollId,
    required String userId,
  });

  Future<List<VoteEntity>> getVotesForPoll(String pollId);
}
