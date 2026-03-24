import 'package:flutter/foundation.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/discussion/entities/comment.dart';
import 'package:sociale_vote/domain/discussion/usecases/add_comment.dart';
import 'package:sociale_vote/domain/notifications/usecases/create_comment_mention_notifications.dart';
import 'package:sociale_vote/domain/notifications/usecases/create_comment_reply_notification.dart';

class AddCommentAndNotify {
  final AddComment _addComment;
  final CreateCommentReplyNotification _createCommentReplyNotification;
  final CreateCommentMentionNotifications _createCommentMentionNotifications;

  AddCommentAndNotify(
    this._addComment,
    this._createCommentReplyNotification,
    this._createCommentMentionNotifications,
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

    final excludedRecipientUserIds = <String>{};

    try {
      final replyNotification = await _createCommentReplyNotification(comment);

      if (replyNotification != null &&
          replyNotification.recipientUserId.trim().isNotEmpty) {
        excludedRecipientUserIds.add(replyNotification.recipientUserId.trim());
      }

      debugPrint(
        'AddCommentAndNotify reply notification result: '
        '${replyNotification == null ? 'null' : replyNotification.id}',
      );
    } catch (e, st) {
      debugPrint('AddCommentAndNotify reply notification error: $e');
      debugPrint('$st');
    }

    try {
      final mentionNotifications = await _createCommentMentionNotifications(
        comment,
        excludedRecipientUserIds: excludedRecipientUserIds,
      );

      debugPrint(
        'AddCommentAndNotify mention notifications created: '
        '${mentionNotifications.length}',
      );
    } catch (e, st) {
      debugPrint('AddCommentAndNotify mention notification error: $e');
      debugPrint('$st');
    }

    return comment;
  }
}