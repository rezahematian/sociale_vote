import 'package:sociale_vote/core/http/api_client.dart';
import 'package:sociale_vote/core/http/api_exception.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/discussion/entities/comment.dart';
import 'package:sociale_vote/domain/discussion/repositories/comment_repository.dart';

/// Implementazione HTTP di [CommentRepository].
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
        .toList();
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

      final targetType = TargetType.values.firstWhere(
        (t) => t.name == map['targetType'],
      );

      final target = TargetRef(
        type: targetType,
        id: map['targetId'] as String,
      );

      return _mapComment(map, target);
    }).toList();
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await _apiClient.deleteJson('/comments/$commentId');
  }

  // ==========================================================
  // Mapping helpers
  // ==========================================================

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

  Comment _mapComment(
    Map<String, dynamic> json,
    TargetRef target,
  ) {
    return Comment(
      id: json['id'] as String,
      userId: json['userId'] as String,
      target: target,
      content: json['content'] as String,
      parentId: json['parentId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      depth: json['depth'] as int? ?? 0,
    );
  }
}