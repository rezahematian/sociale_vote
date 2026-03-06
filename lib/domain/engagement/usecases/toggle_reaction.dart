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
/// includendo anche la reazione dell’utente corrente [userReaction],
/// così la UI può:
/// - aggiornare i contatori
/// - evidenziare il pulsante selezionato
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

    // Determiniamo quale sarà la reaction finale dell'utente
    // dopo l'operazione di toggle.
    ReactionType? finalUserReaction;

    if (current == null) {
      // Nessuna reaction → creiamo nuova.
      await _repository.create(
        userId: userId,
        target: target,
        type: type,
        createdAt: now ?? DateTime.now(),
      );
      finalUserReaction = type;
    } else if (current.type == type) {
      // Stessa reaction → toggle off (cancella).
      await _repository.delete(current.id);
      finalUserReaction = null;
    } else {
      // Reaction opposta → aggiorna il tipo.
      await _repository.updateType(
        reactionId: current.id,
        type: type,
      );
      finalUserReaction = type;
    }

    // In ogni caso, recuperiamo il summary aggregato (like/dislike/heat).
    final summary = await _repository.getSummaryForTarget(target);

    // E creiamo un nuovo ReactionSummary che include
    // anche la reazione dell'utente corrente.
    return ReactionSummary(
      target: summary.target,
      likeCount: summary.likeCount,
      dislikeCount: summary.dislikeCount,
      heat: summary.heat,
      userReaction: finalUserReaction,
    );
  }
}