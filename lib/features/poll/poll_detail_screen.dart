import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/poll/poll_entity.dart';
import '../../domain/poll/poll_option_dto.dart';
import '../../domain/user/user_identity.dart';

import '../comment/comment_controller.dart';
import '../comment/comments_screen.dart';

import 'poll_controller.dart';

class PollDetailScreen extends StatefulWidget {
  final String pollId;
  final PollController pollController;
  final CommentController commentController;
  final UserIdentity currentUser;

  const PollDetailScreen({
    super.key,
    required this.pollId,
    required this.pollController,
    required this.commentController,
    required this.currentUser,
  });

  @override
  State<PollDetailScreen> createState() => _PollDetailScreenState();
}

class _PollDetailScreenState extends State<PollDetailScreen> {
  @override
  void initState() {
    super.initState();
    widget.pollController.loadPoll(widget.pollId);
  }

  int _totalVotes(PollEntity poll) {
    return poll.options.fold<int>(0, (sum, o) => sum + o.votes);
  }

  double _percentage(PollEntity poll, int votes) {
    final total = _totalVotes(poll);
    if (total == 0) return 0;
    return votes / total;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PollController>.value(
      value: widget.pollController,
      child: Consumer<PollController>(
        builder: (context, controller, _) {
          final poll = controller.currentPoll;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Sondaggio civico'),
              actions: [
                if (poll != null)
                  IconButton(
                    icon: const Icon(Icons.comment),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CommentsScreen(
                            pollId: poll.id,
                            currentUser: widget.currentUser,
                            controller: widget.commentController,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
            body: _buildBody(context, controller, poll),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    PollController controller,
    PollEntity? poll,
  ) {
    if (controller.isLoading && poll == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.status == PollControllerStatus.error) {
      return Center(
        child: Text(
          controller.errorMessage ?? 'Errore',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (poll == null) {
      return const Center(
        child: Text('Sondaggio non disponibile'),
      );
    }

    final theme = Theme.of(context);
    final bool showResults = controller.resultsVisible;
    final bool canVote = controller.canVote;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= TITLE =================
          Text(
            poll.title,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            poll.description,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          // ================= STATUS =================
          _PollStatusBanner(
            poll: poll,
            controller: controller,
          ),
          const SizedBox(height: 24),

          // ================= OPTIONS / RESULTS =================
          Text(
            showResults ? 'Risultati' : 'Opzioni di voto',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ...poll.options.map(
            (option) => showResults
                ? _buildResultOption(context, poll, option)
                : _buildVoteOption(
                    context,
                    controller,
                    poll.id,
                    option,
                    canVote,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoteOption(
    BuildContext context,
    PollController controller,
    String pollId,
    PollOptionDto option,
    bool canVote,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(option.label),
        trailing: ElevatedButton(
          onPressed: (!canVote || controller.isLoading)
              ? null
              : () async {
                  await controller.vote(
                    pollId: pollId,
                    optionId: option.id,
                  );

                  if (!mounted) return;

                  if (controller.status ==
                      PollControllerStatus.success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Voto registrato con successo'),
                      ),
                    );
                  } else if (controller.status ==
                      PollControllerStatus.error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          controller.errorMessage ??
                              'Errore durante il voto',
                        ),
                      ),
                    );
                  }
                },
          child: const Text('Vota'),
        ),
      ),
    );
  }

  Widget _buildResultOption(
    BuildContext context,
    PollEntity poll,
    PollOptionDto option,
  ) {
    final percentage = _percentage(poll, option.votes);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    option.label,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                Text(
                  '${(percentage * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _PollStatusBanner extends StatelessWidget {
  final PollEntity poll;
  final PollController controller;

  const _PollStatusBanner({
    required this.poll,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!poll.isOpen) {
      return _buildBanner(
        theme,
        'Sondaggio chiuso',
        Colors.red[700]!,
      );
    }

    if (controller.hasVoted) {
      return _buildBanner(
        theme,
        'Hai già votato · risultati visibili',
        Colors.green[700]!,
      );
    }

    return _buildBanner(
      theme,
      'Puoi partecipare al voto',
      Colors.blue[700]!,
    );
  }

  Widget _buildBanner(
    ThemeData theme,
    String text,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
