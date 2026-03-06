import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/entities/poll_result.dart';
import 'package:sociale_vote/domain/poll/value_objects/quorum_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/quorum_status.dart';

/// Servizio di dominio che valuta il quorum di un poll
/// sulla base delle [QuorumRules] e dei risultati aggregati.
///
/// v1: enforcement reale su quorum assoluto (minAbsoluteVotes).
/// Quando conosciamo meglio la forma di QuorumRules (es. percentuali),
/// estendiamo qui senza toccare controller/UI.
class PollQuorumEvaluator {
  const PollQuorumEvaluator();

  QuorumStatus evaluate({
    required Poll poll,
    required PollResult result,
  }) {
    final QuorumRules? rules = poll.configuration.quorumRules;

    // Nessuna regola di quorum configurata → non applicabile
    if (rules == null || rules.minAbsoluteVotes == null) {
      return QuorumStatus.notApplicable;
    }

    // 👇 Assunzione v1: PollResult espone il totale voti come `totalVotes`.
    // Se il campo ha un altro nome (es. `totalVotesCount`), cambia SOLO questa riga.
    final int totalVotes = result.totalVotes;

    // Nessun voto o meno del minimo → quorum non raggiunto
    if (totalVotes < rules.minAbsoluteVotes!) {
      return QuorumStatus.notReached;
    }

    // Se siamo qui, il requisito assoluto è soddisfatto
    return QuorumStatus.reached;
  }
}