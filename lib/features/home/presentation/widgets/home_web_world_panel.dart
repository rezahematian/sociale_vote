import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/features/news/application/news_controller.dart';
import 'package:sociale_vote/features/poll/application/poll_list_controller.dart';
import 'package:sociale_vote/features/social/application/feed_controller.dart';
import 'package:sociale_vote/app/localization/de_fallback.dart';
import 'package:sociale_vote/shared/widgets/product_signature_label.dart';

/// Compact desktop-only Home information panel.
///
/// Intentional scope:
/// - polls
/// - social discussions/posts
/// - one compact world-news row
///
/// The normal Home feed below remains unchanged and continues to contain the
/// full News section.
class HomeWebWorldPanel extends StatelessWidget {
  final String scopeShortLabel;
  final String? currentUserId;

  const HomeWebWorldPanel({
    super.key,
    required this.scopeShortLabel,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pollController = context.watch<PollListController>();
    final feedController = context.watch<FeedController>();
    final newsController = context.watch<NewsController>();

    final poll =
        pollController.polls.isEmpty ? null : pollController.polls.first;

    final posts = List<Post>.from(feedController.posts);
    posts.sort((a, b) {
      final heatA = feedController.likeCountForPost(a) -
          feedController.dislikeCountForPost(a);
      final heatB = feedController.likeCountForPost(b) -
          feedController.dislikeCountForPost(b);

      if (heatA != heatB) {
        return heatB.compareTo(heatA);
      }

      return b.createdAt.compareTo(a.createdAt);
    });

    final post = posts.isEmpty ? null : posts.first;
    final news = newsController.news.isEmpty ? null : newsController.news.first;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.30,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.16),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.public,
                size: 17,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ProductSignatureLabel(
                  kind: ProductSignatureKind.world,
                  brandStyle: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  descriptorStyle: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _WebPulseRow(
            icon: Icons.how_to_vote_outlined,
            productKind: ProductSignatureKind.vote,
            title: poll?.title,
            trailingValue: poll?.voteCount.toString(),
            loading: pollController.isLoading && poll == null,
            onTap: poll == null
                ? () {
                    Navigator.pushNamed(context, AppRouter.polls);
                  }
                : () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.pollDetail,
                      arguments: poll.id,
                    );
                  },
            onViewAll: () {
              Navigator.pushNamed(context, AppRouter.polls);
            },
          ),
          const SizedBox(height: 6),
          _WebPulseRow(
            icon: Icons.forum_outlined,
            productKind: ProductSignatureKind.voce,
            title: post?.title,
            trailingValue: post == null
                ? null
                : feedController.commentCountForPost(post).toString(),
            loading: feedController.isLoading && post == null,
            onTap: post == null
                ? () {
                    Navigator.pushNamed(context, AppRouter.social);
                  }
                : () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.socialDetail,
                      arguments: post.id.value,
                    );
                  },
            onViewAll: () {
              Navigator.pushNamed(context, AppRouter.social);
            },
          ),
          const SizedBox(height: 6),
          _WebPulseRow(
            icon: Icons.newspaper_outlined,
            productKind: ProductSignatureKind.news,
            title: news?.title,
            trailingValue: null,
            loading: newsController.isLoading && news == null,
            onTap: news == null
                ? () {
                    Navigator.pushNamed(context, AppRouter.news);
                  }
                : () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.newsDetail,
                      arguments: news,
                    );
                  },
            onViewAll: () {
              Navigator.pushNamed(context, AppRouter.news);
            },
          ),
        ],
      ),
    );
  }
}

class _WebPulseRow extends StatelessWidget {
  final IconData icon;
  final ProductSignatureKind productKind;
  final String? title;
  final String? trailingValue;
  final bool loading;
  final VoidCallback onTap;
  final VoidCallback onViewAll;

  const _WebPulseRow({
    required this.icon,
    required this.productKind,
    required this.title,
    required this.trailingValue,
    required this.loading,
    required this.onTap,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface.withValues(alpha: 0.42),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withValues(alpha: 0.10),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: loading
                      ? const Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProductSignatureLabel(
                              kind: productKind,
                              brandStyle: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                                height: 1.0,
                              ),
                              descriptorStyle:
                                  theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 10.0,
                                fontWeight: FontWeight.w500,
                                height: 1.0,
                              ),
                              gap: 2,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              title?.trim().isNotEmpty == true
                                  ? title!
                                  : (Localizations.localeOf(context)
                                              .languageCode ==
                                          'it'
                                      ? 'Apri'
                                      : deOrEnglish(context,
                                          english: 'Open', german: 'Öffnen')),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
                if (trailingValue != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    trailingValue!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(width: 6),
                IconButton(
                  tooltip: Localizations.localeOf(context).languageCode == 'it'
                      ? 'Vedi tutti'
                      : deOrEnglish(context,
                          english: 'View all', german: 'Alle anzeigen'),
                  visualDensity: VisualDensity.compact,
                  onPressed: onViewAll,
                  icon: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
