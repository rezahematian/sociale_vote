import 'package:flutter/material.dart';

import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_status.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_type.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final config = poll.configuration;

    final anonymityLevel = config.anonymityRules.level;
    final participationScope = config.participationRules.scope;
    final minQuorum = config.quorumRules.minAbsoluteVotes;
    final description = poll.description?.trim();

    final String anonymityLabel = anonymityLevel.name == 'anonymous'
        ? l10n.pollDetail_chipAnonymous
        : l10n.pollDetail_chipPublic;

    final String scopeLabel = participationScope.name == 'geoScopeOnly'
        ? l10n.pollDetail_chipRestrictedGeo
        : _mapGeoLabel(l10n, poll);

    final String? quorumText = (minQuorum != null && isQuorumApplicable)
        ? (isQuorumReached
              ? l10n.pollDetail_quorumReached(totalVotes, minQuorum)
              : l10n.pollDetail_quorumNotReached(totalVotes, minQuorum))
        : null;

    final Color typeAccent = theme.colorScheme.primary;
    final Color statusAccent = _statusAccent(poll.status);
    const Color scopeAccent = Color(0xFF2563EB);
    const Color anonymityAccent = Color(0xFFB45309);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildMetaChip(
              context,
              _mapTypeToLabel(l10n, poll.type),
              accentColor: typeAccent,
            ),
            _buildMetaChip(
              context,
              _mapStatusToLabel(l10n, poll.status),
              accentColor: statusAccent,
            ),
            _buildMetaChip(
              context,
              scopeLabel,
              accentColor: scopeAccent,
            ),
            _buildMetaChip(
              context,
              anonymityLabel,
              accentColor: anonymityAccent,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          poll.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.08,
          ),
        ),
        if (description != null && description.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            description,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.45,
              color: theme.colorScheme.onSurface.withOpacity(0.82),
            ),
          ),
        ],
        const SizedBox(height: 18),
        Row(
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
                _buildActionChip(
                  context,
                  icon: Icons.share_outlined,
                  tooltip: 'Condividi',
                  onPressed: onSharePressed,
                ),
                const SizedBox(width: 8),
                _buildActionChip(
                  context,
                  icon: isFavorite ? Icons.star : Icons.star_border,
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
        if (quorumText != null) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.58),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.dividerColor.withOpacity(0.58),
                width: 1,
              ),
            ),
            child: Text(
              quorumText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.72),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMetaChip(
    BuildContext context,
    String label, {
    required Color accentColor,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: accentColor.withOpacity(0.30),
          width: 1.2,
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: accentColor,
          height: 1,
        ),
      ),
    );
  }

  Widget _buildActionChip(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    bool isActive = false,
  }) {
    final theme = Theme.of(context);
    final enabled = onPressed != null;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primary.withOpacity(0.10)
                  : theme.colorScheme.surface.withOpacity(0.82),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isActive
                    ? theme.colorScheme.primary.withOpacity(0.30)
                    : theme.dividerColor.withOpacity(0.72),
                width: 1.1,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: !enabled
                  ? theme.colorScheme.onSurface.withOpacity(0.35)
                  : isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.78),
            ),
          ),
        ),
      ),
    );
  }

  Color _statusAccent(PollStatus status) {
    switch (status) {
      case PollStatus.draft:
        return const Color(0xFF6B7280);
      case PollStatus.open:
        return const Color(0xFF15803D);
      case PollStatus.closed:
        return const Color(0xFFB91C1C);
      case PollStatus.scheduled:
        return const Color(0xFF7C3AED);
    }
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
      case PollStatus.open:
        return l10n.pollStatus_open;
      case PollStatus.closed:
        return l10n.pollStatus_closed;
      case PollStatus.scheduled:
        return l10n.pollStatus_scheduled;
    }
  }

  String _mapGeoLabel(AppLocalizations l10n, Poll poll) {
    final country = poll.countryCode;
    final city = poll.cityId;

    if (country == null && city == null) return l10n.pollGeo_global;
    if (country != null && city == null) return country;
    if (country != null && city != null) return '$city ($country)';
    return l10n.pollGeo_local;
  }
}