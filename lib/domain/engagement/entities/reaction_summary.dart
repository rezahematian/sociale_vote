import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';

import '../value_objects/heat_score.dart';
import '../value_objects/reaction_type.dart';

/// Aggregato di reazioni per un singolo target.
///
/// Questo è quello che useremo per mostrare:
/// 🔥 like, ❄ dislike e calcolare la temperatura.
/// Include anche la reazione dell’utente corrente (se presente).
class ReactionSummary {
  final TargetRef target;
  final int likeCount;
  final int dislikeCount;
  final HeatScore heat;

  /// Reazione dell’utente corrente su questo target.
  /// null = nessuna reazione.
  final ReactionType? userReaction;

  const ReactionSummary({
    required this.target,
    required this.likeCount,
    required this.dislikeCount,
    required this.heat,
    required this.userReaction,
  });

  /// Factory comoda quando hai solo i conteggi.
  /// userReaction è opzionale (default: null).
  factory ReactionSummary.fromCounts({
    required TargetRef target,
    required int likeCount,
    required int dislikeCount,
    ReactionType? userReaction,
  }) {
    return ReactionSummary(
      target: target,
      likeCount: likeCount,
      dislikeCount: dislikeCount,
      heat: HeatScore.fromCounts(
        likeCount: likeCount,
        dislikeCount: dislikeCount,
      ),
      userReaction: userReaction,
    );
  }
}