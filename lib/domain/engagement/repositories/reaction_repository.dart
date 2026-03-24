import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';

import '../entities/reaction.dart';
import '../entities/reaction_summary.dart';
import '../value_objects/reaction_type.dart';

/// Contratto di dominio per la persistenza delle reazioni.
///
/// Non sappiamo ancora se useremo DB locale, REST, ecc.
/// L’implementazione concreta vivrà in infrastructure/engagement/.
abstract class ReactionRepository {
  /// Trova una reaction di un certo utente verso un certo target,
  /// oppure null se non esiste.
  Future<Reaction?> findByUserAndTarget({
    required String userId,
    required TargetRef target,
  });

  /// Crea una nuova reaction.
  Future<Reaction> create({
    required String userId,
    required TargetRef target,
    required ReactionType type,
    required DateTime createdAt,
  });

  /// Aggiorna una reaction esistente (tipicamente cambia solo il type).
  Future<Reaction> updateType({
    required String reactionId,
    required ReactionType type,
  });

  /// Cancella una reaction esistente.
  Future<void> delete(String reactionId);

  /// Restituisce il riepilogo per un singolo target.
  Future<ReactionSummary> getSummaryForTarget(TargetRef target);

  /// Restituisce i riepiloghi per più target in un colpo solo.
  Future<List<ReactionSummary>> getSummariesForTargets(
    List<TargetRef> targets,
  );

  /// Restituisce il riepilogo reazioni per un singolo target
  /// limitato alle reaction create da [since] in poi.
  ///
  /// Serve come foundation per reaction velocity / hot ranking.
  Future<ReactionSummary> getSummaryForTargetSince(
    TargetRef target, {
    required DateTime since,
  });

  /// Restituisce i riepiloghi reazioni per più target
  /// limitati alle reaction create da [since] in poi.
  ///
  /// Mantiene la stessa semantica di [getSummariesForTargets],
  /// ma su finestra temporale recente.
  Future<List<ReactionSummary>> getSummariesForTargetsSince(
    List<TargetRef> targets, {
    required DateTime since,
  });
}