import 'package:flutter/material.dart';

import 'package:sociale_vote/domain/poll/value_objects/poll_outcome.dart';
import 'package:sociale_vote/domain/poll/value_objects/visibility_rules.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

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

    if (!canShowResults) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.45),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.5),
          ),
        ),
        child: Text(
          visibilityMode == ResultsVisibilityMode.afterVote
              ? l10n.pollDetail_resultsAfterVote
              : l10n.pollDetail_resultsWhenClosed,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic,
            color: theme.hintColor,
          ),
        ),
      );
    }

    final rows = _extractRows(result);
    final totalVotes = _extractTotalVotes(result, rows);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.pollDetail_resultsTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
            ),
            if (!isLoading && error == null && totalVotes > 0)
              _buildVotesBadge(
                context,
                _votesLabel(l10n, totalVotes),
              ),
          ],
        ),
        if (hasOutcome) ...[
          const SizedBox(height: 8),
          _buildOutcomeBadge(
            context,
            l10n.pollDetail_outcomePrefix(
              _mapOutcomeLabel(l10n, outcome),
            ),
          ),
        ],
        const SizedBox(height: 12),
        if (isLoading) ...[
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: CircularProgressIndicator(),
            ),
          ),
        ] else if (error != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.error.withOpacity(0.35),
              ),
            ),
            child: Text(
              error!,
              style: TextStyle(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ] else if (rows.isNotEmpty) ...[
          for (int i = 0; i < rows.length; i++) ...[
            _PremiumResultRow(
              label: rows[i].label,
              percentage: rows[i].percentage,
              voteCount: rows[i].voteCount,
              votesLabel: _votesLabel(l10n, rows[i].voteCount),
            ),
            if (i != rows.length - 1) const SizedBox(height: 10),
          ],
        ] else ...[
          Text(
            l10n.pollDetail_noResults,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVotesBadge(BuildContext context, String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(isDark ? 0.18 : 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(isDark ? 0.32 : 0.18),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }

  Widget _buildOutcomeBadge(BuildContext context, String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(isDark ? 0.18 : 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(isDark ? 0.32 : 0.18),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.secondary,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }

  List<_ResultRowData> _extractRows(dynamic source) {
    final rawItems = _readValue(
      source,
      const ['optionResults', 'results', 'items', 'options'],
    );

    if (rawItems is! Iterable) {
      return const <_ResultRowData>[];
    }

    final items = rawItems.toList();
    final resultTotalVotes = _extractIntValue(
      source,
      const ['totalVotes', 'votes', 'voteCount', 'count'],
    );

    final tempRows = <_TempResultRow>[];
    int computedVotes = 0;

    for (final item in items) {
      final label =
          _extractStringValue(item, const [
            'label',
            'title',
            'name',
            'text',
            'optionText',
            'optionLabel',
          ]) ??
          'Opzione';

      final voteCount =
          _extractIntValue(item, const [
            'voteCount',
            'votes',
            'count',
            'totalVotes',
          ]) ??
          0;

      final percentage = _extractDoubleValue(item, const [
        'percentage',
        'percent',
        'share',
        'votePercentage',
      ]);

      computedVotes += voteCount;
      tempRows.add(
        _TempResultRow(
          label: label,
          voteCount: voteCount,
          percentage: percentage,
        ),
      );
    }

    final denominator = (resultTotalVotes != null && resultTotalVotes > 0)
        ? resultTotalVotes
        : computedVotes;

    return tempRows.map((row) {
      final resolvedPercentage =
          row.percentage ??
          (denominator > 0 ? (row.voteCount / denominator) * 100 : 0.0);

      return _ResultRowData(
        label: row.label,
        voteCount: row.voteCount,
        percentage: resolvedPercentage.clamp(0.0, 100.0),
      );
    }).toList();
  }

  int _extractTotalVotes(dynamic source, List<_ResultRowData> rows) {
    final explicitTotal = _extractIntValue(
      source,
      const ['totalVotes', 'votes', 'voteCount', 'count'],
    );
    if (explicitTotal != null && explicitTotal >= 0) {
      return explicitTotal;
    }

    return rows.fold<int>(
      0,
      (sum, row) => sum + row.voteCount,
    );
  }

  dynamic _readValue(dynamic source, List<String> keys) {
    for (final key in keys) {
      final value = _readSingleValue(source, key);
      if (value != null) {
        return value;
      }
    }
    return null;
  }

  dynamic _readSingleValue(dynamic source, String key) {
    if (source == null) {
      return null;
    }

    if (source is Map) {
      if (source.containsKey(key)) {
        return source[key];
      }
      return null;
    }

    try {
      switch (key) {
        case 'optionResults':
          return source.optionResults;
        case 'results':
          return source.results;
        case 'items':
          return source.items;
        case 'options':
          return source.options;
        case 'totalVotes':
          return source.totalVotes;
        case 'votes':
          return source.votes;
        case 'voteCount':
          return source.voteCount;
        case 'count':
          return source.count;
        case 'label':
          return source.label;
        case 'title':
          return source.title;
        case 'name':
          return source.name;
        case 'text':
          return source.text;
        case 'optionText':
          return source.optionText;
        case 'optionLabel':
          return source.optionLabel;
        case 'percentage':
          return source.percentage;
        case 'percent':
          return source.percent;
        case 'share':
          return source.share;
        case 'votePercentage':
          return source.votePercentage;
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  String? _extractStringValue(dynamic source, List<String> keys) {
    final value = _readValue(source, keys);
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return null;
  }

  int? _extractIntValue(dynamic source, List<String> keys) {
    final value = _readValue(source, keys);
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    if (value is String) {
      return int.tryParse(value.trim());
    }
    return null;
  }

  double? _extractDoubleValue(dynamic source, List<String> keys) {
    final value = _readValue(source, keys);
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim().replaceAll('%', ''));
    }
    return null;
  }

  String _votesLabel(AppLocalizations l10n, int votes) {
    final isItalian = l10n.localeName.toLowerCase().startsWith('it');

    if (votes == 1) {
      return isItalian ? '1 voto' : '1 vote';
    }

    return isItalian ? '$votes voti' : '$votes votes';
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

class _PremiumResultRow extends StatelessWidget {
  final String label;
  final double percentage;
  final int voteCount;
  final String votesLabel;

  const _PremiumResultRow({
    required this.label,
    required this.percentage,
    required this.voteCount,
    required this.votesLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final normalized = (percentage.clamp(0.0, 100.0)) / 100.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(isDark ? 0.38 : 0.45),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outline.withOpacity(isDark ? 0.22 : 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${percentage.round()}%',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 10,
              width: double.infinity,
              color: colorScheme.outline.withOpacity(isDark ? 0.24 : 0.10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: normalized,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            votesLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(isDark ? 0.60 : 0.52),
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultRowData {
  final String label;
  final int voteCount;
  final double percentage;

  const _ResultRowData({
    required this.label,
    required this.voteCount,
    required this.percentage,
  });
}

class _TempResultRow {
  final String label;
  final int voteCount;
  final double? percentage;

  const _TempResultRow({
    required this.label,
    required this.voteCount,
    required this.percentage,
  });
}