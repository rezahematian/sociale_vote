import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';

import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

class GetCommentsForTarget {
  final CommentRepository _repository;

  GetCommentsForTarget(this._repository);

  Future<List<Comment>> call(TargetRef target) {
    return _repository.getCommentsForTarget(target);
  }
}