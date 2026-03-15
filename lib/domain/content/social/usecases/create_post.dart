import 'package:sociale_vote/domain/common/value_objects/entity_id.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/content/social/repositories/post_repository.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';

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
    ContentLocation? contentLocation,
  }) {
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
      contentLocation: contentLocation,
      createdByUserId: authorId,
    );

    return _repository.createPost(post);
  }
}
