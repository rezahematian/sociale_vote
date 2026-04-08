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
    final hasUserLabel = trimmedUserLabel != null && trimmedUserLabel.isNotEmpty;

    final heroGradient = isDark
        ? const [
            Color(0xFF0F172A),
            Color(0xFF172554),
          ]
        : const [
            Color(0xFFEFF6FF),
            Color(0xFFF5F3FF),
          ];

    final heroBorderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : theme.colorScheme.outline.withOpacity(0.14);

    final heroShadowColor = isDark
        ? Colors.black.withOpacity(0.18)
        : Colors.black.withOpacity(0.04);

    final chipBackgroundColor = isDark
        ? Colors.white.withOpacity(0.07)
        : Colors.white.withOpacity(0.78);

    final chipBorderColor = isDark
        ? Colors.white.withOpacity(0.10)
        : theme.colorScheme.outline.withOpacity(0.10);

    final chipForegroundColor = isDark
        ? const Color(0xFF9CC2FF)
        : theme.colorScheme.primary;

    final searchForegroundColor = isDark
        ? Colors.white.withOpacity(0.92)
        : theme.colorScheme.primary;

    final searchBackgroundColor = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.white.withOpacity(0.72);

    final searchBorderColor = isDark
        ? Colors.white.withOpacity(0.10)
        : theme.colorScheme.outline.withOpacity(0.14);

    final titleColor = isDark
        ? Colors.white.withOpacity(0.96)
        : theme.colorScheme.onSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: heroBorderColor,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 24,
            offset: const Offset(0, 10),
            color: heroShadowColor,
          ),
        ],
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
                      icon: null,
                      label: scopeShortLabel,
                      foregroundColor: chipForegroundColor,
                      backgroundColor: chipBackgroundColor,
                      borderColor: chipBorderColor,
                    ),
                    if (hasUserLabel)
                      _buildTopChip(
                        theme: theme,
                        icon: Icons.person_outline_rounded,
                        label: trimmedUserLabel!,
                        foregroundColor: chipForegroundColor,
                        backgroundColor: chipBackgroundColor,
                        borderColor: chipBorderColor,
                      ),
                  ],
                ),
              ),
              if (onOpenSearch != null) ...[
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: onOpenSearch,
                  icon: const Icon(Icons.search_rounded, size: 18),
                  label: Text(materialL10n.searchFieldLabel),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: searchForegroundColor,
                    backgroundColor: searchBackgroundColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    side: BorderSide(
                      color: searchBorderColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Decidi il futuro.\nInsieme.',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.0,
              letterSpacing: -0.6,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: onOpenPolls,
                icon: const Icon(Icons.how_to_vote, size: 18),
                label: Text(l10n.homePollsViewAllButton),
              ),
              OutlinedButton.icon(
                onPressed: onOpenNews,
                icon: const Icon(Icons.article_outlined, size: 18),
                label: Text(l10n.homeNewsViewAllButton),
              ),
            ],
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
                fontWeight: FontWeight.w600,
                color: foregroundColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}