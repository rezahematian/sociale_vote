import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/features/poll/application/poll_list_controller.dart';
import 'package:sociale_vote/features/poll/presentation/widgets/poll_card.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';

class HomePollSection extends StatelessWidget {
  final String scopeShortLabel;

  const HomePollSection({
    super.key,
    required this.scopeShortLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<PollListController>();

    final header = Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withOpacity(0.08),
          ),
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.how_to_vote,
            size: 18,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          l10n.homePollsTitle(scopeShortLabel),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    final allPolls = controller.polls;

    Widget content;

    if (controller.isLoading && allPolls.isEmpty) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (allPolls.isEmpty) {
      content = HomePollsPlaceholderCard(
        title: l10n.homePollsEmptyTitle,
        subtitle: l10n.homePollsEmptySubtitle,
      );
    } else {
      final sorted = List<Poll>.from(allPolls);

      sorted.sort((a, b) {
        final heatA =
            controller.likeCountForPoll(a) - controller.dislikeCountForPoll(a);
        final heatB =
            controller.likeCountForPoll(b) - controller.dislikeCountForPoll(b);
        return heatB.compareTo(heatA);
      });

      final polls = sorted.length <= 3
          ? sorted
          : sorted.take(3).toList(growable: false);

      content = Column(
        children: polls
            .map(
              (poll) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () async {
                    await Navigator.pushNamed(
                      context,
                      AppRouter.pollDetail,
                      arguments: poll.id,
                    );

                    final userId = AppDI.instance.currentUserId;
                    await controller.loadPolls(userId: userId);
                  },
                  child: PollCard(
                    poll: poll,
                    fireCount: controller.likeCountForPoll(poll),
                    iceCount: controller.dislikeCountForPoll(poll),
                    userReaction: controller.userReactionForPoll(poll),
                    onFireTap: () async {
                      final allowed =
                          await AuthGuard.ensureCanPerformAction(
                        context,
                        ParticipationAction.react,
                      );
                      if (!allowed) return;

                      final userId = AppDI.instance.currentUserId;
                      if (userId == null || userId.isEmpty) return;

                      await controller.toggleFireForPoll(
                        userId: userId,
                        poll: poll,
                      );
                    },
                    onIceTap: () async {
                      final allowed =
                          await AuthGuard.ensureCanPerformAction(
                        context,
                        ParticipationAction.react,
                      );
                      if (!allowed) return;

                      final userId = AppDI.instance.currentUserId;
                      if (userId == null || userId.isEmpty) return;

                      await controller.toggleIceForPoll(
                        userId: userId,
                        poll: poll,
                      );
                    },
                  ),
                ),
              ),
            )
            .toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const SizedBox(height: 8),
        content,
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRouter.polls,
              );
            },
            icon: const Icon(Icons.arrow_forward),
            label: Text(l10n.homePollsViewAllButton),
          ),
        ),
      ],
    );
  }
}

class HomePollsPlaceholderCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const HomePollsPlaceholderCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 8),
      color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}