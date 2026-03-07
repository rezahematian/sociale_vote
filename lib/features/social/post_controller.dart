import '../../domain/user/user_identity.dart';
import 'post.dart';
import 'post_service.dart';

class PostController {
  final PostService postService;

  PostController(this.postService);

  List<Post> loadPosts() {
    return postService.getAllPosts();
  }

  void createPost({
    required UserIdentity user,
    required String content,
    String? pollId,
    String? newsId,
  }) {
    if (!user.isVerified) {
      throw Exception('User not verified');
    }

    if (content.trim().isEmpty) {
      throw Exception('Empty post');
    }

    final post = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user.userId,
      content: content.trim(),
      pollId: pollId,
      newsId: newsId,
      createdAt: DateTime.now(),
    );

    postService.addPost(post);
  }
}
