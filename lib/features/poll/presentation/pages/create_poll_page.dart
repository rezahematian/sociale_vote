import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_type.dart';
import 'package:sociale_vote/domain/poll/value_objects/anonymity_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/visibility_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/participation_rules.dart';
import 'package:sociale_vote/features/poll/application/create_poll_controller.dart';

class CreatePollPage extends StatelessWidget {
  const CreatePollPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppDI.instance.createCreatePollController(),
      child: const _CreatePollView(),
    );
  }
}

class _CreatePollView extends StatelessWidget {
  const _CreatePollView();

  String _pollTypeLabel(PollType type) {
    switch (type) {
      case PollType.yesNo:
        return 'Yes / No';
      case PollType.singleChoice:
        return 'Single choice';
      case PollType.multipleChoice:
        return 'Multiple choice';
      case PollType.approval:
        return 'Approval voting';
      case PollType.ranked:
        return 'Ranked choice';
      case PollType.score:
        return 'Score / Rating';
    }
  }

  String _formatDate(DateTime dt) {
    // formato semplice: dd/MM/yyyy
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _participationScopeLabel(ParticipationScope scope) {
    switch (scope) {
      case ParticipationScope.everyone:
        return 'Everyone can vote';
      case ParticipationScope.geoScopeOnly:
        return 'Only users in this geographic scope';
    }
  }

  String _anonymityLabel(AnonymityLevel level) {
    switch (level) {
      case AnonymityLevel.anonymous:
        return 'Votes are anonymous';
      case AnonymityLevel.public:
        return 'Votes are public (advanced / restricted use)';
    }
  }

  String _resultsVisibilityLabel(ResultsVisibilityMode mode) {
    switch (mode) {
      case ResultsVisibilityMode.always:
        return 'Always visible (while poll is open)';
      case ResultsVisibilityMode.afterVote:
        return 'Only visible after voting';
      case ResultsVisibilityMode.afterClose:
        return 'Only visible after poll is closed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create Poll'),
            const SizedBox(height: 2),
            Text(
              'Define a new civic vote',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 720,
            ),
            child: Consumer<CreatePollController>(
              builder: (context, controller, _) {
                final isSubmitting = controller.isSubmitting;

                return AbsorbPointer(
                  absorbing: isSubmitting,
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (controller.errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: theme.colorScheme.error.withOpacity(0.4),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: theme.colorScheme.error,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    controller.errorMessage!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // ===== BASIC INFO CARD =====
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Basic information',
                                  style:
                                      theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Define the main details of the poll.',
                                  style:
                                      theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  enabled: !isSubmitting,
                                  decoration: const InputDecoration(
                                    labelText: 'Title *',
                                    border: OutlineInputBorder(),
                                    helperText:
                                        'A clear, concise question or statement.',
                                  ),
                                  onChanged: controller.setTitle,
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  enabled: !isSubmitting,
                                  decoration: const InputDecoration(
                                    labelText: 'Description (optional)',
                                    border: OutlineInputBorder(),
                                    alignLabelWithHint: true,
                                  ),
                                  maxLines: 3,
                                  onChanged: controller.setDescription,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ===== VOTING MODEL CARD =====
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Voting model',
                                  style:
                                      theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Choose how people will express their vote and basic rules.',
                                  style:
                                      theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Poll type',
                                    border: OutlineInputBorder(),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<PollType>(
                                      isExpanded: true,
                                      value: controller.type,
                                      onChanged: isSubmitting
                                          ? null
                                          : (value) {
                                              if (value != null) {
                                                controller.setType(value);
                                              }
                                            },
                                      items: PollType.values
                                          .map(
                                            (type) => DropdownMenuItem(
                                              value: type,
                                              child: Text(
                                                _pollTypeLabel(type),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.rule,
                                      size: 18,
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.8),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Selection rules: minimum ${controller.minSelections}, maximum ${controller.maxSelections} selections '
                                        '(automatically adjusted based on poll type and options).',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: theme.textTheme.bodySmall
                                              ?.color
                                              ?.withOpacity(0.8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SwitchListTile.adaptive(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text(
                                    'Allow voters to change their vote',
                                  ),
                                  subtitle: Text(
                                    'Until the poll is closed.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withOpacity(0.8),
                                    ),
                                  ),
                                  value: controller.allowVoteChange,
                                  onChanged: isSubmitting
                                      ? null
                                      : controller.setAllowVoteChange,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ===== OPTIONS CARD =====
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Options',
                                  style:
                                      theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Add at least two options for voters to choose from. Fields marked with * are mandatory.',
                                  style:
                                      theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Column(
                                  children: List.generate(
                                    controller.options.length,
                                    (index) {
                                      final optionLabel =
                                          'Option ${index + 1}${index < 2 ? " *" : ""}';
                                      final canRemove =
                                          controller.options.length > 2;

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 8),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                enabled: !isSubmitting,
                                                decoration: InputDecoration(
                                                  labelText: optionLabel,
                                                  border:
                                                      const OutlineInputBorder(),
                                                ),
                                                onChanged: (value) =>
                                                    controller.setOptionText(
                                                        index, value),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            if (canRemove)
                                              IconButton(
                                                tooltip: 'Remove option',
                                                onPressed: isSubmitting
                                                    ? null
                                                    : () => controller
                                                        .removeOption(index),
                                                icon: const Icon(Icons
                                                    .remove_circle_outline),
                                              ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton.icon(
                                    onPressed: isSubmitting
                                        ? null
                                        : controller.addOption,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add option'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ===== PARTICIPATION & PRIVACY CARD =====
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Participation & privacy',
                                  style:
                                      theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Decide who can vote and how private the votes should be.',
                                  style:
                                      theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Who can vote?',
                                  style:
                                      theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                RadioListTile<ParticipationScope>(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    _participationScopeLabel(
                                        ParticipationScope.everyone),
                                  ),
                                  subtitle: Text(
                                    'Any registered user can participate.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withOpacity(0.8),
                                    ),
                                  ),
                                  value: ParticipationScope.everyone,
                                  groupValue: controller.participationScope,
                                  onChanged: isSubmitting
                                      ? null
                                      : (value) {
                                          if (value != null) {
                                            controller
                                                .setParticipationScope(value);
                                          }
                                        },
                                ),
                                RadioListTile<ParticipationScope>(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    _participationScopeLabel(
                                        ParticipationScope.geoScopeOnly),
                                  ),
                                  subtitle: Text(
                                    'Only users that belong to the same geographic scope as this poll (world/country/city).',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withOpacity(0.8),
                                    ),
                                  ),
                                  value: ParticipationScope.geoScopeOnly,
                                  groupValue: controller.participationScope,
                                  onChanged: isSubmitting
                                      ? null
                                      : (value) {
                                          if (value != null) {
                                            controller
                                                .setParticipationScope(value);
                                          }
                                        },
                                ),
                                const Divider(height: 24),
                                Text(
                                  'Vote anonymity',
                                  style:
                                      theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                RadioListTile<AnonymityLevel>(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    _anonymityLabel(
                                        AnonymityLevel.anonymous),
                                  ),
                                  subtitle: Text(
                                    'Recommended default for civic voting platforms.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withOpacity(0.8),
                                    ),
                                  ),
                                  value: AnonymityLevel.anonymous,
                                  groupValue: controller.anonymityLevel,
                                  onChanged: isSubmitting
                                      ? null
                                      : (value) {
                                          if (value != null) {
                                            controller
                                                .setAnonymityLevel(value);
                                          }
                                        },
                                ),
                                RadioListTile<AnonymityLevel>(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    _anonymityLabel(AnonymityLevel.public),
                                  ),
                                  subtitle: Text(
                                    'Use with caution: votes may be associated with identities (future feature).',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withOpacity(0.8),
                                    ),
                                  ),
                                  value: AnonymityLevel.public,
                                  groupValue: controller.anonymityLevel,
                                  onChanged: isSubmitting
                                      ? null
                                      : (value) {
                                          if (value != null) {
                                            controller
                                                .setAnonymityLevel(value);
                                          }
                                        },
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ===== RESULTS & VALIDITY CARD =====
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Results & validity',
                                  style:
                                      theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Control when results are visible and define minimum quorum if needed.',
                                  style:
                                      theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Results visibility',
                                    border: OutlineInputBorder(),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<
                                        ResultsVisibilityMode>(
                                      isExpanded: true,
                                      value: controller.resultsVisibility,
                                      onChanged: isSubmitting
                                          ? null
                                          : (value) {
                                              if (value != null) {
                                                controller
                                                    .setResultsVisibility(
                                                        value);
                                              }
                                            },
                                      items: ResultsVisibilityMode.values
                                          .map(
                                            (mode) => DropdownMenuItem(
                                              value: mode,
                                              child: Text(
                                                _resultsVisibilityLabel(mode),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Quorum (optional)',
                                  style:
                                      theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'If set, the poll is considered valid only if at least this number of votes is reached. Leave empty for no quorum.',
                                  style:
                                      theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  enabled: !isSubmitting,
                                  initialValue: controller
                                          .minQuorumVotes
                                          ?.toString() ??
                                      '',
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText:
                                        'Minimum number of votes',
                                  ),
                                  onChanged: (value) {
                                    if (value.trim().isEmpty) {
                                      controller.setMinQuorumVotes(null);
                                    } else {
                                      final parsed =
                                          int.tryParse(value.trim());
                                      controller
                                          .setMinQuorumVotes(parsed);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ===== TIMING CARD =====
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Timing',
                                  style:
                                      theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Define when the poll should be open for voting.',
                                  style:
                                      theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading:
                                      const Icon(Icons.play_circle_outline),
                                  title: const Text('Start date'),
                                  subtitle: Text(
                                    _formatDate(controller.startAt),
                                  ),
                                  trailing: TextButton(
                                    onPressed: isSubmitting
                                        ? null
                                        : () async {
                                            final now = DateTime.now();
                                            final initialDate = controller
                                                    .startAt
                                                    .isBefore(
                                              DateTime(
                                                now.year,
                                                now.month,
                                                now.day,
                                              ),
                                            )
                                                ? now
                                                : controller.startAt;

                                            final picked =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: initialDate,
                                              firstDate: now.subtract(
                                                const Duration(days: 365),
                                              ),
                                              lastDate: now.add(
                                                const Duration(days: 365 * 5),
                                              ),
                                            );
                                            if (picked != null) {
                                              final current =
                                                  controller.startAt;
                                              controller.setStartAt(
                                                DateTime(
                                                  picked.year,
                                                  picked.month,
                                                  picked.day,
                                                  current.hour,
                                                  current.minute,
                                                ),
                                              );
                                            }
                                          },
                                    child: const Text('Change'),
                                  ),
                                ),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.stop_circle_outlined,
                                  ),
                                  title: const Text('End date'),
                                  subtitle: Text(
                                    _formatDate(controller.endAt),
                                  ),
                                  trailing: TextButton(
                                    onPressed: isSubmitting
                                        ? null
                                        : () async {
                                            final now = DateTime.now();
                                            final initialDate = controller
                                                    .endAt
                                                    .isBefore(
                                              DateTime(
                                                now.year,
                                                now.month,
                                                now.day,
                                              ),
                                            )
                                                ? now
                                                : controller.endAt;

                                            final picked =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: initialDate,
                                              firstDate: now.subtract(
                                                const Duration(days: 365),
                                              ),
                                              lastDate: now.add(
                                                const Duration(days: 365 * 5),
                                              ),
                                            );
                                            if (picked != null) {
                                              final current =
                                                  controller.endAt;
                                              controller.setEndAt(
                                                DateTime(
                                                  picked.year,
                                                  picked.month,
                                                  picked.day,
                                                  current.hour,
                                                  current.minute,
                                                ),
                                              );
                                            }
                                          },
                                    child: const Text('Change'),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'The initial status (open/scheduled/closed) will be determined automatically based on these dates.',
                                  style:
                                      theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ===== SUBMIT BUTTON =====
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: controller.canSubmit && !isSubmitting
                                ? () async {
                                    FocusScope.of(context).unfocus();

                                    final pollId =
                                        await controller.submit();
                                    if (!context.mounted) return;
                                    if (pollId != null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          behavior:
                                              SnackBarBehavior.floating,
                                          content: Text(
                                            'Poll created successfully',
                                          ),
                                        ),
                                      );
                                      // Torniamo alla lista passando il PollId
                                      Navigator.of(context).pop(pollId);
                                    }
                                  }
                                : null,
                            icon: isSubmitting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.check),
                            label: Text(
                              isSubmitting ? 'Creating...' : 'Create poll',
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              textStyle:
                                  theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}