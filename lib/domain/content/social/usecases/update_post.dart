import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/content/social/repositories/post_repository.dart';

class UpdatePost {
  final PostRepository _repository;

  UpdatePost(this._repository);

  Future<Post> call({
    required String postId,
    required String title,
    required String content,
  }) {
    return _repository.updatePost(
      postId: postId,
      title: title,
      content: content,
    );
  }
}