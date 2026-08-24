import 'package:flutter/material.dart';

import 'package:sociale_vote/l10n/app_localizations.dart';

class HomeHeroSection extends StatelessWidget {
  final String scopeShortLabel;
  final VoidCallback onOpenPolls;
  final VoidCallback onOpenNews;
  final VoidCallback onCreate;
  final VoidCallback onExplore;
  final VoidCallback? onOpenSearch;
  final VoidCallback? onScopePressed;
  final bool spaceStyle;
  final bool desktopCompact;

  const HomeHeroSection({
    super.key,
    required this.scopeShortLabel,
    required this.onOpenPolls,
    required this.onOpenNews,
    required this.onCreate,
    required this.onExplore,
    this.onOpenSearch,
    this.onScopePressed,
    this.spaceStyle = false,
    this.desktopCompact = false,
  });

  String _purposeText(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode.toLowerCase();
    if (language == 'it') {
      return 'Scopri cosa conta, esprimi la tua Voce e partecipa ai Vote.';
    }
    if (language == 'de') {
      return 'Entdecke, was zählt, teile deine Voce und nimm an Vote teil.';
    }
    return 'Discover what matters, share your Voce and take part in Vote.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final materialL10n = MaterialLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;

    final heroGradient = spaceStyle
        ? const [
            Color(0xD9111B2B),
            Color(0xCC0B1424),
            Color(0xD9151D31),
          ]
        : isDark
            ? const [
                Color(0xFF13213C),
                Color(0xFF1A2B4A),
                Color(0xFF20355D),
              ]
            : const [
                Color(0xFFFCFDFF),
                Color(0xFFF6F8FF),
                Color(0xFFF4F1FF),
              ];

    final heroBorderColor = spaceStyle
        ? const Color(0xFF9AB8DE).withValues(alpha: 0.24)
        : isDark
            ? Colors.white.withValues(alpha: 0.12)
            : colors.outline.withValues(alpha: 0.18);

    final heroShadowColor = spaceStyle
        ? Colors.black.withValues(alpha: 0.34)
        : isDark
            ? Colors.black.withValues(alpha: 0.22)
            : const Color(0xFF0F172A).withValues(alpha: 0.055);

    final chipBackgroundColor = spaceStyle
        ? const Color(0xFF0B1424).withValues(alpha: 0.72)
        : isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.94);

    final chipBorderColor = spaceStyle
        ? const Color(0xFFA5C6EF).withValues(alpha: 0.20)
        : isDark
            ? Colors.white.withValues(alpha: 0.12)
            : colors.outline.withValues(alpha: 0.12);

    final chipForegroundColor = spaceStyle
        ? const Color(0xFF8CC4FF)
        : isDark
            ? const Color(0xFFB5D0FF)
            : colors.primary;

