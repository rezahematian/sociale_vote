import '../entities/poll.dart';
import '../entities/poll_result.dart';
import '../entities/vote.dart';

/// Servizio di dominio che aggrega i voti di un poll
/// e calcola conteggi e percentuali per ogni opzione.
///
/// Non conosce repository, HTTP o storage: lavora solo
/// con entità di dominio (`Poll`, `Vote`, `PollResult`).
class VoteAggregator {
  /// Calcola il [PollResult] per il [poll] dato e la lista di [votes].
  ///
  /// - [poll]: definizione del sondaggio (opzioni, id, ecc.)
  /// - [votes]: lista di voti espressi per quel poll
  ///
  /// Le percentuali sono calcolate rispetto al numero totale
  /// di selezioni (somma di tutte le optionIds dei voti),
  /// così da gestire anche i poll a scelta multipla.
  PollResult aggregate(Poll poll, List<Vote> votes) {
    final Map<String, int> countsByOptionId = {
      for (final option in poll.options) option.id: 0,
    };

    for (final vote in votes) {
      for (final selectedId in vote.optionIds) {
        if (countsByOptionId.containsKey(selectedId)) {
          countsByOptionId[selectedId] = countsByOptionId[selectedId]! + 1;
        }
      }
    }

    return aggregateFromCounts(
      poll,
      totalVotes: votes.length,
      countsByOptionId: countsByOptionId,
    );
  }

  PollResult aggregateFromCounts(
    Poll poll, {
    required int totalVotes,
    required Map<String, int> countsByOptionId,
  }) {
    if (poll.options.isEmpty) {
      return PollResult(
        pollId: poll.id,
        totalVotes: totalVotes,
        optionResults: const <PollOptionResult>[],
      );
    }

    final normalizedCountsByOptionId = <String, int>{
      for (final option in poll.options) option.id: countsByOptionId[option.id] ?? 0,
    };

    final int totalSelections = normalizedCountsByOptionId.values.fold(
      0,
      (a, b) => a + b,
    );

    final optionResults = poll.options.map((option) {
      final count = normalizedCountsByOptionId[option.id] ?? 0;

      final double percentage;
      if (totalSelections == 0) {
        percentage = 0.0;
      } else {
        percentage = (count / totalSelections) * 100.0;
      }

      return PollOptionResult(
        optionId: option.id,
        label: option.label,
        voteCount: count,
        percentage: percentage,
      );
    }).toList(growable: false);

    return PollResult(
      pollId: poll.id,
      totalVotes: totalVotes,
      optionResults: optionResults,
    );
  }
}