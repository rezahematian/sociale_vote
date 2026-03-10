import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';
import 'package:sociale_vote/shared/widgets/engagement_bar.dart';

class HomePostPreviewCard extends StatelessWidget {
  final Post post;

  final int fireCount;
  final int iceCount;
  final ReactionType? userReaction;

  final VoidCallback? onFireTap;
  final VoidCallback? onIceTap;
  final VoidCallback? onReturnedFromDetail;

  const HomePostPreviewCard({
    super.key,
    required this.post,
    this.fireCount = 0,
    this.iceCount = 0,
    this.userReaction,
    this.onFireTap,
    this.onIceTap,
    this.onReturnedFromDetail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Future<void> openPostDetail() async {
      await Navigator.pushNamed(
        context,
        AppRouter.socialDetail,
        arguments: post.id.value,
      );

      onReturnedFromDetail?.call();
    }

    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(12),
      color: theme.colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: openPostDetail,
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
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              FutureBuilder(
                future: AppDI.instance.getCommentsForTarget(
                  TargetRef.post(post.id.value),
                ),
                builder: (context, snapshot) {
                  final comments = snapshot.data as List<dynamic>? ?? const [];
                  final commentCount = snapshot.hasError ? 0 : comments.length;

                  return EngagementBar(
                    fireCount: fireCount,
                    iceCount: iceCount,
                    commentCount: commentCount,
                    userReaction: userReaction,
                    onFireTap: onFireTap,
                    onIceTap: onIceTap,
                    onCommentTap: openPostDetail,
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