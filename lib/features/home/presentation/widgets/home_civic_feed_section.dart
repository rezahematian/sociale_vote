import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/features/home/application/civic_feed_controller.dart';
import 'package:sociale_vote/features/home/application/feed_item.dart';

class HomeCivicFeedSection extends StatelessWidget {
  final String scopeShortLabel;

  const HomeCivicFeedSection({
    super.key,
    required this.scopeShortLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<CivicFeedController>(
      builder: (context, controller, _) {
        if (controller.isLoading && controller.items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (controller.items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Nessun contenuto disponibile.',
              style: theme.textTheme.bodyMedium,
            ),
          );
        }

        final items = controller.items.take(10).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Civic Feed · $scopeShortLabel',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            for (final item in items) ...[
              _FeedCard(item: item),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _FeedCard extends StatelessWidget {
  final FeedItem item;

  const _FeedCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _typeLabel(item.type),
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: 6),
          Text(
            _title(item),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('🔥 ${item.reactionCount}'),
              const SizedBox(width: 12),
              Text('💬 ${item.commentCount}'),
              const Spacer(),
              Text(
                item.rankingScore.toStringAsFixed(1),
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _typeLabel(FeedItemType type) {
    switch (type) {
      case FeedItemType.poll:
        return 'POLL';
      case FeedItemType.news:
        return 'NEWS';
      case FeedItemType.post:
        return 'POST';
    }
  }

  String _title(FeedItem item) {
    final entity = item.poll ?? item.news ?? item.post;

    if (entity == null) {
      return 'Contenuto';
    }

    try {
      final dynamic e = entity;

      if (e.title != null) {
        return e.title.toString();
      }

      if (e.question != null) {
        return e.question.toString();
      }

      if (e.headline != null) {
        return e.headline.toString();
      }
    } catch (_) {}

    return 'Contenuto';
  }
}