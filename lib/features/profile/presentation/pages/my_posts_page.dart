import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';

import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';

import 'package:sociale_vote/features/social/application/feed_controller.dart';
import 'package:sociale_vote/shared/widgets/engagement_bar.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/app/localization/de_fallback.dart';

class MyPostsPage extends StatelessWidget {
  const MyPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = AppDI.instance.currentUserId;
    final l10n = AppLocalizations.of(context)!;
    final isItalian = Localizations.localeOf(context).languageCode == 'it';

    // Blocco guest: per vedere i propri post devi essere loggato
    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.profileMyPostsTitle),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              isItalian
                  ? 'Devi accedere per vedere i tuoi post.'
                  : deOrEnglish(context,
                      english: 'You must be logged in to view your posts.',
                      german:
                          'Du musst angemeldet sein, um deine Beiträge anzuzeigen.'),
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
    final l10n = AppLocalizations.of(context)!;
    final isItalian = Localizations.localeOf(context).languageCode == 'it';
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
        title: Text(l10n.profileMyPostsTitle),
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
              isItalian
                  ? 'Post creati da te'
                  : deOrEnglish(context,
                      english: 'Posts created by you',
                      german: 'Von dir erstellte Beiträge'),
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
                    isItalian
                        ? 'Non hai ancora creato post.'
                        : deOrEnglish(context,
                            english: 'You have not created any posts yet.',
                            german: 'Du hast noch keine Beiträge erstellt.'),
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
              color: theme.dividerColor.withValues(alpha: 0.4),
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
                    _formatPostCreatedAt(context, post.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color
                          ?.withValues(alpha: 0.7),
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

  String _formatPostCreatedAt(BuildContext context, DateTime dateTime) {
    final local = dateTime.toLocal();
    final material = MaterialLocalizations.of(context);
    final date = material.formatMediumDate(local);
    final time = material.formatTimeOfDay(
      TimeOfDay.fromDateTime(local),
      alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
    );
    return '$date $time';
  }
}
