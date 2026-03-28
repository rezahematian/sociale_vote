import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
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
    final newsList =
        allNews.length <= 3 ? allNews : allNews.take(3).toList(growable: false);

    Widget content;

    if (controller.isLoading && newsList.isEmpty) {
      content = const _HomeNewsLoadingState();
    } else if (newsList.isEmpty && controller.hasError) {
      content = HomeNewsPlaceholderCard(
        icon: Icons.wifi_off_rounded,
        title: l10n.homeNewsErrorTitle,
        subtitle: l10n.homeNewsErrorSubtitle,
        actionLabel: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
        onActionPressed: () {
          controller.loadNews();
        },
      );
    } else if (newsList.isEmpty) {
      content = HomeNewsPlaceholderCard(
        icon: Icons.article_outlined,
        title: l10n.homeNewsEmptyTitle,
        subtitle: l10n.homeNewsEmptySubtitle,
        actionLabel: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
        onActionPressed: () {
          controller.loadNews();
        },
      );
    } else {
      final featured = newsList.first;
      final secondary =
          newsList.length > 1 ? newsList.sublist(1) : const <NewsItem>[];

      content = Column(
        children: [
          if (controller.hasError) ...[
            _HomeNewsInlineStatus(
              icon: Icons.info_outline_rounded,
              title: l10n.homeNewsErrorTitle,
              subtitle: l10n.homeNewsErrorSubtitle,
              onRetryPressed: () {
                controller.loadNews();
              },
            ),
            const SizedBox(height: 10),
          ],
          if (controller.isLoading) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 3,
                backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 10),
          ],
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
                      right:
                          news == secondary.first && secondary.length > 1 ? 5 : 0,
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
        const SizedBox(width: 4),
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
          onPressed: controller.isLoading
              ? null
              : () {
                  controller.loadNews();
                },
          icon: controller.isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: LoadingIndicator(),
                )
              : const Icon(Icons.refresh_rounded, size: 20),
        ),
        const SizedBox(width: 4),
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
    final commentCount = controller.commentCountForNews(news);
    final userReaction = summary?.userReaction;

    return NewsPreviewCard(
      news: news,
      compact: compact,
      fireCount: fire,
      iceCount: ice,
      commentCount: commentCount,
      userReaction: userReaction,
      onReturnedFromDetail: () {
        controller.loadNews();
      },
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

class _HomeNewsInlineStatus extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onRetryPressed;

  const _HomeNewsInlineStatus({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onRetryPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      elevated: false,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.78),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: onRetryPressed,
              child: Text(
                MaterialLocalizations.of(context)
                    .refreshIndicatorSemanticLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeNewsLoadingState extends StatelessWidget {
  const _HomeNewsLoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _HomeNewsLoadingCard(compact: false),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _HomeNewsLoadingCard(compact: true)),
            SizedBox(width: 10),
            Expanded(child: _HomeNewsLoadingCard(compact: true)),
          ],
        ),
      ],
    );
  }
}

class _HomeNewsLoadingCard extends StatelessWidget {
  final bool compact;

  const _HomeNewsLoadingCard({
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget bar(double width, {double height = 10}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withOpacity(0.08),
          borderRadius: BorderRadius.circular(999),
        ),
      );
    }

    return AppCard(
      elevated: true,
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      bar(56, height: 8),
                      const SizedBox(height: 8),
                      bar(double.infinity, height: 12),
                      const SizedBox(height: 6),
                      bar(compact ? 110 : 160, height: 12),
                      const SizedBox(height: 8),
                      bar(double.infinity, height: 9),
                      const SizedBox(height: 5),
                      bar(compact ? 100 : 180, height: 9),
                    ],
                  ),
                ),
                SizedBox(width: compact ? 10 : 12),
                Container(
                  width: compact ? 78 : 108,
                  height: compact ? 78 : 92,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
            SizedBox(height: compact ? 10 : 12),
            bar(92, height: 8),
            SizedBox(height: compact ? 8 : 10),
            const Divider(height: 1),
            SizedBox(height: compact ? 8 : 10),
            Row(
              children: [
                bar(52, height: 8),
                const SizedBox(width: 10),
                bar(52, height: 8),
                const SizedBox(width: 10),
                bar(52, height: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HomeNewsPlaceholderCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const HomeNewsPlaceholderCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onActionPressed,
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
            Icon(
              icon,
              size: 22,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 10),
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
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(actionLabel!),
              ),
            ],
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
  final int commentCount;
  final ReactionType? userReaction;
  final VoidCallback? onFireTap;
  final VoidCallback? onIceTap;
  final VoidCallback? onReturnedFromDetail;

  const NewsPreviewCard({
    super.key,
    required this.news,
    required this.compact,
    this.fireCount = 0,
    this.iceCount = 0,
    this.commentCount = 0,
    this.userReaction,
    this.onFireTap,
    this.onIceTap,
    this.onReturnedFromDetail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final source = _sourceLabel(news);

    Future<void> openNewsDetail() async {
      final newsController = context.read<NewsController>();

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider<NewsController>.value(
            value: newsController,
            child: NewsDetailPage(news: news),
          ),
        ),
      );

      onReturnedFromDetail?.call();
    }

    return AppCard(
      elevated: true,
      onTap: openNewsDetail,
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
                      color:
                          theme.textTheme.bodySmall?.color?.withOpacity(0.72),
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
            _NewsPreviewEngagementBar(
              fireCount: fireCount,
              iceCount: iceCount,
              commentCount: commentCount,
              userReaction: userReaction,
              onFireTap: onFireTap,
              onIceTap: onIceTap,
              onCommentTap: openNewsDetail,
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

class _NewsPreviewEngagementBar extends StatelessWidget {
  final int fireCount;
  final int iceCount;
  final int commentCount;
  final ReactionType? userReaction;
  final VoidCallback? onFireTap;
  final VoidCallback? onIceTap;
  final VoidCallback? onCommentTap;

  const _NewsPreviewEngagementBar({
    required this.fireCount,
    required this.iceCount,
    required this.commentCount,
    required this.userReaction,
    required this.onFireTap,
    required this.onIceTap,
    required this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    return EngagementBar(
      fireCount: fireCount,
      iceCount: iceCount,
      commentCount: commentCount,
      userReaction: userReaction,
      onFireTap: onFireTap,
      onIceTap: onIceTap,
      onCommentTap: onCommentTap,
    );
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
          style:
              (compact ? theme.textTheme.bodyMedium : theme.textTheme.titleSmall)
                  ?.copyWith(
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