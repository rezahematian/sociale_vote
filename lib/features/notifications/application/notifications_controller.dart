import 'package:flutter/foundation.dart';
import 'package:sociale_vote/domain/notifications/entities/app_notification.dart';
import 'package:sociale_vote/domain/notifications/usecases/get_notifications_for_user.dart';
import 'package:sociale_vote/domain/notifications/usecases/get_unread_notifications_count.dart';
import 'package:sociale_vote/domain/notifications/usecases/mark_all_notifications_as_read.dart';
import 'package:sociale_vote/domain/notifications/usecases/mark_notification_as_read.dart';

class NotificationsController extends ChangeNotifier {
  final String userId;
  final GetNotificationsForUser _getNotificationsForUser;
  final GetUnreadNotificationsCount _getUnreadNotificationsCount;
  final MarkNotificationAsRead _markNotificationAsRead;
  final MarkAllNotificationsAsRead _markAllNotificationsAsRead;

  NotificationsController({
    required this.userId,
    required GetNotificationsForUser getNotificationsForUser,
    required GetUnreadNotificationsCount getUnreadNotificationsCount,
    required MarkNotificationAsRead markNotificationAsRead,
    required MarkAllNotificationsAsRead markAllNotificationsAsRead,
  })  : _getNotificationsForUser = getNotificationsForUser,
        _getUnreadNotificationsCount = getUnreadNotificationsCount,
        _markNotificationAsRead = markNotificationAsRead,
        _markAllNotificationsAsRead = markAllNotificationsAsRead;

  static const int _defaultPageSize = 20;

  List<AppNotification> _notifications = <AppNotification>[];
  bool _isLoading = false;
  bool _isMarkingAllAsRead = false;
  String? _errorMessage;
  int _unreadCount = 0;
  bool _isDisposed = false;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  bool get isMarkingAllAsRead => _isMarkingAllAsRead;
  String? get errorMessage => _errorMessage;
  bool get hasNotifications => _notifications.isNotEmpty;
  int get unreadCount => _unreadCount;
  bool get hasUnreadNotifications => _unreadCount > 0;
  bool get canMarkAllAsRead =>
      hasUnreadNotifications && !_isLoading && !_isMarkingAllAsRead;

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
      _safeNotifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

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
      _safeNotifyListeners();
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
        _safeNotifyListeners();
      }
      return;
    }

    try {
      final count = await _getUnreadNotificationsCount(normalizedUserId);
      if (_unreadCount != count) {
        _unreadCount = count;
        _safeNotifyListeners();
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
    _safeNotifyListeners();

    try {
      await _markNotificationAsRead(normalizedId);
    } catch (_) {
      _notifications = List<AppNotification>.from(_notifications)
        ..[index] = notification;
      _unreadCount = previousUnreadCount;
      _errorMessage = 'Impossibile aggiornare la notifica.';
      _safeNotifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty ||
        _isMarkingAllAsRead ||
        !hasUnreadNotifications) {
      return;
    }

    final previousNotifications = List<AppNotification>.from(_notifications);
    final previousUnreadCount = _unreadCount;

    _isMarkingAllAsRead = true;
    _errorMessage = null;
    _notifications = _notifications
        .map((notification) => notification.isRead
            ? notification
            : notification.copyWith(isRead: true))
        .toList(growable: false);
    _unreadCount = 0;
    _safeNotifyListeners();

    try {
      await _markAllNotificationsAsRead(normalizedUserId);
    } catch (_) {
      _notifications = previousNotifications;
      _unreadCount = previousUnreadCount;
      _errorMessage = 'Impossibile aggiornare le notifiche.';
    } finally {
      _isMarkingAllAsRead = false;
      _safeNotifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    _safeNotifyListeners();
  }

  void _safeNotifyListeners() {
    if (_isDisposed) {
      return;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
