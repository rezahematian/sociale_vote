import '../entities/poll.dart';
import '../entities/vote.dart';
import '../services/vote_validator.dart';
import '../repositories/i_vote_repository.dart';
import '../exceptions/poll_exceptions.dart';
import '../events/vote_submitted_event.dart';

class SubmitVoteUseCase {
  final IVoteRepository voteRepository;
  final VoteValidator validator;

  SubmitVoteUseCase({
    required this.voteRepository,
    required this.validator,
  });

  Future<(Vote, VoteSubmittedEvent)> execute({
    required String userId,
    required Poll poll,
    required List<String> optionIds,
    String? userCountryCode,
  }) async {
    if (userId.isEmpty) {
      throw UnauthorizedVoteException();
    }

    if (!poll.isOpen) {
      throw PollClosedException();
    }

    final alreadyVoted = await voteRepository.hasUserAlreadyVoted(
      pollId: poll.id.value,
      userId: userId,
    );

    if (alreadyVoted) {
      throw VoteAlreadyCastException();
    }

    validator.validate(
      poll: poll,
      userId: userId,
      userCountryCode: userCountryCode,
      optionIds: optionIds,
    );

    final vote = await voteRepository.submitVote(
      pollId: poll.id.value,
      userId: userId,
      optionIds: optionIds,
    );

    final event = VoteSubmittedEvent(vote);

    return (vote, event);
  }
}