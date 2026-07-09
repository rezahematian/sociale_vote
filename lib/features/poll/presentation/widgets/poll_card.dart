import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/theme/radius.dart';
import 'package:sociale_vote/app/theme/spacing.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
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

  bool get _hasRepresentativePublisher =>
      poll.publishedAsActorType == ActorType.publicOfficial ||
      poll.publishedAsActorType == ActorType.institution;

  static const _PollChipMetrics _chipMetrics = _PollChipMetrics(
    height: 32,
    horizontalPadding: 10,
    iconSize: 14,
    contentGap: 4,
    fontSize: 12,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompactLayout = screenWidth < 700;

    final description = (poll.description ?? '').trim();
    final hasDescription = description.isNotEmpty;
    final visibleOptionResults = result == null
        ? const <PollOptionResult>[]
        : _sortedVisibleOptionResults(result!);
    final hasResults = visibleOptionResults.isNotEmpty;

    final Color cardTopColor = theme.brightness == Brightness.dark
        ? const Color(0xFF18202B)
        : const Color(0xFFFCFDFE);
    final Color cardBottomColor = theme.brightness == Brightness.dark
        ? const Color(0xFF121A24)
        : const Color(0xFFF0F4F9);
    final Color cardBorderColor = theme.brightness == Brightness.dark
        ? const Color(0xFF2C3948)
        : const Color(0xFFD7DFEA);

    final topChipItems = _buildTopChipItems(
      context: context,
      theme: theme,
      l10n: l10n,
      isCompactLayout: isCompactLayout,
    );

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

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.unitM),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF94A3B8).withValues(alpha: 0.10),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: cardBorderColor,
              width: 1.2,
            ),
            gradient: LinearGradient(
              colors: [
                cardTopColor,
                cardBottomColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (topChipItems.isNotEmpty)
                    _SingleLineChipRow(
                      items: topChipItems,
                      chipHeight: _chipMetrics.height,
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
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.78,
                          ),
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
            ),
          ),
        ),
      ),
    );
  }

  List<_PollChipItem> _buildTopChipItems({
    required BuildContext context,
    required ThemeData theme,
    required AppLocalizations l10n,
    required bool isCompactLayout,
  }) {
    final items = <_PollChipItem>[
      _chipItem(
        context: context,
        theme: theme,
        icon: Icons.how_to_vote_rounded,
        label: null,
        child: _buildPollIconChip(theme),
      ),
    ];

    if (_hasRepresentativePublisher) {
      items.add(
        _chipItem(
          context: context,
          theme: theme,
          icon: _representativeIcon(),
          label: _representativeLabel(l10n),
          bold: true,
          child: _buildRepresentativeChip(theme, l10n),
        ),
      );
    }

    items.addAll([
      _chipItem(
        context: context,
        theme: theme,
        icon: null,
        label: _mapStatusToLabel(l10n, poll.status).toUpperCase(),
        bold: true,
        letterSpacing: 0.25,
        child: _buildStatusChip(theme, l10n),
      ),
      _chipItem(
        context: context,
        theme: theme,
        icon: Icons.public,
        label: _scopeLabel(l10n),
        child: _buildScopeChip(theme, l10n),
      ),
    ]);

    if (_hasGeoRestriction) {
      items.add(
        _chipItem(
          context: context,
          theme: theme,
          icon: Icons.lock_outline,
          label: _participationLabel(l10n),
          child: _buildParticipationChip(theme, l10n),
        ),
      );
    }

    final dateLabel = _dateLabel(context, compact: isCompactLayout);
    if (dateLabel != null) {
      items.add(
        _chipItem(
          context: context,
          theme: theme,
          icon: Icons.event_outlined,
          label: dateLabel,
          child: _buildDateChip(theme, dateLabel),
        ),
      );
    }

    if (!isCompactLayout) {
      items.add(
        _chipItem(
          context: context,
          theme: theme,
          icon: poll.configuration.anonymityRules.level ==
                  AnonymityLevel.anonymous
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          label: _anonymityLabel(l10n),
          child: _buildAnonymityChip(theme, l10n),
        ),
      );
    }

    items.add(
      _chipItem(
        context: context,
        theme: theme,
        icon: Icons.category_outlined,
        label: _mapTypeToLabel(l10n, poll.type),
        child: _buildTypeChip(theme, l10n),
      ),
    );

    items.add(
      _chipItem(
        context: context,
        theme: theme,
        icon: Icons.insights_outlined,
        label: _mapCompactResultsVisibilityLabel(
          l10n,
          poll.configuration.visibilityRules.resultsVisibility,
        ),
        child: _buildResultsVisibilityChip(theme, l10n),
      ),
    );

    final quorumLabel = _quorumLabel(l10n);
    if (quorumLabel != null) {
      items.add(
        _chipItem(
          context: context,
          theme: theme,
          icon: Icons.how_to_vote_outlined,
          label: quorumLabel,
          child: _buildQuorumChip(theme, l10n),
        ),
      );
    }

    return items;
  }

  _PollChipItem _chipItem({
    required BuildContext context,
    required ThemeData theme,
    required IconData? icon,
    required String? label,
    required Widget child,
    bool bold = false,
    double? letterSpacing,
  }) {
    return _PollChipItem(
      child: child,
      estimatedWidth: _estimateChipWidth(
        context: context,
        theme: theme,
        icon: icon,
        label: label,
        metrics: _chipMetrics,
        bold: bold,
        letterSpacing: letterSpacing,
      ),
    );
  }

  double _estimateChipWidth({
    required BuildContext context,
    required ThemeData theme,
    required IconData? icon,
    required String? label,
    required _PollChipMetrics metrics,
    bool bold = false,
    double? letterSpacing,
  }) {
    double width = 0;

    final horizontalPadding = label == null
        ? (metrics.horizontalPadding - 1) * 2
        : metrics.horizontalPadding * 2;

    width += horizontalPadding;
    width += 2; // bordo + margine di sicurezza

    if (icon != null) {
      width += metrics.iconSize;
    }

    if (icon != null && label != null) {
      width += metrics.contentGap;
    }

    if (label != null) {
      final style = theme.textTheme.labelMedium?.copyWith(
        fontSize: metrics.fontSize,
        height: 1,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
        letterSpacing: letterSpacing,
      );

      final painter = TextPainter(
        text: TextSpan(text: label, style: style),
        maxLines: 1,
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();

      width += painter.width;
    }

    return width + 6; // buffer anti-overflow
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

  String _representativeLabel(AppLocalizations l10n) {
    final locale = l10n.localeName.toLowerCase();
    final isItalian = locale.startsWith('it');

    switch (poll.publishedAsActorType) {
      case ActorType.publicOfficial:
        return isItalian ? 'Public Official' : 'Public Official';
      case ActorType.institution:
        return isItalian ? 'Institution' : 'Institution';
      default:
        return isItalian ? 'Representative' : 'Representative';
    }
  }

  IconData _representativeIcon() {
    switch (poll.publishedAsActorType) {
      case ActorType.publicOfficial:
        return Icons.workspace_premium_outlined;
      case ActorType.institution:
        return Icons.account_balance_outlined;
      default:
        return Icons.verified_user_outlined;
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

  String _scopeLabel(AppLocalizations l10n) {
    final country = _resolveCountryName(poll.countryCode);
    final city = poll.cityId;

    if (country == null && city == null) {
      return l10n.pollGeo_global;
    } else if (country != null && city == null) {
      return country;
    } else if (country == null && city != null) {
      return city;
    } else {
      return '$city · $country';
    }
  }

  String? _resolveParticipationCountryName() {
    return _resolveCountryName(
      poll.configuration.participationRules.countryCode,
    );
  }

  String _participationLabel(AppLocalizations l10n) {
    final countryName = _resolveParticipationCountryName();
    return countryName != null
        ? l10n.pollCard_restrictedToCountry(countryName)
        : l10n.pollCard_countryRestricted;
  }

  String _anonymityLabel(AppLocalizations l10n) {
    final level = poll.configuration.anonymityRules.level;
    return level == AnonymityLevel.anonymous
        ? l10n.pollDetail_chipAnonymous
        : l10n.pollDetail_chipPublic;
  }

  String? _quorumLabel(AppLocalizations l10n) {
    final minQuorum = poll.configuration.quorumRules.minAbsoluteVotes;
    if (minQuorum == null) return null;
    return l10n.pollCard_quorumLabel(minQuorum);
  }

  String _formatChipDate(BuildContext context, DateTime date,
      {required bool compact}) {
    final locale = Localizations.localeOf(context).languageCode.toLowerCase();
    final local = date.toLocal();

    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = (local.year % 100).toString().padLeft(2, '0');

    final isEnglish = locale.startsWith('en');

    if (compact) {
      return isEnglish ? '$month/$day' : '$day/$month';
    }

    return isEnglish ? '$month/$day/$year' : '$day/$month/$year';
  }

  String? _dateLabel(BuildContext context, {required bool compact}) {
    final start = poll.startAt;
    final end = poll.endAt;

    if (start == null && end == null) {
      return null;
    }

    if (start != null && end != null) {
      final startLabel = _formatChipDate(context, start, compact: compact);
      final endLabel = _formatChipDate(context, end, compact: compact);
      return startLabel == endLabel ? startLabel : '$startLabel→$endLabel';
    }

    if (start != null) {
      return _formatChipDate(context, start, compact: compact);
    }

    return _formatChipDate(context, end!, compact: compact);
  }

  _PollChipTone _pollChipTone(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return const _PollChipTone(
        backgroundColor: Color(0xFF163126),
        foregroundColor: Color(0xFF54D497),
        borderColor: Color(0xFF2A5942),
      );
    }

    return const _PollChipTone(
      backgroundColor: Color(0xFFEAF7EF),
      foregroundColor: Color(0xFF179C5C),
      borderColor: Color(0xFFCFEBD9),
    );
  }

  _PollChipTone _neutralBlueTone(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return const _PollChipTone(
        backgroundColor: Color(0xFF172332),
        foregroundColor: Color(0xFF9AB8E4),
        borderColor: Color(0xFF304457),
      );
    }

    return const _PollChipTone(
      backgroundColor: Color(0xFFF2F7FF),
      foregroundColor: Color(0xFF5B7395),
      borderColor: Color(0xFFD9E6F5),
    );
  }

  _PollChipTone _indigoTone(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return const _PollChipTone(
        backgroundColor: Color(0xFF1D2237),
        foregroundColor: Color(0xFFAEBBF8),
        borderColor: Color(0xFF3B4564),
      );
    }

    return const _PollChipTone(
      backgroundColor: Color(0xFFF1F4FF),
      foregroundColor: Color(0xFF5D6FC8),
      borderColor: Color(0xFFDCE4FF),
    );
  }

  _PollChipTone _violetTone(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return const _PollChipTone(
        backgroundColor: Color(0xFF27203A),
        foregroundColor: Color(0xFFD4B6FF),
        borderColor: Color(0xFF493B63),
      );
    }

    return const _PollChipTone(
      backgroundColor: Color(0xFFF5F1FF),
      foregroundColor: Color(0xFF7A5CC2),
      borderColor: Color(0xFFE5DCFF),
    );
  }

  _PollChipTone _tealTone(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return const _PollChipTone(
        backgroundColor: Color(0xFF17322B),
        foregroundColor: Color(0xFF7EDFC1),
        borderColor: Color(0xFF31584E),
      );
    }

    return const _PollChipTone(
      backgroundColor: Color(0xFFEFFAF6),
      foregroundColor: Color(0xFF1B8A68),
      borderColor: Color(0xFFD8F0E6),
    );
  }

  _PollChipTone _amberTone(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return const _PollChipTone(
        backgroundColor: Color(0xFF35291D),
        foregroundColor: Color(0xFFF0C17B),
        borderColor: Color(0xFF5C4832),
      );
    }

    return const _PollChipTone(
      backgroundColor: Color(0xFFFFF6EC),
      foregroundColor: Color(0xFF9D6F35),
      borderColor: Color(0xFFF2E1CD),
    );
  }

  _PollChipTone _roseTone(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return const _PollChipTone(
        backgroundColor: Color(0xFF362229),
        foregroundColor: Color(0xFFF0AA9D),
        borderColor: Color(0xFF5D3B43),
      );
    }

    return const _PollChipTone(
      backgroundColor: Color(0xFFFFF4EE),
      foregroundColor: Color(0xFFB46654),
      borderColor: Color(0xFFF4DDD4),
    );
  }

  _PollChipTone _representativeTone(ThemeData theme, ActorType actorType) {
    switch (actorType) {
      case ActorType.publicOfficial:
        if (theme.brightness == Brightness.dark) {
          return const _PollChipTone(
            backgroundColor: Color(0xFF392126),
            foregroundColor: Color(0xFFF2AEA3),
            borderColor: Color(0xFF614047),
          );
        }
        return const _PollChipTone(
          backgroundColor: Color(0xFFFFF1EF),
          foregroundColor: Color(0xFFBF5B49),
          borderColor: Color(0xFFF4D8D2),
        );
      case ActorType.institution:
        if (theme.brightness == Brightness.dark) {
          return const _PollChipTone(
            backgroundColor: Color(0xFF16253A),
            foregroundColor: Color(0xFFAEC9F8),
            borderColor: Color(0xFF334A66),
          );
        }
        return const _PollChipTone(
          backgroundColor: Color(0xFFF1F6FF),
          foregroundColor: Color(0xFF4F6FCB),
          borderColor: Color(0xFFD8E5FF),
        );
      default:
        return _neutralBlueTone(theme);
    }
  }

  _PollChipTone _statusTone(ThemeData theme, PollStatus status) {
    switch (status) {
      case PollStatus.open:
        if (theme.brightness == Brightness.dark) {
          return const _PollChipTone(
            backgroundColor: Color(0xFF163126),
            foregroundColor: Color(0xFF58D99C),
            borderColor: Color(0xFF2A5942),
          );
        }
        return const _PollChipTone(
          backgroundColor: Color(0xFFE7F8EE),
          foregroundColor: Color(0xFF0E9F6E),
          borderColor: Color(0xFFCBEFD9),
        );
      case PollStatus.closed:
        if (theme.brightness == Brightness.dark) {
          return const _PollChipTone(
            backgroundColor: Color(0xFF381E24),
            foregroundColor: Color(0xFFFF9AA4),
            borderColor: Color(0xFF5C3941),
          );
        }
        return const _PollChipTone(
          backgroundColor: Color(0xFFFFEAEA),
          foregroundColor: Color(0xFFE02424),
          borderColor: Color(0xFFF8C7C7),
        );
      case PollStatus.scheduled:
        return _neutralBlueTone(theme);
      case PollStatus.draft:
      default:
        if (theme.brightness == Brightness.dark) {
          return const _PollChipTone(
            backgroundColor: Color(0xFF232A35),
            foregroundColor: Color(0xFFC2CBD7),
            borderColor: Color(0xFF3A4653),
          );
        }
        return const _PollChipTone(
          backgroundColor: Color(0xFFF6F7F9),
          foregroundColor: Color(0xFF6B7280),
          borderColor: Color(0xFFE4E7EC),
        );
    }
  }

  Widget _buildPollIconChip(ThemeData theme) {
    final tone = _pollChipTone(theme);

    return _buildMetaPill(
      theme: theme,
      metrics: _chipMetrics,
      icon: Icons.how_to_vote_rounded,
      label: null,
      backgroundColor: tone.backgroundColor,
      foregroundColor: tone.foregroundColor,
      borderColor: tone.borderColor,
    );
  }

  Widget _buildRepresentativeChip(ThemeData theme, AppLocalizations l10n) {
    final actorType = poll.publishedAsActorType;
    if (actorType == null) {
      return const SizedBox.shrink();
    }

    final tone = _representativeTone(theme, actorType);

    return _buildMetaPill(
      theme: theme,
      metrics: _chipMetrics,
      icon: _representativeIcon(),
      label: _representativeLabel(l10n),
      backgroundColor: tone.backgroundColor,
      foregroundColor: tone.foregroundColor,
      borderColor: tone.borderColor,
      bold: true,
    );
  }

  Widget _buildStatusChip(ThemeData theme, AppLocalizations l10n) {
    final tone = _statusTone(theme, poll.status);

    return _buildMetaPill(
      theme: theme,
      metrics: _chipMetrics,
      icon: null,
      label: _mapStatusToLabel(l10n, poll.status).toUpperCase(),
      backgroundColor: tone.backgroundColor,
      foregroundColor: tone.foregroundColor,
      borderColor: tone.borderColor,
      bold: true,
      letterSpacing: 0.25,
    );
  }

  Widget _buildScopeChip(ThemeData theme, AppLocalizations l10n) {
    final tone = _neutralBlueTone(theme);

    return _buildMetaPill(
      theme: theme,
      metrics: _chipMetrics,
      icon: Icons.public,
      label: _scopeLabel(l10n),
      backgroundColor: tone.backgroundColor,
      foregroundColor: tone.foregroundColor,
      borderColor: tone.borderColor,
    );
  }

  Widget _buildParticipationChip(ThemeData theme, AppLocalizations l10n) {
    if (!_hasGeoRestriction) {
      return const SizedBox.shrink();
    }

    final tone = _amberTone(theme);

    return _buildMetaPill(
      theme: theme,
      metrics: _chipMetrics,
      icon: Icons.lock_outline,
      label: _participationLabel(l10n),
      backgroundColor: tone.backgroundColor,
      foregroundColor: tone.foregroundColor,
      borderColor: tone.borderColor,
    );
  }

  Widget _buildDateChip(ThemeData theme, String label) {
    final tone = _neutralBlueTone(theme);

    return _buildMetaPill(
      theme: theme,
      metrics: _chipMetrics,
      icon: Icons.event_outlined,
      label: label,
      backgroundColor: tone.backgroundColor,
      foregroundColor: tone.foregroundColor,
      borderColor: tone.borderColor,
    );
  }

  Widget _buildTypeChip(ThemeData theme, AppLocalizations l10n) {
    final tone = _indigoTone(theme);

    return _buildInfoPill(
      theme: theme,
      metrics: _chipMetrics,
      icon: Icons.category_outlined,
      label: _mapTypeToLabel(l10n, poll.type),
      backgroundColor: tone.backgroundColor,
      foregroundColor: tone.foregroundColor,
      borderColor: tone.borderColor,
    );
  }

  Widget _buildAnonymityChip(ThemeData theme, AppLocalizations l10n) {
    final tone = _violetTone(theme);
    final isAnonymous =
        poll.configuration.anonymityRules.level == AnonymityLevel.anonymous;

    return _buildInfoPill(
      theme: theme,
      metrics: _chipMetrics,
      icon: isAnonymous
          ? Icons.visibility_off_outlined
          : Icons.visibility_outlined,
      label: _anonymityLabel(l10n),
      backgroundColor: tone.backgroundColor,
      foregroundColor: tone.foregroundColor,
      borderColor: tone.borderColor,
    );
  }

  Widget _buildResultsVisibilityChip(
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final tone = _tealTone(theme);

    return _buildInfoPill(
      theme: theme,
      metrics: _chipMetrics,
      icon: Icons.insights_outlined,
      label: _mapCompactResultsVisibilityLabel(
        l10n,
        poll.configuration.visibilityRules.resultsVisibility,
      ),
      backgroundColor: tone.backgroundColor,
      foregroundColor: tone.foregroundColor,
      borderColor: tone.borderColor,
    );
  }

  Widget _buildQuorumChip(ThemeData theme, AppLocalizations l10n) {
    final minQuorum = poll.configuration.quorumRules.minAbsoluteVotes;

    if (minQuorum == null) {
      return const SizedBox.shrink();
    }

    final tone = _roseTone(theme);

    return _buildInfoPill(
      theme: theme,
      metrics: _chipMetrics,
      icon: Icons.how_to_vote_outlined,
      label: l10n.pollCard_quorumLabel(minQuorum),
      backgroundColor: tone.backgroundColor,
      foregroundColor: tone.foregroundColor,
      borderColor: tone.borderColor,
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

class _PollChipTone {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  const _PollChipTone({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
  });
}

class _PollChipItem {
  final Widget child;
  final double estimatedWidth;

  const _PollChipItem({
    required this.child,
    required this.estimatedWidth,
  });
}

class _SingleLineChipRow extends StatelessWidget {
  final List<_PollChipItem> items;
  final double chipHeight;

  const _SingleLineChipRow({
    required this.items,
    required this.chipHeight,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppSpacing.unitXS;
        final maxWidth = constraints.maxWidth;
        final visible = <Widget>[];
        double usedWidth = 0;

        for (final item in items) {
          final nextWidth =
              item.estimatedWidth + (visible.isEmpty ? 0 : spacing);

          if (usedWidth + nextWidth > maxWidth) {
            break;
          }

          if (visible.isNotEmpty) {
            visible.add(const SizedBox(width: spacing));
          }
          visible.add(item.child);
          usedWidth += nextWidth;
        }

        return SizedBox(
          height: chipHeight,
          child: Row(
            children: visible,
          ),
        );
      },
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
      future:
          AppDI.instance.getCommentsForTarget(TargetRef.poll(poll.id.value)),
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
    this.description,
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
                  bottom: index == topOptions.length - 1 ? 0 : AppSpacing.unitS,
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
            backgroundColor:
                theme.colorScheme.surfaceContainerHighest.withValues(
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
          color:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
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

    const strokeWidth = 5.0;
    final center = size.center(Offset.zero);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = const Color(0xFFE9EDF5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    final gradientPaint = Paint()
      ..shader = const SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [
          Color(0xFF22C55E),
          Color(0xFF22C55E),
          Color(0xFFF59E0B),
          Color(0xFFEF4444),
        ],
        stops: [0.0, 0.45, 0.78, 1.0],
        transform: GradientRotation(-math.pi / 2),
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
