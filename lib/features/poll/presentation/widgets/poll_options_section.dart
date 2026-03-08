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

    return Column(
      children: poll.options.map((option) {
        final isSelected = selectedOptionIds.contains(option.id);

        return ListTile(
          title: Text(option.label),
          leading: isSingleChoice
              ? Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                )
              : Icon(
                  isSelected
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                ),
          onTap: poll.status == PollStatus.open
              ? () {
                  onToggleOption(option.id, !isSingleChoice);
                }
              : null,
        );
      }).toList(),
    );
  }
}