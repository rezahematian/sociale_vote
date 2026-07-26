import 'package:flutter/material.dart';
import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/domain/common/value_objects/entity_id.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/notifications/entities/app_notification.dart';
import 'package:sociale_vote/features/notifications/application/notifications_controller.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

class NotificationsPage extends StatefulWidget {
  final NotificationsController controller;

  const NotificationsPage({
    super.key,
    required this.controller,
  });

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String? _openingNotificationId;

  NotificationsController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.loadNotifications();
    });
  }

  Future<void> _handleNotificationTap(AppNotification notification) async {
    final notificationId = notification.id.trim();
    if (notificationId.isEmpty || _openingNotificationId != null) {
      return;
    }

    setState(() {
      _openingNotificationId = notificationId;
    });

    try {
      final opened = await _openNotificationTarget(notification);
      if (!mounted || opened) {
        return;
      }

      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.notificationsNoTargetMessage),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.notificationsTargetUnavailableMessage),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _openingNotificationId = null;
        });
      }
    }
  }

  Future<bool> _openNotificationTarget(AppNotification notification) async {
    final targetId = notification.target.id.trim();
    if (targetId.isEmpty) {
      return false;
    }

    switch (notification.target.type) {
      case TargetType.poll:
        final pollNavigation = Navigator.pushNamed(
          context,
          AppRouter.pollDetail,
          arguments: targetId,
        );
        await _controller.markAsRead(notification.id);
        await pollNavigation;
        return true;

      case TargetType.post:
        final postNavigation = Navigator.pushNamed(
          context,
          AppRouter.socialDetail,
          arguments: targetId,
        );
        await _controller.markAsRead(notification.id);
        await postNavigation;
        return true;

      case TargetType.news:
        final news = await AppDI.instance.getNewsDetail(EntityId(targetId));
        if (!mounted) {
          return false;
        }

        final newsNavigation = Navigator.pushNamed(
          context,
          AppRouter.newsDetail,
          arguments: news,
        );
        await _controller.markAsRead(notification.id);
        await newsNavigation;
        return true;

      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.notificationsPageTitle),
            actions: [
              if (_controller.isMarkingAllAsRead)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else if (_controller.canMarkAllAsRead)
                IconButton(
                  tooltip: l10n.notificationsMarkAllReadAction,
                  onPressed: _controller.markAllAsRead,
                  icon: const Icon(Icons.done_all),
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _controller.refresh,
            child: _buildBody(context, l10n),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    if (_controller.isLoading && !_controller.hasNotifications) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_controller.errorMessage != null && !_controller.hasNotifications) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 40,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.notificationsLoadError,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _controller.refresh,
                  child: Text(l10n.notificationsRetryButton),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (!_controller.hasNotifications) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 40,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.notificationsEmptyMessage,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _controller.notifications.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final notification = _controller.notifications[index];
        final isOpening = _openingNotificationId == notification.id.trim();

        return _NotificationTile(
          notification: notification,
          isOpening: isOpening,
          onTap: isOpening ? null : () => _handleNotificationTap(notification),
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final bool isOpening;
  final VoidCallback? onTap;

  const _NotificationTile({
    required this.notification,
    required this.isOpening,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = _buildTitle(notification, l10n);
    final subtitle = _buildSubtitle(notification, l10n);
    final trailing = _formatDateTime(notification.createdAt);
    final theme = Theme.of(context);

    return Material(
      color: notification.isRead
          ? Colors.transparent
          : theme.colorScheme.primary.withValues(alpha: 0.06),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(_iconForType(notification.type)),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: notification.isRead
                    ? null
                    : const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (!notification.isRead) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.brightness_1,
                size: 10,
                color: theme.colorScheme.primary,
              ),
            ],
          ],
        ),
        subtitle: Text(
          subtitle,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: isOpening
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                trailing,
                style: theme.textTheme.bodySmall,
              ),
        onTap: onTap,
      ),
    );
  }

  String _buildTitle(
    AppNotification notification,
    AppLocalizations l10n,
  ) {
    switch (notification.type) {
      case AppNotificationType.commentReply:
        return l10n.notificationsCommentReplyTitle;
      case AppNotificationType.mention:
        return l10n.notificationsMentionTitle;
      case AppNotificationType.pollResult:
        return l10n.notificationsPollResultTitle;
    }
  }

  String _buildSubtitle(
    AppNotification notification,
    AppLocalizations l10n,
  ) {
    final actorLabel = _shortUserId(
      notification.actorUserId,
      l10n.notificationsUserFallback,
    );
    final targetLabel = _targetLabel(notification, l10n);

    switch (notification.type) {
      case AppNotificationType.commentReply:
        return l10n.notificationsCommentReplySubtitle(
          actorLabel,
          targetLabel,
        );
      case AppNotificationType.mention:
        return l10n.notificationsMentionSubtitle(
          actorLabel,
          targetLabel,
        );
      case AppNotificationType.pollResult:
        return l10n.notificationsPollResultSubtitle(targetLabel);
    }
  }

  String _targetLabel(
    AppNotification notification,
    AppLocalizations l10n,
  ) {
    switch (notification.target.type) {
      case TargetType.post:
        return l10n.notificationsTargetPost;
      case TargetType.news:
        return l10n.notificationsTargetNews;
      case TargetType.poll:
        return l10n.notificationsTargetPoll;
      case TargetType.video:
        return l10n.notificationsTargetVideo;
      default:
        return l10n.notificationsTargetContent;
    }
  }

  String _shortUserId(
    String value,
    String fallback,
  ) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return fallback;
    }
    if (normalized.length <= 8) {
      return normalized;
    }
    return normalized.substring(0, 8);
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }

  IconData _iconForType(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.commentReply:
        return Icons.reply;
      case AppNotificationType.mention:
        return Icons.alternate_email;
      case AppNotificationType.pollResult:
        return Icons.poll;
    }
  }
}
