import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';
import 'package:sociale_vote/features/discovery/application/for_you_feed_controller.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_post_preview_card.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';

class HomeForYouSection extends StatelessWidget {
  final String scopeShortLabel;

  const HomeForYouSection({
    super.key,
    required this.scopeShortLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<ForYouFeedController>();

    final List<Post> posts = controller.posts;

    final header = Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.secondary.withOpacity(0.08),
          ),
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.star,
            size: 18,
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          l10n.homeForYouTitle(scopeShortLabel),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    Widget content;

    if (controller.isLoading && posts.isEmpty) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (controller.hasError) {
      content = Card(
        elevation: 0,
        margin: const EdgeInsets.only(top: 8),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(l10n.homeForYouError),
        ),
      );
    } else if (posts.isEmpty) {
      content = Card(
        elevation: 0,
        margin: const EdgeInsets.only(top: 8),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(l10n.homeForYouEmpty),
        ),
      );
    } else {
      final topPosts =
          posts.length <= 3 ? posts : posts.take(3).toList(growable: false);

      content = Column(
        children: topPosts.map((post) {
          final fire = controller.likeCountForPost(post);
          final ice = controller.dislikeCountForPost(post);
          final commentCount = controller.commentCountForPost(post);
          final previewPost = post.copyWith(commentCount: commentCount);
          final ReactionType? userReaction =
              controller.userReactionForPost(post);

          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: HomePostPreviewCard(
              post: previewPost,
              fireCount: fire,
              iceCount: ice,
              userReaction: userReaction,
              onReturnedFromDetail: () {
                controller.load(
                  userId: AppDI.instance.currentUserId,
                );
              },
              onFireTap: () async {
                final allowed = await AuthGuard.ensureCanPerformAction(
                  context,
                  ParticipationAction.react,
                );
                if (!allowed) return;

                final userId = AppDI.instance.currentUserId!;
                controller.toggleFireForPost(
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

                final userId = AppDI.instance.currentUserId!;
                controller.toggleIceForPost(
                  userId: userId,
                  post: post,
                );
              },
            ),
          );
        }).toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const SizedBox(height: 8),
        content,
      ],
    );
  }
}