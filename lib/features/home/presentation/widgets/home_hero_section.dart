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

    final trimmedUserLabel = userLabel?.trim();
    final hasUserLabel = trimmedUserLabel != null && trimmedUserLabel.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEFF6FF),
            Color(0xFFF5F3FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.14),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 24,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(0.04),
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
                      foregroundColor: theme.colorScheme.primary,
                    ),
                    if (hasUserLabel)
                      _buildTopChip(
                        theme: theme,
                        icon: Icons.person_outline_rounded,
                        label: trimmedUserLabel!,
                        foregroundColor: theme.colorScheme.primary,
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
                    foregroundColor: theme.colorScheme.primary,
                    backgroundColor: Colors.white.withOpacity(0.72),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    side: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.14),
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
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Esplora il tuo scope, segui aree geografiche, scopri sondaggi, news e discussioni civiche in un’unica home.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.76),
              height: 1.5,
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
    IconData? icon,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.10),
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