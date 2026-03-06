import 'package:flutter/material.dart';

/// Barra di engagement riutilizzabile con icone:
/// 🔥 like / supporto
/// ❄ dislike / opposizione
///
/// v1: usata per i post social, in futuro anche per poll/news.
class EngagementBar extends StatelessWidget {
  final int fireCount;
  final int iceCount;
  final VoidCallback? onFireTap;
  final VoidCallback? onIceTap;

  const EngagementBar({
    super.key,
    this.fireCount = 0,
    this.iceCount = 0,
    this.onFireTap,
    this.onIceTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _EngagementButton(
          emoji: '🔥',
          count: fireCount,
          onTap: onFireTap,
          color: colorScheme.primary,
          textStyle: textStyle,
        ),
        const SizedBox(width: 16),
        _EngagementButton(
          emoji: '❄',
          count: iceCount,
          onTap: onIceTap,
          color: colorScheme.secondary,
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
  final Color color;
  final TextStyle? textStyle;

  const _EngagementButton({
    required this.emoji,
    required this.count,
    required this.onTap,
    required this.color,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = (textStyle ?? const TextStyle()).copyWith(
      color: color,
      fontWeight: FontWeight.w600,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: effectiveStyle.copyWith(fontSize: effectiveStyle.fontSize != null
                  ? effectiveStyle.fontSize! + 2
                  : 16),
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