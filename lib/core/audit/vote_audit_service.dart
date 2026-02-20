import 'vote_audit_log.dart';
import '../../domain/poll/vote_entity.dart';

class VoteAuditService {
  final List<VoteAuditLog> _logs = [];

  Future<void> logVote(VoteEntity vote) async {
    final log = VoteAuditLog(
      voteId: vote.id,
      pollId: vote.pollId,
      userId: vote.userId,
      optionId: vote.optionId,
      timestamp: vote.timestamp,
      source: 'client',
    );

    _logs.add(log);

    // In futuro:
    // - invio a backend
    // - firma crittografica
    // - write-once storage
  }

  List<VoteAuditLog> get logs => List.unmodifiable(_logs);
}
