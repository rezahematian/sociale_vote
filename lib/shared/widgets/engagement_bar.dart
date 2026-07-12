import 'package:flutter/material.dart';

import 'package:sociale_vote/app/theme/colors.dart';
import 'package:sociale_vote/app/theme/radius.dart';
import 'package:sociale_vote/app/theme/spacing.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';

/// Barra di engagement standard unica per tutta l'app.
/// Layout compatto: 🔥 ❄ 💬 con numeri accanto.
class EngagementBar extends StatelessWidget {
  final int fireCount;
  final int iceCount;
  final int commentCount;

  final ReactionType? userReaction;

  final VoidCallback? onFireTap;
  final VoidCallback? onIceTap;
  final VoidCallback? onCommentTap;

  const EngagementBar({
    super.key,
    this.fireCount = 0,
    this.iceCount = 0,
    this.commentCount = 0,
    this.userReaction,
    this.onFireTap,
    this.onIceTap,
    this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFireSelected = userReaction == ReactionType.like;
    final isIceSelected = userReaction == ReactionType.dislike;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isCompact = maxWidth.isFinite && maxWidth < 150;
        final spacing = isCompact ? AppSpacing.xxs : AppSpacing.xs;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _EngagementButton(
              icon: Icons.local_fire_department,
              count: fireCount,
              onTap: onFireTap,
              isSelected: isFireSelected,
              activeColor: AppColors.heat,
              softColor: AppColors.heatSoftBackground,
              compact: isCompact,
            ),
            SizedBox(width: spacing),
            _EngagementButton(
              icon: Icons.ac_unit,
              count: iceCount,
              onTap: onIceTap,
              isSelected: isIceSelected,
              activeColor: AppColors.cool,
              softColor: AppColors.coolSoftBackground,
              compact: isCompact,
            ),
            SizedBox(width: spacing),
            _EngagementButton(
              icon: Icons.mode_comment_outlined,
              count: commentCount,
              onTap: onCommentTap,
              isSelected: false,
              activeColor: AppColors.icon,
              softColor: Colors.transparent,
              compact: isCompact,
            ),
          ],
        );
      },
    );
  }
}

class _EngagementButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback? onTap;

  final Color activeColor;
  final Color softColor;
  final bool isSelected;
  final bool compact;

  const _EngagementButton({
    required this.icon,
    required this.count,
    required this.onTap,
    required this.activeColor,
    required this.softColor,
    required this.isSelected,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isSelected ? activeColor : AppColors.icon;
    final Color background = isSelected ? softColor : Colors.transparent;

    final double height = compact ? 28 : 30;
    final double iconSize = compact ? 14 : 16;
    final double fontSize = compact ? 11 : 12;
    final double horizontalPadding = compact ? AppSpacing.xxs : AppSpacing.s;
    final double innerSpacing = compact ? 2 : AppSpacing.xxs;

    return InkWell(
      borderRadius: AppRadius.pillRadius,
      onTap: onTap,
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadius.pillRadius,
          border: Border.all(
            color: isSelected
                ? activeColor.withValues(alpha: 0.4)
                : AppColors.borderSoft,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize, color: iconColor),
            SizedBox(width: innerSpacing),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
