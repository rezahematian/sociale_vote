import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/value_objects/visibility_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_status.dart';

/// Decide se i risultati di un poll possono essere mostrati.
///
/// Centralizza tutta la logica legata a ResultsVisibilityMode.
/// La UI non deve fare switch o controlli diretti.
class PollResultsVisibilityResolver {
  const PollResultsVisibilityResolver();

  bool canShowResults({
    required Poll poll,
    required bool userHasVoted,
  }) {
    final visibilityMode = poll.configuration.visibilityRules.resultsVisibility;

    switch (visibilityMode) {
      case ResultsVisibilityMode.always:
        return true;

      case ResultsVisibilityMode.afterVote:
        return userHasVoted;

      case ResultsVisibilityMode.afterClose:
        return poll.status == PollStatus.closed;
    }
  }
}