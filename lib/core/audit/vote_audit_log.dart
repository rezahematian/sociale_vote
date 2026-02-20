class VoteAuditLog {
  final String voteId;
  final String pollId;
  final String userId;
  final String optionId;
  final DateTime timestamp;
  final String source;

  VoteAuditLog({
    required this.voteId,
    required this.pollId,
    required this.userId,
    required this.optionId,
    required this.timestamp,
    required this.source,
  });
}
