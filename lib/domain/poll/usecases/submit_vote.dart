import '../entities/vote.dart';
import '../repositories/vote_repository.dart';

class SubmitVote {
  final VoteRepository voteRepository;

  SubmitVote(this.voteRepository);

  Future<void> call(Vote vote) {
    return voteRepository.submitVote(vote);
  }
}