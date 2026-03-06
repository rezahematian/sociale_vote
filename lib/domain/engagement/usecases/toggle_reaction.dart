import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';

import '../entities/reaction_summary.dart';
import '../repositories/reaction_repository.dart';
import '../value_objects/reaction_type.dart';

/// Use case di dominio:
/// l’utente tocca 🔥 o ❄ per un certo contenuto.
///
/// Regole:
/// - se non esiste reaction → la crea
/// - se esiste e ha stesso tipo → la rimuove (toggle off)
/// - se esiste e ha tipo diverso → la aggiorna
///
/// Ritorna sempre il ReactionSummary aggiornato per quel target,
/// così la UI può aggiornare i contatori.
class ToggleReaction {
  final ReactionRepository _repository;

  ToggleReaction(this._repository);

  Future<ReactionSummary> call({
    required String userId,
    required TargetRef target,
    required ReactionType type,
    DateTime? now,
  }) async {
    final current = await _repository.findByUserAndTarget(
      userId: userId,
      target: target,
    );

    if (current == null) {
      // Nessuna reaction → creiamo nuova.
      await _repository.create(
        userId: userId,
        target: target,
        type: type,
        createdAt: now ?? DateTime.now(),
      );
    } else if (current.type == type) {
      // Stessa reaction → toggle off (cancella).
      await _repository.delete(current.id);
    } else {
      // Reaction opposta → aggiorna il tipo.
      await _repository.updateType(
        reactionId: current.id,
        type: type,
      );
    }

    // In ogni caso, restituiamo il summary aggiornato.
    return _repository.getSummaryForTarget(target);
  }
}