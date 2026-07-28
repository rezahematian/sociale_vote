import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/app/theme/radius.dart';
import 'package:sociale_vote/app/theme/spacing.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/features/social/application/feed_controller.dart';
import 'package:sociale_vote/features/social/presentation/pages/create_post_page.dart';
import 'package:sociale_vote/features/social/presentation/widgets/post_card.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';
import 'package:sociale_vote/shared/ui/app_card.dart';
import 'package:sociale_vote/shared/ui/loading_indicator.dart';

class SocialFeedPage extends StatelessWidget {
  const SocialFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FeedController>(
      create: (_) {
        final controller = AppDI.instance.createFeedController();
        final userId = AppDI.instance.currentUserId;
        controller.loadFeed(userId: userId);
        return controller;
      },
      child: const _SocialFeedView(),
    );
  }
}

class _SocialFeedView extends StatefulWidget {
  const _SocialFeedView();

  @override
  State<_SocialFeedView> createState() => _SocialFeedViewState();
}

class _SocialFeedViewState extends State<_SocialFeedView> {
  static const double _maxContentWidth = 1120;

  final ScrollController _scrollController = ScrollController();
  bool _isOpeningCreatePost = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final controller = context.read<FeedController>();
    if (controller.isLoading || !_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200 &&
        controller.hasMoreFromSource) {
      controller.loadMorePosts();
    }
  }

  Future<void> _refreshFeed(FeedController controller) {
    final userId = AppDI.instance.currentUserId;
    return controller.refresh(userId: userId);
  }

  Future<void> _retryFeed(FeedController controller) {
    final userId = AppDI.instance.currentUserId;
    return controller.loadFeed(userId: userId);
  }

  Future<void> _createPost() async {
    if (_isOpeningCreatePost) {
      return;
    }

    setState(() {
      _isOpeningCreatePost = true;
    });

    try {
      final allowed = await AuthGuard.ensureCanPerformAction(
        context,
        ParticipationAction.createPost,
      );
      if (!allowed || !mounted) {
        return;
      }

      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => const CreatePostPage(),
        ),
      );

      if (!mounted || result != true) {
        return;
      }

      await _refreshFeed(context.read<FeedController>());
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningCreatePost = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final pageBackground = Color.alphaBlend(
      colorScheme.primary.withValues(alpha: isDark ? 0.035 : 0.012),
      theme.scaffoldBackgroundColor,
    );

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.socialFeedTitle),
      ),
      body: ColoredBox(
        color: pageBackground,
        child: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: _maxContentWidth,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Consumer<FeedController>(
                  builder: (context, controller, _) {
                    final posts = controller.posts;

                    return Column(
                      children: [
                        _FeedToolbar(
                          selectedMode: controller.sortMode,
                          onSelected: controller.setSortMode,
                          onCreatePost: _createPost,
                          isCreatingPost: _isOpeningCreatePost,
                        ),
                        Expanded(
                          child: _buildFeedContent(
                            context,
                            controller: controller,
                            posts: posts,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedContent(
    BuildContext context, {
    required FeedController controller,
    required List<Post> posts,
  }) {
    final l10n = AppLocalizations.of(context)!;

    if (controller.isLoading && posts.isEmpty) {
      return const LoadingIndicator(
        padding: EdgeInsets.only(top: AppSpacing.l),
      );
    }

    if (controller.hasError) {
      return _FeedStateViewport(
        onRefresh: () => _retryFeed(controller),
        child: _SocialErrorState(
          message: l10n.homeSocialErrorSubtitle,
          onRetry: () => _retryFeed(controller),
        ),
      );
    }

    if (posts.isEmpty) {
      return _FeedStateViewport(
        onRefresh: () => _refreshFeed(controller),
        child: const _SocialEmptyState(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _refreshFeed(controller),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePadding,
          AppSpacing.xxs,
          AppSpacing.pagePadding,
          AppSpacing.l,
        ),
        itemCount: posts.length + (controller.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= posts.length) {
            return const LoadingIndicator.inline(
              padding: EdgeInsets.symmetric(
                vertical: AppSpacing.s,
              ),
            );
          }

          final post = posts[index];
          return _PostCard(
            key: ValueKey(post.id.value),
            post: post,
          );
        },
      ),
    );
  }
}

class _FeedToolbar extends StatelessWidget {
  static const double _singleRowMinWidth = 620;

  final FeedSortMode selectedMode;
  final ValueChanged<FeedSortMode> onSelected;
  final Future<void> Function() onCreatePost;
  final bool isCreatingPost;

  const _FeedToolbar({
    required this.selectedMode,
    required this.onSelected,
    required this.onCreatePost,
    required this.isCreatingPost,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final filters = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FeedSortButton(
            icon: Icons.local_fire_department_outlined,
            label: l10n.searchSortHottest,
            selected: selectedMode == FeedSortMode.hottest,
            onTap: () => onSelected(FeedSortMode.hottest),
          ),
          const SizedBox(width: AppSpacing.xs),
          _FeedSortButton(
            icon: Icons.schedule_outlined,
            label: l10n.searchSortLatest,
            selected: selectedMode == FeedSortMode.latest,
            onTap: () => onSelected(FeedSortMode.latest),
          ),
        ],
      ),
    );

    final createButton = FilledButton.icon(
      onPressed: isCreatingPost
          ? null
          : () async {
              await onCreatePost();
            },
      icon: isCreatingPost
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.add, size: 18),
      label: Text(l10n.socialFeedCreatePostButton),
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.xs,
        ),
        textStyle: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.buttonRadius,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.s,
        AppSpacing.pagePadding,
        AppSpacing.xs,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= _singleRowMinWidth) {
            return Row(
              children: [
                Expanded(child: filters),
                const SizedBox(width: AppSpacing.m),
                createButton,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              filters,
              const SizedBox(height: AppSpacing.xs),
              createButton,
            ],
          );
        },
      ),
    );
  }
}

