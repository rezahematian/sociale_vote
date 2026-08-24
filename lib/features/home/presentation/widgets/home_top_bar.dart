import 'package:flutter/material.dart';

import 'package:sociale_vote/app/app.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

enum _AccountMenuAction {
  account,
  appearanceLight,
  appearanceDark,
  appearanceSpace,
  logout,
}

class HomeTopBar extends StatelessWidget {
  final String scopeShortLabel;
  final bool isLoggedIn;
  final int unreadNotificationsCount;
  final VoidCallback onLoginPressed;
  final VoidCallback onRegisterPressed;
  final VoidCallback onProfilePressed;
  final VoidCallback onLogoutPressed;
  final VoidCallback? onDiscoveryPressed;
  final VoidCallback? onHowItWorksPressed;
  final VoidCallback? onNotificationsPressed;
  final AppAppearanceMode? currentAppearanceMode;
  final ValueChanged<AppAppearanceMode>? onAppearanceModeChanged;

  const HomeTopBar({
    super.key,
    required this.scopeShortLabel,
    required this.isLoggedIn,
    required this.unreadNotificationsCount,
    required this.onLoginPressed,
    required this.onRegisterPressed,
    required this.onProfilePressed,
    required this.onLogoutPressed,
    this.onDiscoveryPressed,
    this.onHowItWorksPressed,
    this.onNotificationsPressed,
    this.currentAppearanceMode,
    this.onAppearanceModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!isLoggedIn) {
      final guestActions = Wrap(
        spacing: 6,
        runSpacing: 6,
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          if (onHowItWorksPressed != null)
            _HowItWorksIconButton(onPressed: onHowItWorksPressed!),
          if (onDiscoveryPressed != null) ...[
            _DiscoverIconButton(
              scopeShortLabel: scopeShortLabel,
              onPressed: onDiscoveryPressed!,
            ),
          ],
          OutlinedButton(
            onPressed: onLoginPressed,
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
            child: Text(l10n.homeLoginButton),
          ),
          FilledButton(
            onPressed: onRegisterPressed,
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
            child: Text(l10n.homeRegisterButton),
          ),
        ],
      );

      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 430) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const _ColorfulBrand(),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: guestActions,
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Expanded(child: _ColorfulBrand()),
              const SizedBox(width: 8),
              guestActions,
            ],
          );
        },
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: _ColorfulBrand(),
        ),
        const SizedBox(width: 8),
        if (onHowItWorksPressed != null) ...[
          _HowItWorksIconButton(onPressed: onHowItWorksPressed!),
          const SizedBox(width: 4),
        ],
        _NotificationsButton(
          unreadCount: unreadNotificationsCount,
          onPressed: onNotificationsPressed,
        ),
        if (onDiscoveryPressed != null) ...[
          const SizedBox(width: 4),
          _DiscoverIconButton(
            scopeShortLabel: scopeShortLabel,
            onPressed: onDiscoveryPressed!,
          ),
        ],
        const SizedBox(width: 4),
        _AccountMenuButton(
          onAccountPressed: onProfilePressed,
          onLogoutPressed: onLogoutPressed,
          currentAppearanceMode: currentAppearanceMode,
          onAppearanceModeChanged: onAppearanceModeChanged,
        ),
      ],
    );
  }
}

class _ColorfulBrand extends StatelessWidget {
  const _ColorfulBrand();

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
    const brandText = 'Social Vote';

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

    return RichText(
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
    );
  }
}

class _HowItWorksIconButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _HowItWorksIconButton({required this.onPressed});

  String _label(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode.toLowerCase();
    if (language == 'it') return 'Come funziona Social Vote';
    if (language == 'de') return 'So funktioniert Social Vote';
    return 'How Social Vote works';
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _label(context),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: const _TopBarQuestionShell(),
      ),
    );
  }
}

class _DiscoverIconButton extends StatelessWidget {
  final String scopeShortLabel;
  final VoidCallback onPressed;

