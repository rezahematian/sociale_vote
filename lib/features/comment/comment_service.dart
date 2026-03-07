import 'comment.dart';

class CommentService {
  final List<Comment> _comments = [];

  List<Comment> getCommentsForPoll(String pollId) {
    return _comments.where((c) => c.pollId == pollId).toList();
  }

  void addComment(Comment comment) {
    _comments.add(comment);
  }
}
