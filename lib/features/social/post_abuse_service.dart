import '../../core/rate_limit/rate_limit_guard.dart';
import '../../core/moderation/moderation_guard.dart';
import '../../core/moderation/trust_service.dart';
import '../../domain/user/user_dto.dart';
import 'post.dart';

class PostAbuseService {
  final RateLimitGuard rateLimitGuard;
  final ModerationGuard moderationGuard;
  final TrustService trustService;
  final List<Post> _posts = [];

  PostAbuseService(
    this.rateLimitGuard,
    this.moderationGuard,
    this.trustService,
  );

  void addPost({
    required UserDTO user,
    required String content,
  }) {
    rateLimitGuard.checkPost(user.id);
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
