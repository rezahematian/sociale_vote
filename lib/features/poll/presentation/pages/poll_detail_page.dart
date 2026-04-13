import 'dart:async';

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
import 'package:sociale_vote/domain/poll/repositories/vote_repository.dart';
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

      _resultController.reset();

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
    final buffer = StringBuffer()..writeln(poll.title);

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

  Future<void> _onEditPressed(Poll poll) async {
    final userId = AppDI.instance.currentUserId;
    if (userId == null || !_controller.canEdit(userId: userId)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Puoi modificare solo i tuoi sondaggi senza voti',
          ),
        ),
      );
      return;
    }

    final result = await _showEditPollDialog(context, poll);
    if (!mounted || result == null) {
      return;
    }

    try {
      await _controller.updateCurrentPollText(
        userId: userId,
        title: result.title,
        description: result.description,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sondaggio aggiornato')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<_EditPollFormResult?> _showEditPollDialog(
    BuildContext context,
    Poll poll,
  ) async {
    final titleController = TextEditingController(text: poll.title);
    final descriptionController = TextEditingController(
      text: poll.description ?? '',
    );
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<_EditPollFormResult>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Modifica sondaggio'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Titolo',
                    ),
                    validator: (value) {
                      final normalized = value?.trim() ?? '';
                      if (normalized.isEmpty) {
                        return 'Il titolo è obbligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: descriptionController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Descrizione',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }

                Navigator.of(dialogContext).pop(
                  _EditPollFormResult(
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                  ),
                );
              },
              child: const Text('Salva'),
            ),
          ],
        );
      },
    );

    return result;
  }

  Future<void> _onDeletePressed(Poll poll) async {
    final userId = AppDI.instance.currentUserId;
    if (userId == null || !_controller.canDelete(userId: userId)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Puoi eliminare solo i tuoi sondaggi'),
        ),
      );
      return;
    }

    final confirmed = await _showDeletePollDialog(context, poll);
    if (!mounted || confirmed != true) {
      return;
    }

    final deleted = await _controller.deleteCurrentPoll(userId: userId);
    if (!mounted) return;

    if (deleted) {
      Navigator.of(context).pop(true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Impossibile eliminare il sondaggio'),
      ),
    );
  }

  Future<bool?> _showDeletePollDialog(
    BuildContext context,
    Poll poll,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Elimina sondaggio'),
          content: Text(
            'Vuoi davvero eliminare "${poll.title}"? Questa azione non può essere annullata.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Elimina'),
            ),
          ],
        );
      },
    );
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

  Future<void> _showPublicVotesSheet(
    BuildContext context,
    Poll poll,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return _PublicVotesSheetContent(
          poll: poll,
          resultController: _resultController,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    final pageBackground = Color.alphaBlend(
      colorScheme.primary.withOpacity(isDark ? 0.035 : 0.012),
      theme.scaffoldBackgroundColor,
    );

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 8,
        title: Text(
          l10n.pollDetail_title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
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

              final currentUserId = AppDI.instance.currentUserId;
              final canDelete = currentUserId != null &&
                  _controller.canDelete(userId: currentUserId);
              final canEdit = currentUserId != null &&
                  _controller.canEdit(userId: currentUserId);

              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'report') {
                    _onReportPressed(state.poll);
                    return;
                  }

                  if (value == 'edit') {
                    _onEditPressed(state.poll);
                    return;
                  }

                  if (value == 'delete') {
                    _onDeletePressed(state.poll);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'report',
                    child: Text('Report content'),
                  ),
                  if (canEdit)
                    PopupMenuItem<String>(
                      value: 'edit',
                      enabled: !_controller.isUpdating,
                      child: Text(
                        _controller.isUpdating
                            ? 'Salvataggio...'
                            : 'Modifica sondaggio',
                      ),
                    ),
                  if (canDelete)
                    PopupMenuItem<String>(
                      value: 'delete',
                      enabled: !_controller.isDeleting,
                      child: Text(
                        _controller.isDeleting
                            ? 'Eliminazione...'
                            : 'Elimina sondaggio',
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: ColoredBox(
        color: pageBackground,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final state = _controller.state;

            if (state is PollDetailLoading || state is PollDetailInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PollDetailError) {
              return _buildErrorState(
                context,
                message: state.message,
                onRetry: () {
                  final userId = AppDI.instance.currentUserId;
                  _controller.loadPoll(widget.pollId, userId: userId);
                },
              );
            }

            if (state is PollDetailLoaded) {
              final poll = state.poll;

              if (!_resultsInitialized) {
                _resultsInitialized = true;
                _resultController.loadResults(
                  poll: poll,
                  userHasVoted: false,
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
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final isWideLayout = constraints.maxWidth >= 980;
                        return _buildPollContent(
                          context,
                          poll,
                          isWideLayout: isWideLayout,
                        );
                      },
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
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

    String? userCountryCode;
    try {
      final profile = await AppDI.instance.getUserProfile(userId);
      final normalizedCountry = profile?.country?.trim();
      if (normalizedCountry != null && normalizedCountry.isNotEmpty) {
        userCountryCode = normalizedCountry.toUpperCase();
      }
    } catch (_) {}

    await _voteController.submitVote(
      poll: poll,
      userId: userId,
      userCountryCode: userCountryCode,
    );

    if (_voteController.submittedSuccessfully) {
      _resultController.markUserHasVoted();
      await _resultController.reload();
    }
  }

  Widget _buildPollContent(
    BuildContext context,
    Poll poll, {
    required bool isWideLayout,
  }) {
    final discussionController = context.watch<DiscussionController>();
    final config = poll.configuration;
    final visibilityMode = config.visibilityRules.resultsVisibility;
    final totalVotes = _resultController.result?.totalVotes ?? 0;

    final int fireCount = _controller.likeCount();
    final int iceCount = _controller.dislikeCount();
    final userReaction = _controller.userReaction;
    final int commentCount = discussionController.comments.length;

    final String currentUserForComments = AppDI.instance.currentUserId ?? 'guest';

    final l10n = AppLocalizations.of(context)!;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
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
              const SizedBox(height: 20),
              if (isWideLayout)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 11,
                      child: _buildOptionsCard(
                        context,
                        poll,
                        l10n: l10n,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 10,
                      child: _buildResultsCard(
                        context,
                        poll: poll,
                        visibilityMode: visibilityMode,
                      ),
                    ),
                  ],
                )
              else ...[
                _buildOptionsCard(
                  context,
                  poll,
                  l10n: l10n,
                ),
                const SizedBox(height: 20),
                _buildResultsCard(
                  context,
                  poll: poll,
                  visibilityMode: visibilityMode,
                ),
              ],
              const SizedBox(height: 20),
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

  Widget _buildOptionsCard(
    BuildContext context,
    Poll poll, {
    required AppLocalizations l10n,
  }) {
    final theme = Theme.of(context);
    final voteErrorText = _mapVoteErrorToText(l10n);

    return _buildSectionSurface(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.pollDetail_optionsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 18),
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
                maxWidth: 260,
              ),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
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
    );
  }

  Widget _buildResultsCard(
    BuildContext context, {
    required Poll poll,
    required dynamic visibilityMode,
  }) {
    final showPublicVotesCta = _resultController.canShowPublicVotes;

    return _buildSectionSurface(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PollResultsSection(
            canShowResults: _resultController.canShowResults,
            isLoading: _resultController.isLoading,
            error: _resultController.error,
            result: _resultController.result,
            hasOutcome: _resultController.hasOutcome,
            outcome: _resultController.outcome,
            visibilityMode: visibilityMode,
          ),
          if (showPublicVotesCta) ...[
            const SizedBox(height: 18),
            _buildPublicVotesEntryPoint(context, poll),
          ],
        ],
      ),
    );
  }

  Widget _buildPublicVotesEntryPoint(
    BuildContext context,
    Poll poll,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.visibility_outlined,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Voti pubblici disponibili',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Questo sondaggio permette di vedere chi ha votato cosa.',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _showPublicVotesSheet(context, poll),
            icon: const Icon(Icons.person_search_outlined),
            label: const Text('Vedi voti pubblici'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionSurface(
    BuildContext context, {
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final surfaceColor = Color.alphaBlend(
      colorScheme.primary.withOpacity(isDark ? 0.05 : 0.014),
      colorScheme.surface,
    );

    final borderColor = colorScheme.outline.withOpacity(isDark ? 0.26 : 0.12);

    final shadowColor = isDark
        ? Colors.black.withOpacity(0.18)
        : Colors.black.withOpacity(0.045);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
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

  Widget _buildErrorState(
    BuildContext context, {
    required String message,
    required VoidCallback onRetry,
  }) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: _buildSectionSurface(
            context,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 32,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Riprova'),
                ),
              ],
            ),
          ),
        ),
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

class _PublicVotesSheetContent extends StatefulWidget {
  final Poll poll;
  final PollResultController resultController;

  const _PublicVotesSheetContent({
    required this.poll,
    required this.resultController,
  });

  @override
  State<_PublicVotesSheetContent> createState() =>
      _PublicVotesSheetContentState();
}

class _PublicVotesSheetContentState extends State<_PublicVotesSheetContent> {
  late final TextEditingController _searchController;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController(
      text: widget.resultController.publicVotesQuery,
    );
    _searchController.addListener(_handleSearchTextChanged);

    if (!widget.resultController.publicVotesInitialized &&
        !widget.resultController.isPublicVotesLoading) {
      unawaited(
        widget.resultController.loadPublicVotes(
          query: _searchController.text,
        ),
      );
    }
  }

  void _handleSearchTextChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _handleSearchSubmitted(String value) {
    _searchDebounce?.cancel();
    widget.resultController.loadPublicVotes(query: value);
  }

  void _handleSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () {
        if (!mounted) return;
        widget.resultController.loadPublicVotes(query: value);
      },
    );
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    widget.resultController.loadPublicVotes(query: '');
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_handleSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.88,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Voti pubblici',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Qui puoi vedere chi ha votato cosa in questo sondaggio.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Cerca utente',
                  suffixIcon: _searchController.text.trim().isEmpty
                      ? null
                      : IconButton(
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.close),
                        ),
                ),
                onSubmitted: _handleSearchSubmitted,
                onChanged: _handleSearchChanged,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: AnimatedBuilder(
                  animation: widget.resultController,
                  builder: (context, _) {
                    return _PublicVotesBody(
                      poll: widget.poll,
                      resultController: widget.resultController,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PublicVotesBody extends StatelessWidget {
  final Poll poll;
  final PollResultController resultController;

  const _PublicVotesBody({
    required this.poll,
    required this.resultController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (resultController.isPublicVotesLoading &&
        resultController.publicVotes.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (resultController.publicVotesError != null &&
        resultController.publicVotes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 30,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                'Impossibile caricare i voti pubblici',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () {
                  resultController.loadPublicVotes(
                    query: resultController.publicVotesQuery,
                  );
                },
                child: const Text('Riprova'),
              ),
            ],
          ),
        ),
      );
    }

    if (resultController.publicVotes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            resultController.publicVotesQuery.trim().isEmpty
                ? 'Nessun voto pubblico disponibile'
                : 'Nessun utente trovato per questa ricerca',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    final entries = resultController.publicVotes;

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '${entries.length} risultati caricati',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _PublicVoteTile(
                poll: poll,
                entry: entry,
              );
            },
          ),
        ),
        if (resultController.isPublicVotesLoading &&
            entries.isNotEmpty) ...[
          const SizedBox(height: 12),
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ] else if (resultController.publicVotesHasMore) ...[
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              resultController.loadPublicVotes(
                query: resultController.publicVotesQuery,
                loadMore: true,
              );
            },
            child: const Text('Carica altri'),
          ),
        ],
      ],
    );
  }
}

