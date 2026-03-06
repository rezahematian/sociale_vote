import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';

import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

class AddComment {
  final CommentRepository _repository;

  AddComment(this._repository);

  Future<Comment> call({
    required String userId,
    required TargetRef target,
    required String content,
    String? parentId,
  }) {
    return _repository.addComment(
      userId: userId,
      target: target,
      content: content,
      parentId: parentId,
      createdAt: DateTime.now(),
    );
  }
}