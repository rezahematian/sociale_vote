import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/moderation/entities/report.dart';
import 'package:sociale_vote/domain/moderation/repositories/moderation_repository.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_status.dart';
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
  final bool openCommentsOnLoad;

  const PollDetailPage({
    super.key,
    required this.pollId,
    this.openCommentsOnLoad = false,
  });

  @override
  State<PollDetailPage> createState() => _PollDetailPageState();
}

class _PollDetailPageState extends State<PollDetailPage> {
  static const List<String> _reportReasons = [
    'spam',
    'harassment',
    'hate_speech',
    'misinformation',
    'violence',
    'other',
  ];

  late final PollDetailController _controller;
  late final VoteController _voteController;
  late final PollResultController _resultController;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _commentSectionKey = GlobalKey();

  bool _isFavorite = false;
  bool _favoriteInitialized = false;
  bool _favoriteLoading = false;
  bool _resultsInitialized = false;
  bool _hasAutoScrolledToComments = false;
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
      _hasAutoScrolledToComments = false;
      _initializedFavoritePollId = null;

      final userId = AppDI.instance.currentUserId;
      _controller.loadPoll(widget.pollId, userId: userId);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
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

  void _maybeAutoScrollToComments() {
    if (!widget.openCommentsOnLoad || _hasAutoScrolledToComments) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToComments();
    });
  }

  Future<void> _scrollToComments() async {
    if (!mounted) return;

    if (!_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToComments();
      });
      return;
    }

    _hasAutoScrolledToComments = true;

    Future<void> animateToBottom({
      required Duration duration,
    }) async {
      if (!mounted || !_scrollController.hasClients) return;

      final target = _scrollController.position.maxScrollExtent;
      await _scrollController.animateTo(
        target,
        duration: duration,
        curve: Curves.easeInOut,
      );
    }

    await animateToBottom(duration: const Duration(milliseconds: 320));

    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    await animateToBottom(duration: const Duration(milliseconds: 220));

    final commentContext = _commentSectionKey.currentContext;
    if (commentContext != null && mounted) {
      await Scrollable.ensureVisible(
        commentContext,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    }
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

  Future<void> _onSharePressed(Poll poll) async {
    final description = poll.description?.trim();
    final buffer = StringBuffer()
      ..writeln(poll.title);

    if (description != null && description.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(description);
    }

    buffer
      ..writeln()
      ..writeln('Apri Sociale_Vote per vedere e votare questo sondaggio.');

    try {
      await Share.share(
        buffer.toString().trim(),
        subject: poll.title,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossibile condividere il sondaggio')),
      );
    }
  }

  Future<void> _onReportPressed(Poll poll) async {
    final allowed = await AuthGuard.ensureCanPerformAction(
      context,
      ParticipationAction.reportContent,
    );
    if (!allowed) return;

    final userId = AppDI.instance.currentUserId;
    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Devi essere autenticato per segnalare')),
      );
      return;
    }

    final reason = await _showReportReasonDialog(context);
    if (!mounted || reason == null) return;

    try {
      final result = await AppDI.instance.reportContent(
        Report(
          target: TargetRef.poll(poll.id.value),
          userId: userId,
          reason: reason,
          createdAt: DateTime.now(),
        ),
      );

      if (!mounted) return;

      final message = switch (result) {
        SubmitReportResult.submitted => 'Segnalazione inviata',
        SubmitReportResult.alreadyReported =>
          'Hai già segnalato questo contenuto',
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossibile inviare la segnalazione')),
      );
    }
  }

  Future<String?> _showReportReasonDialog(BuildContext context) async {
    String selectedReason = _reportReasons.first;

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Segnala contenuto'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: _reportReasons.map((reason) {
                  return RadioListTile<String>(
                    value: reason,
                    groupValue: selectedReason,
                    contentPadding: EdgeInsets.zero,
                    title: Text(_reportReasonLabel(reason)),
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() {
                        selectedReason = value;
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annulla'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(selectedReason);
                  },
                  child: const Text('Invia'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _reportReasonLabel(String reason) {
    switch (reason) {
      case 'spam':
        return 'Spam';
      case 'harassment':
        return 'Molestie o abuso';
      case 'hate_speech':
        return 'Incitamento all’odio';
      case 'misinformation':
        return 'Disinformazione';
      case 'violence':
        return 'Violenza';
      case 'other':
        return 'Altro';
    }
    return reason;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final pageBackground = Color.alphaBlend(
      theme.colorScheme.primary.withOpacity(0.03),
      theme.scaffoldBackgroundColor,
    );

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          l10n.pollDetail_title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final state = _controller.state;
              if (state is! PollDetailLoaded) {
                return const SizedBox.shrink();
              }

              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'report') {
                    _onReportPressed(state.poll);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'report',
                    child: Text('Report content'),
                  ),
                ],
              );
            },
          ),
        ],
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

            _maybeAutoScrollToComments();

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
    final discussionController = context.watch<DiscussionController>();

    final config = poll.configuration;
    final visibilityMode = config.visibilityRules.resultsVisibility;
    final totalVotes = _resultController.result?.totalVotes ?? 0;

    final int fireCount = _controller.likeCount();
    final int iceCount = _controller.dislikeCount();
    final userReaction = _controller.userReaction;
    final int commentCount = discussionController.comments.length;

    final String currentUserForComments =
        AppDI.instance.currentUserId ?? 'guest';

    final voteErrorText = _mapVoteErrorToText(l10n);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          child: ListView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildSectionSurface(
                context,
                child: PollDetailHeader(
                  poll: poll,
                  isFavorite: _isFavorite,
                  onFavoritePressed: () {
                    if (_favoriteLoading) return;
                    _onFavoritePressed(poll);
                  },
                  onSharePressed: () => _onSharePressed(poll),
                  fireCount: fireCount,
                  iceCount: iceCount,
                  commentCount: commentCount,
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
                  onCommentTap: _scrollToComments,
                  isQuorumApplicable: _resultController.isQuorumApplicable,
                  isQuorumReached: _resultController.isQuorumReached,
                  totalVotes: totalVotes,
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionSurface(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.pollDetail_optionsTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildInnerSurface(
                      context,
                      child: PollOptionsSection(
                        poll: poll,
                        selectedOptionIds: _voteController.selectedOptionIds,
                        onToggleOption: (optionId, allowMultiple) {
                          _voteController.toggleOption(
                            optionId,
                            allowMultiple: allowMultiple,
                          );
                        },
                      ),
                    ),
                    if (poll.status != PollStatus.open) ...[
                      const SizedBox(height: 16),
                      _buildFeedbackBox(
                        context,
                        message: poll.status == PollStatus.closed
                            ? l10n.pollDetail_statusClosedMessage
                            : poll.status == PollStatus.scheduled
                                ? l10n.pollDetail_statusScheduledMessage
                                : l10n.pollDetail_statusNotAvailableMessage,
                        icon: Icons.info_outline,
                        tone: _FeedbackTone.warning,
                      ),
                    ],
                    if (voteErrorText != null) ...[
                      const SizedBox(height: 14),
                      _buildFeedbackBox(
                        context,
                        message: voteErrorText,
                        icon: Icons.error_outline,
                        tone: _FeedbackTone.error,
                      ),
                    ],
                    if (_voteController.submittedSuccessfully) ...[
                      const SizedBox(height: 14),
                      _buildFeedbackBox(
                        context,
                        message: l10n.pollDetail_voteSubmitted,
                        icon: Icons.check_circle_outline,
                        tone: _FeedbackTone.success,
                      ),
                    ],
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 180,
                          maxWidth: 240,
                        ),
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _canVote(poll)
                              ? () => _onVotePressed(context, poll)
                              : null,
                          child: _voteController.isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n.pollDetail_voteButton),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionSurface(
                context,
                child: PollResultsSection(
                  canShowResults: _resultController.canShowResults,
                  isLoading: _resultController.isLoading,
                  error: _resultController.error,
                  result: _resultController.result,
                  hasOutcome: _resultController.hasOutcome,
                  outcome: _resultController.outcome,
                  visibilityMode: visibilityMode,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                key: _commentSectionKey,
                child: CommentSection(
                  userId: currentUserForComments,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionSurface(
    BuildContext context, {
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.7),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInnerSurface(
    BuildContext context, {
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.58),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.55),
          width: 1,
        ),
      ),
      child: child,
    );
  }

  Widget _buildFeedbackBox(
    BuildContext context, {
    required String message,
    required IconData icon,
    required _FeedbackTone tone,
  }) {
    final theme = Theme.of(context);

    final Color baseColor = switch (tone) {
      _FeedbackTone.success => theme.colorScheme.primary,
      _FeedbackTone.warning => Colors.orange.shade700,
      _FeedbackTone.error => theme.colorScheme.error,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: baseColor.withOpacity(0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: baseColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: baseColor,
                fontWeight: FontWeight.w600,
              ),
            ),
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

enum _FeedbackTone {
  success,
  warning,
  error,
}