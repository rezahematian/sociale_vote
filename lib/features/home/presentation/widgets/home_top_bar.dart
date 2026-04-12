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
  final ThemeMode? currentThemeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

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
    this.currentThemeMode,
    this.onThemeModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final themeModeButton = isLoggedIn &&
            currentThemeMode != null &&
            onThemeModeChanged != null
        ? _ThemeModeCycleButton(
            currentThemeMode: currentThemeMode!,
            onChanged: onThemeModeChanged!,
          )
        : null;

    if (!isLoggedIn) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _ColorfulBrand(
              scopeShortLabel: scopeShortLabel,
            ),
          ),
          const SizedBox(width: 8),
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
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _ColorfulBrand(
            scopeShortLabel: scopeShortLabel,
          ),
        ),
        const SizedBox(width: 8),
        _NotificationsButton(
          unreadCount: unreadNotificationsCount,
          onPressed: onNotificationsPressed,
        ),
        if (onTrendingPressed != null || onForYouPressed != null) ...[
          const SizedBox(width: 4),
          _DiscoverMenuIconButton(
            onTrendingPressed: onTrendingPressed,
            onForYouPressed: onForYouPressed,
          ),
        ],
        if (themeModeButton != null) ...[
          const SizedBox(width: 4),
          themeModeButton,
        ],
        const SizedBox(width: 4),
        _TopBarIconButton(
          tooltip: l10n.homeProfileButton,
          icon: Icons.person_outline_rounded,
          onPressed: onProfilePressed,
        ),
        const SizedBox(width: 4),
        _TopBarIconButton(
          tooltip: l10n.homeLogoutButton,
          icon: Icons.logout_rounded,
          onPressed: onLogoutPressed,
        ),
      ],
    );
  }
}

class _ColorfulBrand extends StatelessWidget {
  final String scopeShortLabel;

  const _ColorfulBrand({
    required this.scopeShortLabel,
  });

  static const List<Color> _brandColors = [
    Color(0xFF4F8CFF),
    Color(0xFF8B5CF6),
    Color(0xFF12B981),
    Color(0xFFFF7A59),
    Color(0xFFF59E0B),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const brandText = 'Sociale Vote';

    final spans = <TextSpan>[];
    var colorIndex = 0;

    for (final rune in brandText.runes) {
      final char = String.fromCharCode(rune);

      if (char == ' ') {
        spans.add(const TextSpan(text: ' '));
        continue;
      }

      spans.add(
        TextSpan(
          text: char,
          style: TextStyle(
            color: _brandColors[colorIndex % _brandColors.length],
            fontWeight: FontWeight.w800,
          ),
        ),
      );
      colorIndex++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.25,
              fontSize: 28,
              height: 1.0,
            ),
            children: spans,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          scopeShortLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelMedium?.copyWith(
            color: Colors.white.withOpacity(0.72),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DiscoverMenuIconButton extends StatelessWidget {
  final VoidCallback? onTrendingPressed;
  final VoidCallback? onForYouPressed;

  const _DiscoverMenuIconButton({
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
      child: const _TopBarIconShell(
        icon: Icons.explore_outlined,
      ),
    );
  }
}

class _ThemeModeCycleButton extends StatelessWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeModeCycleButton({
    required this.currentThemeMode,
    required this.onChanged,
  });

  ThemeMode _nextThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return ThemeMode.light;
      case ThemeMode.light:
        return ThemeMode.dark;
      case ThemeMode.dark:
        return ThemeMode.system;
    }
  }

  IconData _iconForThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
    }
  }

  String _labelForThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Tema: sistema';
      case ThemeMode.light:
        return 'Tema: chiaro';
      case ThemeMode.dark:
        return 'Tema: scuro';
    }
  }

  @override
  Widget build(BuildContext context) {
    return _TopBarIconButton(
      tooltip: _labelForThemeMode(currentThemeMode),
      icon: _iconForThemeMode(currentThemeMode),
      onPressed: () => onChanged(_nextThemeMode(currentThemeMode)),
    );
  }
}

class _TopBarIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  const _TopBarIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: _TopBarIconShell(
          icon: icon,
        ),
      ),
    );
  }
}

class _TopBarIconShell extends StatelessWidget {
  final IconData icon;

  const _TopBarIconShell({
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withOpacity(0.14),
        ),
      ),
      child: Icon(
        icon,
        size: 18,
        color: Colors.white.withOpacity(0.92),
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

    return Tooltip(
      message: 'Notifiche',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned.fill(
                child: _TopBarIconShell(
                  icon: Icons.notifications_outlined,
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
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
                        width: 1.2,
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
        ),
      ),
    );
  }
}