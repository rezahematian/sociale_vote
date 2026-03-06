import '../value_objects/poll_id.dart';

/// Risultato aggregato di un poll.
///
/// Contiene:
/// - [pollId]: l'identificativo del poll
/// - [totalVotes]: numero totale di voti espressi
/// - [optionResults]: lista di risultati per ogni opzione
class PollResult {
  final PollId pollId;
  final int totalVotes;
  final List<PollOptionResult> optionResults;

  const PollResult({
    required this.pollId,
    required this.totalVotes,
    required this.optionResults,
  });
}

/// Risultato per una singola opzione di un poll.
///
/// Contiene:
/// - [optionId]: l'id dell'opzione (coincide con PollOption.id)
/// - [label]: etichetta leggibile dell'opzione (es. "Yes", "No")
/// - [voteCount]: numero di voti ricevuti
/// - [percentage]: percentuale sul totale (0.0–100.0)
class PollOptionResult {
  final String optionId;
  final String label;
  final int voteCount;
  final double percentage;

  const PollOptionResult({
    required this.optionId,
    required this.label,
    required this.voteCount,
    required this.percentage,
  });
}