class _PublicVoteTile extends StatelessWidget {
  final Poll poll;
  final PublicPollVoteEntry entry;

  const _PublicVoteTile({
    required this.poll,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final primaryLabel =
        entry.displayName?.trim().isNotEmpty == true
            ? entry.displayName!.trim()
            : entry.username?.trim().isNotEmpty == true
                ? '@${entry.username!.trim()}'
                : 'Utente';

    final secondaryLabel =
        entry.displayName?.trim().isNotEmpty == true &&
                entry.username?.trim().isNotEmpty == true
            ? '@${entry.username!.trim()}'
            : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: colorScheme.primary.withOpacity(0.12),
                child: Icon(
                  Icons.person_outline,
                  size: 18,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      primaryLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (secondaryLabel != null)
                      Text(
                        secondaryLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(
                            0.75,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                _formatVoteDate(entry.votedAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: entry.optionIds.map((optionId) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.16),
                  ),
                ),
                child: Text(
                  _optionLabelFor(poll, optionId),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
              );
            }).toList(growable: false),
          ),
        ],
      ),
    );
  }

  static String _optionLabelFor(Poll poll, String optionId) {
    for (final option in poll.options) {
      final rawId = _extractOptionId(option);
      if (rawId != optionId) {
        continue;
      }

      final rawLabel = _extractOptionLabel(option);
      if (rawLabel != null && rawLabel.isNotEmpty) {
        return rawLabel;
      }
    }

    return optionId;
  }

  static String? _extractOptionId(dynamic option) {
    if (option == null) return null;

    try {
      final directId = option.id;
      if (directId != null) {
        final nestedValue = _tryReadValueField(directId);
        final normalizedNested = _normalizeDisplayText(nestedValue);
        if (normalizedNested != null) {
          return normalizedNested;
        }

        final normalizedDirect = _normalizeDisplayText(directId);
        if (normalizedDirect != null) {
          return normalizedDirect;
        }
      }
    } catch (_) {}

    try {
      final optionId = option.optionId;
      if (optionId != null) {
        final nestedValue = _tryReadValueField(optionId);
        final normalizedNested = _normalizeDisplayText(nestedValue);
        if (normalizedNested != null) {
          return normalizedNested;
        }

        final normalizedDirect = _normalizeDisplayText(optionId);
        if (normalizedDirect != null) {
          return normalizedDirect;
        }
      }
    } catch (_) {}

    return null;
  }

  static String? _extractOptionLabel(dynamic option) {
    if (option == null) return null;

    for (final candidate in [
      _tryReadField(option, 'label'),
      _tryReadField(option, 'text'),
      _tryReadField(option, 'title'),
      _tryReadField(option, 'value'),
    ]) {
      final normalized = _normalizeDisplayText(candidate);
      if (normalized != null) {
        return normalized;
      }
    }

    return null;
  }

  static dynamic _tryReadField(dynamic target, String fieldName) {
    try {
      switch (fieldName) {
        case 'label':
          return target.label;
        case 'text':
          return target.text;
        case 'title':
          return target.title;
        case 'value':
          return target.value;
      }
    } catch (_) {}
    return null;
  }

  static dynamic _tryReadValueField(dynamic target) {
    try {
      return target.value;
    } catch (_) {
      return null;
    }
  }

  static String? _normalizeDisplayText(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    return text;
  }

  static String _formatVoteDate(DateTime value) {
    final local = value.toLocal();

    String twoDigits(int n) => n.toString().padLeft(2, '0');

    return '${twoDigits(local.day)}/${twoDigits(local.month)} '
        '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
  }
}

class _EditPollFormResult {
  final String title;
  final String? description;

  const _EditPollFormResult({
    required this.title,
    this.description,
  });
}

enum _FeedbackTone {
  success,
  warning,
  error,
}