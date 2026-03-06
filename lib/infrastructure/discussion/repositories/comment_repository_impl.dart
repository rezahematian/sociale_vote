import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/discussion/entities/comment.dart';
import 'package:sociale_vote/domain/discussion/repositories/comment_repository.dart';

class CommentRepositoryImpl implements CommentRepository {
  final Map<String, Comment> _commentsById = {};
  int _idCounter = 0;

  String _nextId() {
    _idCounter++;
    return _idCounter.toString();
  }

  @override
  Future<Comment> addComment({
    required String userId,
    required TargetRef target,
    required String content,
    String? parentId,
    required DateTime createdAt,
  }) async {
    final id = _nextId();

    final comment = Comment(
      id: id,
      userId: userId,
      target: target,
      content: content,
      parentId: parentId,
      depth: parentId == null ? 0 : 1,
      createdAt: createdAt,
    );

    _commentsById[id] = comment;

    return comment;
  }

  @override
  Future<List<Comment>> getCommentsForTarget(TargetRef target) async {
    final list = _commentsById.values
        .where((c) => c.target == target)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return list;
  }

  @override
  Future<void> deleteComment(String commentId) async {
    _commentsById.remove(commentId);
  }
}