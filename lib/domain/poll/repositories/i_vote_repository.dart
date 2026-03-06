import '../entities/vote.dart';

abstract class IVoteRepository {
  Future<Vote> submitVote({
    required String pollId,
    required String userId,
    required List<String> optionIds,
  });

  Future<bool> hasUserAlreadyVoted({
    required String pollId,
    required String userId,
  });

  Future<List<Vote>> getVotesForPoll(String pollId);
}