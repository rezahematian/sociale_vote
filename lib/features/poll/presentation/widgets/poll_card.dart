import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:sociale_vote/app/di.dart';
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
  final PollResult? result;

  final VoidCallback? onFireTap;
  final VoidCallback? onIceTap;
  final VoidCallback? onCommentTap;

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
    this.onCommentTap,
  });

  bool get _hasGeoRestriction =>
      poll.configuration.participationRules.scope ==
      ParticipationScope.geoScopeOnly;

  static const _PollChipMetrics _chipMetrics = _PollChipMetrics(
    height: 32,
    horizontalPadding: 10,
    iconSize: 14,
    contentGap: 4,
    fontSize: 12,
  );

  static const Color _pollChipBackground = Color(0xFFEAF7EF);
  static const Color _pollChipForeground = Color(0xFF179C5C);
  static const Color _pollChipBorder = Color(0xFFCFEBD9);

  static const Color _neutralSoftBlueBg = Color(0xFFF2F7FF);
  static const Color _neutralSoftBlueFg = Color(0xFF5B7395);
  static const Color _neutralSoftBlueBorder = Color(0xFFD9E6F5);

  static const Color _softIndigoBg = Color(0xFFF1F4FF);
  static const Color _softIndigoFg = Color(0xFF5D6FC8);
  static const Color _softIndigoBorder = Color(0xFFDCE4FF);

  static const Color _softVioletBg = Color(0xFFF5F1FF);
  static const Color _softVioletFg = Color(0xFF7A5CC2);
  static const Color _softVioletBorder = Color(0xFFE5DCFF);

  static const Color _softTealBg = Color(0xFFEFFAF6);
  static const Color _softTealFg = Color(0xFF1B8A68);
  static const Color _softTealBorder = Color(0xFFD8F0E6);

  static const Color _softAmberBg = Color(0xFFFFF6EC);
  static const Color _softAmberFg = Color(0xFF9D6F35);
  static const Color _softAmberBorder = Color(0xFFF2E1CD);

  static const Color _softRoseBg = Color(0xFFFFF4EE);
  static const Color _softRoseFg = Color(0xFFB46654);
  static const Color _softRoseBorder = Color(0xFFF4DDD4);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final description = (poll.description ?? '').trim();
    final hasDescription = description.isNotEmpty;
    final hasResults = result != null && result!.optionResults.isNotEmpty;

    final List<Widget> topChips = [
      _buildPollIconChip(theme),
      _buildStatusChip(theme, l10n),
      _buildScopeChip(theme, l10n),
      if (_hasGeoRestriction) _buildParticipationChip(theme, l10n),
      _buildTypeChip(theme, l10n),
      _buildAnonymityChip(theme, l10n),
      _buildResultsVisibilityChip(theme, l10n),
      _buildQuorumChip(theme, l10n),
    ].where((w) => w is! SizedBox).toList(growable: false);

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

    VoidCallback? wrapCommentCallback(VoidCallback? original) {
      if (original == null) return null;

      return () async {
        final allowed = await AuthGuard.ensureCanPerformAction(
          context,
          ParticipationAction.comment,
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
          if (topChips.isNotEmpty)
            Wrap(
              spacing: AppSpacing.unitXS,
              runSpacing: AppSpacing.unitXS,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: topChips,
            ),
          const SizedBox(height: AppSpacing.unitM),
          if (hasResults)
            _PollResultPreview(
              poll: poll,
              result: result!,
              title: poll.title,
              description: hasDescription ? description : null,
            )
          else ...[
            Text(
              poll.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.18,
                letterSpacing: -0.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (hasDescription) ...[
              const SizedBox(height: AppSpacing.unitS),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.78),
                  height: 1.42,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
          const SizedBox(height: AppSpacing.unitM),
          _PollEngagementRow(
            poll: poll,
            fireCount: fireCount,
            iceCount: iceCount,
            userReaction: userReaction,
            onFireTap: wrapReactCallback(onFireTap),
            onIceTap: wrapReactCallback(onIceTap),
            onCommentTap: wrapCommentCallback(onCommentTap),
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

  String _mapCompactResultsVisibilityLabel(
    AppLocalizations l10n,
    ResultsVisibilityMode mode,
  ) {
    final locale = l10n.localeName.toLowerCase();
    final isItalian = locale.startsWith('it');

    switch (mode) {
      case ResultsVisibilityMode.always:
        return isItalian ? 'Risultati visibili' : 'Results visible';
      case ResultsVisibilityMode.afterVote:
        return isItalian ? 'Dopo voto' : 'After vote';
      case ResultsVisibilityMode.afterClose:
        return isItalian ? 'Dopo chiusura' : 'After close';
      default:
        return mode.name;
    }
  }

  String? _resolveCountryName(String? code) {
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

  String? _resolveParticipationCountryName() {
    return _resolveCountryName(
      poll.configuration.participationRules.countryCode,
    );
  }

  Widget _buildPollIconChip(ThemeData theme) {
    return _buildMetaPill(
      theme: theme,
      metrics: _chipMetrics,
      icon: Icons.how_to_vote_rounded,
      label: null,
      backgroundColor: _pollChipBackground,
      foregroundColor: _pollChipForeground,
      borderColor: _pollChipBorder,
    );
  }

  Widget _buildStatusChip(ThemeData theme, AppLocalizations l10n) {
    final status = poll.status;
    final label = _mapStatusToLabel(l10n, status).toUpperCase();

    Color bg;
    Color fg;
    Color border;

    switch (status) {
      case PollStatus.open:
        bg = const Color(0xFFE7F8EE);
        fg = const Color(0xFF0E9F6E);
        border = const Color(0xFFCBEFD9);
        break;
      case PollStatus.closed:
        bg = const Color(0xFFFFEAEA);
        fg = const Color(0xFFE02424);
        border = const Color(0xFFF8C7C7);
        break;
      case PollStatus.scheduled:
        bg = _neutralSoftBlueBg;
        fg = _neutralSoftBlueFg;
        border = _neutralSoftBlueBorder;
        break;
      case PollStatus.draft:
      default:
        bg = const Color(0xFFF6F7F9);
        fg = const Color(0xFF6B7280);
        border = const Color(0xFFE4E7EC);
        break;
    }

    return _buildMetaPill(
      theme: theme,
      metrics: _chipMetrics,
      icon: null,
      label: label,
      backgroundColor: bg,
      foregroundColor: fg,
      borderColor: border,
      bold: true,
      letterSpacing: 0.25,
    );
  }

  Widget _buildScopeChip(ThemeData theme, AppLocalizations l10n) {
    final country = _resolveCountryName(poll.countryCode);
    final city = poll.cityId;

    String label;
    if (country == null && city == null) {
      label = l10n.pollGeo_global;
    } else if (country != null && city == null) {
      label = country;
    } else if (country == null && city != null) {
      label = city;
    } else {
      label = '$city · $country';
    }

    return _buildMetaPill(
      theme: theme,
      metrics: _chipMetrics,
      icon: Icons.public,
      label: label,
      backgroundColor: _neutralSoftBlueBg,
      foregroundColor: _neutralSoftBlueFg,
      borderColor: _neutralSoftBlueBorder,
    );
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

    return _buildMetaPill(
      theme: theme,
      metrics: _chipMetrics,
      icon: Icons.lock_outline,
      label: label,
      backgroundColor: _softAmberBg,
      foregroundColor: _softAmberFg,
      borderColor: _softAmberBorder,
    );
  }

  Widget _buildTypeChip(ThemeData theme, AppLocalizations l10n) {
    return _buildInfoPill(
      theme: theme,
      metrics: _chipMetrics,
      icon: Icons.category_outlined,
      label: _mapTypeToLabel(l10n, poll.type),
      backgroundColor: _softIndigoBg,
      foregroundColor: _softIndigoFg,
      borderColor: _softIndigoBorder,
    );
  }

  Widget _buildAnonymityChip(ThemeData theme, AppLocalizations l10n) {
    final level = poll.configuration.anonymityRules.level;
    final label = level == AnonymityLevel.anonymous
        ? l10n.pollDetail_chipAnonymous
        : l10n.pollDetail_chipPublic;

    return _buildInfoPill(
      theme: theme,
      metrics: _chipMetrics,
      icon: Icons.visibility_outlined,
      label: label,
      backgroundColor: _softVioletBg,
      foregroundColor: _softVioletFg,
      borderColor: _softVioletBorder,
    );
  }

  Widget _buildResultsVisibilityChip(
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final visibility = poll.configuration.visibilityRules.resultsVisibility;
    final label = _mapCompactResultsVisibilityLabel(l10n, visibility);

    return _buildInfoPill(
      theme: theme,
      metrics: _chipMetrics,
      icon: Icons.insights_outlined,
      label: label,
      backgroundColor: _softTealBg,
      foregroundColor: _softTealFg,
      borderColor: _softTealBorder,
    );
  }

  Widget _buildQuorumChip(ThemeData theme, AppLocalizations l10n) {
    final minQuorum = poll.configuration.quorumRules.minAbsoluteVotes;

    if (minQuorum == null) {
      return const SizedBox.shrink();
    }

    return _buildInfoPill(
      theme: theme,
      metrics: _chipMetrics,
      icon: Icons.how_to_vote_outlined,
      label: l10n.pollCard_quorumLabel(minQuorum),
      backgroundColor: _softRoseBg,
      foregroundColor: _softRoseFg,
      borderColor: _softRoseBorder,
    );
  }

  Widget _buildMetaPill({
    required ThemeData theme,
    required _PollChipMetrics metrics,
    required IconData? icon,
    required String? label,
    required Color backgroundColor,
    required Color foregroundColor,
    required Color borderColor,
    bool bold = false,
    double? letterSpacing,
  }) {
    return Container(
      height: metrics.height,
      padding: EdgeInsets.symmetric(
        horizontal: label == null
            ? metrics.horizontalPadding - 1
            : metrics.horizontalPadding,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.pillRadius,
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: metrics.iconSize,
              color: foregroundColor,
            ),
            if (label != null) SizedBox(width: metrics.contentGap),
          ],
          if (label != null)
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontSize: metrics.fontSize,
                height: 1,
                color: foregroundColor,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                letterSpacing: letterSpacing,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoPill({
    required ThemeData theme,
    required _PollChipMetrics metrics,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
    required Color borderColor,
  }) {
    return Container(
      height: metrics.height,
      padding: EdgeInsets.symmetric(horizontal: metrics.horizontalPadding),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.pillRadius,
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: metrics.iconSize,
            color: foregroundColor,
          ),
          SizedBox(width: metrics.contentGap),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontSize: metrics.fontSize,
              height: 1,
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PollChipMetrics {
  final double height;
  final double horizontalPadding;
  final double iconSize;
  final double contentGap;
  final double fontSize;

  const _PollChipMetrics({
    required this.height,
    required this.horizontalPadding,
    required this.iconSize,
    required this.contentGap,
    required this.fontSize,
  });
}

class _PollEngagementRow extends StatelessWidget {
  final Poll poll;
  final int? fireCount;
  final int? iceCount;
  final ReactionType? userReaction;
  final VoidCallback? onFireTap;
  final VoidCallback? onIceTap;
  final VoidCallback? onCommentTap;

  const _PollEngagementRow({
    required this.poll,
    required this.fireCount,
    required this.iceCount,
    required this.userReaction,
    required this.onFireTap,
    required this.onIceTap,
    required this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AppDI.instance.getCommentsForTarget(TargetRef.poll(poll.id.value)),
      builder: (context, snapshot) {
        final comments = snapshot.data as List<dynamic>? ?? const [];
        final commentCount = snapshot.hasError ? 0 : comments.length;

        return Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: EngagementBar(
                  fireCount: fireCount ?? 0,
                  iceCount: iceCount ?? 0,
                  commentCount: commentCount,
                  userReaction: userReaction,
                  onFireTap: onFireTap,
                  onIceTap: onIceTap,
                  onCommentTap: onCommentTap,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PollResultPreview extends StatelessWidget {
  final Poll poll;
  final PollResult result;
  final String title;
  final String? description;

  const _PollResultPreview({
    required this.poll,
    required this.result,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortedOptions = _sortedVisibleOptionResults(result);

    if (sortedOptions.isEmpty) {
      return const SizedBox.shrink();
    }

    final topOptions = sortedOptions.take(3).toList(growable: false);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.18,
                  letterSpacing: -0.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (description != null) ...[
                const SizedBox(height: AppSpacing.unitS),
                Text(
                  description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.78),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.unitM),
        _PollResultDonut(
          poll: poll,
          result: result,
          sortedOptions: sortedOptions,
        ),
        const SizedBox(width: AppSpacing.unitM),
        Expanded(
          flex: 5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(topOptions.length, (index) {
              final option = topOptions[index];
              final color = _pollResultColorForIndex(index);

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == topOptions.length - 1
                      ? 0
                      : AppSpacing.unitS,
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
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.82),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.unitS),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: theme.textTheme.titleSmall?.copyWith(
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
            minHeight: 7,
            backgroundColor: theme.colorScheme.surfaceVariant.withValues(
              alpha: 0.55,
            ),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _PollResultDonut extends StatelessWidget {
  final Poll poll;
  final PollResult result;
  final List<PollOptionResult> sortedOptions;

  const _PollResultDonut({
    required this.poll,
    required this.result,
    required this.sortedOptions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _resolveTimeProgress(poll);

    if (sortedOptions.isEmpty) {
      return Container(
        width: 112,
        height: 112,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.45),
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
          if (progress != null)
            CustomPaint(
              size: const Size(112, 112),
              painter: _PollTimeRingPainter(
                progress: progress,
              ),
            ),
          SizedBox(
            width: 104,
            height: 104,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 31,
                    startDegreeOffset: -90,
                    sections: List.generate(sortedOptions.length, (index) {
                      final option = sortedOptions[index];
                      return PieChartSectionData(
                        value:
                            option.percentage <= 0 ? 0.001 : option.percentage,
                        color: _pollResultColorForIndex(index),
                        radius: 17,
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
                    const SizedBox(height: 3),
                    Text(
                      'votes',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PollTimeRingPainter extends CustomPainter {
  final double progress;

  const _PollTimeRingPainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final clamped = progress.clamp(0.0, 1.0).toDouble();
    final visibleProgress = clamped <= 0.0 ? 0.03 : clamped;

    final strokeWidth = 5.0;
    final center = size.center(Offset.zero);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = const Color(0xFFE9EDF5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    final gradientPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: const [
          Color(0xFF22C55E),
          Color(0xFF22C55E),
          Color(0xFFF59E0B),
          Color(0xFFEF4444),
        ],
        stops: const [0.0, 0.45, 0.78, 1.0],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * visibleProgress,
      false,
      gradientPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PollTimeRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

double? _resolveTimeProgress(Poll poll) {
  final start = poll.startAt;
  final end = poll.endAt;

  if (start == null || end == null) {
    return null;
  }

  final startUtc = start.toUtc();
  final endUtc = end.toUtc();

  if (!endUtc.isAfter(startUtc)) {
    return null;
  }

  final now = DateTime.now().toUtc();

  if (now.isBefore(startUtc)) {
    return 0.0;
  }

  if (now.isAfter(endUtc)) {
    return 1.0;
  }

  final totalMs = endUtc.difference(startUtc).inMilliseconds;
  if (totalMs <= 0) {
    return null;
  }

  final elapsedMs = now.difference(startUtc).inMilliseconds;
  return elapsedMs / totalMs;
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
  const colors = [
    Color(0xFF316BFF),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFF6366F1),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF84CC16),
    Color(0xFFF97316),
  ];

  return colors[index % colors.length];
}