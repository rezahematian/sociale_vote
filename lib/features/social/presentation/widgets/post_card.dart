import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';
import 'package:sociale_vote/shared/widgets/engagement_bar.dart';

/// Card visuale per un singolo post social.
///
/// Responsabilità:
/// - mostra contenuto base del post
/// - mostra barra engagement (🔥 / ❄)
/// - mostra conteggio commenti
/// - garantisce che le azioni passino SEMPRE da AuthGuard
///
/// NOTA:
/// Questo widget NON deve mai gestire direttamente userId.
/// I controller devono già passare callback corrette.
class PostCard extends StatelessWidget {
  final Post post;

  final int fireCount;
  final int iceCount;
  final int? commentCount;

  /// Reazione corrente dell'utente (like / dislike / null).
  final ReactionType? userReaction;

  /// Callback già preparate dal controller.
  final VoidCallback? onFireTap;
  final VoidCallback? onIceTap;
  final VoidCallback? onCommentTap;

  const PostCard({
    super.key,
    required this.post,
    this.fireCount = 0,
    this.iceCount = 0,
    this.commentCount,
    this.userReaction,
    this.onFireTap,
    this.onIceTap,
    this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = post.title.trim();
    final content = post.content.trim();
    final authorName =
        post.authorName.trim().isNotEmpty ? post.authorName.trim() : 'Author';
    final hasTitle = title.isNotEmpty;
    final hasContent = content.isNotEmpty;

    final Color cardTopColor =
        theme.brightness == Brightness.dark
            ? const Color(0xFF18202B)
            : const Color(0xFFFCFDFE);
    final Color cardBottomColor =
        theme.brightness == Brightness.dark
            ? const Color(0xFF121A24)
            : const Color(0xFFF0F4F9);
    final Color cardBorderColor =
        theme.brightness == Brightness.dark
            ? const Color(0xFF2C3948)
            : const Color(0xFFD7DFEA);

    VoidCallback? wrapReactCallback(VoidCallback? original) {
      if (original == null) return null;

      return () async {
        final allowed = await AuthGuard.ensureCanPerformAction(
          context,
          ParticipationAction.react,
        );

        if (!allowed) return;

        original();
      };
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF94A3B8).withValues(alpha: 0.10),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: cardBorderColor,
              width: 1.2,
            ),
            gradient: LinearGradient(
              colors: [
                cardTopColor,
                cardBottomColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onCommentTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _buildDiscussionIconChip(),
                      _buildAuthorChip(theme, authorName),
                    ],
                  ),
                  if (hasTitle || hasContent) const SizedBox(height: 14),
                  if (hasTitle) ...[
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.18,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasContent) const SizedBox(height: 8),
                  ],
                  if (hasContent)
                    Text(
                      content,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.78,
                        ),
                        height: 1.42,
                      ),
                      maxLines: hasTitle ? 3 : 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (hasTitle || hasContent) const SizedBox(height: 10),
                  Text(
                    _formatDateTime(post.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _PostEngagementRow(
                    post: post,
                    commentCount: commentCount,
                    fireCount: fireCount,
                    iceCount: iceCount,
                    userReaction: userReaction,
                    onFireTap: wrapReactCallback(onFireTap),
                    onIceTap: wrapReactCallback(onIceTap),
                    onCommentTap: onCommentTap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiscussionIconChip() {
    const backgroundColor = Color(0xFFEFF4FF);
    const foregroundColor = Color(0xFF316BFF);
    const borderColor = Color(0xFFDCE7FF);

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: const Icon(
        Icons.mode_comment_outlined,
        size: 16,
        color: foregroundColor,
      ),
    );
  }

  Widget _buildAuthorChip(ThemeData theme, String authorName) {
    return _buildHeaderChip(
      theme: theme,
      icon: Icons.person_outline_rounded,
      label: authorName,
      backgroundColor:
          theme.brightness == Brightness.dark
              ? const Color(0xFF1C2836)
              : const Color(0xFFEFF4FB),
      foregroundColor: const Color(0xFF667085),
      borderColor:
          theme.brightness == Brightness.dark
              ? const Color(0xFF314255)
              : const Color(0xFFD9E3EF),
    );
  }

  Widget _buildHeaderChip({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
    required Color borderColor,
  }) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: foregroundColor,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                fontSize: 12,
                height: 1,
                fontWeight: FontWeight.w600,
                color: foregroundColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();

    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }
}

class _PostEngagementRow extends StatelessWidget {
  final Post post;
  final int? commentCount;
  final int fireCount;
  final int iceCount;
  final ReactionType? userReaction;
  final VoidCallback? onFireTap;
  final VoidCallback? onIceTap;
  final VoidCallback? onCommentTap;

  const _PostEngagementRow({
    required this.post,
    required this.commentCount,
    required this.fireCount,
    required this.iceCount,
    required this.userReaction,
    required this.onFireTap,
    required this.onIceTap,
    required this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    if (commentCount != null) {
      return _buildBar(commentCount!);
    }

    return FutureBuilder(
      future: AppDI.instance.getCommentsForTarget(TargetRef.post(post.id.value)),
      builder: (context, snapshot) {
        final comments = snapshot.data as List<dynamic>? ?? const [];
        final resolvedCommentCount = snapshot.hasError ? 0 : comments.length;
        return _buildBar(resolvedCommentCount);
      },
    );
  }

  Widget _buildBar(int resolvedCommentCount) {
    return Align(
      alignment: Alignment.centerLeft,
      child: EngagementBar(
        fireCount: fireCount,
        iceCount: iceCount,
        commentCount: resolvedCommentCount,
        userReaction: userReaction,
        onFireTap: onFireTap,
        onIceTap: onIceTap,
        onCommentTap: onCommentTap,
      ),
    );
  }
}