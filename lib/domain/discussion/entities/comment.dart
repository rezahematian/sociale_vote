import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';

/// Entità commento generica riutilizzabile per:
/// - Social post
/// - News
/// - Poll
/// - Video
///
/// v1:
/// - supporta commenti principali (depth = 0)
/// - supporta reply tramite parentId
class Comment {
  final String id;
  final String userId;
  final TargetRef target;
  final String content;
  final String? parentId;
  final int depth;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.userId,
    required this.target,
    required this.content,
    required this.parentId,
    required this.depth,
    required this.createdAt,
  });

  Comment copyWith({
    String? id,
    String? userId,
    TargetRef? target,
    String? content,
    String? parentId,
    int? depth,
    DateTime? createdAt,
  }) {
    return Comment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      target: target ?? this.target,
      content: content ?? this.content,
      parentId: parentId ?? this.parentId,
      depth: depth ?? this.depth,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}