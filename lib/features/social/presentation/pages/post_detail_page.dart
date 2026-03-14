import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/features/discussion/application/discussion_controller.dart';
import 'package:sociale_vote/features/discussion/presentation/widgets/comment_section.dart';
import 'package:sociale_vote/features/social/application/post_detail_controller.dart';
import 'package:sociale_vote/shared/widgets/engagement_bar.dart';

/// Pagina di dettaglio per un singolo post del social feed.
///
/// Riceve [postId] come String (vedi AppRouter.socialDetail).
class PostDetailPage extends StatelessWidget {
  final String postId;

  const PostDetailPage({
    super.key,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PostDetailController>(
      create: (_) => AppDI.instance.createPostDetailController(postId)..load(),
      child: const _PostDetailView(),
    );
  }
}

class _PostDetailView extends StatefulWidget {
  const _PostDetailView();

  @override
  State<_PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<_PostDetailView> {
  bool _isFavorite = false;
  bool _favoriteInitialized = false;
  bool _favoriteLoading = false;
  int _commentCount = 0;
  String? _initializedPostId;

  Future<void> _initFavoriteStatus(Post post) async {
    final userId = AppDI.instance.currentUserId;
    if (userId == null) {
      if (!mounted) return;
      setState(() {
        _isFavorite = false;
        _favoriteInitialized = true;
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
        _favoriteInitialized = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _favoriteInitialized = true;
      });
    }
  }

  Future<void> _loadCommentCount(Post post) async {
    try {
      final count = await AppDI.instance.getCommentCountForTarget(
        TargetRef.post(post.id.value),
      );
      if (!mounted) return;
      setState(() {
        _commentCount = count;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _commentCount = 0;
      });
    }
  }

  Future<void> _onFavoritePressed(Post post) async {
    if (_favoriteLoading) {
      return;
    }

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

  void _ensurePostInitialized(Post post) {
    if (_initializedPostId == post.id.value) {
      return;
    }

    _initializedPostId = post.id.value;
    _favoriteInitialized = false;
    _favoriteLoading = false;
    _isFavorite = false;
    _commentCount = 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (!_favoriteInitialized) {
        _initFavoriteStatus(post);
      }

      _loadCommentCount(post);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio post'),
      ),
      body: Consumer<PostDetailController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.hasError) {
            return _PostDetailError(
              message: controller.errorMessage ??
                  'Si è verificato un errore nel caricamento del post.',
            );
          }

          final Post? post = controller.post;
          if (post == null) {
            return const _PostDetailError(
              message: 'Post non trovato.',
            );
          }

          _ensurePostInitialized(post);

          final fireCount = controller.likeCount;
          final iceCount = controller.dislikeCount;
          final userReaction = controller.userReaction;

          return ChangeNotifierProvider<DiscussionController>(
            key: ValueKey('discussion-post-${post.id.value}'),
            create: (_) => AppDI.instance
                .createDiscussionController(
                  TargetRef.post(post.id.value),
                  onCommentsChanged: () {
                    _loadCommentCount(post);
                  },
                )
              ..loadComments(),
            child: SingleChildScrollView(
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
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: _favoriteLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                _isFavorite ? Icons.star : Icons.star_border,
                                color: _isFavorite
                                    ? theme.colorScheme.primary
                                    : theme.iconTheme.color,
                              ),
                        tooltip: _isFavorite
                            ? 'Remove from favorites'
                            : 'Add to favorites',
                        onPressed: _favoriteLoading
                            ? null
                            : () => _onFavoritePressed(post),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 18,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        post.authorName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.schedule,
                        size: 18,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(post.createdAt),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Text(
                    post.content,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.9),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 8),

                  EngagementBar(
                    fireCount: fireCount,
                    iceCount: iceCount,
                    commentCount: _commentCount,
                    userReaction: userReaction,
                    onFireTap: () async {
                      final allowed = await AuthGuard.ensureCanPerformAction(
                        context,
                        ParticipationAction.react,
                      );
                      if (!allowed) return;

                      final userId = AppDI.instance.currentUserId;
                      if (userId == null) return;

                      await context
                          .read<PostDetailController>()
                          .toggleFire(userId: userId);
                    },
                    onIceTap: () async {
                      final allowed = await AuthGuard.ensureCanPerformAction(
                        context,
                        ParticipationAction.react,
                      );
                      if (!allowed) return;

                      final userId = AppDI.instance.currentUserId;
                      if (userId == null) return;

                      await context
                          .read<PostDetailController>()
                          .toggleIce(userId: userId);
                    },
                  ),

                  const SizedBox(height: 32),

                  CommentSection(
                    userId: AppDI.instance.currentUserId ?? 'guest',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _PostDetailError extends StatelessWidget {
  final String message;

  const _PostDetailError({
    required this.message,
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
              'Errore',
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
          ],
        ),
      ),
    );
  }
}