import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/app/theme/radius.dart';
import 'package:sociale_vote/app/theme/spacing.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';
import 'package:sociale_vote/shared/services/anti_abuse_error_service.dart';
import 'package:sociale_vote/shared/widgets/user_identity_mark.dart';
import 'package:sociale_vote/shared/widgets/social_vote_symbols.dart';
import 'package:sociale_vote/shared/widgets/content_directionality.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/identity/entities/user_profile.dart';
import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';
import 'package:sociale_vote/domain/moderation/entities/report.dart';
import 'package:sociale_vote/domain/moderation/repositories/moderation_repository.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/entities/poll_result.dart';
import 'package:sociale_vote/domain/poll/repositories/vote_repository.dart';
import 'package:sociale_vote/domain/poll/value_objects/anonymity_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_outcome.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_status.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_type.dart';
import 'package:sociale_vote/domain/poll/value_objects/visibility_rules.dart';
import 'package:sociale_vote/features/discussion/application/discussion_controller.dart';
import 'package:sociale_vote/features/discussion/presentation/widgets/comment_section.dart';
import 'package:sociale_vote/features/profile/presentation/pages/public_user_profile_page.dart';
import 'package:sociale_vote/l10n/app_localizations.dart';

import '../../application/poll_detail_controller.dart';
import '../../application/poll_result_controller.dart';
import '../../application/poll_state.dart';
import '../../application/vote_controller.dart';
import '../widgets/poll_detail_header.dart';

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
  UserProfile? _pollAuthorProfile;
  String? _loadedPollAuthorId;

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
      _pollAuthorProfile = null;
      _loadedPollAuthorId = null;

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

  void _ensurePollAuthorProfileLoaded(Poll poll) {
    final authorId = poll.createdByUserId?.trim();
    if (authorId == null || authorId.isEmpty) {
      return;
    }

    if (_loadedPollAuthorId == authorId) {
      return;
    }

    _loadedPollAuthorId = authorId;
    unawaited(_loadPollAuthorProfile(authorId));
  }

  Future<void> _loadPollAuthorProfile(String authorId) async {
    try {
      final profile =
          await AppDI.instance.userProfileRepository.getUserProfile(authorId);

      if (!mounted || _loadedPollAuthorId != authorId) {
        return;
      }

      setState(() {
        _pollAuthorProfile = profile;
      });
    } catch (_) {
      if (!mounted || _loadedPollAuthorId != authorId) {
        return;
      }

      setState(() {
        _pollAuthorProfile = null;
      });
    }
  }

  void _openPollAuthorProfile(String userId, {String? organizationId}) {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PublicUserProfilePage(
          userId: normalizedUserId,
          organizationId: organizationId,
        ),
      ),
    );
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
    if (commentContext != null && commentContext.mounted) {
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
    if (!allowed || !mounted) return;

    final userId = AppDI.instance.currentUserId;
    if (userId == null) return;

    final l10n = AppLocalizations.of(context)!;

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
        SnackBar(content: Text(l10n.pollDetail_favoriteUpdateError)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _favoriteLoading = false;
        });
      }
    }
  }

  Future<void> _onSharePressed(Poll poll) async {
    final l10n = AppLocalizations.of(context)!;
    final title = poll.title.trim();
    final url = AppRouter.publicPollUrl(poll.id.value);
    final shareText = title.isEmpty ? url : 'Social Vote — $title\n$url';

    try {
      await Share.share(
        shareText,
        subject: poll.title,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pollDetail_shareError)),
      );
    }
  }

  Future<void> _onEditPressed(Poll poll) async {
    final l10n = AppLocalizations.of(context)!;
    final userId = AppDI.instance.currentUserId;

    if (userId == null || !_controller.canEdit(userId: userId)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pollDetail_editPermissionError),
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
        SnackBar(content: Text(l10n.pollDetail_editSuccessMessage)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pollDetail_editError)),
      );
    }
  }

  Future<_EditPollFormResult?> _showEditPollDialog(
    BuildContext context,
    Poll poll,
  ) {
    return showDialog<_EditPollFormResult>(
      context: context,
      builder: (dialogContext) {
        return _EditPollDialog(
          initialTitle: poll.title,
          initialDescription: poll.description ?? '',
        );
      },
    );
  }

  Future<void> _onDeletePressed(Poll poll) async {
    final l10n = AppLocalizations.of(context)!;
    final userId = AppDI.instance.currentUserId;

    if (userId == null || !_controller.canDelete(userId: userId)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pollDetail_deletePermissionError),
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
      SnackBar(
        content: Text(l10n.pollDetail_deleteError),
      ),
    );
  }

  Future<bool?> _showDeletePollDialog(
    BuildContext context,
    Poll poll,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.pollDetail_deleteDialogTitle),
          content: Text(
            l10n.pollDetail_deleteDialogMessage(poll.title),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.commonCancelButton),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.commonDeleteButton),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onReportPressed(Poll poll) async {
    final l10n = AppLocalizations.of(context)!;

    final allowed = await AuthGuard.ensureCanPerformAction(
      context,
      ParticipationAction.reportContent,
    );
    if (!allowed || !mounted) return;

    final userId = AppDI.instance.currentUserId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.contentReport_authenticationRequired)),
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
        SubmitReportResult.submitted => l10n.contentReport_submittedMessage,
        SubmitReportResult.alreadyReported =>
          l10n.contentReport_alreadySubmittedMessage,
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.contentReport_submitError)),
      );
    }
  }

  Future<String?> _showReportReasonDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    String selectedReason = _reportReasons.first;

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.contentReport_dialogTitle),
              content: RadioGroup<String>(
                groupValue: selectedReason,
                onChanged: (value) {
                  if (value == null) return;
                  setDialogState(() {
                    selectedReason = value;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _reportReasons.map((reason) {
                    return RadioListTile<String>(
                      value: reason,
                      contentPadding: EdgeInsets.zero,
                      title: Text(_reportReasonLabel(l10n, reason)),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.commonCancelButton),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(selectedReason);
                  },
                  child: Text(l10n.contentReport_sendButton),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _reportReasonLabel(
    AppLocalizations l10n,
    String reason,
  ) {
    switch (reason) {
      case 'spam':
        return l10n.contentReport_reasonSpam;
      case 'harassment':
        return l10n.contentReport_reasonHarassment;
      case 'hate_speech':
        return l10n.contentReport_reasonHateSpeech;
      case 'misinformation':
        return l10n.contentReport_reasonMisinformation;
      case 'violence':
        return l10n.contentReport_reasonViolence;
      case 'other':
        return l10n.contentReport_reasonOther;
    }
    return reason;
  }

  Future<void> _showPublicVotesSheet(
    BuildContext context,
    Poll poll,
  ) async {
    final colorScheme = Theme.of(context).colorScheme;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 760),
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.sheetRadius,
      ),
      clipBehavior: Clip.antiAlias,
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
      colorScheme.primary.withValues(alpha: isDark ? 0.035 : 0.012),
      theme.scaffoldBackgroundColor,
    );

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final navigator = Navigator.of(context);
            if (navigator.canPop()) {
              navigator.pop();
              return;
            }

            navigator.pushNamedAndRemoveUntil(
              AppRouter.home,
              (route) => false,
            );
          },
        ),
        backgroundColor: pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 8,
        title: Row(
          children: [
            const ContentTypeMark(
              kind: SocialVoteContentKind.vote,
              size: 28,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                l10n.pollDetail_title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
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
                  PopupMenuItem<String>(
                    value: 'report',
                    child: Text(l10n.contentReport_menuAction),
                  ),
                  if (canEdit)
                    PopupMenuItem<String>(
                      value: 'edit',
                      enabled: !_controller.isUpdating,
                      child: Text(
                        _controller.isUpdating
                            ? l10n.pollDetail_editSavingMenuItem
                            : l10n.pollDetail_editMenuItem,
                      ),
                    ),
                  if (canDelete)
                    PopupMenuItem<String>(
                      value: 'delete',
                      enabled: !_controller.isDeleting,
                      child: Text(
                        _controller.isDeleting
                            ? l10n.pollDetail_deleteDeletingMenuItem
                            : l10n.pollDetail_deleteMenuItem,
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
        child: SafeArea(
          top: false,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final state = _controller.state;

              if (state is PollDetailLoading || state is PollDetailInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is PollDetailError) {
                final errorMessage = state.message == 'Poll not found'
                    ? l10n.pollDetail_notFound
                    : l10n.pollDetail_loadError;

                return _buildErrorState(
                  context,
                  message: errorMessage,
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
                      return _buildPollContent(
                        context,
                        poll,
                      );
                    },
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
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

    if (!context.mounted) {
      return;
    }

    if (poll.configuration.anonymityRules.level == AnonymityLevel.public) {
      final l10n = AppLocalizations.of(context)!;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(l10n.pollDetail_chipPublic),
            content: Text(l10n.pollDetail_publicVotesAvailableMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.commonCancelButton),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.pollDetail_voteButton),
              ),
            ],
          );
        },
      );

      if (!mounted || confirmed != true) {
        return;
      }
    }

    final userId = AppDI.instance.currentUserId;
    if (userId == null) {
      return;
    }

    String? userCountryCode;
    var actorType = ActorType.citizen;
    var verificationLevel = VerificationLevel.none;

    try {
      final profile = await AppDI.instance.getUserProfile(userId);

      final normalizedCountry = profile.votingCountryCode?.trim();
      if (normalizedCountry != null && normalizedCountry.isNotEmpty) {
        userCountryCode = normalizedCountry.toUpperCase();
      }

      actorType = profile.actorType;
      verificationLevel = profile.verificationLevel;
    } catch (_) {}

    await _voteController.submitVote(
      poll: poll,
      userId: userId,
      userCountryCode: userCountryCode,
      actorType: actorType,
      verificationLevel: verificationLevel,
    );

    if (_voteController.submittedSuccessfully) {
      _resultController.markUserHasVoted();
      await _resultController.reload();
    }
  }

  Widget _buildPollContent(
    BuildContext context,
    Poll poll,
  ) {
    _ensurePollAuthorProfileLoaded(poll);

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
    final authorUserId = poll.createdByUserId?.trim();
    final hasAuthorUserId = authorUserId != null && authorUserId.isNotEmpty;

    final isCompactLayout = MediaQuery.sizeOf(context).width < 600;
    final horizontalPadding = isCompactLayout ? AppSpacing.s : AppSpacing.l;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            AppSpacing.s,
            horizontalPadding,
            AppSpacing.l,
          ),
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
                  authorProfile: _loadedPollAuthorId == authorUserId
                      ? _pollAuthorProfile
                      : null,
                  onAuthorTap: hasAuthorUserId
                      ? () => _openPollAuthorProfile(
                            authorUserId,
                            organizationId: poll.publisherOrganizationId,
                          )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              _buildVotingAndResultsCard(
                context,
                poll: poll,
                visibilityMode: visibilityMode,
              ),
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

  String _formatVoteReceiptDate(
    BuildContext context,
    DateTime value,
  ) {
    final localValue = value.toLocal();
    final materialL10n = MaterialLocalizations.of(context);
    final date = materialL10n.formatFullDate(localValue);
    final time = materialL10n.formatTimeOfDay(
      TimeOfDay.fromDateTime(localValue),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

    return '$date · $time';
  }

  Future<void> _showVoteReceipt(
    BuildContext context,
    VoteReceipt receipt,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.verified_outlined),
              const SizedBox(width: 10),
              Expanded(
                child: Text(l10n.pollDetail_voteReceiptTitle),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.pollDetail_voteReceiptIdLabel,
                  style: Theme.of(dialogContext).textTheme.labelLarge,
                ),
                const SizedBox(height: 6),
                SelectableText(
                  receipt.receiptId,
                  style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                      ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.pollDetail_voteReceiptDateLabel,
                  style: Theme.of(dialogContext).textTheme.labelLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  _formatVoteReceiptDate(
                    dialogContext,
                    receipt.createdAt,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.pollDetail_voteReceiptPrivacy,
                  style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                        color: Theme.of(dialogContext)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: 0.78),
                      ),
                ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.pollDetail_voteReceiptCloseButton),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVotingAndResultsCard(
    BuildContext context, {
    required Poll poll,
    required ResultsVisibilityMode visibilityMode,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final voteErrorText = _mapVoteErrorToText(l10n);

    final result = _resultController.result;
    final isResultsLoading = _resultController.isLoading;
    final hasResultsError = _resultController.error != null;
    final canShowResults = _resultController.canShowResults;
    final showResultValues = canShowResults &&
        !isResultsLoading &&
        !hasResultsError &&
        result != null;

    final resultByOptionId = <String, PollOptionResult>{
      if (result != null)
        for (final optionResult in result.optionResults)
          optionResult.optionId: optionResult,
    };

    final totalVotes = result?.totalVotes ?? 0;
    final isSelectable = poll.status == PollStatus.open;
    final isSingleChoice =
        poll.type == PollType.singleChoice || poll.type == PollType.yesNo;
    final allowMultiple = !isSingleChoice;
    final showPublicVotesCta = _resultController.canShowPublicVotes;
    final voteReceipt = _resultController.currentUserVoteReceipt;

    return _buildSectionSurface(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  l10n.pollDetail_optionsTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              if (isResultsLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (canShowResults)
                _buildResultsHeader(
                  context,
                  title: l10n.pollDetail_resultsTitle,
                  totalVotes: totalVotes,
                ),
            ],
          ),
          if (showResultValues && _resultController.hasOutcome) ...[
            const SizedBox(height: 10),
            _buildOutcomeBadge(
              context,
              l10n.pollDetail_outcomePrefix(
                _mapOutcomeLabel(l10n, _resultController.outcome),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.34),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.14),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (int index = 0; index < poll.options.length; index++) ...[
                  _PollChoiceResultRow(
                    index: index,
                    label: poll.options[index].label,
                    isSelected: _voteController.selectedOptionIds
                        .contains(poll.options[index].id),
                    isSelectable: isSelectable,
                    allowMultiple: allowMultiple,
                    result: showResultValues
                        ? resultByOptionId[poll.options[index].id]
                        : null,
                    onTap: isSelectable
                        ? () {
                            _voteController.toggleOption(
                              poll.options[index].id,
                              allowMultiple: allowMultiple,
                            );
                          }
                        : null,
                  ),
                  if (index != poll.options.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: colorScheme.outline.withValues(alpha: 0.10),
                    ),
                ],
              ],
            ),
          ),
          if (!isResultsLoading && !hasResultsError && !canShowResults) ...[
            const SizedBox(height: 14),
            _buildFeedbackBox(
              context,
              message: visibilityMode == ResultsVisibilityMode.afterVote
                  ? l10n.pollDetail_resultsAfterVote
                  : l10n.pollDetail_resultsWhenClosed,
              icon: Icons.visibility_off_outlined,
              tone: _FeedbackTone.warning,
            ),
          ],
          if (!isResultsLoading && hasResultsError) ...[
            const SizedBox(height: 14),
            _buildFeedbackBox(
              context,
              message: l10n.pollDetail_noResults,
              icon: Icons.error_outline,
              tone: _FeedbackTone.error,
            ),
          ],
          if (poll.status != PollStatus.open) ...[
            const SizedBox(height: 14),
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
          if (voteReceipt != null) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.center,
              child: OutlinedButton.icon(
                onPressed: () => _showVoteReceipt(
                  context,
                  voteReceipt,
                ),
                icon: const Icon(Icons.receipt_long_outlined),
                label: Text(l10n.pollDetail_voteReceiptButton),
              ),
            ),
          ],
          if (isSelectable) ...[
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 180,
                  maxWidth: 280,
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
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.pollDetail_voteButton),
                ),
              ),
            ),
          ],
          if (showPublicVotesCta) ...[
            const SizedBox(height: 18),
            _buildPublicVotesEntryPoint(context, poll),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsHeader(
    BuildContext context, {
    required String title,
    required int totalVotes,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.how_to_vote_outlined,
                size: 15,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 5),
              Text(
                '$totalVotes',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOutcomeBadge(
    BuildContext context,
    String label,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: colorScheme.secondary,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }

  String _mapOutcomeLabel(
    AppLocalizations l10n,
    PollOutcome outcome,
  ) {
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

  Widget _buildPublicVotesEntryPoint(
    BuildContext context,
    Poll poll,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.16),
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
                  l10n.pollDetail_publicVotesAvailableTitle,
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
            l10n.pollDetail_publicVotesAvailableMessage,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _showPublicVotesSheet(context, poll),
            icon: const Icon(Icons.person_search_outlined),
            label: Text(l10n.pollDetail_publicVotesAction),
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
      colorScheme.primary.withValues(alpha: isDark ? 0.05 : 0.014),
      colorScheme.surface,
    );

    final borderColor =
        colorScheme.outline.withValues(alpha: isDark ? 0.26 : 0.12);

    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.18)
        : Colors.black.withValues(alpha: 0.045);
    final isCompactLayout = MediaQuery.sizeOf(context).width < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isCompactLayout ? AppSpacing.m : AppSpacing.l,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: AppRadius.cardLargeRadius,
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
        color: baseColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: baseColor.withValues(alpha: 0.22),
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
                  child: Text(
                    AppLocalizations.of(context)!.pollDetail_retryButton,
                  ),
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
        return l10n.pollDetail_voteErrorNoOption;
      case VoteErrorType.unauthorized:
        return l10n.pollDetail_voteErrorAuthenticationRequired;
      case VoteErrorType.closed:
        return l10n.pollDetail_voteErrorClosed;
      case VoteErrorType.alreadyVoted:
        return l10n.pollDetail_voteErrorAlreadyVoted;
      case VoteErrorType.rateLimited:
        return antiAbuseRateLimitMessage(context);
      case VoteErrorType.generic:
        return l10n.pollDetail_voteErrorGeneric;
    }
  }
}

