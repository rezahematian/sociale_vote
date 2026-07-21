import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/app/theme/spacing.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/features/social/application/feed_controller.dart';
import 'package:sociale_vote/features/social/presentation/pages/create_post_page.dart';
import 'package:sociale_vote/features/social/presentation/widgets/post_card.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';

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
    if (controller.isLoading) return;
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      if (controller.hasMoreFromSource) {
        controller.loadMorePosts();
      }
    }
  }

  Future<void> _createPost() async {
    final allowed = await AuthGuard.ensureCanPerformAction(
      context,
      ParticipationAction.createPost,
    );
    if (!allowed || !mounted) return;

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const CreatePostPage(),
      ),
    );

    if (!mounted || result != true) {
      return;
    }

    final userId = AppDI.instance.currentUserId;
    await context.read<FeedController>().refresh(userId: userId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Feed'),
      ),
      body: ColoredBox(
        color: theme.scaffoldBackgroundColor,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: _maxContentWidth,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Consumer<FeedController>(
                builder: (context, controller, _) {
                  final allPosts = controller.posts;
                  Widget content;

                  if (controller.isLoading && allPosts.isEmpty) {
                    content = const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (controller.hasError) {
                    content = _SocialErrorState(
                      message: controller.errorMessage ??
                          'Si è verificato un errore nel caricamento del feed.',
                      onRetry: () {
                        final userId = AppDI.instance.currentUserId;
                        return controller.loadFeed(userId: userId);
                      },
                    );
                  } else if (allPosts.isEmpty) {
                    content = RefreshIndicator(
                      onRefresh: () {
                        final userId = AppDI.instance.currentUserId;
                        return controller.refresh(userId: userId);
                      },
                      child: ListView(
                        controller: _scrollController,
                        padding: AppSpacing.page,
                        children: const [
                          _SocialEmptyState(),
                        ],
                      ),
                    );
                  } else {
                    content = RefreshIndicator(
                      onRefresh: () {
                        final userId = AppDI.instance.currentUserId;
                        return controller.refresh(userId: userId);
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.pagePadding,
                          AppSpacing.xxs,
                          AppSpacing.pagePadding,
                          AppSpacing.l,
                        ),
                        itemCount:
                            allPosts.length + (controller.isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= allPosts.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppSpacing.m,
                              ),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final post = allPosts[index];
                          return _PostCard(post: post);
                        },
                      ),
                    );
                  }

                  return Column(
                    children: [
                      _FeedToolbar(
                        selectedMode: controller.sortMode,
                        onSelected: controller.setSortMode,
                        onCreatePost: _createPost,
                      ),
                      Expanded(child: content),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedToolbar extends StatelessWidget {
  static const double _singleRowMinWidth = 520;

  final FeedSortMode selectedMode;
  final ValueChanged<FeedSortMode> onSelected;
  final Future<void> Function() onCreatePost;

  const _FeedToolbar({
    required this.selectedMode,
    required this.onSelected,
    required this.onCreatePost,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filters = Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        ChoiceChip(
          avatar: const Icon(
            Icons.local_fire_department_outlined,
            size: 18,
          ),
          label: const Text('Più caldi'),
          selected: selectedMode == FeedSortMode.hottest,
          onSelected: (_) => onSelected(FeedSortMode.hottest),
        ),
        ChoiceChip(
          avatar: const Icon(
            Icons.schedule_outlined,
            size: 18,
          ),
          label: const Text('Più recenti'),
          selected: selectedMode == FeedSortMode.latest,
          onSelected: (_) => onSelected(FeedSortMode.latest),
        ),
      ],
    );

    final createButton = FilledButton.icon(
      onPressed: () async {
        await onCreatePost();
      },
      icon: const Icon(Icons.add),
      label: const Text('Crea post'),
    );

    return Material(
      color: theme.scaffoldBackgroundColor,
      child: Padding(
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
                Align(
                  alignment: Alignment.centerRight,
                  child: createButton,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SocialEmptyState extends StatelessWidget {
  const _SocialEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 40,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
            Text(
              'Nessun post per quest’area',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Quando verranno pubblicati nuovi post per questo ambito geografico li vedrai qui.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 40,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              'Impossibile caricare il feed',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => onRetry(),
              icon: const Icon(Icons.refresh),
              label: const Text('Riprova'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends StatefulWidget {
  final Post post;

  const _PostCard({
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
