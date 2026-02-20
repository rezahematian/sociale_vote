import '../../core/moderation/moderation_guard.dart';
import '../../core/moderation/trust_service.dart';
import '../../domain/user/user_dto.dart';
import 'post.dart';

class PostModeratedService {
  final ModerationGuard moderationGuard;
  final TrustService trustService;
  final List<Post> _posts = [];

  PostModeratedService(
    this.moderationGuard,
    this.trustService,
  );

  void addPost({
    required UserDTO user,
    required String content,
  }) {
    moderationGuard.enforceAllowed(content);

    trustService.adjustScore(user.id, +1);

    _posts.add(
      Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.id,
        content: content,
        createdAt: DateTime.now(),
      ),
    );
  }

  List<Post> getAll() => List.unmodifiable(_posts);
}
