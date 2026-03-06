import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';

import '../value_objects/heat_score.dart';

/// Aggregato di reazioni per un singolo target.
///
/// Questo è quello che useremo per mostrare:
/// 🔥 like, ❄ dislike e calcolare la temperatura.
class ReactionSummary {
  final TargetRef target;
  final int likeCount;
  final int dislikeCount;
  final HeatScore heat;

  const ReactionSummary({
    required this.target,
    required this.likeCount,
    required this.dislikeCount,
    required this.heat,
  });

  /// Factory comoda quando hai solo i conteggi.
  factory ReactionSummary.fromCounts({
    required TargetRef target,
    required int likeCount,
    required int dislikeCount,
  }) {
    return ReactionSummary(
      target: target,
      likeCount: likeCount,
      dislikeCount: dislikeCount,
      heat: HeatScore.fromCounts(
        likeCount: likeCount,
        dislikeCount: dislikeCount,
      ),
    );
  }
}