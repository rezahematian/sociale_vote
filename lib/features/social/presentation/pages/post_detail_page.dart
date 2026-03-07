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
      create: (_) =>
          AppDI.instance.createPostDetailController(postId)..load(),
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

  Future<void> _initFavoriteStatus(Post post) async {
    final userId = AppDI.instance.currentUserId;
    if (userId == null) {
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
    } catch (_) {
      // v1: nessun handling specifico per errori sui preferiti in-memory.
    }
  }

  Future<void> _onFavoritePressed(Post post) async {
    final allowed = await AuthGuard.ensureCanPerformAction(
      context,
      ParticipationAction.react,
    );
    if (!allowed) return;

    final userId = AppDI.instance.currentUserId;
    if (userId == null) return;

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
      // v1: silenzioso; in futuro si può mostrare SnackBar.
    }
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
            // Per sicurezza: se non c'è post ma non è settato hasError.
            return const _PostDetailError(
              message: 'Post non trovato.',
            );
          }

          // Inizializza stato preferito solo una volta se utente loggato.
          if (AppDI.instance.currentUserId != null &&
              !_favoriteInitialized) {
            _favoriteInitialized = true;
            _initFavoriteStatus(post);
          }

          final fireCount = controller.likeCount;
          final iceCount = controller.dislikeCount;
          final userReaction = controller.userReaction;

          return ChangeNotifierProvider<DiscussionController>(
            create: (_) => AppDI.instance
                .createDiscussionController(
                  TargetRef.post(post.id.value),
                )
              ..loadComments(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titolo + ⭐ preferiti
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          post.title,
                          style:
                              theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isFavorite
                              ? Icons.star
                              : Icons.star_border,
                          color: _isFavorite
                              ? theme.colorScheme.primary
                              : theme.iconTheme.color,
                        ),
                        tooltip: _isFavorite
                            ? 'Remove from favorites'
                            : 'Add to favorites',
                        onPressed: () => _onFavoritePressed(post),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Autore + data
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 18,
                        color: theme.colorScheme.onSurface
                            .withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        post.authorName,
                        style:
                            theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.schedule,
                        size: 18,
                        color: theme.colorScheme.onSurface
                            .withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(post.createdAt),
                        style:
                            theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Contenuto
                  Text(
                    post.content,
                    style:
                        theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withOpacity(0.9),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 8),

                  // ===== ENGAGEMENT BAR (🔥 / ❄) =====
                  EngagementBar(
                    fireCount: fireCount,
                    iceCount: iceCount,
                    userReaction: userReaction,
                    onFireTap: () async {
                      final allowed =
                          await AuthGuard.ensureCanPerformAction(
                        context,
                        ParticipationAction.react,
                      );
                      if (!allowed) return;

                      final userId =
                          AppDI.instance.currentUserId;
                      if (userId == null) return;

                      await context
                          .read<PostDetailController>()
                          .toggleFire(userId: userId);
                    },
                    onIceTap: () async {
                      final allowed =
                          await AuthGuard.ensureCanPerformAction(
                        context,
                        ParticipationAction.react,
                      );
                      if (!allowed) return;

                      final userId =
                          AppDI.instance.currentUserId;
                      if (userId == null) return;

                      await context
                          .read<PostDetailController>()
                          .toggleIce(userId: userId);
                    },
                  ),

                  const SizedBox(height: 32),

                  // ===== COMMENT SECTION (DISCUSSION UNIFICATO) =====
                  CommentSection(
                    userId: AppDI.instance.currentUserId ??
                        'guest', // solo per UI, non per permessi
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
                color: theme.colorScheme.onSurface
                    .withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}