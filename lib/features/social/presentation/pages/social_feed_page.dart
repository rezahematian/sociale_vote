import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/features/social/application/feed_controller.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/shared/widgets/engagement_bar.dart';

class SocialFeedPage extends StatelessWidget {
  const SocialFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FeedController>(
      create: (_) => AppDI.instance.createFeedController()..loadFeed(),
      child: const _SocialFeedView(),
    );
  }
}

class _SocialFeedView extends StatelessWidget {
  const _SocialFeedView();

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
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (controller.hasError) {
              return _SocialErrorState(
                message: controller.errorMessage ??
                    'Si è verificato un errore nel caricamento del feed.',
                onRetry: controller.loadFeed,
              );
            }

            if (controller.posts.isEmpty) {
              return const _SocialEmptyState();
            }

            return RefreshIndicator(
              onRefresh: controller.refresh,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.posts.length,
                itemBuilder: (context, index) {
                  final Post post = controller.posts[index];
                  return _PostCard(post: post);
                },
              ),
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

class _PostCard extends StatelessWidget {
  final Post post;

  const _PostCard({
    required this.post,
  });

  String _formatDate(DateTime date) {
    // v1: formattazione molto semplice.
    // In futuro possiamo usare DateFormat con localization.
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final feedController = context.watch<FeedController>();

    // TODO: quando agganciamo la vera auth, prendiamo lo userId dalla sessione.
    const String userId = 'demo-user';

    final fireCount = feedController.likeCountForPost(post);
    final iceCount = feedController.dislikeCountForPost(post);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRouter.socialDetail,
            arguments: post.id.value,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titolo
              Text(
                post.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              // Autore + data
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
              // Contenuto (snippet)
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

              // Barra di engagement 🔥 / ❄
              EngagementBar(
                fireCount: fireCount,
                iceCount: iceCount,
                onFireTap: () {
                  feedController.toggleFireForPost(
                    userId: userId,
                    post: post,
                  );
                },
                onIceTap: () {
                  feedController.toggleIceForPost(
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