class _PollChoiceResultRow extends StatelessWidget {
  final int index;
  final String label;
  final bool isSelected;
  final bool isSelectable;
  final bool allowMultiple;
  final PollOptionResult? result;
  final VoidCallback? onTap;

  const _PollChoiceResultRow({
    required this.index,
    required this.label,
    required this.isSelected,
    required this.isSelectable,
    required this.allowMultiple,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final resultValue = result;
    final percentage = resultValue?.percentage.clamp(0.0, 100.0) ?? 0.0;
    final progress = percentage / 100.0;

    final selectedBackground = colorScheme.primary.withValues(alpha: 0.055);
    final controlColor = isSelected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.72);

    return Semantics(
      button: isSelectable,
      selected: isSelected,
      label: label,
      child: Material(
        color: isSelected ? selectedBackground : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 68),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: isSelectable
                        ? Icon(
                            allowMultiple
                                ? (isSelected
                                    ? Icons.check_box_rounded
                                    : Icons.check_box_outline_blank_rounded)
                                : (isSelected
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_unchecked_rounded),
                            size: 23,
                            color: controlColor,
                          )
                        : Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.50),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    colorScheme.outline.withValues(alpha: 0.14),
                              ),
                            ),
                            child: Text(
                              String.fromCharCode(65 + index),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SocialVoteDirectionalText(
                                label,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  height: 1.25,
                                ),
                              ),
                            ),
                            if (resultValue != null) ...[
                              const SizedBox(width: 12),
                              Text(
                                '${percentage.round()}%',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (resultValue != null) ...[
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: SizedBox(
                              height: 8,
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor:
                                    colorScheme.outline.withValues(alpha: 0.10),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 7),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.how_to_vote_outlined,
                                size: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${resultValue.voteCount}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          widget.resultController.publicVotesInitialized ||
          widget.resultController.isPublicVotesLoading) {
        return;
      }

      unawaited(
        widget.resultController.loadPublicVotes(
          query: _searchController.text,
        ),
      );
    });
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
    final l10n = AppLocalizations.of(context)!;
    final isCompactLayout = MediaQuery.sizeOf(context).width < 600;
    final horizontalPadding = isCompactLayout ? AppSpacing.m : AppSpacing.l;

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.88,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            AppSpacing.xs,
            horizontalPadding,
            MediaQuery.of(context).viewInsets.bottom + AppSpacing.l,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.pollDetail_publicVotesSheetTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.pollDetail_publicVotesSheetDescription,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: l10n.pollDetail_publicVotesSearchHint,
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
    final l10n = AppLocalizations.of(context)!;

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
                l10n.pollDetail_publicVotesLoadError,
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
                child: Text(l10n.pollDetail_retryButton),
              ),
            ],
          ),
        ),
      );
    }

    if (resultController.publicVotes.isEmpty) {
      final hasSearchQuery =
          resultController.publicVotesQuery.trim().isNotEmpty;

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasSearchQuery
                    ? Icons.search_off_rounded
                    : Icons.how_to_vote_outlined,
                size: 34,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                hasSearchQuery
                    ? l10n.pollDetail_publicVotesSearchEmpty
                    : l10n.pollDetail_publicVotesEmpty,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
            l10n.pollDetail_publicVotesResultsCount(entries.length),
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
        if (resultController.isPublicVotesLoading && entries.isNotEmpty) ...[
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
            child: Text(l10n.pollDetail_publicVotesLoadMore),
          ),
        ],
      ],
    );
  }
}

