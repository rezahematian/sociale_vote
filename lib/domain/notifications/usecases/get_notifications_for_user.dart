import 'package:sociale_vote/domain/notifications/entities/app_notification.dart';
import 'package:sociale_vote/domain/notifications/repositories/notification_repository.dart';

class GetNotificationsForUser {
  final NotificationRepository _repository;

  GetNotificationsForUser(this._repository);

  Future<List<AppNotification>> call(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      return Future<List<AppNotification>>.value(const <AppNotification>[]);
    }

    final safeLimit = limit < 1 ? 20 : limit;
    final safeOffset = offset < 0 ? 0 : offset;

    return _repository.getNotificationsForUser(
      normalizedUserId,
      limit: safeLimit,
      offset: safeOffset,
    );
  }
}