import 'package:flutter/material.dart';

import 'package:sociale_vote/l10n/app_localizations.dart';

class HomeHeroSection extends StatelessWidget {
  final String scopeShortLabel;
  final VoidCallback onOpenPolls;
  final VoidCallback onOpenNews;

  const HomeHeroSection({
    super.key,
    required this.scopeShortLabel,
    required this.onOpenPolls,
    required this.onOpenNews,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.78),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.10),
              ),
            ),
            child: Text(
              scopeShortLabel,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
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
}