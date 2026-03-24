import 'package:flutter/foundation.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/notifications/entities/app_notification.dart';
import 'package:sociale_vote/domain/notifications/repositories/notification_repository.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';

class CreatePollResultNotification {
  final NotificationRepository _notificationRepository;

  CreatePollResultNotification(this._notificationRepository);

  Future<AppNotification?> call({
    required Poll poll,
    required String? actorUserId,
  }) async {
    final recipientUserId = poll.createdByUserId?.trim();
    final normalizedActorUserId = actorUserId?.trim() ?? '';

    debugPrint(
      'CreatePollResultNotification start '
      'pollId=${poll.id.value} '
      'recipientUserId=$recipientUserId '
      'actorUserId=$normalizedActorUserId',
    );

    if (recipientUserId == null || recipientUserId.isEmpty) {
      debugPrint(
        'CreatePollResultNotification skip: creator del poll assente.',
      );
      return null;
    }

    if (normalizedActorUserId.isEmpty) {
      debugPrint(
        'CreatePollResultNotification skip: actorUserId vuoto.',
      );
      return null;
    }

    if (recipientUserId == normalizedActorUserId) {
      debugPrint(
        'CreatePollResultNotification skip: self-notification bloccata.',
      );
      return null;
    }

    final notification = await _notificationRepository.createNotification(
      recipientUserId: recipientUserId,
      actorUserId: normalizedActorUserId,
      type: AppNotificationType.pollResult,
      target: TargetRef.poll(poll.id.value),
      commentId: null,
      createdAt: DateTime.now(),
    );

    debugPrint(
      'CreatePollResultNotification created notificationId=${notification.id}',
    );

    return notification;
  }
}