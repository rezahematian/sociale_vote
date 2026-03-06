import '../value_objects/poll_id.dart';

/// Entità di dominio che rappresenta un voto espresso su un poll.
///
/// Per ora il modello è intenzionalmente minimale:
/// - [pollId]: identifica il poll a cui appartiene il voto
/// - [optionIds]: lista degli id delle opzioni selezionate
/// - [createdAt]: quando è stato espresso il voto
///
/// In futuro potremo estendere il modello con:
/// - identificatore dell'elettore (userId, sessionId, ecc.)
/// - metadati geografici (country/city al momento del voto)
/// - informazioni di auditing (device, ip hash, ecc.)
class Vote {
  final PollId pollId;
  final List<String> optionIds;
  final DateTime createdAt;

  const Vote({
    required this.pollId,
    required this.optionIds,
    required this.createdAt,
  });

  /// Helper per creare un voto "adesso".
  ///
  /// Utile dalla UI, evita di dover passare manualmente la data
  /// in tutti i punti dove costruiamo il voto.
  factory Vote.now({
    required PollId pollId,
    required List<String> optionIds,
  }) {
    return Vote(
      pollId: pollId,
      optionIds: List.unmodifiable(optionIds),
      createdAt: DateTime.now().toUtc(),
    );
  }
}