import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';

import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';

import 'package:sociale_vote/features/social/application/feed_controller.dart';
import 'package:sociale_vote/shared/widgets/engagement_bar.dart';

class MyPostsPage extends StatelessWidget {
  const MyPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = AppDI.instance.currentUserId;

    // Blocco guest: per vedere i propri post devi essere loggato
    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Posts'),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'You must be logged in to view your posts.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return ChangeNotifierProvider<FeedController>(
      create: (_) {
        final controller = AppDI.instance.createFeedController();
        // v1: carichiamo il feed per lo scope corrente; il filtro "my posts"
        // viene applicato lato UI in questa pagina.
        controller.loadFeed(userId: currentUserId);
        return controller;
      },
      child: const _MyPostsView(),
    );
  }
}

class _MyPostsView extends StatelessWidget {
  const _MyPostsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<FeedController>();

    final String? currentUserId = AppDI.instance.currentUserId;

    // Tutti i post caricati dal FeedController
    final List<Post> allPosts = controller.posts;

    // Solo post creati dall'utente corrente (nuovi post con createdByUserId valorizzato)
    final List<Post> posts = currentUserId == null
        ? <Post>[]
        : allPosts
            .where((p) => p.createdByUserId == currentUserId)
            .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posts'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final userId = AppDI.instance.currentUserId;
          if (userId == null) return;
          await controller.loadFeed(userId: userId);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Posts created by you',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            if (controller.isLoading && posts.isEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ] else if (posts.isEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'You have not created any posts yet.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            ] else ...[
              ...posts.map(
                (post) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _MyPostCard(post: post),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MyPostCard extends StatelessWidget {
  final Post post;

  const _MyPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.read<FeedController>();

    final int fireCount = controller.likeCountForPost(post);
    final int iceCount = controller.dislikeCountForPost(post);
    final ReactionType? userReaction = controller.userReactionForPost(post);

    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(12),
      color: theme.colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Apri dettaglio post
          Navigator.pushNamed(
            context,
            AppRouter.socialDetail,
            arguments: post.id,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.4),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (post.content.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  post.content,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: theme.hintColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatPostCreatedAt(post.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 4),
              EngagementBar(
                fireCount: fireCount,
                iceCount: iceCount,
                userReaction: userReaction,
                onFireTap: () async {
                  final userId = AppDI.instance.currentUserId;
                  if (userId == null) return;
                  await controller.toggleFireForPost(
                    userId: userId,
                    post: post,
                  );
                },
                onIceTap: () async {
                  final userId = AppDI.instance.currentUserId;
                  if (userId == null) return;
                  await controller.toggleIceForPost(
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

  String _formatPostCreatedAt(DateTime dateTime) {
    final local = dateTime.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}