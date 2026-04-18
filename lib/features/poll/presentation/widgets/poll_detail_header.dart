import 'package:flutter/material.dart';

import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/value_objects/anonymity_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/participation_rules.dart';
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
      poll.publishedAsActorType == ActorType.institution;

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

    final shareLabel = _localizedText(
      l10n,
      it: 'Condividi',
      en: 'Share',
    );
    final saveLabel = _localizedText(
      l10n,
      it: 'Salva',
      en: 'Save',
    );

    final representativeLabel = _hasRepresentativePublisher
        ? _mapRepresentativeLabel(l10n)
        : null;
    final representativeDisplayName = _normalizeString(poll.publishedAsDisplayName);
    final representativeInfoText =
        _mapRepresentativeInfoText(l10n, representativeDisplayName);

    final locationLabel = _mapLocationLabel(l10n);
    final statusLabel = _mapStatusToLabel(l10n, poll.status);
    final participationLabel = _mapParticipationLabel(l10n);
    final timeWindowLabel = _mapTimeWindowLabel(
      l10n,
      startAt: poll.startAt,
      endAt: poll.endAt,
    );
    final typeLabel = _mapTypeToLabel(l10n, poll.type);
    final voteChangeLabel = config.allowVoteChange
        ? _localizedText(
            l10n,
            it: 'Voto modificabile',
            en: 'Vote can change',
          )
        : _localizedText(
            l10n,
            it: 'Voto non modificabile',
            en: 'Vote locked',
          );
    final anonymityLabel =
        config.anonymityRules.level == AnonymityLevel.anonymous
            ? _localizedText(
                l10n,
                it: 'Voto anonimo',
                en: 'Anonymous vote',
              )
            : _localizedText(
                l10n,
                it: 'Voto pubblico',
                en: 'Public vote',
              );
    final resultsVisibilityLabel = _mapResultsVisibilityLabel(
      l10n,
      config.visibilityRules.resultsVisibility,
    );

    final String? quorumInfoText = (minQuorum != null && isQuorumApplicable)
        ? (isQuorumReached
              ? _localizedText(
                  l10n,
                  it: 'Quorum raggiunto • $totalVotes/$minQuorum',
                  en: 'Quorum reached • $totalVotes/$minQuorum',
                )
              : _localizedText(
                  l10n,
                  it: 'Quorum non raggiunto • $totalVotes/$minQuorum',
                  en: 'Quorum not reached • $totalVotes/$minQuorum',
                ))
        : null;

    final titleColor = colorScheme.onSurface;
    final descriptionColor = colorScheme.onSurface.withOpacity(
      isDark ? 0.76 : 0.72,
    );
    final metaTextColor = colorScheme.onSurface.withOpacity(
      isDark ? 0.60 : 0.58,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobileLayout = constraints.maxWidth < 600;
        final compactBottomRow = constraints.maxWidth < 760;

        final heroChips = <Widget>[
          if (representativeLabel != null)
            _buildRepresentativeChip(
              theme,
              representativeLabel,
              _mobileHeroChipMetrics,
            ),
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
        ];

        final desktopChips = <Widget>[
          if (representativeLabel != null)
            _buildRepresentativeChip(theme, representativeLabel, _chipMetrics),
          _buildStatusChip(theme, statusLabel, poll.status, _chipMetrics),
          _buildLocationChip(theme, locationLabel, _chipMetrics),
          if (timeWindowLabel != null)
            _buildTimeWindowChip(theme, timeWindowLabel, _chipMetrics),
          if (participationLabel != null)
            _buildParticipationChip(theme, participationLabel, _chipMetrics),
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

        final ruleItems = <_PollRuleItem>[
          if (timeWindowLabel != null)
            _PollRuleItem(
              label: _localizedText(
                l10n,
                it: 'Tempistiche',
                en: 'Time window',
              ),
              value: timeWindowLabel,
              icon: Icons.schedule_outlined,
            ),
          _PollRuleItem(
            label: _localizedText(
              l10n,
              it: 'Modalità voto',
              en: 'Vote mode',
            ),
            value: typeLabel,
            icon: Icons.category_outlined,
          ),
          _PollRuleItem(
            label: _localizedText(
              l10n,
              it: 'Modifica voto',
              en: 'Vote changes',
            ),
            value: voteChangeLabel,
            icon: config.allowVoteChange
                ? Icons.restart_alt_rounded
                : Icons.block_outlined,
          ),
          _PollRuleItem(
            label: _localizedText(
              l10n,
              it: 'Anonimato',
              en: 'Privacy',
            ),
            value: anonymityLabel,
            icon: Icons.visibility_outlined,
          ),
          _PollRuleItem(
            label: _localizedText(
              l10n,
              it: 'Visibilità risultati',
              en: 'Results visibility',
            ),
            value: resultsVisibilityLabel,
            icon: Icons.insights_outlined,
          ),
          if (minQuorum != null)
            _PollRuleItem(
              label: _localizedText(
                l10n,
                it: 'Quorum',
                en: 'Quorum',
              ),
              value: l10n.pollCard_quorumLabel(minQuorum),
              icon: Icons.how_to_vote_outlined,
            ),
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
            if (representativeInfoText != null) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _representativeIcon(),
                    size: 16,
                    color: _representativeTone(
                      theme,
                      poll.publishedAsActorType!,
                    ).foregroundColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      representativeInfoText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(
                          isDark ? 0.78 : 0.72,
                        ),
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (createdAt != null) ...[
              const SizedBox(height: 10),
              Text(
                _localizedText(
                  l10n,
                  it: 'Creato il ${_formatDateTime(createdAt)}',
                  en: 'Created on ${_formatDateTime(createdAt)}',
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: metaTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (isMobileLayout && ruleItems.isNotEmpty) ...[
              const SizedBox(height: 18),
              _buildVotingRulesCard(
                context,
                title: _localizedText(
                  l10n,
                  it: 'Regole di voto',
                  en: 'Voting rules',
                ),
                items: ruleItems,
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
              child: isMobileLayout
                  ? Row(
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
                        const SizedBox(width: 8),
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
                      ],
                    )
                  : compactBottomRow
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
                                    label: shareLabel,
                                    tooltip: shareLabel,
                                    onPressed: onSharePressed,
                                  ),
                                  _buildActionPill(
                                    context,
                                    icon: isFavorite
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    label: saveLabel,
                                    tooltip: isFavorite
                                        ? l10n
                                            .pollDetail_removeFromFavoritesTooltip
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
                            ),
                          ],
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVotingRulesCard(
    BuildContext context, {
    required String title,
    required List<_PollRuleItem> items,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(isDark ? 0.36 : 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outline.withOpacity(isDark ? 0.22 : 0.10),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < items.length; i++) ...[
            _buildVotingRuleRow(context, item: items[i]),
            if (i != items.length - 1) ...[
              const SizedBox(height: 10),
              Divider(
                height: 1,
                thickness: 1,
                color: colorScheme.outline.withOpacity(isDark ? 0.18 : 0.08),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildVotingRuleRow(
    BuildContext context, {
    required _PollRuleItem item,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            item.icon,
            size: 16,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.62),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
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
        return _locationTone(theme);
    }
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

  Widget _buildRepresentativeChip(
    ThemeData theme,
    String label,
    _PollChipMetrics metrics,
  ) {
    final actorType = poll.publishedAsActorType;
    if (actorType == null) {
      return const SizedBox.shrink();
    }

    final tone = _representativeTone(theme, actorType);

    return _buildMetaPill(
      theme: theme,
      metrics: metrics,
      icon: _representativeIcon(),
      label: label,
      backgroundColor: tone.backgroundColor,
      foregroundColor: tone.foregroundColor,
      borderColor: tone.borderColor,
      bold: true,
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
      icon: allowVoteChange
          ? Icons.restart_alt_rounded
          : Icons.block_outlined,
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

    final backgroundColor = isActive
        ? activeTone.backgroundColor
        : colorScheme.surface;
    final borderColor = isActive
        ? activeTone.borderColor
        : colorScheme.outline.withOpacity(0.16);
    final foregroundColor = !enabled
        ? colorScheme.onSurface.withOpacity(0.34)
        : isActive
            ? activeTone.foregroundColor
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

    final backgroundColor = isActive
        ? activeTone.backgroundColor
        : colorScheme.surface;
    final borderColor = isActive
        ? activeTone.borderColor
        : colorScheme.outline.withOpacity(0.16);
    final foregroundColor = !enabled
        ? colorScheme.onSurface.withOpacity(0.34)
        : isActive
            ? activeTone.foregroundColor
            : colorScheme.onSurface.withOpacity(0.84);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            width: 36,
            height: 36,
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
    final contentLocation = poll.contentLocation;
    final countryCode = contentLocation?.countryCode ?? poll.countryCode;
    final cityName =
        _normalizeString(contentLocation?.cityName) ?? _normalizeString(poll.cityId);

    final country = _resolveCountryName(countryCode);

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

  String? _mapParticipationLabel(AppLocalizations l10n) {
    final rules = poll.configuration.participationRules;

    if (rules.scope == ParticipationScope.everyone) {
      return null;
    }

    final countryName = _resolveCountryName(rules.countryCode);
    if (countryName != null) {
      return _localizedText(
        l10n,
        it: 'Solo utenti $countryName',
        en: 'Only $countryName users',
      );
    }

    return _localizedText(
      l10n,
      it: 'Partecipazione ristretta',
      en: 'Restricted access',
    );
  }

  String _mapRepresentativeLabel(AppLocalizations l10n) {
    switch (poll.publishedAsActorType) {
      case ActorType.publicOfficial:
        return _localizedText(
          l10n,
          it: 'Public Official',
          en: 'Public Official',
        );
      case ActorType.institution:
        return _localizedText(
          l10n,
          it: 'Institution',
          en: 'Institution',
        );
      default:
        return _localizedText(
          l10n,
          it: 'Representative',
          en: 'Representative',
        );
    }
  }

  String? _mapRepresentativeInfoText(
    AppLocalizations l10n,
    String? displayName,
  ) {
    if (!_hasRepresentativePublisher) {
      return null;
    }

    final actorLabel = _mapRepresentativeLabel(l10n);

    if (displayName != null) {
      return _localizedText(
        l10n,
        it: 'Pubblicato come $actorLabel · $displayName',
        en: 'Published as $actorLabel · $displayName',
      );
    }

    return _localizedText(
      l10n,
      it: 'Pubblicato come $actorLabel',
      en: 'Published as $actorLabel',
    );
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
      return _localizedText(
        l10n,
        it: 'Da ${_formatShortDate(startAt)}',
        en: 'From ${_formatShortDate(startAt)}',
      );
    }

    return _localizedText(
      l10n,
      it: 'Fino ${_formatShortDate(endAt!)}',
      en: 'Until ${_formatShortDate(endAt!)}',
    );
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
        return _localizedText(
          l10n,
          it: 'Risultati sempre visibili',
          en: 'Results always visible',
        );
      case ResultsVisibilityMode.afterVote:
        return _localizedText(
          l10n,
          it: 'Risultati visibili dopo voto',
          en: 'Results visible after vote',
        );
      case ResultsVisibilityMode.afterClose:
        return _localizedText(
          l10n,
          it: 'Risultati visibili dopo chiusura',
          en: 'Results visible after close',
        );
    }
  }

  String _localizedText(
    AppLocalizations l10n, {
    required String it,
    required String en,
  }) {
    final locale = l10n.localeName.toLowerCase();
    return locale.startsWith('it') ? it : en;
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

class _PollRuleItem {
  final String label;
  final String value;
  final IconData icon;

  const _PollRuleItem({
    required this.label,
    required this.value,
    required this.icon,
  });
}