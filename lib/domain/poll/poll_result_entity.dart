class PollResultEntity {
  final List<PollResultItem> items;
  final int totalVotes;

  PollResultEntity({
    required this.items,
    required this.totalVotes,
  });

  /// Opzione con punteggio più alto
  PollResultItem? get winner {
    if (items.isEmpty) return null;
    return items.first;
  }

  /// Risultati ordinati per punteggio decrescente
  factory PollResultEntity.fromRaw({
    required Map<String, double> rawResults,
    required int totalVotes,
  }) {
    final sorted = rawResults.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final items = sorted.map((entry) {
      final percentage = totalVotes == 0
          ? 0.0
          : (entry.value / totalVotes) * 100;

      return PollResultItem(
        optionId: entry.key,
        score: entry.value,
        percentage: percentage,
      );
    }).toList();

    return PollResultEntity(
      items: items,
      totalVotes: totalVotes,
    );
  }
}

class PollResultItem {
  final String optionId;
  final double score;
  final double percentage;

  const PollResultItem({
    required this.optionId,
    required this.score,
    required this.percentage,
  });
}
