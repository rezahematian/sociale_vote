import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/value_objects/anonymity_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_type.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_status.dart';
import 'package:sociale_vote/domain/poll/value_objects/visibility_rules.dart';
import 'package:sociale_vote/shared/widgets/engagement_bar.dart';

class PollCard extends StatelessWidget {
  final Poll poll;
  final VoidCallback? onTap;

  /// Engagement (🔥 / ❄)
  /// Se sono null → nessuna barra mostrata (usato in contesti dove non abbiamo ancora engagement).
  final int? fireCount;
  final int? iceCount;
  final VoidCallback? onFireTap;
  final VoidCallback? onIceTap;

  const PollCard({
    super.key,
    required this.poll,
    this.onTap,
    this.fireCount,
    this.iceCount,
    this.onFireTap,
    this.onIceTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = poll.description ?? '';
    final hasDescription = description.trim().isNotEmpty;

    final bool showEngagementBar =
        fireCount != null && iceCount != null && (onFireTap != null || onIceTap != null);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                  const SizedBox(width: 8),
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
                  const SizedBox(width: 8),
                  _buildStatusChip(theme),
                ],
              ),

              const SizedBox(height: 6),

              // ===== MINI PROGRESS BAR (STATO) =====
              _buildStatusProgressBar(theme),

              if (hasDescription) ...[
                const SizedBox(height: 8),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color:
                        theme.textTheme.bodyMedium?.color?.withOpacity(0.85),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 10),

              // ===== BADGES SECONDARI =====
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildTypeChip(theme),
                  _buildScopeChip(theme),
                  _buildAnonymityChip(theme),
                  _buildResultsVisibilityChip(theme),
                  _buildQuorumChip(theme),
                ],
              ),

              if (showEngagementBar) ...[
                const SizedBox(height: 10),
                // ===== ENGAGEMENT BAR (🔥 / ❄) =====
                EngagementBar(
                  fireCount: fireCount!,
                  iceCount: iceCount!,
                  onFireTap: onFireTap,
                  onIceTap: onIceTap,
                ),
              ],

              const SizedBox(height: 12),

              // ===== FOOTER: COMMENT COUNT + CTA =====
              Row(
                children: [
                  _CommentCountBadge(poll: poll),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View details',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
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
        ),
      ),
    );
  }

  // ===== MAPPERS (ROBUSTI A FUTURI ENUM) =====

  String _mapTypeToLabel(PollType type) {
    switch (type) {
      case PollType.yesNo:
        return 'Yes / No';
      case PollType.singleChoice:
        return 'Single choice';
      case PollType.multipleChoice:
        return 'Multiple choice';
      case PollType.approval:
        return 'Approval voting';
      case PollType.ranked:
        return 'Ranked choice';
      case PollType.score:
        return 'Score / Rating';
      default:
        // Fallback sicuro se un domani aggiungi nuovi tipi
        return type.name;
    }
  }

  String _mapStatusToLabel(PollStatus status) {
    switch (status) {
      case PollStatus.draft:
        return 'Draft';
      case PollStatus.scheduled:
        return 'Scheduled';
      case PollStatus.open:
        return 'Open';
      case PollStatus.closed:
        return 'Closed';
      default:
        return status.name;
    }
  }

  String _mapResultsVisibilityLabel(ResultsVisibilityMode mode) {
    switch (mode) {
      case ResultsVisibilityMode.always:
        return 'Results visible while open';
      case ResultsVisibilityMode.afterVote:
        return 'Results visible after vote';
      case ResultsVisibilityMode.afterClose:
        return 'Results visible after close';
      default:
        return mode.name;
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
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 4,
        backgroundColor:
            theme.colorScheme.surfaceVariant.withOpacity(0.4),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme) {
    final status = poll.status;
    final statusLabel = _mapStatusToLabel(status);
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
        borderRadius: BorderRadius.circular(999),
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

  Widget _buildTypeChip(ThemeData theme) {
    final label = _mapTypeToLabel(poll.type);
    return _buildMiniChip(
      theme,
      Icons.category,
      label,
    );
  }

  Widget _buildScopeChip(ThemeData theme) {
    final country = poll.countryCode;
    final city = poll.cityId;

    String label;
    if (country == null && city == null) {
      label = 'Global';
    } else if (country != null && city == null) {
      label = country;
    } else {
      label = '$city ($country)';
    }

    return _buildMiniChip(theme, Icons.public, label);
  }

  Widget _buildAnonymityChip(ThemeData theme) {
    final level = poll.configuration.anonymityRules.level;
    final label =
        level == AnonymityLevel.anonymous ? 'Anonymous' : 'Public';

    return _buildMiniChip(theme, Icons.visibility, label);
  }

  Widget _buildResultsVisibilityChip(ThemeData theme) {
    final visibility = poll.configuration.visibilityRules.resultsVisibility;
    final label = _mapResultsVisibilityLabel(visibility);

    return _buildMiniChip(theme, Icons.insights, label);
  }

  Widget _buildQuorumChip(ThemeData theme) {
    final minQuorum = poll.configuration.quorumRules.minAbsoluteVotes;

    if (minQuorum == null) {
      return const SizedBox.shrink();
    }

    return _buildMiniChip(theme, Icons.how_to_vote, 'Quorum $minQuorum');
  }

  Widget _buildMiniChip(
    ThemeData theme,
    IconData icon,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
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
          const SizedBox(width: 4),
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

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.comment_outlined,
              size: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }
}