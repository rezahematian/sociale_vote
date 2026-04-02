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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                poll.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite
                    ? theme.colorScheme.primary
                    : theme.iconTheme.color,
              ),
              tooltip: isFavorite
                  ? l10n.pollDetail_removeFromFavoritesTooltip
                  : l10n.pollDetail_addToFavoritesTooltip,
              onPressed: onFavoritePressed,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (poll.description != null && poll.description!.isNotEmpty)
          Text(
            poll.description!,
            style: theme.textTheme.bodyMedium,
          ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _buildChip(context, _mapTypeToLabel(l10n, poll.type)),
            _buildChip(context, _mapStatusToLabel(l10n, poll.status)),
            _buildChip(context, _mapGeoLabel(l10n, poll)),
          ],
        ),
        const SizedBox(height: 12),
        EngagementBar(
          fireCount: fireCount,
          iceCount: iceCount,
          commentCount: commentCount,
          userReaction: userReaction,
          onFireTap: onFireTap,
          onIceTap: onIceTap,
          onCommentTap: onCommentTap,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            if (anonymityLevel.name == 'anonymous')
              _buildChip(context, l10n.pollDetail_chipAnonymous),
            if (anonymityLevel.name == 'public')
              _buildChip(context, l10n.pollDetail_chipPublic),
            if (participationScope.name == 'geoScopeOnly')
              _buildChip(context, l10n.pollDetail_chipRestrictedGeo),
            if (minQuorum != null && isQuorumApplicable)
              _buildChip(
                context,
                isQuorumReached
                    ? l10n.pollDetail_quorumReached(totalVotes, minQuorum)
                    : l10n.pollDetail_quorumNotReached(totalVotes, minQuorum),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(BuildContext context, String label) {
    return Chip(label: Text(label));
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