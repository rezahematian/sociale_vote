import 'dart:async';

import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/features/news/application/news_controller.dart';
import 'package:sociale_vote/features/poll/application/poll_list_controller.dart';
import 'package:sociale_vote/features/social/application/feed_controller.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

/// Compact desktop-only Home information panel.
///
/// Intentional scope:
/// - polls
/// - social discussions/posts
/// - one compact world-news row
///
/// The normal Home feed below remains unchanged and continues to contain the
/// full News section.
class HomeWebWorldPanel extends StatefulWidget {
  final String scopeShortLabel;
  final String? currentUserId;

  const HomeWebWorldPanel({
    super.key,
    required this.scopeShortLabel,
    required this.currentUserId,
  });

  @override
  State<HomeWebWorldPanel> createState() => _HomeWebWorldPanelState();
}

class _HomeWebWorldPanelState extends State<HomeWebWorldPanel> {
  late final PollListController _pollController;
  late final FeedController _feedController;
  late final NewsController _newsController;

  @override
  void initState() {
    super.initState();

    _pollController = AppDI.instance.createPollListController();
    _feedController = AppDI.instance.createFeedController();
    _newsController = AppDI.instance.createNewsController();

    _pollController.addListener(_handleControllerChanged);
    _feedController.addListener(_handleControllerChanged);
    _newsController.addListener(_handleControllerChanged);

    unawaited(
      _pollController.loadPolls(
        userId: widget.currentUserId,
      ),
    );
    unawaited(
      _feedController.loadFeed(
        userId: widget.currentUserId,
      ),
    );
    unawaited(
      _newsController.loadNews(
        userId: widget.currentUserId,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant HomeWebWorldPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentUserId != widget.currentUserId ||
        oldWidget.scopeShortLabel != widget.scopeShortLabel) {
      unawaited(
        _pollController.loadPolls(
          userId: widget.currentUserId,
        ),
      );
      unawaited(
        _feedController.loadFeed(
          userId: widget.currentUserId,
        ),
      );
      unawaited(
        _newsController.loadNews(
          userId: widget.currentUserId,
        ),
      );
    }
  }

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _pollController.removeListener(_handleControllerChanged);
    _feedController.removeListener(_handleControllerChanged);
    _newsController.removeListener(_handleControllerChanged);
    _pollController.dispose();
    _feedController.dispose();
    _newsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final poll =
        _pollController.polls.isEmpty ? null : _pollController.polls.first;

    final posts = List<Post>.from(_feedController.posts);
    posts.sort((a, b) {
      final heatA = _feedController.likeCountForPost(a) -
          _feedController.dislikeCountForPost(a);
      final heatB = _feedController.likeCountForPost(b) -
          _feedController.dislikeCountForPost(b);

      if (heatA != heatB) {
        return heatB.compareTo(heatA);
      }

      return b.createdAt.compareTo(a.createdAt);
    });

    final post = posts.isEmpty ? null : posts.first;
    final news =
        _newsController.news.isEmpty ? null : _newsController.news.first;

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
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
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
                child: Text(
                  'Social Vote · ${widget.scopeShortLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _WebPulseRow(
            icon: Icons.how_to_vote_outlined,
            label: l10n.homePollsTitle(widget.scopeShortLabel),
            title: poll?.title,
            trailingValue: poll?.voteCount.toString(),
            loading: _pollController.isLoading && poll == null,
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
          const SizedBox(height: 8),
          _WebPulseRow(
            icon: Icons.forum_outlined,
            label: l10n.homeSocialTitle(widget.scopeShortLabel),
            title: post?.title,
            trailingValue: post == null
                ? null
                : _feedController.commentCountForPost(post).toString(),
            loading: _feedController.isLoading && post == null,
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
          const SizedBox(height: 8),
          _WebPulseRow(
            icon: Icons.newspaper_outlined,
            label: l10n.homeNewsTitle(widget.scopeShortLabel),
            title: news?.title,
            trailingValue: null,
            loading: _newsController.isLoading && news == null,
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
  final String label;
  final String? title;
  final String? trailingValue;
  final bool loading;
  final VoidCallback onTap;
  final VoidCallback onViewAll;

  const _WebPulseRow({
    required this.icon,
    required this.label,
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
          height: 62,
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
                          alignment: Alignment.centerLeft,
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
                            Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              title?.trim().isNotEmpty == true
                                  ? title!
                                  : 'Apri',
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
                  tooltip: 'Vedi tutti',
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
