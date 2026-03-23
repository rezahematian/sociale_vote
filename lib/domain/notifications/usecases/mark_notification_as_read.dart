import 'package:sociale_vote/domain/notifications/repositories/notification_repository.dart';

class MarkNotificationAsRead {
  final NotificationRepository _repository;

  MarkNotificationAsRead(this._repository);

  Future<void> call(String notificationId) {
    final normalizedId = notificationId.trim();
    if (normalizedId.isEmpty) {
      return Future<void>.value();
    }

    return _repository.markAsRead(normalizedId);
  }
}