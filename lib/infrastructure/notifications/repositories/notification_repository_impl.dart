import 'package:sociale_vote/core/supabase/supabase_client.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/notifications/entities/app_notification.dart';
import 'package:sociale_vote/domain/notifications/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  static const String _notificationsTable = 'notifications';

  @override
  Future<AppNotification> createNotification({
    required String recipientUserId,
    required String actorUserId,
    required AppNotificationType type,
    required TargetRef target,
    String? commentId,
    required DateTime createdAt,
  }) async {
    final rows = await AppSupabase.client
        .from(_notificationsTable)
        .insert({
          'recipient_user_id': recipientUserId,
          'actor_user_id': actorUserId,
          'type': _typeToDb(type),
          'target_type': _targetType(target),
          'target_id': target.id,
          'comment_id': commentId,
          'is_read': false,
          'created_at': createdAt.toUtc().toIso8601String(),
        })
        .select()
        .limit(1);

    if (rows.isEmpty) {
      throw Exception('Creazione notifica fallita.');
    }

    final row = rows.first as Map<String, dynamic>;
    return _mapNotification(row);
  }

  @override
  Future<List<AppNotification>> getNotificationsForUser(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final safeLimit = limit < 1 ? 20 : limit;
    final safeOffset = offset < 0 ? 0 : offset;
    final end = safeOffset + safeLimit - 1;

    final rows = await AppSupabase.client
        .from(_notificationsTable)
        .select()
        .eq('recipient_user_id', userId)
        .order('created_at', ascending: false)
        .range(safeOffset, end);

    return rows
        .whereType<Map<String, dynamic>>()
        .map(_mapNotification)
        .toList(growable: false);
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    final rows = await AppSupabase.client
        .from(_notificationsTable)
        .select('id')
        .eq('recipient_user_id', userId)
        .eq('is_read', false);

    return rows.length;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await AppSupabase.client
        .from(_notificationsTable)
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    await AppSupabase.client
        .from(_notificationsTable)
        .update({'is_read': true})
        .eq('recipient_user_id', userId)
        .eq('is_read', false);
  }

  AppNotification _mapNotification(Map<String, dynamic> row) {
    return AppNotification(
      id: (row['id'] as String?) ?? '',
      recipientUserId: (row['recipient_user_id'] as String?) ?? '',
      actorUserId: (row['actor_user_id'] as String?) ?? '',
      type: _typeFromDb((row['type'] as String?) ?? ''),
      target: _targetFromRow(row),
      commentId: row['comment_id'] as String?,
      isRead: (row['is_read'] as bool?) ?? false,
      createdAt: _parseDateTime(row['created_at']),
    );
  }

  AppNotificationType _typeFromDb(String raw) {
    switch (raw.trim()) {
      case 'comment_reply':
        return AppNotificationType.commentReply;
      case 'mention':
        return AppNotificationType.mention;
      case 'poll_result':
        return AppNotificationType.pollResult;
      default:
        throw Exception('Tipo notifica non supportato: $raw');
    }
  }

  String _typeToDb(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.commentReply:
        return 'comment_reply';
      case AppNotificationType.mention:
        return 'mention';
      case AppNotificationType.pollResult:
        return 'poll_result';
    }
  }

  TargetRef _targetFromRow(Map<String, dynamic> row) {
    final type = (row['target_type'] as String?) ?? '';
    final id = (row['target_id'] as String?) ?? '';

    switch (type) {
      case 'post':
        return TargetRef.post(id);
      case 'news':
        return TargetRef.news(id);
      case 'poll':
        return TargetRef.poll(id);
      case 'video':
        return TargetRef.video(id);
      default:
        throw Exception('Target notification non supportato: $type');
    }
  }

  String _targetType(TargetRef target) {
    switch (target.type) {
      case TargetType.post:
        return 'post';
      case TargetType.news:
        return 'news';
      case TargetType.poll:
        return 'poll';
      case TargetType.video:
        return 'video';
      default:
        throw Exception(
          'Target type non supportato per notifications: ${target.type}',
        );
    }
  }

  DateTime _parseDateTime(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
    }
    return DateTime.now();
  }
}