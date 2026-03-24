import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';

import '../entities/reaction_summary.dart';
import '../repositories/reaction_repository.dart';

/// Use case per ottenere i riepiloghi delle reazioni (🔥, ❄, heat)
/// per una lista di target.
///
/// Se [userId] è valorizzato, il risultato include anche
/// la reazione dell’utente corrente [userReaction] per ogni target.
///
/// Se [since] è valorizzato, il riepilogo viene limitato
/// alle sole reaction create da quell’istante in poi.
/// Questo serve per velocity / hot ranking.
class GetReactionSummary {
  final ReactionRepository _repository;

  GetReactionSummary(this._repository);

  Future<List<ReactionSummary>> call(
    List<TargetRef> targets, {
    String? userId,
    DateTime? since,
  }) async {
    if (targets.isEmpty) {
      return const <ReactionSummary>[];
    }

    // Summary aggregati (like/dislike/heat) per tutti i target.
    final baseSummaries = since == null
        ? await _repository.getSummariesForTargets(targets)
        : await _repository.getSummariesForTargetsSince(
            targets,
            since: since,
          );

    // Se non ci interessa la reazione dell'utente, possiamo restituire subito.
    if (userId == null) {
      return baseSummaries;
    }

    // Altrimenti, arricchiamo ogni summary con la userReaction specifica.
    final summariesByTargetKey = {
      for (final s in baseSummaries) s.target.key: s,
    };

    final enriched = <ReactionSummary>[];

    for (final target in targets) {
      final base = summariesByTargetKey[target.key];

      if (base == null) {
        // Caso limite: nessun summary per questo target,
        // restituiamo uno vuoto con userReaction null.
        enriched.add(
          ReactionSummary.fromCounts(
            target: target,
            likeCount: 0,
            dislikeCount: 0,
            userReaction: null,
          ),
        );
        continue;
      }

      final userReactionEntity = await _repository.findByUserAndTarget(
        userId: userId,
        target: target,
      );

      enriched.add(
        ReactionSummary(
          target: base.target,
          likeCount: base.likeCount,
          dislikeCount: base.dislikeCount,
          heat: base.heat,
          userReaction: userReactionEntity?.type,
        ),
      );
    }

    return enriched;
  }
}