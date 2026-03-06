import 'poll_entity.dart';
import 'vote_entity.dart';
import 'poll_type.dart';

class VoteAggregator {
  Map<String, double> aggregate({
    required PollEntity poll,
    required List<VoteEntity> votes,
  }) {
    switch (poll.type) {
      case PollType.singleChoice:
        return _aggregateSingle(votes);

      case PollType.multipleChoice:
        return _aggregateSingle(votes);

      case PollType.rankedChoice:
        return _aggregateRanked(votes);

      case PollType.weighted:
        return _aggregateWeighted(votes);
    }
  }

  // =========================
  // SINGLE / MULTI
  // =========================

  Map<String, double> _aggregateSingle(
    List<VoteEntity> votes,
  ) {
    final result = <String, double>{};

    for (final vote in votes) {
      for (final selection in vote.selections) {
        result.update(
          selection.optionId,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }

    return result;
  }

  // =========================
  // RANKED (Borda Count)
  // =========================

  Map<String, double> _aggregateRanked(
    List<VoteEntity> votes,
  ) {
    final result = <String, double>{};

    for (final vote in votes) {
      final maxRank = vote.selections.length;

      for (final selection in vote.selections) {
        final score = (maxRank - (selection.rank! - 1)).toDouble();

        result.update(
          selection.optionId,
          (value) => value + score,
          ifAbsent: () => score,
        );
      }
    }

    return result;
  }

  // =========================
  // WEIGHTED
  // =========================

  Map<String, double> _aggregateWeighted(
    List<VoteEntity> votes,
  ) {
    final result = <String, double>{};

    for (final vote in votes) {
      for (final selection in vote.selections) {
        result.update(
          selection.optionId,
          (value) => value + selection.weight!,
          ifAbsent: () => selection.weight!,
        );
      }
    }

    return result;
  }
}
