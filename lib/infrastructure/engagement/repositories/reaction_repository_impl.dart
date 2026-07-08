import 'package:sociale_vote/core/supabase/supabase_client.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/engagement/entities/reaction.dart';
import 'package:sociale_vote/domain/engagement/entities/reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/repositories/reaction_repository.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';

/// Implementazione Supabase del [ReactionRepository].
///
/// V2:
/// - persistenza reale su tabella `public.reactions`
/// - una sola reaction per user + target
/// - summary aggregati calcolati leggendo il database
///
/// V3:
/// - supporto a summary recenti tramite [since]
///   per reaction velocity / hot ranking
class ReactionRepositoryImpl implements ReactionRepository {
  static const String _reactionsTable = 'reactions';

  @override
  Future<Reaction?> findByUserAndTarget({
    required String userId,
    required TargetRef target,
  }) async {
    final rows = await AppSupabase.client
        .from(_reactionsTable)
        .select()
        .eq('user_id', userId)
        .eq('target_type', _targetType(target))
        .eq('target_id', target.id)
        .limit(1);

    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first;
    return _mapReaction(row);
  }

  @override
  Future<Reaction> create({
    required String userId,
    required TargetRef target,
    required ReactionType type,
    required DateTime createdAt,
  }) async {
    final rows = await AppSupabase.client
        .from(_reactionsTable)
        .insert({
          'user_id': userId,
          'target_type': _targetType(target),
          'target_id': target.id,
          'reaction_type': _reactionTypeValue(type),
          'created_at': createdAt.toUtc().toIso8601String(),
        })
        .select()
        .limit(1);

    if (rows.isEmpty) {
      throw Exception('Creazione reaction fallita.');
    }

    final row = rows.first;
    return _mapReaction(row);
  }

  @override
  Future<Reaction> updateType({
    required String reactionId,
    required ReactionType type,
  }) async {
    final rows = await AppSupabase.client
        .from(_reactionsTable)
        .update({
          'reaction_type': _reactionTypeValue(type),
        })
        .eq('id', reactionId)
        .select()
        .limit(1);

    if (rows.isEmpty) {
      throw StateError('Reaction not found: $reactionId');
    }

    final row = rows.first;
    return _mapReaction(row);
  }

  @override
  Future<void> delete(String reactionId) async {
    await AppSupabase.client
        .from(_reactionsTable)
        .delete()
        .eq('id', reactionId);
  }

  @override
  Future<ReactionSummary> getSummaryForTarget(TargetRef target) async {
    final summaries = await getSummariesForTargets([target]);
    if (summaries.isEmpty) {
      return _emptySummary(target);
    }
    return summaries.first;
  }

  @override
  Future<List<ReactionSummary>> getSummariesForTargets(
    List<TargetRef> targets,
  ) async {
    return _getSummariesForTargetsInternal(targets);
  }

  @override
  Future<ReactionSummary> getSummaryForTargetSince(
    TargetRef target, {
    required DateTime since,
  }) async {
    final summaries = await getSummariesForTargetsSince(
      [target],
      since: since,
    );

    if (summaries.isEmpty) {
      return _emptySummary(target);
    }

    return summaries.first;
  }

  @override
  Future<List<ReactionSummary>> getSummariesForTargetsSince(
    List<TargetRef> targets, {
    required DateTime since,
  }) async {
    return _getSummariesForTargetsInternal(
      targets,
      since: since,
    );
  }

