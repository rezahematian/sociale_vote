import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/features/discovery/application/for_you_feed_controller.dart';
import 'package:sociale_vote/features/home/application/feed_item.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_trending_section.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

class HomeForYouSection extends StatelessWidget {
  final String scopeShortLabel;
  final int? maxItems;
  final String? explanation;

  const HomeForYouSection({
    super.key,
    required this.scopeShortLabel,
    this.maxItems = 3,
    this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    final userId = AppDI.instance.currentUserId;
    if (userId == null || userId.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<ForYouFeedController>();

    final List<FeedItem> items = controller.items;

    final header = Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.secondary.withValues(alpha: 0.08),
          ),
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.star,
            size: 18,
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            l10n.homeForYouTitle(scopeShortLabel),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (controller.isLoading)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          IconButton(
            tooltip:
                MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
            onPressed: () {
              context.read<ForYouFeedController>().load(userId: userId);
            },
            icon: const Icon(Icons.refresh),
          ),
      ],
    );

    Widget content;

    if (controller.isLoading && items.isEmpty) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (controller.hasError) {
      content = Card(
        elevation: 0,
        margin: const EdgeInsets.only(top: 8),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(l10n.homeForYouError),
        ),
      );
    } else if (items.isEmpty) {
      content = Card(
        elevation: 0,
        margin: const EdgeInsets.only(top: 8),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(l10n.homeForYouEmpty),
        ),
      );
    } else {
      final visibleItems = maxItems == null || items.length <= maxItems!
          ? items
          : items.take(maxItems!).toList(growable: false);

      content = Column(
        children: visibleItems
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TrendingFeedItemCard(
                  item: item,
                  onReturnRefresh: () => controller.load(userId: userId),
                ),
              ),
            )
            .toList(),
      );
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        header,
        if (explanation != null && explanation!.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            explanation!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
        const SizedBox(height: 8),
        content,
      ],
    );
  }
}
