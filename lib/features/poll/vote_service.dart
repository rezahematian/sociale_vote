import '../../domain/poll/vote_entity.dart';
import '../../domain/poll/vote_request.dart';

import 'vote_repository.dart';

class VoteService {
  // =========================
  // DEPENDENCY
  // =========================
  late final VoteRepository _voteRepository;

  // Costruttore vuoto (compatibile con AppBootstrap)
  VoteService();

  // Iniezione esplicita post-bootstrap
  void attachRepository(VoteRepository voteRepository) {
    _voteRepository = voteRepository;
  }

  // =========================
  // DOMAIN API
  // =========================
  Future<VoteEntity> submitVote(VoteRequest request) async {
    return _voteRepository.submitVote(request);
  }
}
