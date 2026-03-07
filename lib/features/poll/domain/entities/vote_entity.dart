// lib/domain/poll/vote_entity.dart

class VoteEntity {
  final String id;
  final String pollId;
  final String userId;

  /// Lista selezioni (supporta single, multi, ranking, weighted)
  final List<VoteSelection> selections;

  final DateTime timestamp;

  VoteEntity({
    required this.id,
    required this.pollId,
    required this.userId,
    required this.selections,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  VoteEntity copyWith({
    String? id,
    String? pollId,
    String? userId,
    List<VoteSelection>? selections,
    DateTime? timestamp,
  }) {
    return VoteEntity(
      id: id ?? this.id,
      pollId: pollId ?? this.pollId,
      userId: userId ?? this.userId,
      selections: selections ?? this.selections,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VoteEntity &&
        other.id == id &&
        other.pollId == pollId &&
        other.userId == userId &&
        _listEquals(other.selections, selections);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      pollId,
      userId,
      selections,
    );
  }

  bool _listEquals(List<VoteSelection> a, List<VoteSelection> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class VoteSelection {
  final String optionId;

  /// Per ranking (1°, 2°, 3°...)
  final int? rank;

  /// Per weighted voting
  final double? weight;

  const VoteSelection({
    required this.optionId,
    this.rank,
    this.weight,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VoteSelection &&
        other.optionId == optionId &&
        other.rank == rank &&
        other.weight == weight;
  }

  @override
  int get hashCode => Object.hash(optionId, rank, weight);
}
