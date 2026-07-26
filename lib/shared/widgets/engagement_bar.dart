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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isFireSelected = userReaction == ReactionType.like;
    final isIceSelected = userReaction == ReactionType.dislike;

    final neutralColor =
        theme.iconTheme.color ?? (isDark ? AppColors.iconDark : AppColors.icon);
    final disabledColor =
        isDark ? AppColors.iconDisabledDark : AppColors.iconDisabled;
    final borderColor =
        isDark ? AppColors.borderSoftDark : AppColors.borderSoft;

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
              softColor: isDark
                  ? AppColors.heatSoftBackgroundDark
                  : AppColors.heatSoftBackground,
              neutralColor: neutralColor,
              disabledColor: disabledColor,
              borderColor: borderColor,
              compact: isCompact,
            ),
            SizedBox(width: spacing),
            _EngagementButton(
              icon: Icons.ac_unit,
              count: iceCount,
              onTap: onIceTap,
              isSelected: isIceSelected,
              activeColor: AppColors.cool,
              softColor: isDark
                  ? AppColors.coolSoftBackgroundDark
                  : AppColors.coolSoftBackground,
              neutralColor: neutralColor,
              disabledColor: disabledColor,
              borderColor: borderColor,
              compact: isCompact,
            ),
            SizedBox(width: spacing),
            _EngagementButton(
              icon: Icons.mode_comment_outlined,
              count: commentCount,
              onTap: onCommentTap,
              isSelected: false,
              activeColor: neutralColor,
              softColor: Colors.transparent,
              neutralColor: neutralColor,
              disabledColor: disabledColor,
              borderColor: borderColor,
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
  final Color neutralColor;
  final Color disabledColor;
  final Color borderColor;
  final bool isSelected;
  final bool compact;

  const _EngagementButton({
    required this.icon,
    required this.count,
    required this.onTap,
    required this.activeColor,
    required this.softColor,
    required this.neutralColor,
    required this.disabledColor,
    required this.borderColor,
    required this.isSelected,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    final iconColor = isSelected
        ? activeColor
        : isEnabled
            ? neutralColor
            : disabledColor;
    final background = isSelected ? softColor : Colors.transparent;

    final visualHeight = compact ? 28.0 : 30.0;
    final tapTargetExtent = compact ? 40.0 : 44.0;
    final iconSize = compact ? 14.0 : 16.0;
    final fontSize = compact ? 11.0 : 12.0;
    final horizontalPadding = compact ? AppSpacing.xxs : AppSpacing.s;
    final innerSpacing = compact ? 2.0 : AppSpacing.xxs;

    return Semantics(
      button: true,
      enabled: isEnabled,
      child: InkWell(
        borderRadius: AppRadius.pillRadius,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: tapTargetExtent,
            minHeight: tapTargetExtent,
          ),
          child: Center(
            child: Container(
              height: visualHeight,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              decoration: BoxDecoration(
                color: background,
                borderRadius: AppRadius.pillRadius,
                border: Border.all(
                  color: isSelected
                      ? activeColor.withValues(alpha: 0.4)
                      : borderColor,
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
          ),
        ),
      ),
    );
  }
}
