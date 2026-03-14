import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';
import 'package:sociale_vote/shared/widgets/engagement_bar.dart';

class HomePostPreviewCard extends StatefulWidget {
  final Post post;

  final int fireCount;
  final int iceCount;
  final int commentCount;
  final ReactionType? userReaction;

  final VoidCallback? onFireTap;
  final VoidCallback? onIceTap;
  final VoidCallback? onReturnedFromDetail;

  const HomePostPreviewCard({
    super.key,
    required this.post,
    this.fireCount = 0,
    this.iceCount = 0,
    this.commentCount = 0,
    this.userReaction,
    this.onFireTap,
    this.onIceTap,
    this.onReturnedFromDetail,
  });

  @override
  State<HomePostPreviewCard> createState() => _HomePostPreviewCardState();
}

class _HomePostPreviewCardState extends State<HomePostPreviewCard> {
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
  void didUpdateWidget(covariant HomePostPreviewCard oldWidget) {
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
    } catch (_) {}
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

  Future<void> _openPostDetail() async {
    await Navigator.pushNamed(
      context,
      AppRouter.socialDetail,
      arguments: post.id.value,
    );

    widget.onReturnedFromDetail?.call();
    await _initFavoriteStatus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(12),
      color: theme.colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _openPostDetail,
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      post.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
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
              EngagementBar(
                fireCount: widget.fireCount,
                iceCount: widget.iceCount,
                commentCount: widget.commentCount,
                userReaction: widget.userReaction,
                onFireTap: widget.onFireTap,
                onIceTap: widget.onIceTap,
                onCommentTap: _openPostDetail,
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