import 'package:flutter/material.dart';

import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/value_objects/anonymity_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_status.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_type.dart';
import 'package:sociale_vote/domain/poll/value_objects/visibility_rules.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/data/countries.dart';
import 'package:sociale_vote/shared/widgets/engagement_bar.dart';

class PollDetailHeader extends StatelessWidget {
  final Poll poll;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;
  final VoidCallback? onSharePressed;
  final int fireCount;
  final int iceCount;
  final int commentCount;
  final dynamic userReaction;
  final Future<void> Function() onFireTap;
  final Future<void> Function() onIceTap;
  final VoidCallback? onCommentTap;
  final bool isQuorumApplicable;
  final bool isQuorumReached;
  final int totalVotes;

  const PollDetailHeader({
    super.key,
    required this.poll,
    required this.isFavorite,
    required this.onFavoritePressed,
    this.onSharePressed,
    required this.fireCount,
    required this.iceCount,
    this.commentCount = 0,
    required this.userReaction,
    required this.onFireTap,
    required this.onIceTap,
    this.onCommentTap,
    required this.isQuorumApplicable,
    required this.isQuorumReached,
    required this.totalVotes,
  });

  static const _PollChipMetrics _chipMetrics = _PollChipMetrics(
    height: 32,
    horizontalPadding: 10,
    iconSize: 14,
    contentGap: 4,
    fontSize: 12,
  );

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

  static const Color _softGreenBg = Color(0xFFE7F8EE);
  static const Color _softGreenFg = Color(0xFF0E9F6E);
  static const Color _softGreenBorder = Color(0xFFCBEFD9);

  static const Color _softRedBg = Color(0xFFFFEAEA);
  static const Color _softRedFg = Color(0xFFE02424);
  static const Color _softRedBorder = Color(0xFFF8C7C7);

  static const Color _softGrayBg = Color(0xFFF6F7F9);
  static const Color _softGrayFg = Color(0xFF6B7280);
  static const Color _softGrayBorder = Color(0xFFE4E7EC);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    final config = poll.configuration;
    final description = poll.description?.trim();
    final createdAt = _tryGetCreatedAt(poll);
    final minQuorum = config.quorumRules.minAbsoluteVotes;

    final locationLabel = _mapLocationLabel(l10n);
    final statusLabel = _mapStatusToLabel(l10n, poll.status);
    final timeWindowLabel = _mapTimeWindowLabel(
      startAt: poll.startAt,
      endAt: poll.endAt,
    );
    final typeLabel = _mapTypeToLabel(l10n, poll.type);
    final voteChangeLabel = config.allowVoteChange
        ? 'Voto modificabile'
        : 'Voto non modificabile';
    final anonymityLabel = config.anonymityRules.level == AnonymityLevel.anonymous
        ? l10n.pollDetail_chipAnonymous
        : l10n.pollDetail_chipPublic;
    final resultsVisibilityLabel = _mapResultsVisibilityLabel(
      l10n,
      config.visibilityRules.resultsVisibility,
    );

    final String? quorumInfoText = (minQuorum != null && isQuorumApplicable)
        ? (isQuorumReached
              ? 'Quorum raggiunto • $totalVotes/$minQuorum'
              : 'Quorum non raggiunto • $totalVotes/$minQuorum')
        : null;

    final titleColor = colorScheme.onSurface;
    final descriptionColor = colorScheme.onSurface.withOpacity(
      isDark ? 0.76 : 0.72,
    );
    final metaTextColor = colorScheme.onSurface.withOpacity(
      isDark ? 0.60 : 0.58,
    );

