import 'package:flutter/material.dart';

import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_status.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_type.dart';

class PollOptionsSection extends StatelessWidget {
  final Poll poll;
  final Set<String> selectedOptionIds;
  final void Function(String optionId, bool allowMultiple) onToggleOption;

  const PollOptionsSection({
    super.key,
    required this.poll,
    required this.selectedOptionIds,
    required this.onToggleOption,
  });

  @override
  Widget build(BuildContext context) {
    final isSingleChoice =
        poll.type == PollType.singleChoice || poll.type == PollType.yesNo;
    final isSelectable = poll.status == PollStatus.open;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < poll.options.length; i++) ...[
          _PollOptionTile(
            index: i,
            label: poll.options[i].label,
            isSelected: selectedOptionIds.contains(poll.options[i].id),
            isSingleChoice: isSingleChoice,
            isEnabled: isSelectable,
            onTap: isSelectable
                ? () => onToggleOption(poll.options[i].id, !isSingleChoice)
                : null,
          ),
          if (i != poll.options.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _PollOptionTile extends StatelessWidget {
  final int index;
  final String label;
  final bool isSelected;
  final bool isSingleChoice;
  final bool isEnabled;
  final VoidCallback? onTap;

  const _PollOptionTile({
    required this.index,
    required this.label,
    required this.isSelected,
    required this.isSingleChoice,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = isSelected
        ? colorScheme.primary.withOpacity(isDark ? 0.78 : 0.82)
        : colorScheme.outline.withOpacity(isDark ? 0.32 : 0.14);

    final backgroundColor = isSelected
        ? colorScheme.primary.withOpacity(isDark ? 0.12 : 0.07)
        : colorScheme.surface;

    final leadingBackground = isSelected
        ? colorScheme.primary.withOpacity(isDark ? 0.18 : 0.13)
        : colorScheme.surfaceContainerHighest.withOpacity(isDark ? 0.36 : 0.55);

    final leadingBorder = isSelected
        ? colorScheme.primary.withOpacity(isDark ? 0.42 : 0.24)
        : colorScheme.outline.withOpacity(isDark ? 0.28 : 0.12);

    final controlColor = isSelected
        ? colorScheme.primary
        : colorScheme.onSurface.withOpacity(isDark ? 0.64 : 0.52);

    final textColor = isEnabled
        ? colorScheme.onSurface
        : colorScheme.onSurface.withOpacity(0.48);

    final badgeText = String.fromCharCode(65 + (index % 26));

    return Opacity(
      opacity: isEnabled ? 1 : 0.76,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 1.45 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    isDark
                        ? (isSelected ? 0.16 : 0.10)
                        : (isSelected ? 0.035 : 0.018),
                  ),
                  blurRadius: isSelected ? 12 : 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: leadingBackground,
                    shape: BoxShape.circle,
                    border: Border.all(color: leadingBorder),
                  ),
                  child: Text(
                    badgeText,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface.withOpacity(0.78),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Icon(
                    isSingleChoice
                        ? (isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked)
                        : (isSelected
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded),
                    size: 22,
                    color: controlColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      height: 1.2,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
