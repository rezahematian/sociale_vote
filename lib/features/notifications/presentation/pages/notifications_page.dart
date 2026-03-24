import 'package:flutter/material.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/domain/notifications/entities/app_notification.dart';
import 'package:sociale_vote/features/notifications/application/notifications_controller.dart';

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
  NotificationsController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadNotifications();
    });
  }

  Future<void> _handleNotificationTap(AppNotification notification) async {
    await _controller.markAsRead(notification.id);

    if (!mounted) return;

    final opened = await _openNotificationTarget(notification);
    if (!mounted || opened) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Questa notifica non ha ancora una destinazione apribile.'),
      ),
    );
  }

  Future<bool> _openNotificationTarget(AppNotification notification) async {
    final targetId = notification.target.id.trim();
    if (targetId.isEmpty) {
      return false;
    }

    switch (notification.target.type.name) {
      case 'poll':
        await Navigator.pushNamed(
          context,
          AppRouter.pollDetail,
          arguments: targetId,
        );
        return true;

      case 'post':
        await Navigator.pushNamed(
          context,
          AppRouter.socialDetail,
          arguments: targetId,
        );
        return true;

      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Notifiche'),
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
                TextButton(
                  onPressed: _controller.markAllAsRead,
                  child: const Text('Segna tutte'),
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _controller.refresh,
            child: _buildBody(context),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
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
            height: MediaQuery.of(context).size.height * 0.35,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  _controller.errorMessage!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _controller.refresh,
                  child: const Text('Riprova'),
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
            height: MediaQuery.of(context).size.height * 0.35,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Nessuna notifica disponibile.',
              textAlign: TextAlign.center,
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
        return _NotificationTile(
          notification: notification,
          onTap: () => _handleNotificationTap(notification),
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;

  const _NotificationTile({
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = _buildTitle(notification);
    final subtitle = _buildSubtitle(notification);
    final trailing = _formatDateTime(notification.createdAt);
    final theme = Theme.of(context);

    return Container(
      color: notification.isRead
          ? null
          : theme.colorScheme.primary.withOpacity(0.06),
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
        trailing: Text(
          trailing,
          style: theme.textTheme.bodySmall,
        ),
        onTap: onTap,
      ),
    );
  }

  String _buildTitle(AppNotification notification) {
    switch (notification.type) {
      case AppNotificationType.commentReply:
        return 'Nuova risposta al tuo commento';
      case AppNotificationType.mention:
        return 'Sei stato menzionato';
      case AppNotificationType.pollResult:
        return 'Aggiornamento sondaggio';
    }
  }

  String _buildSubtitle(AppNotification notification) {
    final actorLabel = _shortUserId(notification.actorUserId);
    final targetLabel = _targetLabel(notification);

    switch (notification.type) {
      case AppNotificationType.commentReply:
        return 'Utente $actorLabel ha risposto in $targetLabel';
      case AppNotificationType.mention:
        return 'Utente $actorLabel ti ha menzionato in $targetLabel';
      case AppNotificationType.pollResult:
        return 'Nuovo risultato disponibile in $targetLabel';
    }
  }

  String _targetLabel(AppNotification notification) {
    switch (notification.target.type.name) {
      case 'post':
        return 'un post';
      case 'news':
        return 'una news';
      case 'poll':
        return 'un sondaggio';
      case 'video':
        return 'un video';
      default:
        return 'un contenuto';
    }
  }

  String _shortUserId(String value) {
    final normalized = value.trim();
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