class _FeedSortButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FeedSortButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = selected
        ? colorScheme.primary.withValues(alpha: 0.12)
        : colorScheme.surface.withValues(alpha: isDark ? 0.28 : 0.82);
    final borderColor = selected
        ? colorScheme.primary
        : colorScheme.outline.withValues(alpha: isDark ? 0.24 : 0.14);
    final foregroundColor = selected
        ? colorScheme.primary
        : colorScheme.onSurface.withValues(alpha: 0.82);

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.buttonRadius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 132,
              minHeight: 44,
            ),
            child: Ink(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: AppRadius.buttonRadius,
                border: Border.all(
                  color: borderColor,
                  width: selected ? 1.2 : 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: foregroundColor,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: foregroundColor,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w600,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedStateViewport extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const _FeedStateViewport({
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePadding,
              AppSpacing.xs,
              AppSpacing.pagePadding,
              AppSpacing.l,
            ),
            sliver: SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: SizedBox(
                    width: double.infinity,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialEmptyState extends StatelessWidget {
  const _SocialEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.forum_outlined,
            size: 40,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            l10n.homeSocialEmptyTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.homeSocialEmptySubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SocialErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _SocialErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 40,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            l10n.homeSocialErrorTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.m),
          FilledButton.icon(
            onPressed: () async {
              await onRetry();
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(l10n.searchRetryButton),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 44),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.buttonRadius,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatefulWidget {
  final Post post;

  const _PostCard({
    super.key,
    required this.post,
  });

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _isOpeningDetail = false;

  Post get post => widget.post;

  Future<void> _openDetailAndRefresh() async {
    if (_isOpeningDetail) {
      return;
    }

    setState(() {
      _isOpeningDetail = true;
    });

    try {
      await Navigator.of(context).pushNamed(
        AppRouter.socialDetail,
        arguments: post.id.value,
      );

      if (!mounted) {
        return;
      }

      final userId = AppDI.instance.currentUserId;
      await context.read<FeedController>().refresh(userId: userId);
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningDetail = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedController = context.watch<FeedController>();

    final fireCount = feedController.likeCountForPost(post);
    final iceCount = feedController.dislikeCountForPost(post);
    final commentCount = feedController.commentCountForPost(post);
    final userReaction = feedController.userReactionForPost(post);

    return AbsorbPointer(
      absorbing: _isOpeningDetail,
      child: PostCard(
        post: post,
        fireCount: fireCount,
        iceCount: iceCount,
        commentCount: commentCount,
        userReaction: userReaction,
        onFireTap: () async {
          final userId = AppDI.instance.currentUserId;
          if (userId == null) return;

          await feedController.toggleFireForPost(
            userId: userId,
            post: post,
          );
        },
        onIceTap: () async {
          final userId = AppDI.instance.currentUserId;
          if (userId == null) return;

          await feedController.toggleIceForPost(
            userId: userId,
            post: post,
          );
        },
        onCommentTap: _openDetailAndRefresh,
      ),
    );
  }
}
