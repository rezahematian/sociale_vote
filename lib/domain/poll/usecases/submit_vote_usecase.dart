import '../entities/poll_entity.dart';
import '../entities/vote_entity.dart';
import '../value_objects/vote_request.dart';
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

  Future<(VoteEntity, VoteSubmittedEvent)> execute({
    required String userId,
    required PollEntity poll,
    required List<VoteSelection> selections,
  }) async {
    if (userId.isEmpty) {
      throw UnauthorizedVoteException();
    }

    if (!poll.isOpen) {
      throw PollClosedException();
    }

    final alreadyVoted = await voteRepository.hasUserAlreadyVoted(
      pollId: poll.id,
      userId: userId,
    );

    if (alreadyVoted) {
      throw VoteAlreadyCastException();
    }

    validator.validate(
      poll: poll,
      selections: selections,
    );

    final request = VoteRequest(
      pollId: poll.id,
      userId: userId,
      selections: selections,
    );

    final vote = await voteRepository.submitVote(request);

    final event = VoteSubmittedEvent(vote);

    return (vote, event);
  }
}
