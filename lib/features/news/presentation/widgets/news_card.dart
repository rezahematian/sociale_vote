import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';
import 'package:sociale_vote/features/news/presentation/pages/news_detail_page.dart';
import 'package:sociale_vote/shared/ui/app_card.dart';
import 'package:sociale_vote/shared/widgets/engagement_bar.dart';

class NewsCard extends StatelessWidget {
  final NewsItem news;

  final bool compact;

  final int fireCount;
  final int iceCount;
  final int? commentCount;
  final ReactionType? userReaction;

  final VoidCallback? onFireTap;
  final VoidCallback? onIceTap;
  final VoidCallback? onCommentTap;
  final VoidCallback? onCardTap;

  const NewsCard({
    super.key,
    required this.news,
    this.compact = false,
    this.fireCount = 0,
    this.iceCount = 0,
    this.commentCount,
    this.userReaction,
    this.onFireTap,
    this.onIceTap,
    this.onCommentTap,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    VoidCallback? wrapReactCallback(VoidCallback? original) {
      if (original == null) return null;

      return () async {
        final allowed = await AuthGuard.ensureCanPerformAction(
          context,
          ParticipationAction.react,
        );
        if (!allowed) return;

        original();
      };
    }

    void openDetail() {
      if (onCardTap != null) {
        onCardTap!.call();
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => NewsDetailPage(news: news),
        ),
      );
    }

    void openCommentsOrDetail() {
      if (onCommentTap != null) {
        onCommentTap!.call();
        return;
      }

      openDetail();
    }

    final String title = news.title.trim().isNotEmpty ? news.title.trim() : 'News';

    final String? summary =
        news.summary != null && news.summary!.trim().isNotEmpty
            ? news.summary!.trim()
            : null;

    final String? imageUrl =
        news.imageUrl != null && news.imageUrl!.trim().isNotEmpty
            ? news.imageUrl!.trim()
            : null;

    final String sourceName = _sourceLabel(news);

    final String publishedLabel = _formatPublishedAt(news.publishedAt);

    final double imageWidth = compact ? 78 : 108;
    final double imageHeight = compact ? 78 : 92;
    final EdgeInsets cardPadding = EdgeInsets.all(compact ? 12 : 14);

    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevated: true,
      onTap: openDetail,
      child: Padding(
        padding: cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildNewsIconChip(),
                _buildSourceChip(theme, sourceName),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _NewsTextBlock(
                    title: title,
                    summary: summary,
                    compact: compact,
                  ),
                ),
                if (imageUrl != null) ...[
                  SizedBox(width: compact ? 10 : 12),
                  _NewsThumbnail(
                    imageUrl: imageUrl,
                    width: imageWidth,
                    height: imageHeight,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Text(
              publishedLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.58),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            _NewsEngagementBar(
              news: news,
              commentCount: commentCount,
              fireCount: fireCount,
              iceCount: iceCount,
              userReaction: userReaction,
              onFireTap: wrapReactCallback(onFireTap),
              onIceTap: wrapReactCallback(onIceTap),
              onCommentTap: openCommentsOrDetail,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsIconChip() {
    const backgroundColor = Color(0xFFFFF1F1);
    const foregroundColor = Color(0xFFE14D4D);
    const borderColor = Color(0xFFFFD9D9);

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: const Icon(
        Icons.newspaper_outlined,
        size: 16,
        color: foregroundColor,
      ),
    );
  }

  Widget _buildSourceChip(ThemeData theme, String sourceName) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FB),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.language_outlined,
            size: 14,
            color: Color(0xFF667085),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              sourceName,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                fontSize: 12,
                height: 1,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF667085),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _sourceLabel(NewsItem news) {
    final effective = news.effectiveSourceLabel?.trim();
    if (effective != null && effective.isNotEmpty) {
      return effective;
    }

    final author = news.authorId.trim();
    if (author.isNotEmpty) {
      return author.length <= 28 ? author : author.substring(0, 28);
    }

    return 'News';
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

class _NewsTextBlock extends StatelessWidget {
  final String title;
  final String? summary;
  final bool compact;

  const _NewsTextBlock({
    required this.title,
    required this.summary,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              (compact ? theme.textTheme.bodyMedium : theme.textTheme.titleSmall)
                  ?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
          maxLines: compact ? 3 : 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (summary != null) ...[
          const SizedBox(height: 6),
          Text(
            summary!,
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
  final double width;
  final double height;

  const _NewsThumbnail({
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NewsEngagementBar extends StatelessWidget {
  final NewsItem news;
  final int? commentCount;
  final int fireCount;
  final int iceCount;
  final ReactionType? userReaction;
  final VoidCallback? onFireTap;
  final VoidCallback? onIceTap;
  final VoidCallback? onCommentTap;

  const _NewsEngagementBar({
    required this.news,
    required this.commentCount,
    required this.fireCount,
    required this.iceCount,
    required this.userReaction,
    required this.onFireTap,
    required this.onIceTap,
    required this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    if (commentCount != null) {
      return _buildBar(commentCount!);
    }

    return FutureBuilder(
      future: AppDI.instance.getCommentsForTarget(TargetRef.news(news.id.value)),
      builder: (context, snapshot) {
        final comments = snapshot.data as List<dynamic>? ?? const [];
        final resolvedCommentCount = snapshot.hasError ? 0 : comments.length;
        return _buildBar(resolvedCommentCount);
      },
    );
  }

  Widget _buildBar(int resolvedCommentCount) {
    return EngagementBar(
      fireCount: fireCount,
      iceCount: iceCount,
      commentCount: resolvedCommentCount,
      userReaction: userReaction,
      onFireTap: onFireTap,
      onIceTap: onIceTap,
      onCommentTap: onCommentTap,
    );
  }
}