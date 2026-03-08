import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/entities/poll_option.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_status.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_type.dart';
import 'package:sociale_vote/domain/poll/value_objects/visibility_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_outcome.dart';
import 'package:sociale_vote/features/discussion/application/discussion_controller.dart';
import 'package:sociale_vote/features/discussion/presentation/widgets/comment_section.dart';
import 'package:sociale_vote/shared/widgets/engagement_bar.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

import '../../application/poll_detail_controller.dart';
import '../../application/poll_result_controller.dart';
import '../../application/poll_state.dart';
import '../../application/vote_controller.dart';
import '../widgets/poll_result_chart.dart';

class PollDetailPage extends StatefulWidget {
  final PollId pollId;

  const PollDetailPage({
    super.key,
    required this.pollId,
  });

  @override
  State<PollDetailPage> createState() => _PollDetailPageState();
}

class _PollDetailPageState extends State<PollDetailPage> {
  late final PollDetailController _controller;
  late final VoteController _voteController;
  late final PollResultController _resultController;

  bool _isFavorite = false;
  bool _favoriteInitialized = false;

  @override
  void initState() {
    super.initState();

    final di = AppDI.instance;

    _controller = di.createPollDetailController();
    _voteController = di.createVoteController();
    _resultController = di.createPollResultController();

    final userId = di.currentUserId;
    _controller.loadPoll(widget.pollId, userId: userId);
  }

