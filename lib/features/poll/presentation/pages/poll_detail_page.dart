import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_status.dart';
import 'package:sociale_vote/domain/poll/value_objects/visibility_rules.dart';
import 'package:sociale_vote/features/discussion/application/discussion_controller.dart';
import 'package:sociale_vote/features/discussion/presentation/widgets/comment_section.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

import '../../application/poll_detail_controller.dart';
import '../../application/poll_result_controller.dart';
import '../../application/poll_state.dart';
import '../../application/vote_controller.dart';
import '../widgets/poll_detail_header.dart';
import '../widgets/poll_options_section.dart';
import '../widgets/poll_results_section.dart';

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
  bool _favoriteLoading = false;
  bool _resultsInitialized = false;
  String? _initializedFavoritePollId;

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
  void didUpdateWidget(covariant PollDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.pollId.value != widget.pollId.value) {
      _isFavorite = false;
      _favoriteInitialized = false;
      _favoriteLoading = false;
      _resultsInitialized = false;
      _initializedFavoritePollId = null;

      final userId = AppDI.instance.currentUserId;
      _controller.loadPoll(widget.pollId, userId: userId);
    }
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
      if (!mounted) return;
      setState(() {
        _isFavorite = false;
        _favoriteInitialized = true;
        _initializedFavoritePollId = poll.id.value;
      });
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
        _favoriteInitialized = true;
        _initializedFavoritePollId = poll.id.value;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _favoriteInitialized = true;
        _initializedFavoritePollId = poll.id.value;
      });
    }
  }

  Future<void> _onFavoritePressed(Poll poll) async {
    if (_favoriteLoading) {
      return;
    }

    final allowed = await AuthGuard.ensureCanPerformAction(
      context,
      ParticipationAction.react,
    );
    if (!allowed) return;

    final userId = AppDI.instance.currentUserId;
    if (userId == null) return;

    setState(() {
      _favoriteLoading = true;
    });

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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossibile aggiornare i preferiti')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _favoriteLoading = false;
      });
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

            if (!_resultsInitialized) {
              _resultsInitialized = true;
              _resultController.loadResults(
                poll: poll,
                userHasVoted: _voteController.submittedSuccessfully,
              );
            }

            final shouldInitFavorite =
                AppDI.instance.currentUserId != null &&
                (!_favoriteInitialized ||
                    _initializedFavoritePollId != poll.id.value);

            if (shouldInitFavorite) {
              _favoriteInitialized = false;
              _initializedFavoritePollId = poll.id.value;
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
      _resultController.markUserHasVoted();
      await _resultController.reload();
    }
  }

  Widget _buildPollContent(BuildContext context, Poll poll) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final config = poll.configuration;
    final visibilityMode = config.visibilityRules.resultsVisibility;
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
          PollDetailHeader(
            poll: poll,
            isFavorite: _isFavorite,
            onFavoritePressed: () {
              if (_favoriteLoading) return;
              _onFavoritePressed(poll);
            },
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
            isQuorumApplicable: _resultController.isQuorumApplicable,
            isQuorumReached: _resultController.isQuorumReached,
            totalVotes: totalVotes,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.pollDetail_optionsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          PollOptionsSection(
            poll: poll,
            selectedOptionIds: _voteController.selectedOptionIds,
            onToggleOption: (optionId, allowMultiple) {
              _voteController.toggleOption(
                optionId,
                allowMultiple: allowMultiple,
              );
            },
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
          PollResultsSection(
            canShowResults: _resultController.canShowResults,
            isLoading: _resultController.isLoading,
            error: _resultController.error,
            result: _resultController.result,
            hasOutcome: _resultController.hasOutcome,
            outcome: _resultController.outcome,
            visibilityMode: visibilityMode,
          ),
          const SizedBox(height: 32),
          CommentSection(
            userId: currentUserForComments,
          ),
        ],
      ),
    );
  }

  String? _mapVoteErrorToText(AppLocalizations l10n) {
    switch (_voteController.errorType) {
      case VoteErrorType.none:
        return null;
      case VoteErrorType.noSelection:
        return "Seleziona almeno un'opzione";
      case VoteErrorType.unauthorized:
        return 'Devi essere autenticato per votare';
      case VoteErrorType.closed:
        return 'Questo sondaggio è chiuso';
      case VoteErrorType.alreadyVoted:
        return 'Hai già votato in questo sondaggio';
      case VoteErrorType.generic:
        return 'Impossibile registrare il voto';
    }
  }
}