import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';

import '../repositories/comment_repository.dart';

class GetCommentCountForTarget {
  final CommentRepository _repository;

  GetCommentCountForTarget(this._repository);

  Future<int> call(TargetRef target) {
    return _repository.countCommentsForTarget(target);
  }
}