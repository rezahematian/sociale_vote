import 'package:flutter/material.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

/// Maximum selectable answers for a new multiple-choice Vote.
/// The minimum is fixed at one answer.
class CreatePollSelectionLimits extends StatelessWidget {
  final int maxSelections;
  final int selectionLimit;
  final bool enabled;
  final ValueChanged<int> onMaxChanged;

  const CreatePollSelectionLimits({
    super.key,
    required this.maxSelections,
    required this.selectionLimit,
    required this.enabled,
    required this.onMaxChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final first = selectionLimit >= 2 ? 2 : 1;

    return InputDecorator(
      decoration: InputDecoration(
        labelText: l10n.createPollMaximumAnswersLabel,
        enabled: enabled,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          key: const ValueKey('poll_max_selections'),
          value: maxSelections,
          isExpanded: true,
          isDense: true,
          items: [
            for (var number = first; number <= selectionLimit; number++)
              DropdownMenuItem(value: number, child: Text('$number')),
          ],
          onChanged: enabled
              ? (value) {
                  if (value != null) onMaxChanged(value);
                }
              : null,
        ),
      ),
    );
  }
}
