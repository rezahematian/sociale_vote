import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/features/discovery/application/trending_controller.dart';
import 'package:sociale_vote/features/home/application/feed_item.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

class HomeTrendingSection extends StatelessWidget {
  final int? maxItems;
  final String? explanation;

  const HomeTrendingSection({
    super.key,
    this.maxItems = 3,
    this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<TrendingController>();

    final items = controller.items;

    final header = Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
          ),
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.trending_up,
            size: 18,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            l10n.homeTrendingTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
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
              context.read<TrendingController>().loadTrending();
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
          child: Text(l10n.homeTrendingError),
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
          child: Text(l10n.homeTrendingEmpty),
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
                  onReturnRefresh: controller.loadTrending,
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

class TrendingFeedItemCard extends StatelessWidget {
  final FeedItem item;
  final Future<void> Function()? onReturnRefresh;

  const TrendingFeedItemCard({
    super.key,
    required this.item,
    this.onReturnRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = _titleForItem(item);
    final subtitle = _subtitleForItem(item);
    final typeLabel = _typeLabel(context, item);
    final typeIcon = _typeIcon(item);

    final canOpen =
        item.isPost || item.isPoll || (item.isNews && item.news != null);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: canOpen ? () => _openItem(context, item) : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    typeIcon,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    typeLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null && subtitle.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 6,
                children: [
                  _MetricPill(
                    icon: Icons.local_fire_department_outlined,
                    value: item.reactionCount.toString(),
                  ),
                  _MetricPill(
                    icon: Icons.mode_comment_outlined,
                    value: item.commentCount.toString(),
                  ),
                  if (item.isPoll)
                    _MetricPill(
                      icon: Icons.how_to_vote_outlined,
                      value: item.voteCount.toString(),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: theme.hintColor,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _formatItemCreatedAt(item.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openItem(BuildContext context, FeedItem item) async {
    var openedDetail = false;

    if (item.isPost) {
      openedDetail = true;
      await Navigator.pushNamed(
        context,
        AppRouter.socialDetail,
        arguments: item.id,
      );
    } else if (item.isPoll) {
      openedDetail = true;
      await Navigator.pushNamed(
        context,
        AppRouter.pollDetail,
        arguments: item.id,
      );
    } else if (item.isNews && item.news != null) {
      openedDetail = true;
      await Navigator.pushNamed(
        context,
        AppRouter.newsDetail,
        arguments: item.news,
      );
    }

    if (!openedDetail || !context.mounted) {
      return;
    }

    await onReturnRefresh?.call();
  }

  String _titleForItem(FeedItem item) {
    if (item.isPost) {
      return item.post?.title ?? '';
    }
    if (item.isNews) {
      return item.news?.title ?? '';
    }
    return item.poll?.title ?? '';
  }

  String? _subtitleForItem(FeedItem item) {
    if (item.isPost) {
      final content = item.post?.content.trim();
      return (content == null || content.isEmpty) ? null : content;
    }

    if (item.isNews) {
      final summary = item.news?.summary?.trim();
      if (summary != null && summary.isNotEmpty) {
        return summary;
      }

      final content = item.news?.content.trim();
      return (content == null || content.isEmpty) ? null : content;
    }

    final description = item.poll?.description?.trim();
    return (description == null || description.isEmpty) ? null : description;
  }

  String _typeLabel(BuildContext context, FeedItem item) {
    final l10n = AppLocalizations.of(context)!;

    if (item.isPost) return l10n.searchResultTypePost;
    if (item.isNews) return l10n.searchResultTypeNews;
    return l10n.searchResultTypePoll;
  }

  IconData _typeIcon(FeedItem item) {
    if (item.isPost) return Icons.forum_outlined;
    if (item.isNews) return Icons.newspaper_outlined;
    return Icons.poll_outlined;
  }

  String _formatItemCreatedAt(DateTime dateTime) {
    final local = dateTime.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }
}

class _MetricPill extends StatelessWidget {
  final IconData icon;
  final String value;

  const _MetricPill({
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: theme.hintColor,
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
