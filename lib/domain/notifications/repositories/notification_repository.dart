import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/notifications/entities/app_notification.dart';

abstract class NotificationRepository {
  Future<AppNotification> createNotification({
    required String recipientUserId,
    required String actorUserId,
    required AppNotificationType type,
    required TargetRef target,
    String? commentId,
    required DateTime createdAt,
  });

  Future<List<AppNotification>> getNotificationsForUser(
    String userId, {
    int limit = 20,
    int offset = 0,
  });

  Future<int> getUnreadCount(String userId);

  Future<void> markAsRead(String notificationId);

  Future<void> markAllAsRead(String userId);
}