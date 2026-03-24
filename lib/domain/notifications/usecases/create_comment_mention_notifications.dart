import 'package:flutter/foundation.dart';
import 'package:sociale_vote/domain/discussion/entities/comment.dart';
import 'package:sociale_vote/domain/identity/entities/user_profile.dart';
import 'package:sociale_vote/domain/identity/repositories/user_profile_repository.dart';
import 'package:sociale_vote/domain/notifications/entities/app_notification.dart';
import 'package:sociale_vote/domain/notifications/repositories/notification_repository.dart';

class CreateCommentMentionNotifications {
  final UserProfileRepository _userProfileRepository;
  final NotificationRepository _notificationRepository;

  static final RegExp _mentionRegExp = RegExp(
    r'(^|[^a-z0-9_])@([a-z0-9_]{3,20})(?=$|[^a-z0-9_])',
    caseSensitive: false,
  );

  CreateCommentMentionNotifications(
    this._userProfileRepository,
    this._notificationRepository,
  );

  Future<List<AppNotification>> call(
    Comment comment, {
    Set<String>? excludedRecipientUserIds,
  }) async {
    final actorUserId = comment.userId.trim();
    final content = comment.content.trim();

    debugPrint(
      'CreateCommentMentionNotifications start '
      'commentId=${comment.id} '
      'actorUserId=$actorUserId '
      'target=${comment.target.type.name}:${comment.target.id}',
    );

    if (actorUserId.isEmpty || content.isEmpty) {
      debugPrint(
        'CreateCommentMentionNotifications skip: actorUserId o content vuoto.',
      );
      return const <AppNotification>[];
    }

    final mentionedUsernames = _extractMentionedUsernames(content);
    if (mentionedUsernames.isEmpty) {
      debugPrint(
        'CreateCommentMentionNotifications skip: nessuna mention trovata.',
      );
      return const <AppNotification>[];
    }

    final excludedRecipients = <String>{
      for (final value in excludedRecipientUserIds ?? const <String>{})
        if (value.trim().isNotEmpty) value.trim(),
    };

    final processedRecipientUserIds = <String>{...excludedRecipients};
    final createdNotifications = <AppNotification>[];

    for (final username in mentionedUsernames) {
      try {
        final UserProfile? profile =
            await _userProfileRepository.getUserProfileByUsername(username);

        if (profile == null) {
          debugPrint(
            'CreateCommentMentionNotifications skip: username @$username non trovato.',
          );
          continue;
        }

        final recipientUserId = profile.id.trim();
        if (recipientUserId.isEmpty) {
          debugPrint(
            'CreateCommentMentionNotifications skip: recipient vuoto per @$username.',
          );
          continue;
        }

        if (recipientUserId == actorUserId) {
          debugPrint(
            'CreateCommentMentionNotifications skip: self-mention bloccata per @$username.',
          );
          continue;
        }

        if (processedRecipientUserIds.contains(recipientUserId)) {
          debugPrint(
            'CreateCommentMentionNotifications skip: recipient già processato '
            'per @$username userId=$recipientUserId.',
          );
          continue;
        }

        final notification = await _notificationRepository.createNotification(
          recipientUserId: recipientUserId,
          actorUserId: actorUserId,
          type: AppNotificationType.mention,
          target: comment.target,
          commentId: comment.id,
          createdAt: comment.createdAt,
        );

        processedRecipientUserIds.add(recipientUserId);
        createdNotifications.add(notification);

        debugPrint(
          'CreateCommentMentionNotifications created '
          'notificationId=${notification.id} '
          'username=@$username '
          'recipientUserId=$recipientUserId',
        );
      } catch (e, st) {
        debugPrint(
          'CreateCommentMentionNotifications error for @$username: $e',
        );
        debugPrint('$st');
      }
    }

    return List<AppNotification>.unmodifiable(createdNotifications);
  }

  Set<String> _extractMentionedUsernames(String content) {
    final usernames = <String>{};

    for (final match in _mentionRegExp.allMatches(content)) {
      final raw = match.group(2)?.trim().toLowerCase();
      if (raw == null || raw.isEmpty) {
        continue;
      }
      usernames.add(raw);
    }

    return usernames;
  }
}