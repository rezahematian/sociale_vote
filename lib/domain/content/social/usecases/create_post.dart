import 'package:sociale_vote/domain/common/value_objects/entity_id.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/content/social/repositories/post_repository.dart';

class CreatePost {
  final PostRepository _repository;

  CreatePost(this._repository);

  Future<Post> call({
    required String authorId,
    required String authorName,
    required String title,
    required String content,
    String? countryCode,
    String? cityId,
  }) {
    // v1: generiamo qui un nuovo EntityId semplice.
    // In futuro si può centralizzare la generazione ID (es. UUID).
    final EntityId newId =
        EntityId(DateTime.now().millisecondsSinceEpoch.toString());

    final Post post = Post(
      id: newId,
      authorName: authorName,
      title: title,
      content: content,
      createdAt: DateTime.now(),
      countryCode: countryCode,
      cityId: cityId,
      createdByUserId: authorId,
    );

    return _repository.createPost(post);
  }
}