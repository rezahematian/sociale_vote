import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/poll/poll_card.dart';
import '../features/poll/poll_feed_controller.dart';
import '../features/poll/poll_controller.dart';
import '../features/poll/poll_detail_screen.dart';
import '../features/poll/create_poll_screen.dart';

import '../features/comment/comment_controller.dart';
import '../features/news/news_controller.dart';

import '../features/social/post_controller.dart';

import '../features/video/video_controller.dart';

import '../domain/user/user_identity.dart';

class FeedScreen extends StatefulWidget {
  final PollFeedController pollFeedController;
  final PollController pollController;
  final CommentController commentController;
  final NewsController newsController;
  final PostController postController;
  final VideoController videoController;
  final UserIdentity currentUser;

  const FeedScreen({
    super.key,
    required this.pollFeedController,
    required this.pollController,
    required this.commentController,
    required this.newsController,
    required this.postController,
    required this.videoController,
    required this.currentUser,
  });

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    widget.pollFeedController.loadFeed();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.pollFeedController,
      child: Consumer<PollFeedController>(
        builder: (context, feedController, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFF4F6F8),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              title: const Text(
                'CivicFeed',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Crea sondaggio',
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreatePollScreen(),
                      ),
                    );
                    widget.pollFeedController.refresh();
                  },
                ),
              ],
            ),
            body: _buildBody(feedController),
          );
        },
      ),
    );
  }

  Widget _buildBody(PollFeedController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.error != null) {
      return Center(
        child: Text(
          controller.error!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (controller.polls.isEmpty) {
      return const Center(
        child: Text('Nessun sondaggio disponibile'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.loadFeed(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: controller.polls.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (context, index) {
          final poll = controller.polls[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: PollCard(
              poll: poll,
              onTap: () async {
                await widget.pollController.loadPoll(poll.id);

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PollDetailScreen(
                      pollId: poll.id,
                      pollController: widget.pollController,
                      commentController: widget.commentController,
                      currentUser: widget.currentUser,
                    ),
                  ),
                );

                widget.pollFeedController.refresh();
              },
            ),
          );
        },
      ),
    );
  }
}
