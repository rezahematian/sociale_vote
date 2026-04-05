import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';
import 'package:sociale_vote/shared/ui/app_card.dart';
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
      _initializeFavorite();
    }
  }

  void _initializeFavorite() {
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
    final title = post.title.trim();
    final content = post.content.trim();
    final hasTitle = title.isNotEmpty;
    final hasContent = content.isNotEmpty;

    /// Wrapper sicurezza:
    /// - Verifica permesso via AuthGuard
    /// - Non esegue nulla se non autorizzato
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

    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevated: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildDiscussionChip(theme),
                    _buildAuthorChip(theme),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildFavoriteButton(theme),
            ],
          ),
          if (hasTitle || hasContent) const SizedBox(height: 12),
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
                color: theme.colorScheme.onSurface.withValues(alpha: 0.78),
                height: 1.42,
              ),
              maxLines: hasTitle ? 3 : 4,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              _formatDateTime(post.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _PostEngagementRow(
            post: post,
            fireCount: widget.fireCount,
            iceCount: widget.iceCount,
            userReaction: widget.userReaction,
            onFireTap: wrapReactCallback(widget.onFireTap),
            onIceTap: wrapReactCallback(widget.onIceTap),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscussionChip(ThemeData theme) {
    return _buildHeaderChip(
      theme: theme,
      icon: Icons.mode_comment_outlined,
      label: 'Discussion',
      backgroundColor: const Color(0xFFEFF4FF),
      foregroundColor: const Color(0xFF316BFF),
      borderColor: const Color(0xFFDCE7FF),
    );
  }

  Widget _buildAuthorChip(ThemeData theme) {
    return _buildHeaderChip(
      theme: theme,
      icon: Icons.person_outline_rounded,
      label: post.authorName,
      backgroundColor: const Color(0xFFF4F7FB),
      foregroundColor: const Color(0xFF667085),
      borderColor: const Color(0xFFE2E8F0),
    );
  }

  Widget _buildFavoriteButton(ThemeData theme) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        tooltip: _isFavorite
            ? 'Remove from favorites'
            : 'Add to favorites',
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        onPressed: _favoriteLoading ? null : _onFavoritePressed,
        icon: _favoriteLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                _isFavorite ? Icons.star : Icons.star_border,
                size: 20,
                color: _isFavorite
                    ? theme.colorScheme.primary
                    : theme.iconTheme.color,
              ),
      ),
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
  final int fireCount;
  final int iceCount;
  final ReactionType? userReaction;
  final VoidCallback? onFireTap;
  final VoidCallback? onIceTap;

  const _PostEngagementRow({
    required this.post,
    required this.fireCount,
    required this.iceCount,
    required this.userReaction,
    required this.onFireTap,
    required this.onIceTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AppDI.instance.getCommentsForTarget(TargetRef.post(post.id.value)),
      builder: (context, snapshot) {
        final comments = snapshot.data as List<dynamic>? ?? const [];
        final commentCount = snapshot.hasError ? 0 : comments.length;

        return Align(
          alignment: Alignment.centerLeft,
          child: EngagementBar(
            fireCount: fireCount,
            iceCount: iceCount,
            commentCount: commentCount,
            userReaction: userReaction,
            onFireTap: onFireTap,
            onIceTap: onIceTap,
          ),
        );
      },
    );
  }
}