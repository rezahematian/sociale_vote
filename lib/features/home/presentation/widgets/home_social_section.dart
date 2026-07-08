import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';
import 'package:sociale_vote/features/home/presentation/widgets/home_post_preview_card.dart';
import 'package:sociale_vote/features/social/application/feed_controller.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';

class HomeSocialSection extends StatelessWidget {
  final String scopeShortLabel;

  const HomeSocialSection({
    super.key,
    required this.scopeShortLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<FeedController>();

    final posts = controller.posts;

    final sorted = List<Post>.from(posts);
    sorted.sort((a, b) {
      final heatA =
          controller.likeCountForPost(a) - controller.dislikeCountForPost(a);
      final heatB =
          controller.likeCountForPost(b) - controller.dislikeCountForPost(b);
      return heatB.compareTo(heatA);
    });

    final topPosts =
        sorted.length <= 3 ? sorted : sorted.take(3).toList(growable: false);

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withOpacity(0.08),
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.forum_rounded,
            size: 18,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.homeSocialTitle(scopeShortLabel),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                scopeShortLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    Widget content;

    if (controller.isLoading && topPosts.isEmpty) {
      content = Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.08),
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (controller.hasError) {
      content = _buildSocialPlaceholderCard(
        context,
        title: l10n.homeSocialErrorTitle,
        subtitle: l10n.homeSocialErrorSubtitle,
      );
    } else if (topPosts.isEmpty) {
      content = _buildSocialPlaceholderCard(
        context,
        title: l10n.homeSocialEmptyTitle,
        subtitle: l10n.homeSocialEmptySubtitle,
      );
    } else {
      content = Column(
        children: topPosts.map(
          (post) {
            final fire = controller.likeCountForPost(post);
            final ice = controller.dislikeCountForPost(post);
            final commentCount = controller.commentCountForPost(post);
            final previewPost = post.copyWith(commentCount: commentCount);
            final ReactionType? userReaction =
                controller.userReactionForPost(post);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: HomePostPreviewCard(
                post: previewPost,
                fireCount: fire,
                iceCount: ice,
                commentCount: commentCount,
                userReaction: userReaction,
                onReturnedFromDetail: () {
                  controller.refresh(
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
                  await controller.toggleFireForPost(
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
                  await controller.toggleIceForPost(
                    userId: userId,
                    post: post,
                  );
                },
              ),
            );
          },
        ).toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const SizedBox(height: 12),
        content,
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRouter.social,
              );
            },
            icon: const Icon(Icons.arrow_outward_rounded, size: 18),
            label: Text(l10n.homeSocialViewFeedButton),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialPlaceholderCard(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.08),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