  const _DiscoverIconButton({
    required this.scopeShortLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Discovery · $scopeShortLabel',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: const _TopBarIconShell(
          icon: Icons.explore_outlined,
        ),
      ),
    );
  }
}

class _AccountMenuButton extends StatelessWidget {
  final VoidCallback onAccountPressed;
  final VoidCallback onLogoutPressed;
  final AppAppearanceMode? currentAppearanceMode;
  final ValueChanged<AppAppearanceMode>? onAppearanceModeChanged;

  const _AccountMenuButton({
    required this.onAccountPressed,
    required this.onLogoutPressed,
    required this.currentAppearanceMode,
    required this.onAppearanceModeChanged,
  });

  bool get _canChangeAppearance =>
      currentAppearanceMode != null && onAppearanceModeChanged != null;

  bool _isSelectedAppearance(AppAppearanceMode value) =>
      currentAppearanceMode == value;

  PopupMenuItem<_AccountMenuAction> _themeItem({
    required _AccountMenuAction action,
    required IconData icon,
    required String label,
    required bool selected,
  }) {
    return PopupMenuItem<_AccountMenuAction>(
      value: action,
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          if (selected) ...[
            const SizedBox(width: 8),
            const Icon(Icons.check, size: 18),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<_AccountMenuAction>(
      tooltip: l10n.homeAccountMenuLabel,
      onSelected: (value) {
        switch (value) {
          case _AccountMenuAction.account:
            onAccountPressed();
            break;
          case _AccountMenuAction.appearanceLight:
            onAppearanceModeChanged?.call(AppAppearanceMode.light);
            break;
          case _AccountMenuAction.appearanceDark:
            onAppearanceModeChanged?.call(AppAppearanceMode.dark);
            break;
          case _AccountMenuAction.appearanceSpace:
            onAppearanceModeChanged?.call(AppAppearanceMode.space);
            break;
          case _AccountMenuAction.logout:
            onLogoutPressed();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<_AccountMenuAction>(
          value: _AccountMenuAction.account,
          child: Row(
            children: [
              const Icon(Icons.manage_accounts_outlined, size: 18),
              const SizedBox(width: 8),
              Text(l10n.homeAccountMenuLabel),
            ],
          ),
        ),
        if (_canChangeAppearance) ...[
          const PopupMenuDivider(),
          _themeItem(
            action: _AccountMenuAction.appearanceLight,
            icon: Icons.light_mode_outlined,
            label: l10n.homeThemeLightMenuItem,
            selected: _isSelectedAppearance(AppAppearanceMode.light),
          ),
          _themeItem(
            action: _AccountMenuAction.appearanceDark,
            icon: Icons.dark_mode_outlined,
            label: l10n.homeThemeDarkMenuItem,
            selected: _isSelectedAppearance(AppAppearanceMode.dark),
          ),
          _themeItem(
            action: _AccountMenuAction.appearanceSpace,
            icon: Icons.auto_awesome,
            label: 'Space',
            selected: _isSelectedAppearance(AppAppearanceMode.space),
          ),
        ],
        const PopupMenuDivider(),
        PopupMenuItem<_AccountMenuAction>(
          value: _AccountMenuAction.logout,
          child: Row(
            children: [
              const Icon(Icons.logout_rounded, size: 18),
              const SizedBox(width: 8),
              Text(l10n.homeLogoutButton),
            ],
          ),
        ),
      ],
      child: const _TopBarIconShell(
        icon: Icons.manage_accounts_outlined,
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
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
        ),
      ),
      child: Icon(
        icon,
        size: 18,
        color: Colors.white.withValues(alpha: 0.92),
      ),
    );
  }
}

class _TopBarQuestionShell extends StatelessWidget {
  const _TopBarQuestionShell();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '?',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.96),
              fontWeight: FontWeight.w900,
              height: 1,
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
    final l10n = AppLocalizations.of(context)!;
    final displayCount = unreadCount > 99 ? '99+' : unreadCount.toString();

    return Tooltip(
      message: l10n.homeNotificationsTooltip,
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
