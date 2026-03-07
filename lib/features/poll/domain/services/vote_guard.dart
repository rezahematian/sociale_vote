import '../entities/poll_entity.dart';
import '../entities/vote_request.dart';
import '../value_objects/voting_policy.dart';

class VoteGuard {
  final VotingPolicy votingPolicy;

  const VoteGuard({
    required this.votingPolicy,
  });

  void ensureCanVote({
    required String userId,
    required PollEntity poll,
    required VoteRequest request,
  }) {
    _validateUser(userId);
    _validatePollState(poll);
    _validateRequestIntegrity(poll, request);

    votingPolicy.checkVoteAllowed(
      poll: poll,
      request: request,
    );
  }

  // =========================
  // PRIVATE VALIDATIONS
  // =========================

  void _validateUser(String userId) {
    if (userId.isEmpty) {
      throw Exception('Invalid user identity');
    }
  }

  void _validatePollState(PollEntity poll) {
    if (!poll.isOpen) {
      throw Exception('Poll is closed or expired');
    }

    if (poll.userHasVoted) {
      throw Exception('User has already voted');
    }
  }

  void _validateRequestIntegrity(
    PollEntity poll,
    VoteRequest request,
  ) {
    if (request.selections.isEmpty) {
      throw Exception('No selections provided');
    }

    final optionIds =
        poll.options.map((o) => o.id).toSet();

    for (final selection in request.selections) {
      if (!optionIds.contains(selection.optionId)) {
        throw Exception('Invalid option selected');
      }
    }

    // multi-selection limit
    if (!poll.configuration.allowMultipleSelection &&
        request.selections.length > 1) {
      throw Exception(
          'Multiple selections not allowed');
    }

    if (poll.configuration.maxSelections != null &&
        request.selections.length >
            poll.configuration.maxSelections!) {
      throw Exception(
          'Exceeded maximum allowed selections');
    }
  }
}