  Future<List<ReactionSummary>> _getSummariesForTargetsInternal(
    List<TargetRef> targets, {
    DateTime? since,
  }) async {
    if (targets.isEmpty) {
      return const [];
    }

    final groupedByType = <String, List<TargetRef>>{};
    final countsByKey = <String, _ReactionCounts>{};

    for (final target in targets) {
      final targetType = _targetType(target);
      groupedByType.putIfAbsent(targetType, () => <TargetRef>[]).add(target);

      final key = _summaryKey(target);
      countsByKey.putIfAbsent(key, _ReactionCounts.new);
    }

    for (final entry in groupedByType.entries) {
      final targetType = entry.key;
      final typeTargets = entry.value;

      final targetIds = typeTargets
          .map((target) => target.id.trim())
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      if (targetIds.isEmpty) {
        continue;
      }

      dynamic query = AppSupabase.client
          .from(_reactionsTable)
          .select('target_id, reaction_type, created_at')
          .eq('target_type', targetType)
          .inFilter('target_id', targetIds);

      if (since != null) {
        query = query.gte(
          'created_at',
          since.toUtc().toIso8601String(),
        );
      }

      final rows = await query;

      for (final row in rows) {
        if (row is! Map<String, dynamic>) {
          continue;
        }

        final targetId = (row['target_id'] as String?)?.trim();
        if (targetId == null || targetId.isEmpty) {
          continue;
        }

        final key = _summaryKeyFromParts(targetType, targetId);
        final counts = countsByKey.putIfAbsent(key, _ReactionCounts.new);

        final reactionType = row['reaction_type'] as String?;
        if (reactionType == 'like') {
          counts.likeCount++;
        } else if (reactionType == 'dislike') {
          counts.dislikeCount++;
        }
      }
    }

    return targets.map((target) {
      final counts = countsByKey[_summaryKey(target)] ?? _ReactionCounts();

      return ReactionSummary.fromCounts(
        target: target,
        likeCount: counts.likeCount,
        dislikeCount: counts.dislikeCount,
        userReaction: null,
      );
    }).toList();
  }

  ReactionSummary _emptySummary(TargetRef target) {
    return ReactionSummary.fromCounts(
      target: target,
      likeCount: 0,
      dislikeCount: 0,
      userReaction: null,
    );
  }

  String _summaryKey(TargetRef target) {
    return _summaryKeyFromParts(_targetType(target), target.id);
  }

  String _summaryKeyFromParts(String targetType, String targetId) {
    return '$targetType|${targetId.trim()}';
  }

  Reaction _mapReaction(Map<String, dynamic> row) {
    return Reaction(
      id: (row['id'] as String?) ?? '',
      userId: (row['user_id'] as String?) ?? '',
      target: _targetFromRow(row),
      type: _reactionTypeFromValue(row['reaction_type'] as String?),
      createdAt: _parseDateTime(row['created_at']),
    );
  }

  TargetRef _targetFromRow(Map<String, dynamic> row) {
    final type = (row['target_type'] as String?) ?? '';
    final id = (row['target_id'] as String?) ?? '';

    switch (type) {
      case 'post':
        return TargetRef.post(id);
      case 'news':
        return TargetRef.news(id);
      case 'poll':
        return TargetRef.poll(id);
      case 'video':
        return TargetRef.video(id);
      default:
        throw Exception('Tipo target reaction non supportato: $type');
    }
  }

  String _targetType(TargetRef target) {
    switch (target.type) {
      case TargetType.post:
        return 'post';
      case TargetType.news:
        return 'news';
      case TargetType.poll:
        return 'poll';
      case TargetType.video:
        return 'video';
      default:
        throw Exception(
          'Target type non supportato per reactions: ${target.type}',
        );
    }
  }

  String _reactionTypeValue(ReactionType type) {
    switch (type) {
      case ReactionType.like:
        return 'like';
      case ReactionType.dislike:
        return 'dislike';
    }
  }

  ReactionType _reactionTypeFromValue(String? value) {
    switch (value) {
      case 'like':
        return ReactionType.like;
      case 'dislike':
        return ReactionType.dislike;
      default:
        return ReactionType.like;
    }
  }

  DateTime _parseDateTime(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
    }
    return DateTime.now();
  }
}

class _ReactionCounts {
  int likeCount;
  int dislikeCount;

  _ReactionCounts({
    this.likeCount = 0,
    this.dislikeCount = 0,
  });
}
