import 'package:sociale_vote/domain/poll/entities/vote.dart';
import 'package:sociale_vote/domain/poll/repositories/vote_repository.dart';

class VoteService {
  VoteRepository? _voteRepository;

  // Costruttore vuoto (compatibile con AppBootstrap)
  VoteService();

  // Iniezione esplicita post-bootstrap
  void attachRepository(VoteRepository voteRepository) {
    _voteRepository = voteRepository;
  }

  // =========================
  // DOMAIN API
  // =========================
  Future<void> submitVote(Vote vote) async {
    final repo = _voteRepository;
    if (repo == null) {
      throw StateError(
        'VoteService not initialized: call attachRepository(VoteRepository) before submitVote().',
      );
    }

    await repo.submitVote(vote);
  }
}