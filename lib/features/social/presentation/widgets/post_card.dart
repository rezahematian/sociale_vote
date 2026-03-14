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
class PostCard extends StatefulWidget {
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
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isFavorite = false;
  bool _favoriteLoading = false;
  String? _initializedPostId;

  Post get post => widget.post;

  @override
  void initState() {
    super.initState();
    _initializeFavorite();
  }

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.post.id.value != widget.post.id.value) {
      _isFavorite = false;
      _favoriteLoading = false;
      _initializedPostId = null;
      _initializeFavorite();
    }
  }

  void _initializeFavorite() {
    _initializedPostId = post.id.value;
    _initFavoriteStatus();
  }

  Future<void> _initFavoriteStatus() async {
    final userId = AppDI.instance.currentUserId;

    if (userId == null) {
      if (!mounted) return;
      setState(() {
        _isFavorite = false;
      });
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
      // Nessun blocco UI se fallisce il check favorite.
    }
  }

  Future<void> _onFavoritePressed() async {
    if (_favoriteLoading) return;

    final allowed = await AuthGuard.ensureCanPerformAction(
      context,
      ParticipationAction.react,
    );
    if (!allowed) return;

    final userId = AppDI.instance.currentUserId;
    if (userId == null) return;

    setState(() {
      _favoriteLoading = true;
    });

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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossibile aggiornare i preferiti')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _favoriteLoading = false;
      });
    }
  }

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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Post',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: _isFavorite
                    ? 'Remove from favorites'
                    : 'Add to favorites',
                onPressed: _favoriteLoading ? null : _onFavoritePressed,
                icon: _favoriteLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _isFavorite ? Icons.star : Icons.star_border,
                        color: _isFavorite
                            ? theme.colorScheme.primary
                            : theme.iconTheme.color,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            post.toString(),
            style: theme.textTheme.bodyMedium,
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),

          Row(
            children: [
              _CommentCountBadge(post: post),
              const Spacer(),
              EngagementBar(
                fireCount: widget.fireCount,
                iceCount: widget.iceCount,
                userReaction: widget.userReaction,
                onFireTap: _wrapReactCallback(widget.onFireTap),
                onIceTap: _wrapReactCallback(widget.onIceTap),
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
      future: AppDI.instance.getCommentsForTarget(TargetRef.post(post.id.value)),
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