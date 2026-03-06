import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';

import '../entities/reaction_summary.dart';
import '../repositories/reaction_repository.dart';

/// Use case per ottenere i riepiloghi delle reazioni (🔥, ❄, heat)
/// per una lista di target.
class GetReactionSummary {
  final ReactionRepository _repository;

  GetReactionSummary(this._repository);

  Future<List<ReactionSummary>> call(List<TargetRef> targets) {
    if (targets.isEmpty) {
      return Future.value(const <ReactionSummary>[]);
    }
    return _repository.getSummariesForTargets(targets);
  }
}