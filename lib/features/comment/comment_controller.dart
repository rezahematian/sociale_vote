import '../../domain/user/user_identity.dart';
import 'comment.dart';
import 'comment_service.dart';

class CommentController {
  final CommentService commentService;

  CommentController(this.commentService);

  List<Comment> loadComments(String pollId) {
    return commentService.getCommentsForPoll(pollId);
  }

  void addComment({
    required UserIdentity user,
    required String pollId,
    required String text,
  }) {
    if (!user.isVerified) {
      throw Exception('User not verified');
    }

    if (text.trim().isEmpty) {
      throw Exception('Empty comment');
    }

    final comment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      pollId: pollId,
      userId: user.userId,
      text: text.trim(),
      createdAt: DateTime.now(),
    );

    commentService.addComment(comment);
  }
}
