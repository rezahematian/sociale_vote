import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/theme/colors.dart';
import 'package:sociale_vote/app/theme/radius.dart';
import 'package:sociale_vote/app/theme/spacing.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/entities/poll_result.dart';
import 'package:sociale_vote/domain/poll/value_objects/anonymity_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/participation_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_status.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_type.dart';
import 'package:sociale_vote/domain/poll/value_objects/visibility_rules.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/data/countries.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';
import 'package:sociale_vote/shared/ui/app_card.dart';
import 'package:sociale_vote/shared/widgets/engagement_bar.dart';

class PollCard extends StatelessWidget {
  final Poll poll;
  final VoidCallback? onTap;

  /// Engagement (🔥 / ❄)
  final int? fireCount;
  final int? iceCount;

  /// Reazione corrente dell'utente su questo poll.
  final ReactionType? userReaction;

  /// Risultati opzionali del poll.
  /// Se presenti, la card mostra una preview premium con donut + top opzioni.
  final PollResult? result;

  final VoidCallback? onFireTap;
  final VoidCallback? onIceTap;

  const PollCard({
    super.key,
    required this.poll,
    this.onTap,
    this.fireCount,
    this.iceCount,
    this.userReaction,
    this.result,
    this.onFireTap,
    this.onIceTap,
  });

  bool get _hasGeoRestriction =>
      poll.configuration.participationRules.scope ==
      ParticipationScope.geoScopeOnly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final description = poll.description ?? '';
    final hasDescription = description.trim().isNotEmpty;
    final hasResults = result != null && result!.optionResults.isNotEmpty;