class _PublicVoteTile extends StatefulWidget {
  final Poll poll;
  final PublicPollVoteEntry entry;

  const _PublicVoteTile({
    required this.poll,
    required this.entry,
  });

  @override
  State<_PublicVoteTile> createState() => _PublicVoteTileState();
}

class _PublicVoteTileState extends State<_PublicVoteTile> {
  UserProfile? _authorProfile;
  String? _loadedUserId;

  @override
  void initState() {
    super.initState();
    _loadAuthorProfile();
  }

  @override
  void didUpdateWidget(covariant _PublicVoteTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.entry.userId != widget.entry.userId) {
      _authorProfile = null;
      _loadedUserId = null;
      _loadAuthorProfile();
    }
  }

  Future<void> _loadAuthorProfile() async {
    final userId = widget.entry.userId.trim();
    if (userId.isEmpty) {
      return;
    }

    _loadedUserId = userId;

    try {
      final profile = await AppDI.instance.userProfileRepository.getUserProfile(
        userId,
      );

      if (!mounted || _loadedUserId != userId) {
        return;
      }

      setState(() {
        _authorProfile = profile;
      });
    } catch (_) {
      if (!mounted || _loadedUserId != userId) {
        return;
      }

      setState(() {
        _authorProfile = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final poll = widget.poll;
    final entry = widget.entry;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = theme.colorScheme;

    final primaryLabel = entry.displayName?.trim().isNotEmpty == true
        ? entry.displayName!.trim()
        : entry.username?.trim().isNotEmpty == true
            ? '@${entry.username!.trim()}'
            : l10n.pollDetail_publicVotesUserFallback;

    final secondaryLabel = entry.displayName?.trim().isNotEmpty == true &&
            entry.username?.trim().isNotEmpty == true
        ? '@${entry.username!.trim()}'
        : null;
    final isCompactLayout = MediaQuery.sizeOf(context).width < 430;
    final votedAtLabel = _formatVoteDate(context, entry.votedAt);

    final identityContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 4,
          children: [
            Text(
              primaryLabel,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (_authorProfile != null &&
                UserIdentityMark.shouldShowForProfile(_authorProfile!))
              UserIdentityMark.fromProfile(
                _authorProfile!,
                size: 14,
              ),
          ],
        ),
        if (secondaryLabel != null)
          Text(
            secondaryLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );

    final votedAtText = Text(
      votedAtLabel,
      maxLines: 2,
      textAlign: TextAlign.right,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: AppRadius.cardRadius,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
                child: Icon(
                  Icons.person_outline,
                  size: 18,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: identityContent),
              if (!isCompactLayout) ...[
                const SizedBox(width: AppSpacing.s),
                votedAtText,
              ],
            ],
          ),
          if (isCompactLayout) ...[
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerRight,
              child: votedAtText,
            ),
          ],
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
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.16),
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

  static String _formatVoteDate(
    BuildContext context,
    DateTime value,
  ) {
    final local = value.toLocal();
    final materialLocalizations = MaterialLocalizations.of(context);
    final dateLabel = materialLocalizations.formatShortDate(local);
    final timeLabel = materialLocalizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(local),
      alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
    );

    return '$dateLabel · $timeLabel';
  }
}

