class VoteSelection {
  final String optionId;

  /// Per ranked voting (posizione)
  final int? rank;

  /// Per score voting (punteggio)
  final int? score;

  const VoteSelection({
    required this.optionId,
    this.rank,
    this.score,
  });
}

class VoteRequest {
  final String pollId;
  final String userId;
  final DateTime timestamp;

  /// Lista selezioni (single, multiple, ranked, score, approval)
  final List<VoteSelection> selections;

  const VoteRequest({
    required this.pollId,
    required this.userId,
    required this.timestamp,
    required this.selections,
  });

  // =========================
  // DOMAIN HELPERS
  // =========================

  int get selectedCount => selections.length;

  bool get isEmpty => selections.isEmpty;

  bool get isSingleSelection => selections.length == 1;

  bool get containsRanking =>
      selections.any((s) => s.rank != null);

  bool get containsScore =>
      selections.any((s) => s.score != null);

  List<int> get ranks =>
      selections.where((s) => s.rank != null).map((s) => s.rank!).toList();

  List<int> get scores =>
      selections.where((s) => s.score != null).map((s) => s.score!).toList();
}
