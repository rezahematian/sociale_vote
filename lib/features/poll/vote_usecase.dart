import 'package:sociale_vote/domain/poll/poll_entity.dart';
import 'package:sociale_vote/domain/poll/vote_entity.dart';
import 'package:sociale_vote/domain/poll/vote_request.dart';
import '../../core/security/vote_guard.dart';
import 'vote_repository.dart';

class VoteUseCase {
  final VoteRepository repository;
  final VoteGuard voteGuard;

  VoteUseCase(
    this.repository,
    this.voteGuard,
  );

  Future<VoteEntity> execute({
    required String userId,
    required PollEntity poll,
    required VoteRequest request,
  }) async {
    voteGuard.ensureCanVote(
      userId: userId,
      poll: poll,
    );

    return repository.submit(request);
  }
}
