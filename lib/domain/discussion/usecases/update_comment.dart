import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

class UpdateComment {
  final CommentRepository _repository;

  UpdateComment(this._repository);

  Future<Comment> call({
    required String commentId,
    required String content,
  }) {
    final trimmed = content.trim();

    if (trimmed.isEmpty) {
      throw Exception('Il contenuto del commento non può essere vuoto.');
    }

    return _repository.updateComment(
      commentId: commentId,
      content: trimmed,
    );
  }
}