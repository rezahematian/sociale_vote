import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/shared/data/countries.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';
import 'package:sociale_vote/shared/widgets/engagement_bar.dart';
import 'package:sociale_vote/shared/widgets/user_identity_mark.dart';

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
    final isDark = theme.brightness == Brightness.dark;

    final Color cardTopColor =
        isDark ? const Color(0xFF182230) : const Color(0xFFFCFDFE);
    final Color cardBottomColor =
        isDark ? const Color(0xFF121B27) : const Color(0xFFF1F5FA);
    final Color cardBorderColor =
        isDark ? const Color(0xFF2E3B4B) : const Color(0xFFD7DFEA);

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
                      _buildDiscussionIconChip(theme),
                      _buildAuthorChip(theme, authorName),
                      _buildLocationChip(theme),
                    ],
                  ),
                  if (hasTitle || hasContent) const SizedBox(height: 12),
                  if (hasTitle) ...[
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.16,
                        letterSpacing: -0.2,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasContent) const SizedBox(height: 9),
                  ],
                  if (hasContent)
                    Text(
                      content,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.78,
                        ),
                        height: 1.46,
                      ),
                      maxLines: hasTitle ? 3 : 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (hasTitle || hasContent) const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: _PostEngagementRow(
                          post: post,
                          commentCount: commentCount,
                          fireCount: fireCount,
                          iceCount: iceCount,
                          userReaction: userReaction,
                          onFireTap: wrapReactCallback(onFireTap),
                          onIceTap: wrapReactCallback(onIceTap),
                          onCommentTap: onCommentTap,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: _buildDateRow(theme),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiscussionIconChip(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor =
        isDark ? const Color(0xFF1A2D4A) : const Color(0xFFEFF4FF);
    final foregroundColor =
        isDark ? const Color(0xFF9FC0FF) : const Color(0xFF316BFF);
    final borderColor =
        isDark ? const Color(0xFF314C72) : const Color(0xFFDCE7FF);

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
      child: Icon(
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
      backgroundColor: theme.brightness == Brightness.dark
          ? const Color(0xFF1C2836)
          : const Color(0xFFEFF4FB),
      foregroundColor: theme.brightness == Brightness.dark
          ? const Color(0xFFB7C4D6)
          : const Color(0xFF667085),
      borderColor: theme.brightness == Brightness.dark
          ? const Color(0xFF314255)
          : const Color(0xFFD9E3EF),
      identityMark: UserIdentityMark.shouldShow(
        actorType: post.authorActorType,
        verificationLevel: post.authorVerificationLevel,
        institutionLevel: post.authorInstitutionLevel,
      )
          ? UserIdentityMark(
              actorType: post.authorActorType,
              verificationLevel: post.authorVerificationLevel,
              institutionLevel: post.authorInstitutionLevel,
              size: 14,
            )
          : null,
    );
  }

  Widget _buildLocationChip(ThemeData theme) {
    final countryCode = post.countryCode?.trim().isNotEmpty == true
        ? post.countryCode!.trim()
        : post.contentLocation?.countryCode?.trim();
    final cityName = post.contentLocation?.cityName?.trim().isNotEmpty == true
        ? post.contentLocation!.cityName!.trim()
        : post.cityId?.trim();
    final countryName = countryCode == null || countryCode.isEmpty
        ? null
        : Countries.findByCode(countryCode)?.name ?? countryCode;

    final String label;
    if (cityName != null && cityName.isNotEmpty) {
      label = countryName == null || countryName.isEmpty
          ? cityName
          : '$cityName, $countryName';
    } else if (countryName != null && countryName.isNotEmpty) {
      label = countryName;
    } else {
      label = 'Globale';
    }

    return _buildHeaderChip(
      theme: theme,
      icon: Icons.location_on_outlined,
      label: label,
      backgroundColor: theme.brightness == Brightness.dark
          ? const Color(0xFF182B27)
          : const Color(0xFFEDF8F4),
      foregroundColor: theme.brightness == Brightness.dark
          ? const Color(0xFF9AD8C3)
          : const Color(0xFF287A62),
      borderColor: theme.brightness == Brightness.dark
          ? const Color(0xFF2E5148)
          : const Color(0xFFCFE9DF),
    );
  }

  Widget _buildHeaderChip({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
    required Color borderColor,
    Widget? identityMark,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
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
          if (identityMark != null) identityMark,
        ],
      ),
    );
  }

  Widget _buildDateRow(ThemeData theme) {
    final color = theme.colorScheme.onSurface.withValues(alpha: 0.56);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.schedule_outlined,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          _formatDateTime(post.createdAt),
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      ],
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
      future:
          AppDI.instance.getCommentsForTarget(TargetRef.post(post.id.value)),
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
