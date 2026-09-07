import 'package:flutter/material.dart';

import 'package:sociale_vote/app/app.dart';
import 'package:sociale_vote/app/localization/appearance_label.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/widgets/social_vote_brand_lockup.dart';

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
      // Social Vote final guest header: keep brand + auth on one compact row.
      List<Widget> guestUtilityActions({double size = 36}) => <Widget>[
            if (onHowItWorksPressed != null)
              _HowItWorksIconButton(
                onPressed: onHowItWorksPressed!,
                size: size,
              ),
            if (onDiscoveryPressed != null)
              _DiscoverIconButton(
                scopeShortLabel: scopeShortLabel,
                onPressed: onDiscoveryPressed!,
                size: size,
              ),
          ];

      Widget guestAuthActions({bool compact = false}) {
        final horizontalPadding = compact ? 7.0 : 10.0;
        final height = compact ? 34.0 : 36.0;
        final textStyle = compact ? Theme.of(context).textTheme.labelLarge : null;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            OutlinedButton(
              onPressed: onLoginPressed,
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                minimumSize: Size(0, height),
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: textStyle,
              ),
              child: Text(l10n.homeLoginButton),
            ),
            const SizedBox(width: 4),
            FilledButton(
              onPressed: onRegisterPressed,
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                minimumSize: Size(0, height),
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: textStyle,
              ),
              child: Text(l10n.homeRegisterButton),
            ),
          ],
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 430) {
            // SOCIAL VOTE GUEST HEADER ONE-LINE CONTRACT V1.0.0
            // Keep brand + help + discovery + login + register on the same
            // optical baseline on Android and narrow Web. The two flex zones
            // may scale down slightly for long localized auth labels, but the
            // header never creates a second authentication row.
            final compactUtilities = guestUtilityActions(size: 34);
            final compactActions = Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ...compactUtilities.expand(
                  (widget) => <Widget>[widget, const SizedBox(width: 3)],
                ),
                guestAuthActions(compact: true),
              ],
            );

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Expanded(
                  flex: 5,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: SocialVoteHeaderBrand(height: 40),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 7,
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerEnd,
                      child: compactActions,
                    ),
                  ),
                ),
              ],
            );
          }

          final utilities = guestUtilityActions();
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Expanded(child: SocialVoteHeaderBrand()),
              const SizedBox(width: 8),
              if (utilities.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: utilities,
                ),
                const SizedBox(width: 6),
              ],
              guestAuthActions(),
            ],
          );
        },
      );
    }

    // SOCIAL VOTE AUTHENTICATED HEADER OPTICAL ALIGNMENT V1.0.0
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: SocialVoteHeaderBrand(),
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

class _HowItWorksIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double size;

  const _HowItWorksIconButton({
    required this.onPressed,
    this.size = 36,
  });

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
        child: _TopBarQuestionShell(size: size),
      ),
    );
  }
}

class _DiscoverIconButton extends StatelessWidget {
  final String scopeShortLabel;
  final VoidCallback onPressed;
  final double size;

  const _DiscoverIconButton({
    required this.scopeShortLabel,
    required this.onPressed,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Discovery Â· $scopeShortLabel',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: _TopBarIconShell(
          icon: Icons.explore_outlined,
          size: size,
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
            label: socialVoteSpaceAppearanceLabel(context),
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
  final double size;

  const _TopBarIconShell({
    required this.icon,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
        ),
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: Colors.white.withValues(alpha: 0.92),
      ),
    );
  }
}

class _TopBarQuestionShell extends StatelessWidget {
  final double size;

  const _TopBarQuestionShell({this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
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

