import 'package:flutter/foundation.dart';
import 'package:sociale_vote/domain/discussion/entities/comment.dart';
import 'package:sociale_vote/domain/discussion/repositories/comment_repository.dart';
import 'package:sociale_vote/domain/notifications/entities/app_notification.dart';
import 'package:sociale_vote/domain/notifications/repositories/notification_repository.dart';

class CreateCommentReplyNotification {
  final CommentRepository _commentRepository;
  final NotificationRepository _notificationRepository;

  CreateCommentReplyNotification(
    this._commentRepository,
    this._notificationRepository,
  );

  Future<AppNotification?> call(Comment reply) async {
    final parentId = reply.parentId?.trim();

    debugPrint(
      'CreateCommentReplyNotification start '
      'replyId=${reply.id} '
      'replyUserId=${reply.userId} '
      'parentId=$parentId '
      'target=${reply.target.type.name}:${reply.target.id}',
    );

    if (parentId == null || parentId.isEmpty) {
      debugPrint(
        'CreateCommentReplyNotification skip: parentId assente, quindi non è una reply.',
      );
      return null;
    }

    final parentComment = await _commentRepository.getCommentById(parentId);

    if (parentComment == null) {
      debugPrint(
        'CreateCommentReplyNotification skip: parent comment non trovato.',
      );
      return null;
    }

    final recipientUserId = parentComment.userId.trim();
    final actorUserId = reply.userId.trim();

    debugPrint(
      'CreateCommentReplyNotification parent found '
      'parentCommentId=${parentComment.id} '
      'parentUserId=${parentComment.userId} '
      'recipientUserId=$recipientUserId '
      'actorUserId=$actorUserId',
    );

    if (recipientUserId.isEmpty || actorUserId.isEmpty) {
      debugPrint(
        'CreateCommentReplyNotification skip: recipientUserId o actorUserId vuoto.',
      );
      return null;
    }

    if (recipientUserId == actorUserId) {
      debugPrint(
        'CreateCommentReplyNotification skip: self-notification bloccata.',
      );
      return null;
    }

    final notification = await _notificationRepository.createNotification(
      recipientUserId: recipientUserId,
      actorUserId: actorUserId,
      type: AppNotificationType.commentReply,
      target: reply.target,
      commentId: reply.id,
      createdAt: reply.createdAt,
    );

    debugPrint(
      'CreateCommentReplyNotification created notificationId=${notification.id}',
    );

    return notification;
  }
}