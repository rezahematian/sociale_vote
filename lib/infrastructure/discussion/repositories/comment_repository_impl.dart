import 'package:sociale_vote/core/supabase/supabase_client.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/discussion/entities/comment.dart';
import 'package:sociale_vote/domain/discussion/repositories/comment_repository.dart';

class CommentRepositoryImpl implements CommentRepository {
  static const String _commentsTable = 'comments';

  @override
  Future<Comment> addComment({
    required String userId,
    required TargetRef target,
    required String content,
    String? parentId,
    required DateTime createdAt,
  }) async {
    final depth = await _resolveDepth(parentId);

    final rows = await AppSupabase.client
        .from(_commentsTable)
        .insert({
          'target_type': _targetType(target),
          'target_id': target.id,
          'author_id': userId,
          'content': content,
          'parent_id': parentId,
          'depth': depth,
          'created_at': createdAt.toUtc().toIso8601String(),
        })
        .select()
        .limit(1);

    if (rows.isEmpty) {
      throw Exception('Creazione commento fallita.');
    }

    final row = rows.first as Map<String, dynamic>;
    return _mapComment(row);
  }

  @override
  Future<Comment> updateComment({
    required String commentId,
    required String content,
  }) async {
    final rows = await AppSupabase.client
        .from(_commentsTable)
        .update({
          'content': content,
        })
        .eq('id', commentId)
        .select()
        .limit(1);

    if (rows.isEmpty) {
      throw Exception('Aggiornamento commento fallito.');
    }

    final row = rows.first as Map<String, dynamic>;
    return _mapComment(row);
  }

  @override
  Future<List<Comment>> getCommentsForTarget(TargetRef target) async {
    final rows = await AppSupabase.client
        .from(_commentsTable)
        .select()
        .eq('target_type', _targetType(target))
        .eq('target_id', target.id)
        .order('created_at', ascending: true);

    return rows
        .whereType<Map<String, dynamic>>()
        .map(_mapComment)
        .toList(growable: false);
  }

  @override
  Future<int> countCommentsForTarget(TargetRef target) async {
    final counts = await countCommentsForTargets([target]);
    return counts[_targetKey(target)] ?? 0;
  }

  Future<Map<String, int>> countCommentsForTargets(
    List<TargetRef> targets,
  ) async {
    if (targets.isEmpty) {
      return const <String, int>{};
    }

    final groupedByType = <String, List<TargetRef>>{};
    final countsByKey = <String, int>{};

    for (final target in targets) {
      final targetType = _targetType(target);
      groupedByType.putIfAbsent(targetType, () => <TargetRef>[]).add(target);
      countsByKey.putIfAbsent(_targetKey(target), () => 0);
    }

    for (final entry in groupedByType.entries) {
      final targetType = entry.key;
      final typeTargets = entry.value;

      final targetIds = typeTargets
          .map((target) => target.id.trim())
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList(growable: false);

      if (targetIds.isEmpty) {
        continue;
      }

      final rows = await AppSupabase.client
          .from(_commentsTable)
          .select('target_id')
          .eq('target_type', targetType)
          .inFilter('target_id', targetIds);

      for (final row in rows) {
        if (row is! Map<String, dynamic>) {
          continue;
        }

        final targetId = (row['target_id'] as String?)?.trim();
        if (targetId == null || targetId.isEmpty) {
          continue;
        }

        final key = _targetKeyFromParts(targetType, targetId);
        countsByKey.update(
          key,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }

    return countsByKey;
  }

  @override
  Future<List<Comment>> getCommentsByUser(String userId) async {
    final rows = await AppSupabase.client
        .from(_commentsTable)
        .select()
        .eq('author_id', userId)
        .order('created_at', ascending: false);

    return rows
        .whereType<Map<String, dynamic>>()
        .map(_mapComment)
        .toList(growable: false);
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await AppSupabase.client.from(_commentsTable).delete().eq('id', commentId);
  }

  Future<int> _resolveDepth(String? parentId) async {
    if (parentId == null || parentId.trim().isEmpty) {
      return 0;
    }

    final rows = await AppSupabase.client
        .from(_commentsTable)
        .select('depth')
        .eq('id', parentId)
        .limit(1);

    if (rows.isEmpty) {
      throw Exception('Commento padre non trovato.');
    }

    final row = rows.first as Map<String, dynamic>;
    final parentDepth = (row['depth'] as int?) ?? 0;
    return parentDepth + 1;
  }

  Comment _mapComment(Map<String, dynamic> row) {
    return Comment(
      id: (row['id'] as String?) ?? '',
      userId: (row['author_id'] as String?) ?? '',
      target: _targetFromRow(row),
      content: (row['content'] as String?) ?? '',
      parentId: row['parent_id'] as String?,
      depth: (row['depth'] as int?) ?? 0,
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
        throw Exception('Tipo target comment non supportato: $type');
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
          'Target type non supportato per commenti: ${target.type}',
        );
    }
  }

  String _targetKey(TargetRef target) {
    return _targetKeyFromParts(_targetType(target), target.id);
  }

  String _targetKeyFromParts(String targetType, String targetId) {
    return '$targetType|${targetId.trim()}';
  }

  DateTime _parseDateTime(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
    }
    return DateTime.now();
  }
}