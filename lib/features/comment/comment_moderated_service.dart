import '../../core/moderation/moderation_guard.dart';
import '../../core/moderation/trust_service.dart';
import '../../domain/user/user_dto.dart';
import 'comment.dart';

class CommentModeratedService {
  final ModerationGuard moderationGuard;
  final TrustService trustService;
  final List<Comment> _comments = [];

  CommentModeratedService(
    this.moderationGuard,
    this.trustService,
  );

  void addComment({
    required UserDTO user,
    required String content,
    String? pollId,
  }) {
    moderationGuard.enforceAllowed(content);

    trustService.adjustScore(user.id, +1);

    _comments.add(
      Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.id,
        content: content,
        pollId: pollId,
        createdAt: DateTime.now(),
      ),
    );
  }

  List<Comment> getAll() => List.unmodifiable(_comments);
}
