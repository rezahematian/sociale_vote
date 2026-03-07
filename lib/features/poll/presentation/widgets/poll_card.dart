import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/theme/spacing.dart';
import 'package:sociale_vote/app/theme/radius.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/value_objects/anonymity_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_type.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_status.dart';
import 'package:sociale_vote/domain/poll/value_objects/visibility_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/participation_rules.dart';
import 'package:sociale_vote/shared/data/countries.dart';
import 'package:sociale_vote/shared/widgets/engagement_bar.dart';
import 'package:sociale_vote/shared/widgets/app_card.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

class PollCard extends StatelessWidget {
  final Poll poll;
  final VoidCallback? onTap;

  /// Engagement (🔥 / ❄)
  final int? fireCount;
  final int? iceCount;

  /// Reazione corrente dell'utente su questo poll.
  final ReactionType? userReaction;

  final VoidCallback? onFireTap;
  final VoidCallback? onIceTap;

  const PollCard({
    super.key,
    required this.poll,
    this.onTap,
    this.fireCount,
    this.iceCount,
    this.userReaction,
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

    final bool showEngagementBar =
        fireCount != null &&
        iceCount != null &&
        (onFireTap != null || onIceTap != null);

    // Wrapper per applicare AuthGuard prima di eseguire le callback reali.
    VoidCallback? _wrapReactCallback(VoidCallback? original) {
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
          // ===== HEADER =====
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
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.unitS),
              // Stato + badge country restriction impilati a destra
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

          // ===== MINI PROGRESS BAR (STATO) =====
          _buildStatusProgressBar(theme),

          if (hasDescription) ...[
            const SizedBox(height: AppSpacing.unitS),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.85),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: AppSpacing.unitM),

          // ===== BADGES SECONDARI =====
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

          // ===== FOOTER: ENGAGEMENT + COMMENTI + CTA =====
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (showEngagementBar) ...[
                EngagementBar(
                  fireCount: fireCount!,
                  iceCount: iceCount!,
                  userReaction: userReaction,
                  onFireTap: _wrapReactCallback(onFireTap),
                  onIceTap: _wrapReactCallback(onIceTap),
                ),
                const SizedBox(width: AppSpacing.unitS),
              ],

              _CommentCountBadge(poll: poll),

              const Spacer(),

              Row(
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
            ],
          ),
        ],
      ),
    );
  }

  // ===== MAPPERS (ROBUSTI A FUTURI ENUM) =====

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
      final country = Countries.all
          .firstWhere((c) => c.code.toUpperCase() == upper);
      return country.name;
    } catch (_) {
      // fallback: se non troviamo nel dataset, usa il codice
      return code;
    }
  }

  // ===== WIDGET HELPER =====

  Widget _buildStatusProgressBar(ThemeData theme) {
    final status = poll.status;

    double value;
    Color color;

    switch (status) {
      case PollStatus.open:
        value = 0.6; // visivamente attivo
        color = Colors.green;
        break;
      case PollStatus.closed:
        value = 1.0;
        color = theme.colorScheme.outline;
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
        backgroundColor:
            theme.colorScheme.surfaceVariant.withOpacity(0.4),
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
      bg = Colors.green.withOpacity(0.12);
      fg = Colors.green.shade700;
    } else if (normalized.contains('closed')) {
      bg = theme.colorScheme.error.withOpacity(0.12);
      fg = theme.colorScheme.error;
    } else {
      bg = theme.colorScheme.primary.withOpacity(0.12);
      fg = theme.colorScheme.primary;
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
    return _buildMiniChip(
      theme,
      Icons.category,
      label,
    );
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
        color: Colors.orange.withOpacity(0.12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_outline,
            size: 14,
            color: Colors.orange.shade700,
          ),
          const SizedBox(width: AppSpacing.unitXS),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.orange.shade700,
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
    final visibility =
        poll.configuration.visibilityRules.resultsVisibility;
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

/// Badge che mostra il numero di commenti per questo poll usando il dominio `discussion/`.
class _CommentCountBadge extends StatelessWidget {
  final Poll poll;

  const _CommentCountBadge({required this.poll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder(
      future: AppDI.instance
          .getCommentsForTarget(TargetRef.poll(poll.id.value)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Durante il load non mostriamo nulla per non far “saltare” il layout.
          return const SizedBox.shrink();
        }

        if (snapshot.hasError) {
          // In caso di errore, silenzioso: niente badge.
          return const SizedBox.shrink();
        }

        final comments = snapshot.data as List<dynamic>? ?? const [];
        final count = comments.length;

        if (count == 0) {
          // Nessun commento → nessun badge, UI pulita.
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.unitS,
            vertical: AppSpacing.unitXS,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.7),
            borderRadius: AppRadius.buttonRadius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.comment_outlined,
                size: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.75),
              ),
              const SizedBox(width: AppSpacing.unitXS),
              Text(
                '$count',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}