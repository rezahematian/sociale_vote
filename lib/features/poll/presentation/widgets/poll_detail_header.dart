import 'package:flutter/material.dart';

import 'package:sociale_vote/domain/identity/entities/user_profile.dart';
import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/value_objects/anonymity_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/participation_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_status.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_type.dart';
import 'package:sociale_vote/domain/poll/value_objects/visibility_rules.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/data/countries.dart';
import 'package:sociale_vote/shared/widgets/engagement_bar.dart';
import 'package:sociale_vote/shared/widgets/social_vote_symbols.dart';
import 'package:sociale_vote/shared/widgets/content_directionality.dart';

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
  final UserProfile? authorProfile;
  final VoidCallback? onAuthorTap;

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
    this.authorProfile,
    this.onAuthorTap,
  });

  static const _PollChipMetrics _chipMetrics = _PollChipMetrics(
    height: 32,
    horizontalPadding: 10,
    iconSize: 14,
    contentGap: 4,
    fontSize: 12,
  );

  static const _PollChipMetrics _mobileHeroChipMetrics = _PollChipMetrics(
    height: 30,
    horizontalPadding: 9,
    iconSize: 13,
    contentGap: 4,
    fontSize: 11.5,
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

  bool get _hasRepresentativePublisher =>
      poll.publishedAsActorType == ActorType.publicOfficial ||
      poll.publishedAsActorType == ActorType.institution ||
      poll.publishedAsActorType == ActorType.organization;

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

    final shareLabel = l10n.postDetail_shareAction;
    final saveLabel = l10n.commonSaveButton;

    final representativeLabel =
        _hasRepresentativePublisher ? _mapRepresentativeLabel(l10n) : null;
    final representativeDisplayName =
        _normalizeString(poll.publishedAsDisplayName);

    final locationLabel = _mapLocationLabel(l10n);
    final statusLabel = _mapStatusToLabel(l10n, poll.status);
    final participationLabel = _mapParticipationLabel(l10n);
    final verificationRequirementLabel = _mapVerificationRequirementLabel(l10n);
    final timeWindowLabel = _mapTimeWindowLabel(
      l10n,
      startAt: poll.startAt,
      endAt: poll.endAt,
    );
    final typeLabel = _mapTypeToLabel(l10n, poll.type);
    final voteChangeLabel = _mapVoteChangeLabel(
      l10n,
      allowVoteChange: config.allowVoteChange,
    );
    final anonymityLabel =
        config.anonymityRules.level == AnonymityLevel.anonymous
            ? l10n.pollDetail_chipAnonymous
            : l10n.pollDetail_chipPublic;
    final resultsVisibilityLabel = _mapResultsVisibilityLabel(
      l10n,
      config.visibilityRules.resultsVisibility,
    );

    final String? quorumInfoText = (minQuorum != null && isQuorumApplicable)
        ? (isQuorumReached
            ? l10n.pollDetail_quorumReached(totalVotes, minQuorum)
            : l10n.pollDetail_quorumNotReached(totalVotes, minQuorum))
        : null;

    final titleColor = colorScheme.onSurface;
    final descriptionColor = colorScheme.onSurface.withValues(
      alpha: isDark ? 0.76 : 0.72,
    );
    final metaTextColor = colorScheme.onSurface.withValues(
      alpha: isDark ? 0.60 : 0.58,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobileLayout = constraints.maxWidth < 600;
        final useCompactActionIcons = constraints.maxWidth < 960;

        final heroChips = <Widget>[
          _buildStatusChip(
            theme,
            statusLabel,
            poll.status,
            _mobileHeroChipMetrics,
          ),
          _buildLocationChip(theme, locationLabel, _mobileHeroChipMetrics),
          if (timeWindowLabel != null)
            _buildTimeWindowChip(
              theme,
              timeWindowLabel,
              _mobileHeroChipMetrics,
            ),
          if (participationLabel != null)
            _buildParticipationChip(
              theme,
              participationLabel,
              _mobileHeroChipMetrics,
            ),
          if (verificationRequirementLabel != null)
            _buildParticipationChip(
              theme,
              verificationRequirementLabel,
              _mobileHeroChipMetrics,
            ),
        ];

        final desktopChips = <Widget>[
          _buildStatusChip(theme, statusLabel, poll.status, _chipMetrics),
          _buildLocationChip(theme, locationLabel, _chipMetrics),
          if (timeWindowLabel != null)
            _buildTimeWindowChip(theme, timeWindowLabel, _chipMetrics),
          if (participationLabel != null)
            _buildParticipationChip(theme, participationLabel, _chipMetrics),
          if (verificationRequirementLabel != null)
            _buildParticipationChip(
              theme,
              verificationRequirementLabel,
              _chipMetrics,
            ),
          _buildTypeChip(theme, typeLabel, _chipMetrics),
          _buildVoteChangeChip(
            theme,
            voteChangeLabel,
            config.allowVoteChange,
            _chipMetrics,
          ),
          _buildAnonymityChip(theme, anonymityLabel, _chipMetrics),
          _buildResultsVisibilityChip(
            theme,
            resultsVisibilityLabel,
            _chipMetrics,
          ),
          if (minQuorum != null)
            _buildQuorumChip(theme, l10n, minQuorum, _chipMetrics),
        ];

        final ruleSummaryValues = <String>[
          if (timeWindowLabel != null) timeWindowLabel,
          if (verificationRequirementLabel != null)
            verificationRequirementLabel,
          typeLabel,
          voteChangeLabel,
          anonymityLabel,
          resultsVisibilityLabel,
          if (minQuorum != null) l10n.pollCard_quorumLabel(minQuorum),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isMobileLayout)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: heroChips,
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: desktopChips,
              ),
            const SizedBox(height: 22),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: SocialVoteDirectionalText(
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
                child: SocialVoteDirectionalText(
                  description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.48,
                    color: descriptionColor,
                  ),
                ),
              ),
            ],
            if (_hasRepresentativePublisher && representativeLabel != null) ...[
              const SizedBox(height: 14),
              _buildPublishedIdentityRow(
                actorLabel: representativeLabel,
                displayName: representativeDisplayName,
              ),
            ],
            if (authorProfile != null && !_hasRepresentativePublisher) ...[
              const SizedBox(height: 10),
              _buildCreatorRow(
                l10n,
                authorProfile!,
              ),
            ],
            if (createdAt != null) ...[
              const SizedBox(height: 10),
              Text(
                _mapCreatedOnLabel(l10n, createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: metaTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (isMobileLayout && ruleSummaryValues.isNotEmpty) ...[
              const SizedBox(height: 18),
              _buildVotingRulesSummary(
                context,
                title: _mapVotingRulesLabel(l10n),
                values: ruleSummaryValues,
              ),
            ],
            if (quorumInfoText != null) ...[
              const SizedBox(height: 14),
              _buildInfoStrip(
                context,
                text: quorumInfoText,
                accentColor:
                    isQuorumReached ? const Color(0xFF0E9F6E) : _softVioletFg,
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
                    color: colorScheme.outline.withValues(
                      alpha: isDark ? 0.24 : 0.12,
                    ),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
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
                  ),
                  const SizedBox(width: 12),
                  if (useCompactActionIcons) ...[
                    _buildCompactActionIcon(
                      context,
                      icon: Icons.share_outlined,
                      tooltip: shareLabel,
                      onPressed: onSharePressed,
                    ),
                    const SizedBox(width: 8),
                    _buildCompactActionIcon(
                      context,
                      icon: isFavorite
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      tooltip: isFavorite
                          ? l10n.pollDetail_removeFromFavoritesTooltip
                          : l10n.pollDetail_addToFavoritesTooltip,
                      onPressed: onFavoritePressed,
                      isActive: isFavorite,
                    ),
                  ] else ...[
                    _buildActionPill(
                      context,
                      icon: Icons.share_outlined,
                      label: shareLabel,
                      tooltip: shareLabel,
                      onPressed: onSharePressed,
                    ),
                    const SizedBox(width: 8),
                    _buildActionPill(
                      context,
                      icon: isFavorite
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      label: saveLabel,
                      tooltip: isFavorite
                          ? l10n.pollDetail_removeFromFavoritesTooltip
                          : l10n.pollDetail_addToFavoritesTooltip,
                      onPressed: onFavoritePressed,
                      isActive: isFavorite,
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVotingRulesSummary(
    BuildContext context, {
    required String title,
    required List<String> values,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: isDark ? 0.08 : 0.045),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: isDark ? 0.18 : 0.10),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.rule_outlined,
              size: 17,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  values.join('  •  '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(
                      alpha: isDark ? 0.72 : 0.66,
                    ),
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _PollChipTone _locationTone(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return const _PollChipTone(
        backgroundColor: Color(0xFF182535),
        foregroundColor: Color(0xFF9DBDF4),
        borderColor: Color(0xFF30455E),
      );
    }

    return const _PollChipTone(
      backgroundColor: _neutralSoftBlueBg,
      foregroundColor: _neutralSoftBlueFg,
      borderColor: _neutralSoftBlueBorder,
    );
  }

  _PollChipTone _statusTone(ThemeData theme, PollStatus status) {
    switch (status) {
      case PollStatus.open:
        if (theme.brightness == Brightness.dark) {
          return const _PollChipTone(
            backgroundColor: Color(0xFF163226),
            foregroundColor: Color(0xFF58D99C),
            borderColor: Color(0xFF2B5A45),
          );
        }
        return const _PollChipTone(
          backgroundColor: _softGreenBg,
          foregroundColor: _softGreenFg,
          borderColor: _softGreenBorder,
        );
      case PollStatus.closed:
        if (theme.brightness == Brightness.dark) {
          return const _PollChipTone(
            backgroundColor: Color(0xFF381C21),
            foregroundColor: Color(0xFFFF8B94),
            borderColor: Color(0xFF5F323A),
          );
        }
        return const _PollChipTone(
          backgroundColor: _softRedBg,
          foregroundColor: _softRedFg,
          borderColor: _softRedBorder,
        );
      case PollStatus.scheduled:
        return _locationTone(theme);
      case PollStatus.draft:
        if (theme.brightness == Brightness.dark) {
          return const _PollChipTone(
            backgroundColor: Color(0xFF232A35),
            foregroundColor: Color(0xFFC0CAD7),
            borderColor: Color(0xFF3A4654),
          );
        }
        return const _PollChipTone(
          backgroundColor: _softGrayBg,
          foregroundColor: _softGrayFg,
          borderColor: _softGrayBorder,
        );
    }
  }

  _PollChipTone _participationTone(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return const _PollChipTone(
        backgroundColor: Color(0xFF34281B),
        foregroundColor: Color(0xFFF2C078),
        borderColor: Color(0xFF5A4631),
      );
    }

    return const _PollChipTone(
      backgroundColor: _softAmberBg,
      foregroundColor: _softAmberFg,
      borderColor: _softAmberBorder,
    );
  }

  _PollChipTone _timeTone(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return const _PollChipTone(
        backgroundColor: Color(0xFF1F2532),
        foregroundColor: Color(0xFFC6D2E3),
        borderColor: Color(0xFF364154),
      );
    }

    return const _PollChipTone(
      backgroundColor: Color(0xFFF5F7FB),
      foregroundColor: Color(0xFF5F6D82),
      borderColor: Color(0xFFDDE5F0),
    );
  }

  _PollChipTone _typeTone(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return const _PollChipTone(
        backgroundColor: Color(0xFF1D2237),
        foregroundColor: Color(0xFFAEBBF8),
        borderColor: Color(0xFF3B4564),
      );
    }

    return const _PollChipTone(
      backgroundColor: _softIndigoBg,
      foregroundColor: _softIndigoFg,
      borderColor: _softIndigoBorder,
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
      backgroundColor: _softTealBg,
      foregroundColor: _softTealFg,
      borderColor: _softTealBorder,
    );
  }

  _PollChipTone _anonymityTone(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return const _PollChipTone(
        backgroundColor: Color(0xFF2A203A),
        foregroundColor: Color(0xFFD8B8FF),
        borderColor: Color(0xFF4A3A63),
      );
    }

    return const _PollChipTone(
      backgroundColor: _softVioletBg,
      foregroundColor: _softVioletFg,
      borderColor: _softVioletBorder,
    );
  }

  _PollChipTone _quorumTone(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return const _PollChipTone(
        backgroundColor: Color(0xFF362229),
        foregroundColor: Color(0xFFF0AA9D),
        borderColor: Color(0xFF5D3B43),
      );
    }

    return const _PollChipTone(
      backgroundColor: _softRoseBg,
      foregroundColor: _softRoseFg,
      borderColor: _softRoseBorder,
    );
  }

  Widget _buildLocationChip(
    ThemeData theme,
    String label,
    _PollChipMetrics metrics,
  ) {
    final tone = _locationTone(theme);

    return _buildInfoPill(
      theme: theme,
      metrics: metrics,
      icon: Icons.public,
      label: label,
      backgroundColor: tone.backgroundColor,
      foregroundColor: tone.foregroundColor,
      borderColor: tone.borderColor,
    );
  }

  Widget _buildStatusChip(
    ThemeData theme,
    String label,
    PollStatus status,
    _PollChipMetrics metrics,
  ) {
    final tone = _statusTone(theme, status);

    return _buildMetaPill(
      theme: theme,
      metrics: metrics,
      icon: null,
      label: label.toUpperCase(),
      backgroundColor: tone.backgroundColor,
      foregroundColor: tone.foregroundColor,
      borderColor: tone.borderColor,
      bold: true,
      letterSpacing: 0.25,
    );
  }

  Widget _buildParticipationChip(
    ThemeData theme,
    String label,
    _PollChipMetrics metrics,
  ) {
    final tone = _participationTone(theme);

    return _buildInfoPill(
      theme: theme,
      metrics: metrics,
      icon: Icons.lock_outline,
      label: label,
      backgroundColor: tone.backgroundColor,
      foregroundColor: tone.foregroundColor,
      borderColor: tone.borderColor,
    );
  }

  Widget _buildTimeWindowChip(
    ThemeData theme,
    String label,
    _PollChipMetrics metrics,
  ) {
    final tone = _timeTone(theme);

    return _buildInfoPill(
      theme: theme,
      metrics: metrics,
      icon: Icons.schedule_outlined,
      label: label,
      backgroundColor: tone.backgroundColor,
      foregroundColor: tone.foregroundColor,
      borderColor: tone.borderColor,
    );
  }

  Widget _buildTypeChip(
    ThemeData theme,
    String label,
    _PollChipMetrics metrics,
  ) {
    final tone = _typeTone(theme);

    return _buildInfoPill(
      theme: theme,
      metrics: metrics,
      icon: Icons.category_outlined,
      label: label,
      backgroundColor: tone.backgroundColor,
      foregroundColor: tone.foregroundColor,
      borderColor: tone.borderColor,
    );
  }

  Widget _buildVoteChangeChip(
    ThemeData theme,
    String label,
    bool allowVoteChange,
    _PollChipMetrics metrics,
  ) {
    final tone = _tealTone(theme);

    return _buildInfoPill(
      theme: theme,
      metrics: metrics,
      icon: allowVoteChange ? Icons.restart_alt_rounded : Icons.block_outlined,
      label: label,
      backgroundColor: tone.backgroundColor,
      foregroundColor: tone.foregroundColor,
      borderColor: tone.borderColor,
    );
  }

  Widget _buildAnonymityChip(
    ThemeData theme,
    String label,
    _PollChipMetrics metrics,
  ) {
    final tone = _anonymityTone(theme);

    return _buildInfoPill(
      theme: theme,
      metrics: metrics,
      icon: poll.configuration.anonymityRules.level == AnonymityLevel.anonymous
          ? Icons.visibility_off_outlined
          : Icons.visibility_outlined,
      label: label,
      backgroundColor: tone.backgroundColor,
      foregroundColor: tone.foregroundColor,
      borderColor: tone.borderColor,
    );
  }

  Widget _buildResultsVisibilityChip(
    ThemeData theme,
    String label,
    _PollChipMetrics metrics,
  ) {
    final tone = _tealTone(theme);

    return _buildInfoPill(
      theme: theme,
      metrics: metrics,
      icon: Icons.insights_outlined,
      label: label,
      backgroundColor: tone.backgroundColor,
      foregroundColor: tone.foregroundColor,
      borderColor: tone.borderColor,
    );
  }

  Widget _buildQuorumChip(
    ThemeData theme,
    AppLocalizations l10n,
    int minQuorum,
    _PollChipMetrics metrics,
  ) {
    final tone = _quorumTone(theme);

    return _buildInfoPill(
      theme: theme,
      metrics: metrics,
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
    final activeTone = _participationTone(theme);

    final backgroundColor =
        isActive ? activeTone.backgroundColor : colorScheme.surface;
    final borderColor = isActive
        ? activeTone.borderColor
        : colorScheme.outline.withValues(alpha: 0.16);
    final foregroundColor = !enabled
        ? colorScheme.onSurface.withValues(alpha: 0.34)
        : isActive
            ? activeTone.foregroundColor
            : colorScheme.onSurface.withValues(alpha: 0.84);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            height: 44,
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

  Widget _buildCompactActionIcon(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    bool isActive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final enabled = onPressed != null;
    final activeTone = _participationTone(theme);

    final backgroundColor =
        isActive ? activeTone.backgroundColor : colorScheme.surface;
    final borderColor = isActive
        ? activeTone.borderColor
        : colorScheme.outline.withValues(alpha: 0.16);
    final foregroundColor = !enabled
        ? colorScheme.onSurface.withValues(alpha: 0.34)
        : isActive
            ? activeTone.foregroundColor
            : colorScheme.onSurface.withValues(alpha: 0.84);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: foregroundColor,
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
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.18),
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

  Widget _buildPublishedIdentityRow({
    required String actorLabel,
    required String? displayName,
  }) {
    final primaryLabel = displayName ?? actorLabel;

    return PublisherSignature(
      displayName: primaryLabel,
      imageUrl: poll.authorAvatarUrl,
      actorType: poll.publishedAsActorType!,
      verificationLevel: VerificationLevel.none,
      institutionLevel: poll.publishedAsInstitutionLevel,
      density: PublisherSignatureDensity.regular,
      maxWidth: 440,
      onTap: onAuthorTap,
    );
  }

  Widget _buildCreatorRow(
    AppLocalizations l10n,
    UserProfile profile,
  ) {
    final displayName = _normalizeString(profile.displayName);
    final username = _normalizeString(profile.username);
    final primaryLabel = displayName ??
        (username != null
            ? '@$username'
            : l10n.pollDetail_publicVotesUserFallback);
    final usernameLabel =
        displayName != null && username != null ? '@$username' : null;
    final canOpen = onAuthorTap != null;
    return PublisherSignature(
      displayName: primaryLabel,
      username: usernameLabel,
      imageUrl: profile.avatarUrl,
      actorType: profile.actorType,
      verificationLevel: profile.verificationLevel,
      institutionLevel: profile.institutionLevel,
      density: PublisherSignatureDensity.regular,
      maxWidth: 440,
      onTap: canOpen ? onAuthorTap : null,
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
    final contentLocation = poll.contentLocation;
    final countryCode = contentLocation?.countryCode ?? poll.countryCode;
    final cityName = _normalizeString(contentLocation?.cityName) ??
        _normalizeString(poll.cityId);

    final country = _resolveCountryName(l10n, countryCode);

    if (country == null && cityName == null) {
      return l10n.pollGeo_global;
    }
    if (country != null && cityName == null) {
      return country;
    }
    if (country == null && cityName != null) {
      return cityName;
    }
    return '$cityName · $country';
  }

  String? _mapVerificationRequirementLabel(AppLocalizations l10n) {
    switch (poll.configuration.participationRules.minimumVerificationLevel) {
      case VerificationLevel.none:
        return null;
      case VerificationLevel.level1:
        return _mapMinimumVerificationLabel(l10n, level: 1);
      case VerificationLevel.level2:
        return _mapMinimumVerificationLabel(l10n, level: 2);
    }
  }

  String? _mapParticipationLabel(AppLocalizations l10n) {
    final rules = poll.configuration.participationRules;

    if (rules.scope == ParticipationScope.everyone) {
      return null;
    }

    final countryName = _resolveCountryName(l10n, rules.countryCode);
    if (countryName != null) {
      return l10n.pollCard_restrictedToCountry(countryName);
    }

    return l10n.pollCard_countryRestricted;
  }

  String _mapRepresentativeLabel(AppLocalizations l10n) {
    switch (poll.publishedAsActorType) {
      case ActorType.publicOfficial:
        return l10n.pollCard_publicOfficialPublisher;
      case ActorType.institution:
        return l10n.pollCard_institutionPublisher;
      case ActorType.organization:
        return l10n.identityBadgeVerifiedOrganization;
      default:
        return l10n.pollCard_representativePublisher;
    }
  }

  String? _resolveCountryName(AppLocalizations l10n, String? code) {
    if (code == null) return null;

    return Countries.nameForCode(
      code,
      languageCode: l10n.localeName,
      fallback: code,
    );
  }

  String? _mapTimeWindowLabel(
    AppLocalizations l10n, {
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
      return _mapFromDateLabel(l10n, _formatShortDate(startAt));
    }

    return _mapUntilDateLabel(l10n, _formatShortDate(endAt!));
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
    switch (mode) {
      case ResultsVisibilityMode.always:
        return l10n.pollCard_resultsVisibleChip;
      case ResultsVisibilityMode.afterVote:
        return l10n.pollCard_resultsAfterVoteChip;
      case ResultsVisibilityMode.afterClose:
        return l10n.pollCard_resultsAfterCloseChip;
    }
  }

  String _mapVoteChangeLabel(
    AppLocalizations l10n, {
    required bool allowVoteChange,
  }) {
    final language = l10n.localeName.toLowerCase().split('_').first;
    final labels = switch (language) {
      'it' => ('Voto modificabile', 'Voto non modificabile'),
      'de' => ('Stimme änderbar', 'Stimme gesperrt'),
      'fa' => ('امکان تغییر رأی', 'رأی قفل‌شده'),
      'es' => ('Voto modificable', 'Voto bloqueado'),
      'pt' => ('Voto alterável', 'Voto bloqueado'),
      'fr' => ('Vote modifiable', 'Vote verrouillé'),
      'ar' => ('يمكن تغيير التصويت', 'التصويت مقفل'),
      'ro' => ('Vot modificabil', 'Vot blocat'),
      'ru' => ('Голос можно изменить', 'Голос заблокирован'),
      'zh' => ('可修改投票', '投票已锁定'),
      _ => ('Vote can change', 'Vote locked'),
    };
    return allowVoteChange ? labels.$1 : labels.$2;
  }

  String _mapCreatedOnLabel(AppLocalizations l10n, DateTime value) {
    final date = _formatDateTime(value);
    final language = l10n.localeName.toLowerCase().split('_').first;
    return switch (language) {
      'it' => 'Creato il $date',
      'de' => 'Erstellt am $date',
      'fa' => 'ایجادشده در $date',
      'es' => 'Creado el $date',
      'pt' => 'Criado em $date',
      'fr' => 'Créé le $date',
      'ar' => 'أُنشئ في $date',
      'ro' => 'Creat la $date',
      'ru' => 'Создано $date',
      'zh' => '创建于 $date',
      _ => 'Created on $date',
    };
  }

  String _mapVotingRulesLabel(AppLocalizations l10n) {
    final language = l10n.localeName.toLowerCase().split('_').first;
    return switch (language) {
      'it' => 'Regole di voto',
      'de' => 'Abstimmungsregeln',
      'fa' => 'قوانین رأی‌گیری',
      'es' => 'Reglas de votación',
      'pt' => 'Regras de votação',
      'fr' => 'Règles de vote',
      'ar' => 'قواعد التصويت',
      'ro' => 'Reguli de vot',
      'ru' => 'Правила голосования',
      'zh' => '投票规则',
      _ => 'Voting rules',
    };
  }

  String _mapMinimumVerificationLabel(
    AppLocalizations l10n, {
    required int level,
  }) {
    final language = l10n.localeName.toLowerCase().split('_').first;
    return switch (language) {
      'it' => 'Verifica minima: Livello $level',
      'de' => 'Mindestverifizierung: Stufe $level',
      'fa' => 'حداقل احراز هویت: سطح $level',
      'es' => 'Verificación mínima: Nivel $level',
      'pt' => 'Verificação mínima: Nível $level',
      'fr' => 'Vérification minimale : Niveau $level',
      'ar' => 'الحد الأدنى للتحقق: المستوى $level',
      'ro' => 'Verificare minimă: Nivel $level',
      'ru' => 'Минимальная проверка: уровень $level',
      'zh' => '最低验证：级别 $level',
      _ => 'Minimum verification: Level $level',
    };
  }

  String _mapFromDateLabel(AppLocalizations l10n, String date) {
    final language = l10n.localeName.toLowerCase().split('_').first;
    return switch (language) {
      'it' => 'Da $date',
      'de' => 'Ab $date',
      'fa' => 'از $date',
      'es' => 'Desde $date',
      'pt' => 'Desde $date',
      'fr' => 'À partir du $date',
      'ar' => 'من $date',
      'ro' => 'Din $date',
      'ru' => 'С $date',
      'zh' => '自 $date',
      _ => 'From $date',
    };
  }

  String _mapUntilDateLabel(AppLocalizations l10n, String date) {
    final language = l10n.localeName.toLowerCase().split('_').first;
    return switch (language) {
      'it' => 'Fino $date',
      'de' => 'Bis $date',
      'fa' => 'تا $date',
      'es' => 'Hasta $date',
      'pt' => 'Até $date',
      'fr' => 'Jusqu’au $date',
      'ar' => 'حتى $date',
      'ro' => 'Până la $date',
      'ru' => 'До $date',
      'zh' => '至 $date',
      _ => 'Until $date',
    };
  }

  String? _normalizeString(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
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
