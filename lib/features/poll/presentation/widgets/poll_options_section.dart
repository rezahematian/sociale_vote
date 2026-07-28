import 'package:flutter/material.dart';

import 'package:sociale_vote/app/theme/radius.dart';
import 'package:sociale_vote/app/theme/spacing.dart';
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
    final dividerColor = Theme.of(context).colorScheme.outline.withValues(
        alpha: Theme.of(context).brightness == Brightness.dark ? 0.24 : 0.11);

    return Column(
      children: [
        for (int i = 0; i < poll.options.length; i++) ...[
          _PollOptionRow(
            index: i,
            label: poll.options[i].label,
            isSelected: selectedOptionIds.contains(poll.options[i].id),
            isSingleChoice: isSingleChoice,
            isEnabled: isSelectable,
            onTap: isSelectable
                ? () => onToggleOption(poll.options[i].id, !isSingleChoice)
                : null,
          ),
          if (i != poll.options.length - 1)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xs,
              ),
              child: Divider(
                height: 1,
                thickness: 1,
                color: dividerColor,
              ),
            ),
        ],
      ],
    );
  }
}

class _PollOptionRow extends StatelessWidget {
  final int index;
  final String label;
  final bool isSelected;
  final bool isSingleChoice;
  final bool isEnabled;
  final VoidCallback? onTap;

  const _PollOptionRow({
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

    final selectedBackground = colorScheme.primary.withValues(
      alpha: isDark ? 0.14 : 0.07,
    );
    final selectedBorder = colorScheme.primary.withValues(
      alpha: isDark ? 0.46 : 0.24,
    );
    final textColor = colorScheme.onSurface.withValues(
      alpha: isEnabled ? 0.94 : 0.78,
    );

    return Semantics(
      button: isEnabled,
      enabled: isEnabled,
      selected: isSelected,
      label: label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected ? selectedBackground : Colors.transparent,
          borderRadius: AppRadius.inputRadius,
          border: Border.all(
            color: isSelected ? selectedBorder : Colors.transparent,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppRadius.inputRadius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.inputRadius,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    _OptionLeading(
                      index: index,
                      isSelected: isSelected,
                      isSingleChoice: isSingleChoice,
                      isEnabled: isEnabled,
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      child: Text(
                        label,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: textColor,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionLeading extends StatelessWidget {
  final int index;
  final bool isSelected;
  final bool isSingleChoice;
  final bool isEnabled;

  const _OptionLeading({
    required this.index,
    required this.isSelected,
    required this.isSingleChoice,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (isEnabled || isSelected) {
      final icon = isSingleChoice
          ? (isSelected
              ? Icons.radio_button_checked
              : Icons.radio_button_unchecked)
          : (isSelected
              ? Icons.check_box_rounded
              : Icons.check_box_outline_blank_rounded);

      return SizedBox(
        width: 36,
        height: 36,
        child: Icon(
          icon,
          size: 23,
          color: isSelected
              ? colorScheme.primary
              : colorScheme.onSurface.withValues(alpha: 0.48),
        ),
      );
    }

    final badgeText = String.fromCharCode(65 + (index % 26));

    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.42 : 0.56,
        ),
        shape: BoxShape.circle,
      ),
      child: Text(
        badgeText,
        style: theme.textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.70),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
