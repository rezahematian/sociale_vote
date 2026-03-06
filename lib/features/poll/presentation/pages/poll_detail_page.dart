import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/entities/poll_option.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_status.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_type.dart';
import 'package:sociale_vote/domain/poll/value_objects/visibility_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/anonymity_rules.dart';
import 'package:sociale_vote/domain/poll/value_objects/participation_rules.dart';
import 'package:sociale_vote/features/discussion/application/discussion_controller.dart';
import 'package:sociale_vote/features/discussion/presentation/widgets/comment_section.dart';
import 'package:sociale_vote/shared/widgets/engagement_bar.dart';

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

  @override
  void initState() {
    super.initState();

    final di = AppDI.instance;

    _controller = di.createPollDetailController();
    _voteController = di.createVoteController();
    _resultController = di.createPollResultController();

    _controller.loadPoll(widget.pollId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poll Detail'),
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
              _resultController.loadResults(poll);
            }

            return ChangeNotifierProvider<DiscussionController>(
              create: (_) => AppDI.instance
                  .createDiscussionController(
                    TargetRef.poll(poll.id.value),
                  )
                ..loadComments(),
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

  Future<void> _onVotePressed(Poll poll) async {
    if (poll.status != PollStatus.open) return;
    if (!_canVote(poll)) return;

    await _voteController.submitVote(
      poll: poll,
      userId: AppDI.instance.currentUserId,
      userCountryCode: null,
    );

    if (_voteController.submittedSuccessfully) {
      await _resultController.loadResults(poll);
    }
  }

  Widget _buildPollContent(BuildContext context, Poll poll) {
    final theme = Theme.of(context);
    final config = poll.configuration;

    final visibilityMode = config.visibilityRules.resultsVisibility;
    final anonymityLevel = config.anonymityRules.level;
    final participationScope = config.participationRules.scope;
    final minQuorum = config.quorumRules.minAbsoluteVotes;

    final totalVotes = _resultController.result?.totalVotes ?? 0;
    final quorumReached =
        minQuorum == null ? true : totalVotes >= minQuorum;

    final hasVoted = _voteController.submittedSuccessfully;

    bool canShowResults;
    switch (visibilityMode) {
      case ResultsVisibilityMode.always:
        canShowResults = true;
        break;
      case ResultsVisibilityMode.afterVote:
        canShowResults = hasVoted;
        break;
      case ResultsVisibilityMode.afterClose:
        canShowResults = poll.status == PollStatus.closed;
        break;
    }

    final int fireCount = _controller.likeCount();
    final int iceCount = _controller.dislikeCount();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Text(
            poll.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (poll.description != null && poll.description!.isNotEmpty)
            Text(poll.description!, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          _buildMetaRow(context, poll),
          const SizedBox(height: 12),
          EngagementBar(
            fireCount: fireCount,
            iceCount: iceCount,
            onFireTap: () {
              final userId = AppDI.instance.currentUserId;
              if (userId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please log in to react to this poll.'),
                  ),
                );
                return;
              }
              _controller.toggleFire(userId: userId);
            },
            onIceTap: () {
              final userId = AppDI.instance.currentUserId;
              if (userId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please log in to react to this poll.'),
                  ),
                );
                return;
              }
              _controller.toggleIce(userId: userId);
            },
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (anonymityLevel.name == 'anonymous')
                _buildChip(context, 'Anonymous vote'),
              if (anonymityLevel.name == 'public')
                _buildChip(context, 'Public vote'),
              if (participationScope.name == 'geoScopeOnly')
                _buildChip(context, 'Restricted to geographic scope'),
              if (minQuorum != null)
                _buildChip(
                  context,
                  quorumReached
                      ? 'Quorum reached'
                      : 'Quorum not reached ($totalVotes / $minQuorum)',
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Options',
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
                  ? 'This poll is closed.'
                  : poll.status == PollStatus.scheduled
                      ? 'This poll is not yet open.'
                      : 'Voting is not available.',
              style: TextStyle(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_voteController.errorMessage != null) ...[
            Text(
              _voteController.errorMessage!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            const SizedBox(height: 12),
          ],
          if (_voteController.submittedSuccessfully) ...[
            Text(
              'Vote submitted successfully!',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
          ],
          FilledButton(
            onPressed: _canVote(poll) ? () => _onVotePressed(poll) : null,
            child: _voteController.isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Vote'),
          ),
          const SizedBox(height: 32),
          if (canShowResults) ...[
            Text(
              'Results',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
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
                'No results available yet.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ] else ...[
            Text(
              visibilityMode == ResultsVisibilityMode.afterVote
                  ? 'Results will be visible after you vote.'
                  : 'Results will be visible when the poll is closed.',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 32),
          CommentSection(
            userId: AppDI.instance.currentUserId ?? 'demo-user',
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(BuildContext context, Poll poll) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        _buildChip(context, _mapTypeToLabel(poll.type)),
        _buildChip(context, _mapStatusToLabel(poll.status)),
        _buildChip(context, _mapGeoLabel(poll)),
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
              isSelected
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
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

  String _mapTypeToLabel(PollType type) {
    switch (type) {
      case PollType.yesNo:
        return 'Yes / No';
      case PollType.singleChoice:
        return 'Single choice';
      case PollType.multipleChoice:
        return 'Multiple choice';
      case PollType.approval:
        return 'Approval';
      default:
        return _enumName(type);
    }
  }

  String _mapStatusToLabel(PollStatus status) {
    switch (status) {
      case PollStatus.draft:
        return 'Draft';
      case PollStatus.open:
        return 'Open';
      case PollStatus.closed:
        return 'Closed';
      case PollStatus.scheduled:
        return 'Scheduled';
      default:
        return _enumName(status);
    }
  }

  String _mapGeoLabel(Poll poll) {
    final country = poll.countryCode;
    final city = poll.cityId;

    if (country == null && city == null) return 'Global';
    if (country != null && city == null) return country;
    if (country != null && city != null) return '$city ($country)';
    return 'Local';
  }
}