/// Regole di quorum / validità della votazione.
///
/// Per ora supportiamo solo un quorum assoluto minimo.
/// In futuro possiamo aggiungere percentuali, ecc.
class QuorumRules {
  /// Numero minimo assoluto di voti richiesti perché la votazione
  /// sia considerata valida. Se null o <= 0, nessun quorum.
  final int? minAbsoluteVotes;

  const QuorumRules({
    this.minAbsoluteVotes,
  });

  bool get hasQuorumRequirement =>
      minAbsoluteVotes != null && minAbsoluteVotes! > 0;

  QuorumRules copyWith({
    int? minAbsoluteVotes,
  }) {
    return QuorumRules(
      minAbsoluteVotes: minAbsoluteVotes ?? this.minAbsoluteVotes,
    );
  }
}