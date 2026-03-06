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
    if (votes.isEmpty || poll.options.isEmpty) {
      return PollResult(
        pollId: poll.id,
        totalVotes: 0,
        optionResults: poll.options
            .map(
              (option) => PollOptionResult(
                optionId: option.id,
                label: option.label,
                voteCount: 0,
                percentage: 0.0,
              ),
            )
            .toList(),
      );
    }

    // Conteggio selezioni per opzione.
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

    final int totalSelections = countsByOptionId.values.fold(0, (a, b) => a + b);
    final int totalVotes = votes.length;

    final optionResults = poll.options.map((option) {
      final count = countsByOptionId[option.id] ?? 0;

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
    }).toList();

    return PollResult(
      pollId: poll.id,
      totalVotes: totalVotes,
      optionResults: optionResults,
    );
  }
}