  @override
  void dispose() {
    _controller.dispose();
    _voteController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  bool _canVote(Poll poll) {
    return poll.status == PollStatus.open &&
        !_voteController.isSubmitting &&
        _voteController.selectedOptionIds.isNotEmpty;
  }

  Future<void> _initFavoriteStatus(Poll poll) async {
    final userId = AppDI.instance.currentUserId;
    if (userId == null) {
      return;
    }

    try {
      final isFav = await AppDI.instance.isFavorite(
        userId: userId,
        target: TargetRef.poll(poll.id.value),
      );
      if (!mounted) return;
      setState(() {
        _isFavorite = isFav;
      });
    } catch (_) {
      // v1: nessun handling specifico per errori sui preferiti in-memory.
    }
  }

  Future<void> _onFavoritePressed(Poll poll) async {
    final allowed = await AuthGuard.ensureCanPerformAction(
      context,
      ParticipationAction.react,
    );
    if (!allowed) return;

    final userId = AppDI.instance.currentUserId;
    if (userId == null) return;

    try {
      final newState = await AppDI.instance.toggleFavorite(
        userId: userId,
        target: TargetRef.poll(poll.id.value),
      );
      if (!mounted) return;
      setState(() {
        _isFavorite = newState;
      });
    } catch (_) {
      // v1: silenzioso; in futuro si può mostrare SnackBar.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pollDetail_title),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final state = _controller.state;

          if (state is PollDetailLoading || state is PollDetailInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PollDetailError) {
            return Center(child: Text(state.message));
          }

          if (state is PollDetailLoaded) {
            final poll = state.poll;

            if (!_resultController.isLoading &&
                _resultController.result == null &&
                _resultController.error == null) {
              _resultController.loadResults(
                poll: poll,
                userHasVoted: _voteController.submittedSuccessfully,
              );
            }

            if (AppDI.instance.currentUserId != null &&
                !_favoriteInitialized) {
              _favoriteInitialized = true;
              _initFavoriteStatus(poll);
            }

            return ChangeNotifierProvider<DiscussionController>(
              create: (_) => AppDI.instance.createDiscussionController(
                TargetRef.poll(poll.id.value),
              )..loadComments(),
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _voteController,
                  _resultController,
                ]),
                builder: (context, __) {
                  return _buildPollContent(context, poll);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<void> _onVotePressed(BuildContext context, Poll poll) async {
    if (poll.status != PollStatus.open) return;
    if (!_canVote(poll)) return;

    final allowed = await AuthGuard.ensureCanPerformAction(
      context,
      ParticipationAction.vote,
    );
    if (!allowed) {
      return;
    }

    final userId = AppDI.instance.currentUserId;
    if (userId == null) {
      return;
    }

    await _voteController.submitVote(
      poll: poll,
      userId: userId,
      userCountryCode: null,
    );

    if (_voteController.submittedSuccessfully) {
      await _resultController.loadResults(
        poll: poll,
        userHasVoted: true,
      );
    }
  }

  Widget _buildPollContent(BuildContext context, Poll poll) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final config = poll.configuration;

    final visibilityMode = config.visibilityRules.resultsVisibility;
    final anonymityLevel = config.anonymityRules.level;
    final participationScope = config.participationRules.scope;
    final minQuorum = config.quorumRules.minAbsoluteVotes;

    final totalVotes = _resultController.result?.totalVotes ?? 0;

    final int fireCount = _controller.likeCount();
    final int iceCount = _controller.dislikeCount();
    final userReaction = _controller.userReaction;

    final String currentUserForComments =
        AppDI.instance.currentUserId ?? 'guest';

    final voteErrorText = _mapVoteErrorToText(l10n);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
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
                  _isFavorite ? Icons.star : Icons.star_border,
                  color: _isFavorite
                      ? theme.colorScheme.primary
                      : theme.iconTheme.color,
                ),
                tooltip: _isFavorite
                    ? l10n.pollDetail_removeFromFavoritesTooltip
                    : l10n.pollDetail_addToFavoritesTooltip,
                onPressed: () => _onFavoritePressed(poll),
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
          _buildMetaRow(context, poll),
          const SizedBox(height: 12),
          EngagementBar(
            fireCount: fireCount,
            iceCount: iceCount,
            userReaction: userReaction,
            onFireTap: () async {
              final allowed = await AuthGuard.ensureCanPerformAction(
                context,
                ParticipationAction.react,
              );
              if (!allowed) return;

              final userId = AppDI.instance.currentUserId;
              if (userId == null) return;

              await _controller.toggleFire(userId: userId);
            },
            onIceTap: () async {
              final allowed = await AuthGuard.ensureCanPerformAction(
                context,
                ParticipationAction.react,
              );
              if (!allowed) return;

              final userId = AppDI.instance.currentUserId;
              if (userId == null) return;

              await _controller.toggleIce(userId: userId);
            },
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
              if (minQuorum != null && _resultController.isQuorumApplicable)
                _buildChip(
                  context,
                  _resultController.isQuorumReached
                      ? l10n.pollDetail_quorumReached(
                          totalVotes,
                          minQuorum,
                        )
                      : l10n.pollDetail_quorumNotReached(
                          totalVotes,
                          minQuorum,
                        ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.pollDetail_optionsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...poll.options.map(
            (option) => _buildOptionTile(context, poll, option),
          ),
          const SizedBox(height: 24),
          if (poll.status != PollStatus.open) ...[
            Text(
              poll.status == PollStatus.closed
                  ? l10n.pollDetail_statusClosedMessage
                  : poll.status == PollStatus.scheduled
                      ? l10n.pollDetail_statusScheduledMessage
                      : l10n.pollDetail_statusNotAvailableMessage,
              style: TextStyle(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (voteErrorText != null) ...[
            Text(
              voteErrorText,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            const SizedBox(height: 12),
          ],
          if (_voteController.submittedSuccessfully) ...[
            Text(
              l10n.pollDetail_voteSubmitted,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
          ],
          FilledButton(
            onPressed: _canVote(poll)
                ? () => _onVotePressed(context, poll)
                : null,
            child: _voteController.isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.pollDetail_voteButton),
          ),
          const SizedBox(height: 32),
          if (_resultController.canShowResults) ...[
            Text(
              l10n.pollDetail_resultsTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (_resultController.hasOutcome) ...[
              Text(
                l10n.pollDetail_outcomePrefix(
                  _mapOutcomeLabel(l10n, _resultController.outcome),
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (_resultController.isLoading) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ] else if (_resultController.error != null) ...[
              Text(
                _resultController.error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ] else if (_resultController.result != null) ...[
              PollResultChart(result: _resultController.result!),
            ] else ...[
              Text(
                l10n.pollDetail_noResults,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ] else ...[
            Text(
              visibilityMode == ResultsVisibilityMode.afterVote
                  ? l10n.pollDetail_resultsAfterVote
                  : l10n.pollDetail_resultsWhenClosed,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 32),
          CommentSection(
            userId: currentUserForComments,
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(BuildContext context, Poll poll) {
    final l10n = AppLocalizations.of(context)!;

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        _buildChip(context, _mapTypeToLabel(l10n, poll.type)),
        _buildChip(context, _mapStatusToLabel(l10n, poll.status)),
        _buildChip(context, _mapGeoLabel(l10n, poll)),
      ],
    );
  }

  Widget _buildChip(BuildContext context, String label) {
    return Chip(label: Text(label));
  }

  Widget _buildOptionTile(
    BuildContext context,
    Poll poll,
    PollOption option,
  ) {
    final isSingleChoice =
        poll.type == PollType.singleChoice || poll.type == PollType.yesNo;

    final isSelected =
        _voteController.selectedOptionIds.contains(option.id);

    return ListTile(
      title: Text(option.label),
      leading: isSingleChoice
          ? Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
            )
          : Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
            ),
      onTap: poll.status == PollStatus.open
          ? () {
              _voteController.toggleOption(
                option.id,
                allowMultiple: !isSingleChoice,
              );
            }
          : null,
    );
  }

  String _enumName(Object e) {
    final text = e.toString();
    final dotIndex = text.indexOf('.');
    if (dotIndex == -1) return text;
    return text.substring(dotIndex + 1);
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

  String _mapOutcomeLabel(AppLocalizations l10n, PollOutcome outcome) {
    switch (outcome) {
      case PollOutcome.approved:
        return l10n.pollOutcome_approved;
      case PollOutcome.rejected:
        return l10n.pollOutcome_rejected;
      case PollOutcome.tie:
        return l10n.pollOutcome_tie;
      case PollOutcome.noMajority:
        return l10n.pollOutcome_noMajority;
      case PollOutcome.notApplicable:
        return l10n.pollOutcome_notApplicable;
    }
  }

  String? _mapVoteErrorToText(AppLocalizations l10n) {
    switch (_voteController.errorType) {
      case VoteErrorType.none:
        return null;
      case VoteErrorType.noSelection:
        return l10n.voteError_noSelection;
      case VoteErrorType.unauthorized:
        return l10n.voteError_unauthorized;
      case VoteErrorType.closed:
        return l10n.pollDetail_statusClosedMessage;
      case VoteErrorType.generic:
        return l10n.voteError_generic;
    }
  }
}