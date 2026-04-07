import 'package:flutter/material.dart';

import 'package:sociale_vote/l10n/app_localizations.dart';

enum _TopBarMenuAction {
  trending,
  forYou,
}

class HomeTopBar extends StatelessWidget {
  final String scopeShortLabel;
  final bool isLoggedIn;
  final int unreadNotificationsCount;
  final VoidCallback onLoginPressed;
  final VoidCallback onRegisterPressed;
  final VoidCallback onProfilePressed;
  final VoidCallback onLogoutPressed;
  final VoidCallback? onTrendingPressed;
  final VoidCallback? onForYouPressed;
  final VoidCallback? onNotificationsPressed;

  const HomeTopBar({
    super.key,
    required this.scopeShortLabel,
    required this.isLoggedIn,
    required this.unreadNotificationsCount,
    required this.onLoginPressed,
    required this.onRegisterPressed,
    required this.onProfilePressed,
    required this.onLogoutPressed,
    this.onTrendingPressed,
    this.onForYouPressed,
    this.onNotificationsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sociale Vote',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              scopeShortLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white.withOpacity(0.72),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const Spacer(),
        if (!isLoggedIn) ...[
          OutlinedButton(
            onPressed: onLoginPressed,
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
            child: Text(l10n.homeLoginButton),
          ),
          const SizedBox(width: 6),
          FilledButton(
            onPressed: onRegisterPressed,
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
            child: Text(l10n.homeRegisterButton),
          ),
        ] else ...[
          _NotificationsButton(
            unreadCount: unreadNotificationsCount,
            onPressed: onNotificationsPressed,
          ),
          if (onTrendingPressed != null || onForYouPressed != null) ...[
            const SizedBox(width: 6),
            _DiscoverMenuButton(
              onTrendingPressed: onTrendingPressed,
              onForYouPressed: onForYouPressed,
            ),
          ],
          const SizedBox(width: 6),
          OutlinedButton(
            onPressed: onProfilePressed,
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
            child: Text(l10n.homeProfileButton),
          ),
          const SizedBox(width: 6),
          TextButton(
            onPressed: onLogoutPressed,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white.withOpacity(0.9),
            ),
            child: Text(l10n.homeLogoutButton),
          ),
        ],
      ],
    );
  }
}

class _DiscoverMenuButton extends StatelessWidget {
  final VoidCallback? onTrendingPressed;
  final VoidCallback? onForYouPressed;

  const _DiscoverMenuButton({
    required this.onTrendingPressed,
    required this.onForYouPressed,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_TopBarMenuAction>(
      tooltip: 'Discover',
      onSelected: (value) {
        switch (value) {
          case _TopBarMenuAction.trending:
            onTrendingPressed?.call();
            break;
          case _TopBarMenuAction.forYou:
            onForYouPressed?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        if (onTrendingPressed != null)
          const PopupMenuItem<_TopBarMenuAction>(
            value: _TopBarMenuAction.trending,
            child: Row(
              children: [
                Icon(Icons.local_fire_department_outlined, size: 18),
                SizedBox(width: 8),
                Text('Trending'),
              ],
            ),
          ),
        if (onForYouPressed != null)
          const PopupMenuItem<_TopBarMenuAction>(
            value: _TopBarMenuAction.forYou,
            child: Row(
              children: [
                Icon(Icons.auto_awesome_outlined, size: 18),
                SizedBox(width: 8),
                Text('For You'),
              ],
            ),
          ),
      ],
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: const Color(0xFF316BFF),
            width: 1,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.explore_outlined,
              size: 17,
              color: Color(0xFF316BFF),
            ),
            SizedBox(width: 6),
            Text(
              'Discover',
              style: TextStyle(
                color: Color(0xFF316BFF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsButton extends StatelessWidget {
  final int unreadCount;
  final VoidCallback? onPressed;

  const _NotificationsButton({
    required this.unreadCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayCount = unreadCount > 99 ? '99+' : unreadCount.toString();

    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            onPressed: onPressed,
            tooltip: 'Notifiche',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            color: Colors.white.withOpacity(0.88),
            icon: const Icon(Icons.notifications_outlined),
          ),
          if (unreadCount > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 1,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.black,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  displayCount,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onError,
                    fontWeight: FontWeight.w700,
                    fontSize: unreadCount > 99 ? 9 : 10,
                    height: 1.1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}