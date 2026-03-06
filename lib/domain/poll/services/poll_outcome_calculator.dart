import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/entities/poll_result.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_outcome.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_type.dart';
import 'package:sociale_vote/domain/poll/value_objects/quorum_status.dart';

/// Calcola l'esito ufficiale di un poll.
///
/// Regole v1:
/// - Se quorum non raggiunto → notApplicable
/// - Se 0 voti → notApplicable
/// - Yes/No & SingleChoice:
///     - >50% → approved
///     - =50% o pareggio → tie
///     - <50% → noMajority
/// - Altri tipi → notApplicable (estendibile)
class PollOutcomeCalculator {
  const PollOutcomeCalculator();

  PollOutcome calculate({
    required Poll poll,
    required PollResult result,
    required QuorumStatus quorumStatus,
  }) {
    // 1️⃣ Quorum enforcement
    if (quorumStatus == QuorumStatus.notReached) {
      return PollOutcome.notApplicable;
    }

    // 2️⃣ Nessun voto
    if (result.totalVotes == 0) {
      return PollOutcome.notApplicable;
    }

    // 3️⃣ Solo per Yes/No e SingleChoice in v1
    if (poll.type == PollType.yesNo ||
        poll.type == PollType.singleChoice) {

      if (result.optionResults.isEmpty) {
        return PollOutcome.notApplicable;
      }

      // Trova massimo numero di voti
      final maxVotes = result.optionResults
          .map((o) => o.voteCount)
          .reduce((a, b) => a > b ? a : b);

      // Conta quante opzioni hanno lo stesso massimo
      final topOptions = result.optionResults
          .where((o) => o.voteCount == maxVotes)
          .toList();

      // Pareggio
      if (topOptions.length > 1) {
        return PollOutcome.tie;
      }

      final winningOption = topOptions.first;

      // Percentuale già calcolata nel dominio (0–100)
      final percent = winningOption.percentage;

      if (percent > 50.0) {
        return PollOutcome.approved;
      }

      if (percent == 50.0) {
        return PollOutcome.tie;
      }

      return PollOutcome.noMajority;
    }

    // Tipi non ancora gestiti formalmente
    return PollOutcome.notApplicable;
  }
}