import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/shared/widgets/engagement_bar.dart';

/// Card visuale per un singolo post social.
///
/// v1:
/// - mostra un contenuto base del post (toString)
/// - mostra barra di engagement con 🔥 e ❄
///
/// La logica di chi è loggato / userId / ecc. resta nel controller.
/// Qui passiamo solo callback e contatori già calcolati.
class PostCard extends StatelessWidget {
  final Post post;

  /// Conteggio like (🔥) e dislike (❄) da mostrare sotto il post.
  final int fireCount;
  final int iceCount;

  /// Callback per tap su 🔥 e ❄.
  final VoidCallback? onFireTap;
  final VoidCallback? onIceTap;

  const PostCard({
    super.key,
    required this.post,
    this.fireCount = 0,
    this.iceCount = 0,
    this.onFireTap,
    this.onIceTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header super semplice v1: in futuro possiamo usare
            // autore, avatar, data, ecc.
            Text(
              'Post',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            // Contenuto post - placeholder sicuro che non rompe la compilazione.
            Text(
              post.toString(),
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // ===== FOOTER: COMMENT COUNT + ENGAGEMENT BAR =====
            Row(
              children: [
                _CommentCountBadge(post: post),
                const Spacer(),
                EngagementBar(
                  fireCount: fireCount,
                  iceCount: iceCount,
                  onFireTap: onFireTap,
                  onIceTap: onIceTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge che mostra il numero di commenti per questo post usando il dominio `discussion/`.
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
          // Durante il load non mostriamo nulla per non far saltare il layout.
          return const SizedBox.shrink();
        }

        if (snapshot.hasError) {
          // In caso di errore, nessun badge (silenzioso).
          return const SizedBox.shrink();
        }

        final comments = snapshot.data as List<dynamic>? ?? const [];
        final count = comments.length;

        if (count == 0) {
          // Nessun commento → nessun badge.
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