import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';
import 'package:sociale_vote/features/news/application/news_controller.dart';
import 'package:sociale_vote/features/news/domain/news_language.dart';
import 'package:sociale_vote/features/news/presentation/pages/news_detail_page.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';
import 'package:sociale_vote/shared/ui/app_card.dart';
import 'package:sociale_vote/shared/ui/loading_indicator.dart';
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

      final heatA = (summaryA?.likeCount ?? 0) - (summaryA?.dislikeCount ?? 0);
      final heatB = (summaryB?.likeCount ?? 0) - (summaryB?.dislikeCount ?? 0);

      return heatB.compareTo(heatA);
    });

    final newsList =
        sorted.length <= 3 ? sorted : sorted.take(3).toList(growable: false);

    Widget content;

    if (controller.isLoading && newsList.isEmpty) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: LoadingIndicator(),
          ),
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
      final featured = newsList.first;
      final secondary = newsList.length > 1 ? newsList.sublist(1) : const <NewsItem>[];

      content = Column(
        children: [
          _NewsCardBuilder(
            news: featured,
            compact: false,
          ),
          if (secondary.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: secondary.map((news) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: news == secondary.first && secondary.length > 1 ? 5 : 0,
                      left: news != secondary.first ? 5 : 0,
                    ),
                    child: _NewsCardBuilder(
                      news: news,
                      compact: true,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HomeNewsHeader(scopeShortLabel: scopeShortLabel),
        const SizedBox(height: 10),
        content,
        const SizedBox(height: 10),
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
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeNewsHeader extends StatelessWidget {
  final String scopeShortLabel;

  const _HomeNewsHeader({
    required this.scopeShortLabel,
  });

  String _languageLabel(NewsLanguage language) {
    switch (language) {
      case NewsLanguage.auto:
        return 'AUTO';
      case NewsLanguage.it:
        return 'IT';
      case NewsLanguage.en:
        return 'EN';
      case NewsLanguage.es:
        return 'ES';
      case NewsLanguage.fr:
        return 'FR';
      case NewsLanguage.de:
        return 'DE';
      case NewsLanguage.ar:
        return 'AR';
      case NewsLanguage.fa:
        return 'FA';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<NewsController>();
    final currentUserId = AppDI.instance.currentUserId;

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.08),
                ),
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.article_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.homeNewsTitle(scopeShortLabel),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<NewsLanguage>(
          tooltip: l10n.newsFeed_languageTooltip,
          onSelected: (lang) {
            controller.setLanguage(lang, userId: currentUserId);
          },
          itemBuilder: (context) => const [
            PopupMenuItem<NewsLanguage>(
              value: NewsLanguage.auto,
              child: Text('AUTO'),
            ),
            PopupMenuItem<NewsLanguage>(
              value: NewsLanguage.it,
              child: Text('IT'),
            ),
            PopupMenuItem<NewsLanguage>(
              value: NewsLanguage.en,
              child: Text('EN'),
            ),
            PopupMenuItem<NewsLanguage>(
              value: NewsLanguage.es,
              child: Text('ES'),
            ),
            PopupMenuItem<NewsLanguage>(
              value: NewsLanguage.fr,
              child: Text('FR'),
            ),
            PopupMenuItem<NewsLanguage>(
              value: NewsLanguage.de,
              child: Text('DE'),
            ),
            PopupMenuItem<NewsLanguage>(
              value: NewsLanguage.ar,
              child: Text('AR'),
            ),
            PopupMenuItem<NewsLanguage>(
              value: NewsLanguage.fa,
              child: Text('FA'),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.45),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: theme.dividerColor.withOpacity(0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.language,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.75),
                ),
                const SizedBox(width: 6),
                Text(
                  _languageLabel(controller.selectedLanguage),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.arrow_drop_down, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NewsCardBuilder extends StatelessWidget {
  final NewsItem news;
  final bool compact;

  const _NewsCardBuilder({
    required this.news,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NewsController>();
    final summary = controller.summaryForNews(news);

    final fire = summary?.likeCount ?? 0;
    final ice = summary?.dislikeCount ?? 0;
    final userReaction = summary?.userReaction;

    return NewsPreviewCard(
      news: news,
      compact: compact,
      fireCount: fire,
      iceCount: ice,
      userReaction: userReaction,
      onFireTap: () async {
        final allowed = await AuthGuard.ensureCanPerformAction(
          context,
          ParticipationAction.react,
        );
        if (!allowed) return;

        final userId = AppDI.instance.currentUserId;
        if (userId == null) return;

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

        final userId = AppDI.instance.currentUserId;
        if (userId == null) return;

        controller.toggleIceForNews(
          userId: userId,
          newsItem: news,
        );
      },
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

    return AppCard(
      elevated: false,
      child: Padding(
        padding: const EdgeInsets.all(14),
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
  final bool compact;
  final int fireCount;
  final int iceCount;
  final ReactionType? userReaction;
  final VoidCallback? onFireTap;
  final VoidCallback? onIceTap;

  const NewsPreviewCard({
    super.key,
    required this.news,
    required this.compact,
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
    final source = _sourceLabel(news);

    return AppCard(
      elevated: true,
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
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.isBreaking) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  l10n.homeNewsBreakingBadge,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onError,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _NewsCardTextBlock(
                    news: news,
                    source: source,
                    compact: compact,
                  ),
                ),
                if (_hasImage(news)) ...[
                  SizedBox(width: compact ? 10 : 12),
                  _NewsThumbnail(
                    imageUrl: news.imageUrl!,
                    compact: compact,
                  ),
                ],
              ],
            ),
            SizedBox(height: compact ? 10 : 12),
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
                    _formatPublishedAt(news.publishedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.72),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: compact ? 8 : 10),
            const Divider(height: 1),
            SizedBox(height: compact ? 6 : 8),
            Row(
              children: [
                _CommentCountBadge(news: news),
                const SizedBox(width: 8),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: EngagementBar(
                      fireCount: fireCount,
                      iceCount: iceCount,
                      userReaction: userReaction,
                      onFireTap: onFireTap,
                      onIceTap: onIceTap,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static bool _hasImage(NewsItem news) {
    final url = news.imageUrl;
    return url != null && url.trim().isNotEmpty;
  }

  static String _sourceLabel(NewsItem news) {
    final raw = news.authorId.trim();
    if (raw.isEmpty) return 'GNews';
    if (raw.length <= 28) return raw;
    return raw.substring(0, 28);
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

class _NewsCardTextBlock extends StatelessWidget {
  final NewsItem news;
  final String source;
  final bool compact;

  const _NewsCardTextBlock({
    required this.news,
    required this.source,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          source,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          news.title,
          style: (compact ? theme.textTheme.bodyMedium : theme.textTheme.titleSmall)?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
          maxLines: compact ? 3 : 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (news.summary != null && news.summary!.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            news.summary!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.82),
              height: 1.25,
            ),
            maxLines: compact ? 3 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _NewsThumbnail extends StatelessWidget {
  final String imageUrl;
  final bool compact;

  const _NewsThumbnail({
    required this.imageUrl,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final double width = compact ? 78 : 108;
    final double height = compact ? 78 : 92;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: width,
        height: height,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: theme.colorScheme.onSurface.withOpacity(0.06),
            alignment: Alignment.center,
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 20,
              color: theme.colorScheme.onSurface.withOpacity(0.35),
            ),
          ),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: theme.colorScheme.onSurface.withOpacity(0.06),
              alignment: Alignment.center,
              child: const SizedBox(
                width: 18,
                height: 18,
                child: LoadingIndicator(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CommentCountBadge extends StatelessWidget {
  final NewsItem news;

  const _CommentCountBadge({
    required this.news,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder(
      future: AppDI.instance.getCommentsForTarget(TargetRef.news(news.id.value)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 54,
            height: 28,
          );
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final comments = snapshot.data as List<dynamic>? ?? const [];
        final count = comments.length;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.42),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.30),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.mode_comment_outlined,
                size: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.72),
              ),
              const SizedBox(width: 5),
              Text(
                '$count',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.82),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}