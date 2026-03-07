import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/features/poll/application/poll_list_controller.dart';
import 'package:sociale_vote/features/poll/presentation/widgets/poll_card.dart';

class MyPollsPage extends StatelessWidget {
  const MyPollsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = AppDI.instance.currentUserId;

    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Polls'),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'You must be logged in to view your polls.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return ChangeNotifierProvider<PollListController>(
      create: (_) {
        final controller = AppDI.instance.createPollListController();
        controller.loadPolls(userId: currentUserId);
        return controller;
      },
      child: const _MyPollsView(),
    );
  }
}

class _MyPollsView extends StatelessWidget {
  const _MyPollsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<PollListController>();

    final String? currentUserId = AppDI.instance.currentUserId;

    // Tutti i poll caricati dal controller
    final List<Poll> allPolls = controller.polls;

    // Solo i poll creati dall'utente corrente (nuovi poll con createdByUserId valorizzato)
    final List<Poll> polls = currentUserId == null
        ? <Poll>[]
        : allPolls
            .where((p) => p.createdByUserId == currentUserId)
            .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Polls'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final userId = AppDI.instance.currentUserId;
          if (userId == null) return;
          await controller.loadPolls(userId: userId);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Polls created by you',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            if (controller.isLoading && polls.isEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ] else if (polls.isEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'You have not created any polls yet.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            ] else ...[
              ...polls.map(
                (poll) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.pollDetail,
                        arguments: poll.id,
                      );
                    },
                    child: PollCard(poll: poll),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}