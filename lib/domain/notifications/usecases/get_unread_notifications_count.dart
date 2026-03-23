import 'package:sociale_vote/domain/notifications/repositories/notification_repository.dart';

class GetUnreadNotificationsCount {
  final NotificationRepository _repository;

  GetUnreadNotificationsCount(this._repository);

  Future<int> call(String userId) {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      return Future<int>.value(0);
    }

    return _repository.getUnreadCount(normalizedUserId);
  }
}