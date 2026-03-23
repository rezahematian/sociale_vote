import 'package:flutter/foundation.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/discussion/entities/comment.dart';
import 'package:sociale_vote/domain/discussion/usecases/add_comment.dart';
import 'package:sociale_vote/domain/notifications/usecases/create_comment_reply_notification.dart';

class AddCommentAndNotify {
  final AddComment _addComment;
  final CreateCommentReplyNotification _createCommentReplyNotification;

  AddCommentAndNotify(
    this._addComment,
    this._createCommentReplyNotification,
  );

  Future<Comment> call({
    required String userId,
    required TargetRef target,
    required String content,
    String? parentId,
  }) async {
    final comment = await _addComment(
      userId: userId,
      target: target,
      content: content,
      parentId: parentId,
    );

    try {
      final notification = await _createCommentReplyNotification(comment);

      debugPrint(
        'AddCommentAndNotify notification result: '
        '${notification == null ? 'null' : notification.id}',
      );
    } catch (e, st) {
      debugPrint('AddCommentAndNotify notification error: $e');
      debugPrint('$st');
    }

    return comment;
  }
}