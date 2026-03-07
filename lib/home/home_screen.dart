import 'package:flutter/material.dart';

import '../core/bootstrap/app_bootstrap.dart';

import '../features/poll/poll_controller.dart';
import '../features/poll/poll_feed_controller.dart';

import '../features/comment/comment_controller.dart';
import '../features/comment/comment_service.dart';

import '../features/news/news_controller.dart';
import '../features/news/news_service.dart';

import '../features/social/post_controller.dart';
import '../features/social/post_service.dart';

import '../features/video/video_controller.dart';
import '../features/video/video_service.dart';

import '../domain/user/user_identity.dart';

import 'feed_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  // =========================
  // CONTROLLERS (FROM BOOTSTRAP)
  // =========================
  final PollController pollController =
      AppBootstrap.pollController;

  late final PollFeedController pollFeedController =
      PollFeedController(AppBootstrap.pollService);

  // =========================
  // OTHER FEATURES (LOCAL)
  // =========================
  final CommentController commentController =
      CommentController(CommentService());

  final NewsController newsController =
      NewsController(NewsService());

  final PostController postController =
      PostController(PostService());

  final VideoController videoController =
      VideoController(VideoService());

  // =========================
  // DEMO USER (SESSION)
  // =========================
  final UserIdentity demoUser = const UserIdentity(
    id: 'user_1',
    username: 'demo_user',
    isVerified: true,
  );

  @override
  Widget build(BuildContext context) {
    newsController.createDemoNews();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'CivicFeed',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 8,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Partecipa ai sondaggi della community',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[600]),
              ),
            ),
          ),
        ),
      ),
      body: FeedScreen(
        pollController: pollController,
        pollFeedController: pollFeedController,
        commentController: commentController,
        newsController: newsController,
        postController: postController,
        videoController: videoController,
        currentUser: demoUser,
      ),
    );
  }
}
