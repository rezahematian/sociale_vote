import 'package:sociale_vote/core/http/api_client.dart';
import 'package:sociale_vote/core/http/api_exception.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/discussion/entities/comment.dart';
import 'package:sociale_vote/domain/discussion/repositories/comment_repository.dart';

/// Implementazione HTTP di [CommentRepository].
///
/// Nota:
/// - questo adapter oggi non è il path attivo in DI
/// - viene tenuto allineato al contratto per evitare drift/rotture future
class CommentRepositoryHttp implements CommentRepository {
  final ApiClient _apiClient;

  CommentRepositoryHttp(this._apiClient);

  @override
  Future<Comment> addComment({
    required String userId,
    required TargetRef target,
    required String content,
    String? parentId,
    required DateTime createdAt,
  }) async {
    final response = await _apiClient.postJson(
      '/comments',
      body: {
        'userId': userId,
        'targetType': _mapTargetType(target),
        'targetId': _mapTargetId(target),
        'content': content,
        'parentId': parentId,
        'createdAt': createdAt.toUtc().toIso8601String(),
      },
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(
        message: 'Invalid response format while creating comment.',
      );
    }

    return _mapComment(
      Map<String, dynamic>.from(response),
      target,
    );
  }

  @override
  Future<Comment?> getCommentById(String commentId) async {
    final normalizedId = commentId.trim();
    if (normalizedId.isEmpty) {
      return null;
    }

    final response = await _apiClient.getJson('/comments/$normalizedId');

    if (response == null) {
      return null;
    }

    if (response is! Map<String, dynamic>) {
      throw ApiException(
        message: 'Invalid response format while loading comment by id.',
      );
    }

    final map = Map<String, dynamic>.from(response);
    final target = _targetFromJson(map);

    return _mapComment(map, target);
  }

  @override
  Future<List<Comment>> getCommentsForTarget(TargetRef target) async {
    final response = await _apiClient.getJson(
      '/comments',
      query: {
        'type': _mapTargetType(target),
        'id': _mapTargetId(target),
      },
    );

    if (response is! List) {
      throw ApiException(
        message: 'Invalid response format while loading comments.',
      );
    }

    return response
        .map<Comment>(
          (json) => _mapComment(
            Map<String, dynamic>.from(json as Map),
            target,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<int> countCommentsForTarget(TargetRef target) async {
    final comments = await getCommentsForTarget(target);
    return comments.length;
  }

  @override
  Future<Map<String, int>> countCommentsForTargets(
    List<TargetRef> targets,
  ) async {
    if (targets.isEmpty) {
      return const <String, int>{};
    }

    final entries = await Future.wait(
      targets.map((target) async {
        final count = await countCommentsForTarget(target);
        return MapEntry(_targetKey(target), count);
      }),
    );

    return Map<String, int>.fromEntries(entries);
  }

  @override
  Future<List<Comment>> getCommentsByUser(String userId) async {
    final response = await _apiClient.getJson(
      '/comments',
      query: {
        'userId': userId,
      },
    );

    if (response is! List) {
      throw ApiException(
        message: 'Invalid response format while loading user comments.',
      );
    }

    return response.map<Comment>((json) {
      final map = Map<String, dynamic>.from(json as Map);
      final target = _targetFromJson(map);
      return _mapComment(map, target);
    }).toList(growable: false);
  }

  @override
  Future<Comment> updateComment({
    required String commentId,
    required String content,
  }) {
    throw UnimplementedError(
      'CommentRepositoryHttp.updateComment non implementato: '
      'endpoint/metodo HTTP non confermati.',
    );
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await _apiClient.deleteJson('/comments/$commentId');
  }

  String _mapTargetType(TargetRef target) {
    switch (target.type) {
      case TargetType.poll:
        return 'poll';
      case TargetType.news:
        return 'news';
      case TargetType.post:
        return 'post';
      case TargetType.video:
        return 'video';
      case TargetType.city:
        return 'city';
      case TargetType.country:
        return 'country';
      case TargetType.topic:
        return 'topic';
      default:
        return target.type.name;
    }
  }

  String _mapTargetId(TargetRef target) {
    return target.id;
  }

  String _targetKey(TargetRef target) {
    return '${_mapTargetType(target)}|${target.id.trim()}';
  }

  TargetRef _targetFromJson(Map<String, dynamic> json) {
    final rawType = (json['targetType'] ?? json['target_type'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    final rawId = (json['targetId'] ?? json['target_id'] ?? '')
        .toString()
        .trim();

    switch (rawType) {
      case 'post':
        return TargetRef.post(rawId);
      case 'news':
        return TargetRef.news(rawId);
      case 'poll':
        return TargetRef.poll(rawId);
      case 'video':
        return TargetRef.video(rawId);
      case 'city':
        return TargetRef.city(rawId);
      case 'country':
        return TargetRef.country(rawId);
      case 'topic':
        return TargetRef.topic(rawId);
      default:
        throw ApiException(
          message: 'Unsupported targetType while mapping comment: $rawType',
        );
    }
  }

  Comment _mapComment(
    Map<String, dynamic> json,
    TargetRef target,
  ) {
    return Comment(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? json['user_id'] ?? '').toString(),
      target: target,
      content: (json['content'] ?? '').toString(),
      parentId: (json['parentId'] ?? json['parent_id']) as String?,
      createdAt: DateTime.parse(
        (json['createdAt'] ?? json['created_at']).toString(),
      ),
      depth: (json['depth'] as int?) ?? 0,
    );
  }
}