    final chips = <Widget>[
      _buildLocationChip(theme, locationLabel),
      _buildStatusChip(theme, statusLabel, poll.status),
      if (timeWindowLabel != null) _buildTimeWindowChip(theme, timeWindowLabel),
      _buildTypeChip(theme, typeLabel),
      _buildVoteChangeChip(theme, voteChangeLabel, config.allowVoteChange),
      _buildAnonymityChip(theme, anonymityLabel),
      _buildResultsVisibilityChip(theme, resultsVisibilityLabel),
      if (minQuorum != null) _buildQuorumChip(theme, l10n, minQuorum),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compactBottomRow = constraints.maxWidth < 760;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: chips,
            ),
            const SizedBox(height: 22),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Text(
                poll.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.06,
                  letterSpacing: -0.4,
                  color: titleColor,
                ),
              ),
            ),
            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Text(
                  description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.48,
                    color: descriptionColor,
                  ),
                ),
              ),
            ],
            if (createdAt != null) ...[
              const SizedBox(height: 10),
              Text(
                'Creato il ${_formatDateTime(createdAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: metaTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (quorumInfoText != null) ...[
              const SizedBox(height: 14),
              _buildInfoStrip(
                context,
                text: quorumInfoText,
                accentColor: isQuorumReached
                    ? const Color(0xFF0E9F6E)
                    : _softVioletFg,
                icon: isQuorumReached
                    ? Icons.check_circle_outline
                    : Icons.info_outline,
              ),
            ],
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outline.withOpacity(
                      isDark ? 0.24 : 0.12,
                    ),
                    width: 1,
                  ),
                ),
              ),
              child: compactBottomRow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EngagementBar(
                          fireCount: fireCount,
                          iceCount: iceCount,
                          commentCount: commentCount,
                          userReaction: userReaction,
                          onFireTap: onFireTap,
                          onIceTap: onIceTap,
                          onCommentTap: onCommentTap,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.end,
                            children: [
                              _buildActionPill(
                                context,
                                icon: Icons.share_outlined,
                                label: 'Condividi',
                                tooltip: 'Condividi',
                                onPressed: onSharePressed,
                              ),
                              _buildActionPill(
                                context,
                                icon: isFavorite
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                label: 'Salva',
                                tooltip: isFavorite
                                    ? l10n.pollDetail_removeFromFavoritesTooltip
                                    : l10n.pollDetail_addToFavoritesTooltip,
                                onPressed: onFavoritePressed,
                                isActive: isFavorite,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: EngagementBar(
                            fireCount: fireCount,
                            iceCount: iceCount,
                            commentCount: commentCount,
                            userReaction: userReaction,
                            onFireTap: onFireTap,
                            onIceTap: onIceTap,
                            onCommentTap: onCommentTap,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildActionPill(
                              context,
                              icon: Icons.share_outlined,
                              label: 'Condividi',
                              tooltip: 'Condividi',
                              onPressed: onSharePressed,
                            ),
                            const SizedBox(width: 8),
                            _buildActionPill(
                              context,
                              icon: isFavorite
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              label: 'Salva',
                              tooltip: isFavorite
                                  ? l10n.pollDetail_removeFromFavoritesTooltip
                                  : l10n.pollDetail_addToFavoritesTooltip,
                              onPressed: onFavoritePressed,
                              isActive: isFavorite,
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocationChip(ThemeData theme, String label) {
    return _buildInfoPill(
      theme: theme,
      metrics: _chipMetrics,
      icon: Icons.public,
      label: label,
      backgroundColor: _neutralSoftBlueBg,
      foregroundColor: _neutralSoftBlueFg,
      borderColor: _neutralSoftBlueBorder,
    );
  }

  Widget _buildStatusChip(
    ThemeData theme,
    String label,
    PollStatus status,
  ) {
    Color bg;
    Color fg;
    Color border;

    switch (status) {
      case PollStatus.open:
        bg = _softGreenBg;
        fg = _softGreenFg;
        border = _softGreenBorder;
        break;
      case PollStatus.closed:
        bg = _softRedBg;
        fg = _softRedFg;
        border = _softRedBorder;
        break;
      case PollStatus.scheduled:
        bg = _neutralSoftBlueBg;
        fg = _neutralSoftBlueFg;
        border = _neutralSoftBlueBorder;
        break;
      case PollStatus.draft:
        bg = _softGrayBg;
        fg = _softGrayFg;
        border = _softGrayBorder;
        break;
    }

    return _buildMetaPill(
      theme: theme,
      metrics: _chipMetrics,
      icon: null,
      label: label.toUpperCase(),
      backgroundColor: bg,
      foregroundColor: fg,
      borderColor: border,
      bold: true,
      letterSpacing: 0.25,
    );
  }

  Widget _buildTimeWindowChip(ThemeData theme, String label) {
    return _buildInfoPill(
      theme: theme,
      metrics: _chipMetrics,
      icon: Icons.schedule_outlined,
      label: label,
      backgroundColor: _softAmberBg,
      foregroundColor: _softAmberFg,
      borderColor: _softAmberBorder,
    );
  }

  Widget _buildTypeChip(ThemeData theme, String label) {
    return _buildInfoPill(
      theme: theme,
      metrics: _chipMetrics,
      icon: Icons.category_outlined,
      label: label,
      backgroundColor: _softIndigoBg,
      foregroundColor: _softIndigoFg,
      borderColor: _softIndigoBorder,
    );
  }

  Widget _buildVoteChangeChip(
    ThemeData theme,
    String label,
    bool allowVoteChange,
  ) {
    return _buildInfoPill(
      theme: theme,
      metrics: _chipMetrics,
      icon: allowVoteChange
          ? Icons.restart_alt_rounded
          : Icons.block_outlined,
      label: label,
      backgroundColor: _softTealBg,
      foregroundColor: _softTealFg,
      borderColor: _softTealBorder,
    );
  }

  Widget _buildAnonymityChip(ThemeData theme, String label) {
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

  Widget _buildResultsVisibilityChip(ThemeData theme, String label) {
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

  Widget _buildQuorumChip(
    ThemeData theme,
    AppLocalizations l10n,
    int minQuorum,
  ) {
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
        borderRadius: BorderRadius.circular(999),
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
        borderRadius: BorderRadius.circular(999),
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

  Widget _buildActionPill(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String tooltip,
    required VoidCallback? onPressed,
    bool isActive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final enabled = onPressed != null;

    final backgroundColor = isActive ? _softAmberBg : colorScheme.surface;
    final borderColor = isActive
        ? _softAmberBorder
        : colorScheme.outline.withOpacity(0.16);
    final foregroundColor = !enabled
        ? colorScheme.onSurface.withOpacity(0.34)
        : isActive
            ? _softAmberFg
            : colorScheme.onSurface.withOpacity(0.84);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(999),
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
                  size: 18,
                  color: foregroundColor,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: foregroundColor,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoStrip(
    BuildContext context, {
    required String text,
    required Color accentColor,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor.withOpacity(0.18),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: accentColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _tryGetCreatedAt(Poll poll) {
    try {
      final dynamic value = poll;
      final dynamic createdAt = value.createdAt;
      if (createdAt is DateTime) {
        return createdAt;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String _mapLocationLabel(AppLocalizations l10n) {
    final country = _resolveCountryName(poll.countryCode);
    final city = poll.cityId;

    if (country == null && city == null) {
      return l10n.pollGeo_global;
    }
    if (country != null && city == null) {
      return country;
    }
    if (country == null && city != null) {
      return city;
    }
    return '$city · $country';
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

  String? _mapTimeWindowLabel({
    required DateTime? startAt,
    required DateTime? endAt,
  }) {
    if (startAt == null && endAt == null) {
      return null;
    }

    if (startAt != null && endAt != null) {
      return '${_formatShortDate(startAt)} → ${_formatShortDate(endAt)}';
    }

    if (startAt != null) {
      return 'Da ${_formatShortDate(startAt)}';
    }

    return 'Fino ${_formatShortDate(endAt!)}';
  }

  String _formatShortDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month';
  }

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/$year • $hour:$minute';
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
    }
  }

  String _mapResultsVisibilityLabel(
    AppLocalizations l10n,
    ResultsVisibilityMode mode,
  ) {
    final locale = l10n.localeName.toLowerCase();
    final isItalian = locale.startsWith('it');

    switch (mode) {
      case ResultsVisibilityMode.always:
        return isItalian ? 'Sempre visibili' : 'Always visible';
      case ResultsVisibilityMode.afterVote:
        return isItalian ? 'Visibili dopo voto' : 'Visible after vote';
      case ResultsVisibilityMode.afterClose:
        return isItalian ? 'Visibili dopo chiusura' : 'Visible after close';
      default:
        return isItalian ? 'Risultati' : 'Results';
    }
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