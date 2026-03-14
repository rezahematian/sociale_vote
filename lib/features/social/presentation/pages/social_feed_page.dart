import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/app/theme/colors.dart';
import 'package:sociale_vote/app/theme/radius.dart';
import 'package:sociale_vote/app/theme/spacing.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';
import 'package:sociale_vote/features/poll/application/poll_list_controller.dart';
import 'package:sociale_vote/features/poll/presentation/widgets/poll_card.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';
import 'package:sociale_vote/shared/ui/app_card.dart';
import 'package:sociale_vote/shared/ui/loading_indicator.dart';

import 'package:sociale_vote/features/social/application/feed_controller.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/features/social/presentation/pages/create_post_page.dart';
import 'package:sociale_vote/shared/widgets/engagement_bar.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Feed'),
      ),
      body: Container(
        color: theme.colorScheme.surface,
        child: Consumer<FeedController>(
          builder: (context, controller, _) {
            final allPosts = controller.posts;

            if (controller.isLoading && allPosts.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (controller.hasError) {
              return _SocialErrorState(
                message: controller.errorMessage ??
                    'Si è verificato un errore nel caricamento del feed.',
                onRetry: () {
                  final userId = AppDI.instance.currentUserId;
                  return controller.loadFeed(userId: userId);
                },
              );
            }

            if (allPosts.isEmpty) {
              return RefreshIndicator(
                onRefresh: () {
                  final userId = AppDI.instance.currentUserId;
                  return controller.refresh(userId: userId);
                },
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  children: const [
                    _SocialEmptyState(),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () {
                final userId = AppDI.instance.currentUserId;
                return controller.refresh(userId: userId);
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: allPosts.length,
                itemBuilder: (context, index) {
                  final Post post = allPosts[index];
                  return _PostCard(post: post);
                },
              ),
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final allowed = await AuthGuard.ensureCanPerformAction(
            context,
            ParticipationAction.createPost,
          );
          if (!allowed) return;

          final feedController = context.read<FeedController>();

          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => const CreatePostPage(),
            ),
          );

          if (result == true) {
            final userId = AppDI.instance.currentUserId;
            await feedController.refresh(userId: userId);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Create post'),
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
              color: theme.colorScheme.onSurface.withOpacity(0.6),
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
                color: theme.colorScheme.onSurface.withOpacity(0.7),
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
                color: theme.colorScheme.onSurface.withOpacity(0.7),
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
  bool _isFavorite = false;
  bool _favoriteLoading = false;
  String? _initializedPostId;

  Post get post => widget.post;

  @override
  void initState() {
    super.initState();
    _initializeFavorite();
  }

  @override
  void didUpdateWidget(covariant _PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.post.id.value != widget.post.id.value) {
      _isFavorite = false;
      _favoriteLoading = false;
      _initializedPostId = null;
      _initializeFavorite();
    }
  }

  void _initializeFavorite() {
    _initializedPostId = post.id.value;
    _initFavoriteStatus();
  }

  Future<void> _initFavoriteStatus() async {
    final userId = AppDI.instance.currentUserId;

    if (userId == null) {
      if (!mounted) return;
      setState(() {
        _isFavorite = false;
      });
      return;
    }

    try {
      final isFav = await AppDI.instance.isFavorite(
        userId: userId,
        target: TargetRef.post(post.id.value),
      );

      if (!mounted) return;
      setState(() {
        _isFavorite = isFav;
      });
    } catch (_) {}
  }

  Future<void> _onFavoritePressed() async {
    if (_favoriteLoading) return;

    final allowed = await AuthGuard.ensureCanPerformAction(
      context,
      ParticipationAction.react,
    );
    if (!allowed) return;

    final userId = AppDI.instance.currentUserId;
    if (userId == null) return;

    setState(() {
      _favoriteLoading = true;
    });

    try {
      final newState = await AppDI.instance.toggleFavorite(
        userId: userId,
        target: TargetRef.post(post.id.value),
      );

      if (!mounted) return;
      setState(() {
        _isFavorite = newState;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossibile aggiornare i preferiti')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _favoriteLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final feedController = context.watch<FeedController>();

    final fireCount = feedController.likeCountForPost(post);
    final iceCount = feedController.dislikeCountForPost(post);
    final userReaction = feedController.userReactionForPost(post);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () async {
          final controller = context.read<FeedController>();

          await Navigator.of(context).pushNamed(
            AppRouter.socialDetail,
            arguments: post.id.value,
          );

          final userId = AppDI.instance.currentUserId;
          await controller.refresh(userId: userId);

          if (!mounted) return;
          await _initFavoriteStatus();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      post.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: _isFavorite
                        ? 'Remove from favorites'
                        : 'Add to favorites',
                    onPressed: _favoriteLoading ? null : _onFavoritePressed,
                    icon: _favoriteLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _isFavorite ? Icons.star : Icons.star_border,
                            color: _isFavorite
                                ? theme.colorScheme.primary
                                : theme.iconTheme.color,
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    post.authorName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(post.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              EngagementBar(
                fireCount: fireCount,
                iceCount: iceCount,
                userReaction: userReaction,
                onFireTap: () async {
                  final allowed = await AuthGuard.ensureCanPerformAction(
                    context,
                    ParticipationAction.react,
                  );
                  if (!allowed) return;

                  final userId = AppDI.instance.currentUserId;
                  if (userId == null) return;

                  await feedController.toggleFireForPost(
                    userId: userId,
                    post: post,
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

                  await feedController.toggleIceForPost(
                    userId: userId,
                    post: post,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}