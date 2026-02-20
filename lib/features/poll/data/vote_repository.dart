import '../domain/entities/vote_entity.dart';
import '../domain/entities/vote_request.dart';

abstract class IVoteService {
  Future<VoteEntity> submitVote(VoteRequest request);

  Future<void> submitHeatVote({
    required String pollId,
    required String userId,
    required bool isHot,
  });
}

class VoteRepository {
  // =========================
  // DEPENDENCY
  // =========================
  final IVoteService voteService;

  VoteRepository({
    required this.voteService,
  });

  // =========================
  // SUBMIT VOTE (STRUCTURED)
  // =========================
  Future<VoteEntity> submitVote(
    VoteRequest request,
  ) async {
    try {
      final vote = await voteService.submitVote(request);
      return vote;
    } catch (e) {
      throw Exception('Errore invio voto: $e');
    }
  }

  // =========================
  // 🔥 SUBMIT HEAT VOTE
  // =========================
  Future<void> submitHeatVote({
    required String pollId,
    required String userId,
    required bool isHot,
  }) async {
    try {
      await voteService.submitHeatVote(
        pollId: pollId,
        userId: userId,
        isHot: isHot,
      );
    } catch (e) {
      throw Exception('Errore invio heat vote: $e');
    }
  }
}