class _EditPollDialog extends StatefulWidget {
  final String initialTitle;
  final String initialDescription;

  const _EditPollDialog({
    required this.initialTitle,
    required this.initialDescription,
  });

  @override
  State<_EditPollDialog> createState() => _EditPollDialogState();
}

class _EditPollDialogState extends State<_EditPollDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
    _titleController.addListener(_refreshEditableDirection);
    _descriptionController.addListener(_refreshEditableDirection);
  }

  void _refreshEditableDirection() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_refreshEditableDirection);
    _descriptionController.removeListener(_refreshEditableDirection);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final title = _titleController.text.trim();
    final normalizedDescription = _descriptionController.text.trim();

    Navigator.of(context).pop(
      _EditPollFormResult(
        title: title,
        description:
            normalizedDescription.isEmpty ? null : normalizedDescription,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.pollDetail_editDialogTitle),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                autofocus: true,
                textInputAction: TextInputAction.next,
                textDirection: socialVoteEditableTextDirection(
                  context,
                  _titleController.text,
                ),
                textAlign: socialVoteEditableTextAlign(
                  context,
                  _titleController.text,
                ),
                decoration: InputDecoration(
                  labelText: l10n.pollDetail_editTitleFieldLabel,
                ),
                validator: (value) {
                  final normalized = value?.trim() ?? '';
                  if (normalized.isEmpty) {
                    return l10n.pollDetail_editTitleRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 5,
                textDirection: socialVoteEditableTextDirection(
                  context,
                  _descriptionController.text,
                ),
                textAlign: socialVoteEditableTextAlign(
                  context,
                  _descriptionController.text,
                ),
                decoration: InputDecoration(
                  labelText: l10n.pollDetail_editDescriptionFieldLabel,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancelButton),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(l10n.commonSaveButton),
        ),
      ],
    );
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
