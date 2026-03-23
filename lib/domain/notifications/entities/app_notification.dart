import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';

enum AppNotificationType {
  commentReply,
  mention,
  pollResult,
}

class AppNotification {
  final String id;
  final String recipientUserId;
  final String actorUserId;
  final AppNotificationType type;
  final TargetRef target;
  final String? commentId;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.recipientUserId,
    required this.actorUserId,
    required this.type,
    required this.target,
    required this.commentId,
    required this.isRead,
    required this.createdAt,
  });

  AppNotification copyWith({
    String? id,
    String? recipientUserId,
    String? actorUserId,
    AppNotificationType? type,
    TargetRef? target,
    String? commentId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      recipientUserId: recipientUserId ?? this.recipientUserId,
      actorUserId: actorUserId ?? this.actorUserId,
      type: type ?? this.type,
      target: target ?? this.target,
      commentId: commentId ?? this.commentId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}