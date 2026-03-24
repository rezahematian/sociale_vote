import 'package:sociale_vote/domain/notifications/repositories/notification_repository.dart';

class MarkAllNotificationsAsRead {
  final NotificationRepository _notificationRepository;

  MarkAllNotificationsAsRead(this._notificationRepository);

  Future<void> call(String userId) async {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      return;
    }

    await _notificationRepository.markAllAsRead(normalizedUserId);
  }
}