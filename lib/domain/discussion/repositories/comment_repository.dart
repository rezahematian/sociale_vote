import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import '../entities/comment.dart';

abstract class CommentRepository {
  Future<Comment> addComment({
    required String userId,
    required TargetRef target,
    required String content,
    String? parentId,
    required DateTime createdAt,
  });

  Future<List<Comment>> getCommentsForTarget(TargetRef target);

  Future<int> countCommentsForTarget(TargetRef target);

  /// Count batch per più target.
  ///
  /// La chiave restituita usa il formato:
  /// `targetType|targetId`
  /// per restare coerente con l'implementazione corrente.
  Future<Map<String, int>> countCommentsForTargets(
    List<TargetRef> targets,
  );

  /// Nuovo metodo per My Comments
  Future<List<Comment>> getCommentsByUser(String userId);

  Future<Comment> updateComment({
    required String commentId,
    required String content,
  });

  Future<void> deleteComment(String commentId);
}