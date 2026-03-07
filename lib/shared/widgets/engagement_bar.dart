import 'package:flutter/material.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';

/// Barra di engagement riutilizzabile con icone:
/// 🔥 like / supporto
/// ❄ dislike / opposizione
///
/// v2:
/// - usata per post social, poll, news
/// - evidenzia la reazione selezionata dall’utente tramite [userReaction]
/// - colore:
///   - nessuna reazione → grigio
///   - 🔥 selezionato → arancione
///   - ❄ selezionato → blu
class EngagementBar extends StatelessWidget {
  final int fireCount;
  final int iceCount;

  /// Reazione corrente dell’utente su questo target.
  /// - [ReactionType.like]    → 🔥 evidenziato
  /// - [ReactionType.dislike] → ❄ evidenziato
  /// - null → nessun evidenziato (entrambi grigi)
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

    // Colori fissi per coerenza in tutta l’app
    const fireActiveColor = Colors.orange; // 🔥
    const iceActiveColor = Colors.blue; // ❄

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _EngagementButton(
          emoji: '🔥',
          count: fireCount,
          onTap: onFireTap,
          isSelected: isFireSelected,
          activeColor: fireActiveColor,
          textStyle: textStyle,
        ),
        const SizedBox(width: 16),
        _EngagementButton(
          emoji: '❄',
          count: iceCount,
          onTap: onIceTap,
          isSelected: isIceSelected,
          activeColor: iceActiveColor,
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

  /// Colore “attivo” di questo tipo di reazione (es. arancione / blu).
  final Color activeColor;
  final TextStyle? textStyle;

  /// Se true, il bottone è nello stato “selezionato” (utente ha reagito così).
  final bool isSelected;

  const _EngagementButton({
    required this.emoji,
    required this.count,
    required this.onTap,
    required this.activeColor,
    required this.textStyle,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = textStyle ?? const TextStyle();

    // Grigio quando non selezionato, attivo (arancione/blu) quando selezionato
    final Color inactiveColor = Colors.grey;

    final effectiveTextColor = isSelected ? activeColor : inactiveColor;

    final effectiveStyle = baseStyle.copyWith(
      color: effectiveTextColor,
      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
    );

    final backgroundColor =
        isSelected ? activeColor.withOpacity(0.12) : Colors.transparent;

    final borderColor = isSelected
        ? activeColor.withOpacity(0.5)
        : inactiveColor.withOpacity(0.4);

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: effectiveStyle.copyWith(
                fontSize: (effectiveStyle.fontSize != null
                        ? effectiveStyle.fontSize!
                        : 14) +
                    2,
              ),
            ),
            const SizedBox(width: 4),
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