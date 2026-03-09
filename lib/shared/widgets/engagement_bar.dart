import 'package:flutter/material.dart';

import 'package:sociale_vote/app/theme/colors.dart';
import 'package:sociale_vote/app/theme/radius.dart';
import 'package:sociale_vote/app/theme/spacing.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';

/// Barra di engagement riutilizzabile con icone:
/// 🔥 like / supporto
/// ❄ dislike / opposizione
///
/// v2:
/// - usata per post social, poll, news
/// - evidenzia la reazione selezionata dall’utente tramite [userReaction]
/// - colore:
///   - nessuna reazione → neutro
///   - 🔥 selezionato → heat
///   - ❄ selezionato → cool
class EngagementBar extends StatelessWidget {
  final int fireCount;
  final int iceCount;

  /// Reazione corrente dell’utente su questo target.
  /// - [ReactionType.like]    → 🔥 evidenziato
  /// - [ReactionType.dislike] → ❄ evidenziato
  /// - null → nessun evidenziato
  final ReactionType? userReaction;

  final VoidCallback? onFireTap;
  final VoidCallback? onIceTap;

  const EngagementBar({
    super.key,
    this.fireCount = 0,
    this.iceCount = 0,
    this.userReaction,
    this.onFireTap,
    this.onIceTap,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    final isFireSelected = userReaction == ReactionType.like;
    final isIceSelected = userReaction == ReactionType.dislike;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _EngagementButton(
          emoji: '🔥',
          count: fireCount,
          onTap: onFireTap,
          isSelected: isFireSelected,
          activeColor: AppColors.heat,
          softColor: AppColors.heatSoftBackground,
          textStyle: textStyle,
        ),
        const SizedBox(width: AppSpacing.m),
        _EngagementButton(
          emoji: '❄',
          count: iceCount,
          onTap: onIceTap,
          isSelected: isIceSelected,
          activeColor: AppColors.cool,
          softColor: AppColors.coolSoftBackground,
          textStyle: textStyle,
        ),
      ],
    );
  }
}

class _EngagementButton extends StatelessWidget {
  final String emoji;
  final int count;
  final VoidCallback? onTap;

  /// Colore attivo del tipo di reazione.
  final Color activeColor;

  /// Background soft del tipo di reazione.
  final Color softColor;

  final TextStyle? textStyle;

  /// Se true, il bottone è nello stato “selezionato”.
  final bool isSelected;

  const _EngagementButton({
    required this.emoji,
    required this.count,
    required this.onTap,
    required this.activeColor,
    required this.softColor,
    required this.textStyle,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = textStyle ?? const TextStyle();

    final Color inactiveColor = AppColors.icon;
    final Color effectiveTextColor = isSelected ? activeColor : inactiveColor;

    final effectiveStyle = baseStyle.copyWith(
      color: effectiveTextColor,
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
    );

    final Color backgroundColor =
        isSelected ? softColor : Colors.transparent;

    final Color borderColor = isSelected
        ? activeColor.withOpacity(0.45)
        : AppColors.borderSoft;

    return InkWell(
      borderRadius: AppRadius.pillRadius,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppRadius.pillRadius,
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: effectiveStyle.copyWith(
                fontSize: (effectiveStyle.fontSize ?? 14) + 2,
              ),
            ),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              count.toString(),
              style: effectiveStyle,
            ),
          ],
        ),
      ),
    );
  }
}