    VoidCallback? wrapReactCallback(VoidCallback? original) {
      if (original == null) return null;

      return () async {
        final allowed = await AuthGuard.ensureCanPerformAction(
          context,
          ParticipationAction.react,
        );
        if (!allowed) return;

        original();
      };
    }

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.unitM),
      elevated: true,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.how_to_vote,
                size: 20,
                color: theme.colorScheme.primary.withOpacity(0.8),
              ),
              const SizedBox(width: AppSpacing.unitS),
              Expanded(
                child: Text(
                  poll.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.unitS),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatusChip(theme, l10n),
                  if (_hasGeoRestriction) ...[
                    const SizedBox(height: AppSpacing.unitXS),
                    _buildParticipationChip(theme, l10n),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.unitS),
          _buildStatusProgressBar(theme),
          if (hasDescription) ...[
            const SizedBox(height: AppSpacing.unitS),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.85),
              ),
              maxLines: hasResults ? 1 : 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: AppSpacing.unitM),
          if (hasResults) ...[
            _PollResultPreview(result: result!),
            const SizedBox(height: AppSpacing.unitM),
          ],
          Wrap(
            spacing: AppSpacing.unitS,
            runSpacing: AppSpacing.unitS,
            children: [
              _buildTypeChip(theme, l10n),
              _buildScopeChip(theme, l10n),
              _buildAnonymityChip(theme, l10n),
              _buildResultsVisibilityChip(theme, l10n),
              _buildQuorumChip(theme, l10n),
            ],
          ),
          const SizedBox(height: AppSpacing.unitM),
          _PollEngagementRow(
            poll: poll,
            fireCount: fireCount,
            iceCount: iceCount,
            userReaction: userReaction,
            onFireTap: wrapReactCallback(onFireTap),
            onIceTap: wrapReactCallback(onIceTap),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.pollCard_viewDetails,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: AppSpacing.unitXS),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _mapTypeToLabel(AppLocalizations l10n, PollType type) {
    switch (type) {
      case PollType.yesNo:
        return l10n.pollType_yesNo;
      case PollType.singleChoice:
        return l10n.pollType_singleChoice;
      case PollType.multipleChoice:
        return l10n.pollType_multipleChoice;
      case PollType.approval:
        return l10n.pollType_approval;
      case PollType.ranked:
        return l10n.pollType_ranked;
      case PollType.score:
        return l10n.pollType_score;
      default:
        return type.name;
    }
  }

  String _mapStatusToLabel(AppLocalizations l10n, PollStatus status) {
    switch (status) {
      case PollStatus.draft:
        return l10n.pollStatus_draft;
      case PollStatus.scheduled:
        return l10n.pollStatus_scheduled;
      case PollStatus.open:
        return l10n.pollStatus_open;
      case PollStatus.closed:
        return l10n.pollStatus_closed;
      default:
        return status.name;
    }
  }

  String _mapResultsVisibilityLabel(
    AppLocalizations l10n,
    ResultsVisibilityMode mode,
  ) {
    switch (mode) {
      case ResultsVisibilityMode.always:
        return l10n.pollVisibility_whileOpen;
      case ResultsVisibilityMode.afterVote:
        return l10n.pollVisibility_afterVote;
      case ResultsVisibilityMode.afterClose:
        return l10n.pollVisibility_afterClose;
      default:
        return mode.name;
    }
  }

  String? _resolveParticipationCountryName() {
    final rules = poll.configuration.participationRules;
    final code = rules.countryCode;
    if (code == null) return null;

    final upper = code.toUpperCase();

    try {
      final country =
          Countries.all.firstWhere((c) => c.code.toUpperCase() == upper);
      return country.name;
    } catch (_) {
      return code;
    }
  }

  Widget _buildStatusProgressBar(ThemeData theme) {
    final status = poll.status;

    double value;
    Color color;

    switch (status) {
      case PollStatus.open:
        value = 0.6;
        color = AppColors.success;
        break;
      case PollStatus.closed:
        value = 1.0;
        color = AppColors.textMuted;
        break;
      case PollStatus.scheduled:
      case PollStatus.draft:
      default:
        value = 0.3;
        color = theme.colorScheme.primary.withOpacity(0.4);
        break;
    }

    return ClipRRect(
      borderRadius: AppRadius.buttonRadius,
      child: LinearProgressIndicator(
        value: value,
        minHeight: 4,
        backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme, AppLocalizations l10n) {
    final status = poll.status;
    final statusLabel = _mapStatusToLabel(l10n, status);
    final normalized = status.name.toLowerCase();

    Color bg;
    Color fg;

    if (normalized.contains('open')) {
      bg = AppColors.successSoftBackground;
      fg = AppColors.success;
    } else if (normalized.contains('closed')) {
      bg = AppColors.errorSoftBackground;
      fg = AppColors.error;
    } else {
      bg = AppColors.primarySoftBackground;
      fg = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.pillRadius,
      ),
      child: Text(
        statusLabel.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTypeChip(ThemeData theme, AppLocalizations l10n) {
    final label = _mapTypeToLabel(l10n, poll.type);
    return _buildMiniChip(theme, Icons.category, label);
  }

  Widget _buildScopeChip(ThemeData theme, AppLocalizations l10n) {
    final country = poll.countryCode;
    final city = poll.cityId;

    String label;
    if (country == null && city == null) {
      label = l10n.pollGeo_global;
    } else if (country != null && city == null) {
      label = country;
    } else {
      label = '$city ($country)';
    }

    return _buildMiniChip(theme, Icons.public, label);
  }

  Widget _buildParticipationChip(ThemeData theme, AppLocalizations l10n) {
    final rules = poll.configuration.participationRules;

    if (rules.scope != ParticipationScope.geoScopeOnly) {
      return const SizedBox.shrink();
    }

    final countryName = _resolveParticipationCountryName();
    final label = countryName != null
        ? l10n.pollCard_restrictedToCountry(countryName)
        : l10n.pollCard_countryRestricted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: AppRadius.pillRadius,
        color: AppColors.warningSoftBackground,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_outline,
            size: 14,
            color: AppColors.warning,
          ),
          const SizedBox(width: AppSpacing.unitXS),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnonymityChip(ThemeData theme, AppLocalizations l10n) {
    final level = poll.configuration.anonymityRules.level;
    final label = level == AnonymityLevel.anonymous
        ? l10n.pollDetail_chipAnonymous
        : l10n.pollDetail_chipPublic;

    return _buildMiniChip(theme, Icons.visibility, label);
  }

  Widget _buildResultsVisibilityChip(
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final visibility = poll.configuration.visibilityRules.resultsVisibility;
    final label = _mapResultsVisibilityLabel(l10n, visibility);

    return _buildMiniChip(theme, Icons.insights, label);
  }

  Widget _buildQuorumChip(ThemeData theme, AppLocalizations l10n) {
    final minQuorum = poll.configuration.quorumRules.minAbsoluteVotes;

    if (minQuorum == null) {
      return const SizedBox.shrink();
    }

    final label = l10n.pollCard_quorumLabel(minQuorum);

    return _buildMiniChip(theme, Icons.how_to_vote, label);
  }

  Widget _buildMiniChip(
    ThemeData theme,
    IconData icon,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: AppRadius.pillRadius,
        color: theme.colorScheme.surfaceVariant.withOpacity(0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          const SizedBox(width: AppSpacing.unitXS),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PollEngagementRow extends StatelessWidget {
  final Poll poll;
  final int? fireCount;
  final int? iceCount;
  final ReactionType? userReaction;
  final VoidCallback? onFireTap;
  final VoidCallback? onIceTap;
  final Widget trailing;

  const _PollEngagementRow({
    required this.poll,
    required this.fireCount,
    required this.iceCount,
    required this.userReaction,
    required this.onFireTap,
    required this.onIceTap,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AppDI.instance.getCommentsForTarget(TargetRef.poll(poll.id.value)),
      builder: (context, snapshot) {
        final comments = snapshot.data as List<dynamic>? ?? const [];
        final commentCount = snapshot.hasError ? 0 : comments.length;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: EngagementBar(
                fireCount: fireCount ?? 0,
                iceCount: iceCount ?? 0,
                commentCount: commentCount,
                userReaction: userReaction,
                onFireTap: onFireTap,
                onIceTap: onIceTap,
              ),
            ),
            const SizedBox(width: AppSpacing.unitS),
            trailing,
          ],
        );
      },
    );
  }
}

class _PollResultPreview extends StatelessWidget {
  final PollResult result;

  const _PollResultPreview({
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final sortedOptions = _sortedVisibleOptionResults(result);

    if (sortedOptions.isEmpty) {
      return const SizedBox.shrink();
    }

    final topOptions = sortedOptions.take(3).toList(growable: false);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _PollResultDonut(
          result: result,
          sortedOptions: sortedOptions,
        ),
        const SizedBox(width: AppSpacing.unitL),
        Expanded(
          child: Column(
            children: List.generate(topOptions.length, (index) {
              final option = topOptions[index];
              final color = _pollResultColorForIndex(index);

              return Padding(
                padding: const EdgeInsets.only(
                  bottom: AppSpacing.unitS,
                ),
                child: _PollResultRow(
                  option: option,
                  color: color,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _PollResultRow extends StatelessWidget {
  final PollOptionResult option;
  final Color color;

  const _PollResultRow({
    required this.option,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = option.percentage.clamp(0.0, 100.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                option.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.unitS),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.unitXS),
        ClipRRect(
          borderRadius: AppRadius.buttonRadius,
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 6,
            backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.35),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _PollResultDonut extends StatelessWidget {
  final PollResult result;
  final List<PollOptionResult> sortedOptions;

  const _PollResultDonut({
    required this.result,
    required this.sortedOptions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (sortedOptions.isEmpty) {
      return Container(
        width: 112,
        height: 112,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surfaceVariant.withOpacity(0.35),
        ),
        alignment: Alignment.center,
        child: Text(
          '0',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return SizedBox(
      width: 112,
      height: 112,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 34,
              startDegreeOffset: -90,
              sections: List.generate(sortedOptions.length, (index) {
                final option = sortedOptions[index];
                return PieChartSectionData(
                  value: option.percentage <= 0 ? 0.001 : option.percentage,
                  color: _pollResultColorForIndex(index),
                  radius: 18,
                  showTitle: false,
                );
              }),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${result.totalVotes}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'votes',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.62),
                  height: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

List<PollOptionResult> _sortedVisibleOptionResults(PollResult result) {
  final items = result.optionResults
      .where((e) => e.voteCount > 0 || e.percentage > 0)
      .toList(growable: false);

  final sorted = List<PollOptionResult>.from(items)
    ..sort((a, b) => b.percentage.compareTo(a.percentage));

  return sorted;
}

Color _pollResultColorForIndex(int index) {
  final colors = [
    const Color(0xFF2563EB),
    const Color(0xFFEF4444),
    const Color(0xFFF59E0B),
    const Color(0xFF10B981),
    const Color(0xFF8B5CF6),
    const Color(0xFFEC4899),
    const Color(0xFF14B8A6),
    const Color(0xFFF97316),
    const Color(0xFF84CC16),
    const Color(0xFF6366F1),
  ];

  return colors[index % colors.length];
}