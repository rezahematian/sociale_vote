import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/entities/poll_option.dart';
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
                            pollId: poll.id.value,
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
    Poll? poll,
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

    // Nel dominio pulito i risultati NON sono nel Poll (niente option.votes).
    // Qui mostriamo solo le opzioni di voto. I risultati verranno via PollResultController.
    final bool canVote = controller.canVote && poll.isOpen;

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
          if ((poll.description ?? '').trim().isNotEmpty)
            Text(
              poll.description!,
              style: theme.textTheme.bodyMedium,
            ),
          const SizedBox(height: 16),

          // ================= STATUS =================
          _PollStatusBanner(
            poll: poll,
          ),
          const SizedBox(height: 24),

          // ================= OPTIONS =================
          Text(
            'Opzioni di voto',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ...poll.options.map(
            (option) => _buildVoteOption(
              context,
              controller,
              poll.id.value,
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
    PollOption option,
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
                    optionIds: [option.id],
                  );

                  if (!mounted) return;

                  if (controller.status == PollControllerStatus.success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Voto registrato con successo'),
                      ),
                    );
                  } else if (controller.status == PollControllerStatus.error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          controller.errorMessage ?? 'Errore durante il voto',
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
}

class _PollStatusBanner extends StatelessWidget {
  final Poll poll;

  const _PollStatusBanner({
    required this.poll,
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