    final titleColor = spaceStyle
        ? const Color(0xFFF8FBFF)
        : isDark
            ? Colors.white.withValues(alpha: 0.97)
            : colors.onSurface;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isVeryNarrow = constraints.maxWidth < 390;
        final horizontalPadding =
            desktopCompact ? 16.0 : (isVeryNarrow ? 16.0 : 18.0);

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              desktopCompact ? 22 : 26,
            ),
            gradient: LinearGradient(
              colors: heroGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: heroBorderColor),
            boxShadow: [
              BoxShadow(
                blurRadius: desktopCompact
                    ? (spaceStyle ? 22 : 16)
                    : (spaceStyle ? 30 : 22),
                offset: Offset(
                  0,
                  desktopCompact ? 7 : (spaceStyle ? 14 : 10),
                ),
                color: heroShadowColor,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              desktopCompact ? 22 : 26,
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -34,
                  right: -22,
                  child: IgnorePointer(
                    child: Container(
                      width: 118,
                      height: 118,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: spaceStyle
                            ? const Color(0xFF78B7FF).withValues(alpha: 0.055)
                            : isDark
                                ? Colors.white.withValues(alpha: 0.045)
                                : colors.primary.withValues(alpha: 0.055),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -42,
                  left: -26,
                  child: IgnorePointer(
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: spaceStyle
                            ? const Color(0xFFA8A2FF).withValues(alpha: 0.055)
                            : isDark
                                ? const Color(0xFF7C9BFF)
                                    .withValues(alpha: 0.06)
                                : const Color(0xFF8B5CF6)
                                    .withValues(alpha: 0.045),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    16,
                    horizontalPadding,
                    16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _buildTopChip(
                                theme: theme,
                                icon: Icons.public_outlined,
                                label: scopeShortLabel,
                                foregroundColor: chipForegroundColor,
                                backgroundColor: chipBackgroundColor,
                                borderColor: chipBorderColor,
                                onTap: onScopePressed,
                                trailingIcon: onScopePressed == null
                                    ? null
                                    : Icons.expand_more_rounded,
                              ),
                            ),
                          ),
                          if (onOpenSearch != null) ...[
                            SizedBox(width: desktopCompact ? 7 : 10),
                            _buildSearchButton(
                              label: materialL10n.searchFieldLabel,
                              theme: theme,
                              foregroundColor: chipForegroundColor,
                              backgroundColor: chipBackgroundColor,
                              borderColor: chipBorderColor,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        l10n.homeHeroHeadline,
                        style: (desktopCompact
                                ? theme.textTheme.titleLarge
                                : theme.textTheme.headlineSmall)
                            ?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                          letterSpacing: -0.45,
                          color: titleColor,
                        ),
                      ),
                      SizedBox(height: desktopCompact ? 6 : 8),
                      Text(
                        _purposeText(context),
                        maxLines: desktopCompact ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: titleColor.withValues(alpha: 0.78),
                          height: 1.32,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: desktopCompact ? 10 : 16),
                      Row(
                        children: [
                          Expanded(
                            child: _DashboardActionButton(
                              icon: Icons.how_to_vote_outlined,
                              label: l10n.homeHeroPollsAction,
                              onPressed: onOpenPolls,
                              emphasized: true,
                              spaceStyle: spaceStyle,
                              compact: desktopCompact,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _DashboardActionButton(
                              icon: Icons.article_outlined,
                              label: l10n.homeHeroNewsAction,
                              onPressed: onOpenNews,
                              spaceStyle: spaceStyle,
                              compact: desktopCompact,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: desktopCompact ? 7 : 10),
                      Row(
                        children: [
                          Expanded(
                            child: _DashboardActionButton(
                              icon: Icons.add_circle_outline_rounded,
                              label: l10n.homeHeroCreateAction,
                              onPressed: onCreate,
                              softPrimary: true,
                              spaceStyle: spaceStyle,
                              compact: desktopCompact,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _DashboardActionButton(
                              icon: Icons.travel_explore_outlined,
                              label: l10n.homeHeroExploreAction,
                              onPressed: onExplore,
                              softPrimary: true,
                              spaceStyle: spaceStyle,
                              compact: desktopCompact,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchButton({
    required String label,
    required ThemeData theme,
    required Color foregroundColor,
    required Color backgroundColor,
    required Color borderColor,
  }) {
    return OutlinedButton.icon(
      onPressed: onOpenSearch,
      icon: const Icon(Icons.search_rounded, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 10,
        ),
        textStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        side: BorderSide(color: borderColor),
      ),
    );
  }

  Widget _buildTopChip({
    required ThemeData theme,
    required String label,
    required Color foregroundColor,
    required Color backgroundColor,
    required Color borderColor,
    IconData? icon,
    IconData? trailingIcon,
    VoidCallback? onTap,
  }) {
    final chip = Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: foregroundColor),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: foregroundColor,
              ),
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 4),
            Icon(trailingIcon, size: 17, color: foregroundColor),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return chip;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: chip,
      ),
    );
  }
}

class _DashboardActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool emphasized;
  final bool softPrimary;
  final bool spaceStyle;
  final bool compact;

  const _DashboardActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.emphasized = false,
    this.softPrimary = false,
    this.spaceStyle = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = spaceStyle
        ? (emphasized
            ? const Color(0xFF2D74E8).withValues(alpha: 0.92)
            : softPrimary
                ? const Color(0xFF163056).withValues(alpha: 0.68)
                : const Color(0xFF0D1727).withValues(alpha: 0.72))
        : emphasized
            ? colors.primary
            : softPrimary
                ? colors.primary.withValues(alpha: isDark ? 0.16 : 0.075)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.88));

    final foregroundColor = spaceStyle
        ? (emphasized ? const Color(0xFFFFFFFF) : const Color(0xFFEAF3FF))
        : emphasized
            ? colors.onPrimary
            : softPrimary
                ? (isDark ? const Color(0xFFB7D1FF) : colors.primary)
                : colors.onSurface;

    final borderColor = spaceStyle
        ? (emphasized
            ? const Color(0xFF6BA6FF).withValues(alpha: 0.72)
            : const Color(0xFF91B5E4).withValues(alpha: 0.20))
        : emphasized
            ? colors.primary
            : softPrimary
                ? colors.primary.withValues(alpha: 0.22)
                : colors.outline.withValues(alpha: isDark ? 0.18 : 0.14);

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 19, color: foregroundColor),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
