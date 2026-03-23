import 'package:flutter/foundation.dart';
import 'package:sociale_vote/domain/notifications/entities/app_notification.dart';
import 'package:sociale_vote/domain/notifications/usecases/get_notifications_for_user.dart';
import 'package:sociale_vote/domain/notifications/usecases/get_unread_notifications_count.dart';
import 'package:sociale_vote/domain/notifications/usecases/mark_notification_as_read.dart';

class NotificationsController extends ChangeNotifier {
  final String userId;
  final GetNotificationsForUser _getNotificationsForUser;
  final GetUnreadNotificationsCount _getUnreadNotificationsCount;
  final MarkNotificationAsRead _markNotificationAsRead;

  NotificationsController({
    required this.userId,
    required GetNotificationsForUser getNotificationsForUser,
    required GetUnreadNotificationsCount getUnreadNotificationsCount,
    required MarkNotificationAsRead markNotificationAsRead,
  })  : _getNotificationsForUser = getNotificationsForUser,
        _getUnreadNotificationsCount = getUnreadNotificationsCount,
        _markNotificationAsRead = markNotificationAsRead;

  static const int _defaultPageSize = 20;

  List<AppNotification> _notifications = <AppNotification>[];
  bool _isLoading = false;
  String? _errorMessage;
  int _unreadCount = 0;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasNotifications => _notifications.isNotEmpty;
  int get unreadCount => _unreadCount;
  bool get hasUnreadNotifications => _unreadCount > 0;

  Future<void> loadNotifications({
    int limit = _defaultPageSize,
    int offset = 0,
  }) async {
    if (_isLoading) return;

    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      _notifications = <AppNotification>[];
      _unreadCount = 0;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait<dynamic>([
        _getNotificationsForUser(
          normalizedUserId,
          limit: limit,
          offset: offset,
        ),
        _getUnreadNotificationsCount(normalizedUserId),
      ]);

      _notifications = List<AppNotification>.from(
        results[0] as List<AppNotification>,
      );
      _unreadCount = results[1] as int;
    } catch (_) {
      _errorMessage = 'Impossibile caricare le notifiche.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() {
    return loadNotifications(
      limit: _defaultPageSize,
      offset: 0,
    );
  }

  Future<void> refreshUnreadCount() async {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      if (_unreadCount != 0) {
        _unreadCount = 0;
        notifyListeners();
      }
      return;
    }

    try {
      final count = await _getUnreadNotificationsCount(normalizedUserId);
      if (_unreadCount != count) {
        _unreadCount = count;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> markAsRead(String notificationId) async {
    final normalizedId = notificationId.trim();
    if (normalizedId.isEmpty) {
      return;
    }

    final index = _notifications.indexWhere((n) => n.id == normalizedId);
    if (index < 0) {
      return;
    }

    final notification = _notifications[index];
    if (notification.isRead) {
      return;
    }

    final previousUnreadCount = _unreadCount;

    _notifications = List<AppNotification>.from(_notifications)
      ..[index] = notification.copyWith(isRead: true);
    if (_unreadCount > 0) {
      _unreadCount -= 1;
    }
    notifyListeners();

    try {
      await _markNotificationAsRead(normalizedId);
    } catch (_) {
      _notifications = List<AppNotification>.from(_notifications)
        ..[index] = notification;
      _unreadCount = previousUnreadCount;
      _errorMessage = 'Impossibile aggiornare la notifica.';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}