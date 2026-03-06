import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/engagement/entities/reaction.dart';
import 'package:sociale_vote/domain/engagement/entities/reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/repositories/reaction_repository.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';

/// Implementazione in-memory del ReactionRepository.
///
/// V1:
/// - storage solo in RAM
/// - nessuna persistenza
/// - calcolo summary on-the-fly
///
/// È perfetto per:
/// - sviluppo locale
/// - test UI
/// - futura sostituzione con API REST
class ReactionRepositoryImpl implements ReactionRepository {
  /// key: reactionId
  final Map<String, Reaction> _reactionsById = {};

  /// key: userId|targetKey
  final Map<String, String> _reactionIndex = {};

  int _idCounter = 0;

  String _nextId() {
    _idCounter++;
    return _idCounter.toString();
  }

  String _indexKey(String userId, TargetRef target) {
    return '$userId|${target.key}';
  }

  @override
  Future<Reaction?> findByUserAndTarget({
    required String userId,
    required TargetRef target,
  }) async {
    final indexKey = _indexKey(userId, target);
    final reactionId = _reactionIndex[indexKey];
    if (reactionId == null) return null;
    return _reactionsById[reactionId];
  }

  @override
  Future<Reaction> create({
    required String userId,
    required TargetRef target,
    required ReactionType type,
    required DateTime createdAt,
  }) async {
    final id = _nextId();

    final reaction = Reaction(
      id: id,
      userId: userId,
      target: target,
      type: type,
      createdAt: createdAt,
    );

    _reactionsById[id] = reaction;
    _reactionIndex[_indexKey(userId, target)] = id;

    return reaction;
  }

  @override
  Future<Reaction> updateType({
    required String reactionId,
    required ReactionType type,
  }) async {
    final existing = _reactionsById[reactionId];
    if (existing == null) {
      throw StateError('Reaction not found: $reactionId');
    }

    final updated = existing.copyWith(type: type);
    _reactionsById[reactionId] = updated;

    return updated;
  }

  @override
  Future<void> delete(String reactionId) async {
    final existing = _reactionsById.remove(reactionId);
    if (existing == null) return;

    final indexKey = _indexKey(existing.userId, existing.target);
    _reactionIndex.remove(indexKey);
  }

  @override
  Future<ReactionSummary> getSummaryForTarget(TargetRef target) async {
    int likeCount = 0;
    int dislikeCount = 0;

    for (final reaction in _reactionsById.values) {
      if (reaction.target == target) {
        if (reaction.type == ReactionType.like) {
          likeCount++;
        } else {
          dislikeCount++;
        }
      }
    }

    return ReactionSummary.fromCounts(
      target: target,
      likeCount: likeCount,
      dislikeCount: dislikeCount,
    );
  }

  @override
  Future<List<ReactionSummary>> getSummariesForTargets(
    List<TargetRef> targets,
  ) async {
    if (targets.isEmpty) {
      return const [];
    }

    final summaries = <ReactionSummary>[];

    for (final target in targets) {
      summaries.add(await getSummaryForTarget(target));
    }

    return summaries;
  }
}