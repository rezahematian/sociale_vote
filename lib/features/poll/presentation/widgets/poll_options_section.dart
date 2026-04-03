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
          if (i != poll.options.length - 1) const SizedBox(height: 14),
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

    final borderColor = isSelected
        ? theme.colorScheme.primary.withOpacity(0.85)
        : theme.dividerColor.withOpacity(0.75);

    final backgroundColor = isSelected
        ? theme.colorScheme.primary.withOpacity(0.07)
        : theme.cardColor;

    final leadingBackground = isSelected
        ? theme.colorScheme.primary.withOpacity(0.14)
        : theme.colorScheme.surface.withOpacity(0.9);

    final leadingBorder = isSelected
        ? theme.colorScheme.primary.withOpacity(0.35)
        : theme.dividerColor.withOpacity(0.55);

    final leadingIconColor = isSelected
        ? theme.colorScheme.primary
        : theme.hintColor.withOpacity(0.95);

    final textColor = isEnabled
        ? theme.colorScheme.onSurface
        : theme.hintColor.withOpacity(0.95);

    final badgeText = String.fromCharCode(65 + (index % 26));

    return Opacity(
      opacity: isEnabled ? 1 : 0.72,
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
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 1.5 : 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isSelected ? 0.045 : 0.025),
                  blurRadius: isSelected ? 14 : 10,
                  offset: const Offset(0, 3),
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
                    border: Border.all(
                      color: leadingBorder,
                    ),
                  ),
                  child: Text(
                    badgeText,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                SizedBox(
                  width: 26,
                  height: 26,
                  child: Icon(
                    isSingleChoice
                        ? (isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked)
                        : (isSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank),
                    size: 24,
                    color: leadingIconColor,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 160),
                  opacity: isSelected ? 1 : 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.18),
                      ),
                    ),
                    child: Text(
                      'Selezionata',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
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