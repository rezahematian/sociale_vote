import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';
import 'package:sociale_vote/shared/widgets/engagement_bar.dart';
import 'package:sociale_vote/shared/ui/app_card.dart';

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

  /// Reazione corrente dell'utente (like / dislike / null).
  final ReactionType? userReaction;

  /// Callback già preparate dal controller.
  final VoidCallback? onFireTap;
  final VoidCallback? onIceTap;

  const PostCard({
    super.key,
    required this.post,
    this.fireCount = 0,
    this.iceCount = 0,
    this.userReaction,
    this.onFireTap,
    this.onIceTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    /// Wrapper sicurezza:
    /// - Verifica permesso via AuthGuard
    /// - Non esegue nulla se non autorizzato
    VoidCallback? _wrapReactCallback(VoidCallback? original) {
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

    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevated: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header placeholder (in futuro autore, avatar, data)
          Text(
            'Post',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          // Contenuto post (placeholder sicuro)
          Text(
            post.toString(),
            style: theme.textTheme.bodyMedium,
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // ===== FOOTER =====
          Row(
            children: [
              _CommentCountBadge(post: post),
              const Spacer(),
              EngagementBar(
                fireCount: fireCount,
                iceCount: iceCount,
                userReaction: userReaction,
                onFireTap: _wrapReactCallback(onFireTap),
                onIceTap: _wrapReactCallback(onIceTap),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Badge conteggio commenti (discussion/).
class _CommentCountBadge extends StatelessWidget {
  final Post post;

  const _CommentCountBadge({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder(
      future: AppDI.instance
          .getCommentsForTarget(TargetRef.post(post.id.value)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final comments = snapshot.data as List<dynamic>? ?? const [];
        final count = comments.length;

        if (count == 0) {
          return const SizedBox.shrink();
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.comment_outlined,
              size: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }
}