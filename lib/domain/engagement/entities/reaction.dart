import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';

import '../value_objects/reaction_type.dart';

/// Singola reazione di un utente verso un target (poll, news, post, ...).
///
/// Vincoli di business:
/// - un utente può avere al massimo UNA reaction per (target, userId)
/// - ToggleReaction gestisce creazione/aggiornamento/cancellazione
class Reaction {
  final String id;
  final String userId;
  final TargetRef target;
  final ReactionType type;
  final DateTime createdAt;

  const Reaction({
    required this.id,
    required this.userId,
    required this.target,
    required this.type,
    required this.createdAt,
  });

  Reaction copyWith({
    String? id,
    String? userId,
    TargetRef? target,
    ReactionType? type,
    DateTime? createdAt,
  }) {
    return Reaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      target: target ?? this.target,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}