import 'package:flutter/material.dart';

import 'package:sociale_vote/l10n/app_localizations.dart';

class HomeHeroSection extends StatelessWidget {
  final String scopeShortLabel;
  final String? userLabel;
  final VoidCallback onOpenPolls;
  final VoidCallback onOpenNews;
  final VoidCallback? onOpenSearch;

  const HomeHeroSection({
    super.key,
    required this.scopeShortLabel,
    required this.onOpenPolls,
    required this.onOpenNews,
    this.userLabel,
    this.onOpenSearch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final materialL10n = MaterialLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final trimmedUserLabel = userLabel?.trim();
    final hasUserLabel =
        trimmedUserLabel != null && trimmedUserLabel.isNotEmpty;

    final heroGradient = isDark
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

    final heroBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : theme.colorScheme.outline.withValues(alpha: 0.18);

    final heroShadowColor = isDark
        ? Colors.black.withValues(alpha: 0.24)
        : const Color(0xFF0F172A).withValues(alpha: 0.07);

    final chipBackgroundColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.94);

    final chipBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : theme.colorScheme.outline.withValues(alpha: 0.12);

    final chipForegroundColor =
        isDark ? const Color(0xFFB5D0FF) : theme.colorScheme.primary;

    final searchForegroundColor = isDark
        ? Colors.white.withValues(alpha: 0.94)
        : theme.colorScheme.primary;

    final searchBackgroundColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.96);

    final searchBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : theme.colorScheme.outline.withValues(alpha: 0.16);

    final titleColor = isDark
        ? Colors.white.withValues(alpha: 0.97)
        : theme.colorScheme.onSurface;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 640;
        final horizontalPadding = isCompact ? 20.0 : 24.0;
        final verticalPadding = isCompact ? 20.0 : 24.0;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: heroGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: heroBorderColor),
            boxShadow: [
              BoxShadow(
                blurRadius: 26,
                offset: const Offset(0, 12),
                color: heroShadowColor,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                Positioned(
                  top: -28,
                  right: -18,
                  child: IgnorePointer(
                    child: Container(
                      width: isCompact ? 112 : 136,
                      height: isCompact ? 112 : 136,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : theme.colorScheme.primary.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -34,
                  left: -22,
                  child: IgnorePointer(
                    child: Container(
                      width: isCompact ? 96 : 120,
                      height: isCompact ? 96 : 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? const Color(0xFF7C9BFF).withValues(alpha: 0.07)
                            : const Color(0xFF8B5CF6).withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    verticalPadding,
                    horizontalPadding,
                    isCompact ? 18 : 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildTopChip(
                                  theme: theme,
                                  icon: Icons.public_outlined,
                                  label: scopeShortLabel,
                                  foregroundColor: chipForegroundColor,
                                  backgroundColor: chipBackgroundColor,
                                  borderColor: chipBorderColor,
                                ),
                                if (hasUserLabel)
                                  _buildTopChip(
                                    theme: theme,
                                    icon: Icons.person_outline_rounded,
                                    label: trimmedUserLabel,
                                    foregroundColor: chipForegroundColor,
                                    backgroundColor: chipBackgroundColor,
                                    borderColor: chipBorderColor,
                                  ),
                              ],
                            ),
                          ),
                          if (onOpenSearch != null) ...[
                            const SizedBox(width: 12),
                            _buildSearchButton(
                              label: materialL10n.searchFieldLabel,
                              theme: theme,
                              foregroundColor: searchForegroundColor,
                              backgroundColor: searchBackgroundColor,
                              borderColor: searchBorderColor,
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: isCompact ? 20 : 22),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isCompact ? double.infinity : 520,
                        ),
                        child: Text(
                          'Decidi il futuro.\nInsieme.',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 0.98,
                            letterSpacing: -0.7,
                            color: titleColor,
                          ),
                        ),
                      ),
                      SizedBox(height: isCompact ? 20 : 22),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          FilledButton.icon(
                            onPressed: onOpenPolls,
                            icon: const Icon(Icons.how_to_vote, size: 18),
                            label: Text(l10n.homePollsViewAllButton),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 13,
                              ),
                              textStyle: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: onOpenNews,
                            icon: const Icon(Icons.article_outlined, size: 18),
                            label: Text(l10n.homeNewsViewAllButton),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark
                                  ? Colors.white.withValues(alpha: 0.92)
                                  : theme.colorScheme.onSurface,
                              backgroundColor: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.white.withValues(alpha: 0.88),
                              side: BorderSide(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.12)
                                    : theme.colorScheme.outline
                                        .withValues(alpha: 0.16),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 13,
                              ),
                              textStyle: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
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
          horizontal: 14,
          vertical: 11,
        ),
        textStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        side: BorderSide(
          color: borderColor,
        ),
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
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: foregroundColor,
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: foregroundColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
