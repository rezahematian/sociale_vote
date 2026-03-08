import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';
import 'package:sociale_vote/features/news/application/news_controller.dart';
import 'package:sociale_vote/features/news/presentation/pages/news_detail_page.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';
import 'package:sociale_vote/shared/widgets/engagement_bar.dart';

class HomeNewsSection extends StatelessWidget {
  final String scopeShortLabel;

  const HomeNewsSection({
    super.key,
    required this.scopeShortLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<NewsController>();

    final allNews = controller.news;

    final sorted = List<NewsItem>.from(allNews);
    sorted.sort((a, b) {
      final summaryA = controller.summaryForNews(a);
      final summaryB = controller.summaryForNews(b);

      final heatA =
          (summaryA?.likeCount ?? 0) - (summaryA?.dislikeCount ?? 0);
      final heatB =
          (summaryB?.likeCount ?? 0) - (summaryB?.dislikeCount ?? 0);

      return heatB.compareTo(heatA);
    });

    final newsList =
        sorted.length <= 3 ? sorted : sorted.take(3).toList(growable: false);

    final header = Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withOpacity(0.08),
          ),
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.article,
            size: 18,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          l10n.homeNewsTitle(scopeShortLabel),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    Widget content;

    if (controller.isLoading && newsList.isEmpty) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (controller.hasError) {
      content = HomeNewsPlaceholderCard(
        title: l10n.homeNewsErrorTitle,
        subtitle: l10n.homeNewsErrorSubtitle,
      );
    } else if (newsList.isEmpty) {
      content = HomeNewsPlaceholderCard(
        title: l10n.homeNewsEmptyTitle,
        subtitle: l10n.homeNewsEmptySubtitle,
      );
    } else {
      content = Column(
        children: newsList.map((news) {
          final summary = controller.summaryForNews(news);

          final fire = summary?.likeCount ?? 0;
          final ice = summary?.dislikeCount ?? 0;
          final userReaction = summary?.userReaction;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: NewsPreviewCard(
              news: news,
              fireCount: fire,
              iceCount: ice,
              userReaction: userReaction,
              onFireTap: () async {
                final allowed = await AuthGuard.ensureCanPerformAction(
                  context,
                  ParticipationAction.react,
                );
                if (!allowed) return;

                final userId = AppDI.instance.currentUserId!;
                controller.toggleFireForNews(
                  userId: userId,
                  newsItem: news,
                );
              },
              onIceTap: () async {
                final allowed = await AuthGuard.ensureCanPerformAction(
                  context,
                  ParticipationAction.react,
                );
                if (!allowed) return;

                final userId = AppDI.instance.currentUserId!;
                controller.toggleIceForNews(
                  userId: userId,
                  newsItem: news,
                );
              },
            ),
          );
        }).toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const SizedBox(height: 8),
        content,
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRouter.news,
              );
            },
            icon: const Icon(Icons.arrow_forward),
            label: Text(l10n.homeNewsViewAllButton),
          ),
        ),
      ],
    );
  }
}

class HomeNewsPlaceholderCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const HomeNewsPlaceholderCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 8),
      color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewsPreviewCard extends StatelessWidget {
  final NewsItem news;
  final int fireCount;
  final int iceCount;
  final ReactionType? userReaction;
  final VoidCallback? onFireTap;
  final VoidCallback? onIceTap;

  const NewsPreviewCard({
    super.key,
    required this.news,
    this.fireCount = 0,
    this.iceCount = 0,
    this.userReaction,
    this.onFireTap,
    this.onIceTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(12),
      color: theme.colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final newsController = context.read<NewsController>();

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider<NewsController>.value(
                value: newsController,
                child: NewsDetailPage(news: news),
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.4),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (news.isBreaking) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l10n.homeNewsBreakingBadge,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onError,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
              Text(
                news.title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (news.summary != null &&
                  news.summary!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  news.summary!,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: theme.hintColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatPublishedAt(news.publishedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color
                          ?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 4),
              EngagementBar(
                fireCount: fireCount,
                iceCount: iceCount,
                userReaction: userReaction,
                onFireTap: onFireTap,
                onIceTap: onIceTap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPublishedAt(DateTime dateTime) {
    final local = dateTime.toLocal();

    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();

    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }
}