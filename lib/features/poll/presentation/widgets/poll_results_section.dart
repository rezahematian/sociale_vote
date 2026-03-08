import 'package:flutter/material.dart';

import 'package:sociale_vote/domain/poll/value_objects/poll_outcome.dart';
import 'package:sociale_vote/domain/poll/value_objects/visibility_rules.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

import 'poll_result_chart.dart';

class PollResultsSection extends StatelessWidget {
  final bool canShowResults;
  final bool isLoading;
  final String? error;
  final dynamic result;

  final bool hasOutcome;
  final PollOutcome outcome;

  final ResultsVisibilityMode visibilityMode;

  const PollResultsSection({
    super.key,
    required this.canShowResults,
    required this.isLoading,
    required this.error,
    required this.result,
    required this.hasOutcome,
    required this.outcome,
    required this.visibilityMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (canShowResults) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.pollDetail_resultsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          if (hasOutcome) ...[
            Text(
              l10n.pollDetail_outcomePrefix(
                _mapOutcomeLabel(l10n, outcome),
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
          ],

          if (isLoading) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              ),
            )
          ] else if (error != null) ...[
            Text(
              error!,
              style: TextStyle(color: theme.colorScheme.error),
            )
          ] else if (result != null) ...[
            PollResultChart(result: result)
          ] else ...[
            Text(
              l10n.pollDetail_noResults,
              style: theme.textTheme.bodySmall,
            )
          ],
        ],
      );
    }

    return Text(
      visibilityMode == ResultsVisibilityMode.afterVote
          ? l10n.pollDetail_resultsAfterVote
          : l10n.pollDetail_resultsWhenClosed,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontStyle: FontStyle.italic,
      ),
    );
  }

  String _mapOutcomeLabel(AppLocalizations l10n, PollOutcome outcome) {
    switch (outcome) {
      case PollOutcome.approved:
        return l10n.pollOutcome_approved;
      case PollOutcome.rejected:
        return l10n.pollOutcome_rejected;
      case PollOutcome.tie:
        return l10n.pollOutcome_tie;
      case PollOutcome.noMajority:
        return l10n.pollOutcome_noMajority;
      case PollOutcome.notApplicable:
        return l10n.pollOutcome_notApplicable;
    }
  }
}