import 'package:sociale_vote/domain/poll/repositories/poll_repository.dart';
import 'package:sociale_vote/domain/poll/repositories/vote_repository.dart';
import 'package:sociale_vote/domain/poll/services/vote_aggregator.dart';
import 'package:sociale_vote/domain/poll/usecases/get_poll_detail.dart';
import 'package:sociale_vote/domain/poll/usecases/get_polls.dart';
import 'package:sociale_vote/domain/poll/usecases/get_poll_results.dart';
import 'package:sociale_vote/domain/poll/usecases/submit_vote.dart';
import 'package:sociale_vote/domain/poll/usecases/create_poll.dart';

import 'package:sociale_vote/domain/content/news/repositories/news_repository.dart';
import 'package:sociale_vote/domain/content/news/usecases/get_news_detail.dart';
import 'package:sociale_vote/domain/content/news/usecases/get_news_feed.dart';

import 'package:sociale_vote/domain/content/social/repositories/post_repository.dart';
import 'package:sociale_vote/domain/content/social/usecases/get_feed.dart';

import 'package:sociale_vote/domain/engagement/repositories/reaction_repository.dart';
import 'package:sociale_vote/domain/engagement/usecases/get_reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/usecases/toggle_reaction.dart';

import 'package:sociale_vote/domain/discussion/repositories/comment_repository.dart';
import 'package:sociale_vote/domain/discussion/usecases/add_comment.dart';
import 'package:sociale_vote/domain/discussion/usecases/get_comments_for_target.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';

import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';

import 'package:sociale_vote/features/poll/application/poll_detail_controller.dart';
import 'package:sociale_vote/features/poll/application/poll_list_controller.dart';
import 'package:sociale_vote/features/poll/application/poll_result_controller.dart';
import 'package:sociale_vote/features/poll/application/vote_controller.dart';
import 'package:sociale_vote/features/poll/application/create_poll_controller.dart';

import 'package:sociale_vote/features/news/application/news_controller.dart';

import 'package:sociale_vote/features/social/application/feed_controller.dart';

import 'package:sociale_vote/features/discussion/application/discussion_controller.dart';

import 'package:sociale_vote/infrastructure/poll/repositories/poll_repository_impl.dart';
import 'package:sociale_vote/infrastructure/poll/repositories/vote_repository_impl.dart';
import 'package:sociale_vote/infrastructure/news/repositories/news_repository_impl.dart';
import 'package:sociale_vote/infrastructure/social/repositories/post_repository_impl.dart';

import 'package:sociale_vote/infrastructure/engagement/repositories/reaction_repository_impl.dart';
import 'package:sociale_vote/infrastructure/discussion/repositories/comment_repository_impl.dart';

/// Contenitore molto semplice per la Dependency Injection
/// dell'applicazione.
class AppDI {
  AppDI._internal();

  static final AppDI instance = AppDI._internal();

  // ==========================================================
  // CONTROLLERS GLOBALI
  // ==========================================================

  final GeoScopeController _geoScopeController = GeoScopeController();

  GeoScopeController get geoScopeController => _geoScopeController;

  // ==========================================================
  // REPOSITORIES (singleton in-memory)
  // ==========================================================

  final PollRepository _pollRepository = PollRepositoryImpl();
  final VoteRepository _voteRepository = VoteRepositoryImpl();
  final NewsRepository _newsRepository = NewsRepositoryImpl();
  final PostRepository _postRepository = PostRepositoryImpl();
  final ReactionRepository _reactionRepository = ReactionRepositoryImpl();
  final CommentRepository _commentRepository = CommentRepositoryImpl();

  PollRepository get pollRepository => _pollRepository;

  VoteRepository get voteRepository => _voteRepository;

  NewsRepository get newsRepository => _newsRepository;

  PostRepository get postRepository => _postRepository;

  ReactionRepository get reactionRepository => _reactionRepository;

  CommentRepository get commentRepository => _commentRepository;

  // ==========================================================
  // IDENTITY / SESSION (per ora stub)
  // ==========================================================

  /// Id utente corrente.
  ///
  /// TODO: collegare a `SessionRepository` / `IdentityService` reale.
  String? get currentUserId => 'demo-user';

  // ==========================================================
  // SERVICES
  // ==========================================================

  VoteAggregator get voteAggregator => VoteAggregator();

  // ==========================================================
  // USE CASES - POLL
  // ==========================================================

  GetPolls get getPolls => GetPolls(pollRepository);

  GetPollDetail get getPollDetail => GetPollDetail(pollRepository);

  SubmitVote get submitVote => SubmitVote(voteRepository);

  GetPollResults get getPollResults =>
      GetPollResults(voteRepository, voteAggregator);

  CreatePoll get createPoll => CreatePoll(pollRepository);

  // ==========================================================
  // USE CASES - NEWS
  // ==========================================================

  GetNewsFeed get getNewsFeed => GetNewsFeed(newsRepository);

  GetNewsDetail get getNewsDetail => GetNewsDetail(newsRepository);

  // ==========================================================
  // USE CASES - SOCIAL
  // ==========================================================

  GetFeed get getFeed => GetFeed(postRepository);

  // ==========================================================
  // USE CASES - ENGAGEMENT
  // ==========================================================

  ToggleReaction get toggleReaction => ToggleReaction(reactionRepository);

  GetReactionSummary get getReactionSummary =>
      GetReactionSummary(reactionRepository);

  // ==========================================================
  // USE CASES - DISCUSSION (commenti)
  // ==========================================================

  AddComment get addComment => AddComment(commentRepository);

  GetCommentsForTarget get getCommentsForTarget =>
      GetCommentsForTarget(commentRepository);

  // ==========================================================
  // CONTROLLERS - POLL
  // ==========================================================

  PollListController createPollListController() {
    return PollListController(
      getPollsUseCase: getPolls,
      geoScopeController: geoScopeController,
      toggleReaction: toggleReaction,
      getReactionSummary: getReactionSummary,
    );
  }

  PollDetailController createPollDetailController() {
    return PollDetailController(
      getPollDetail,
      toggleReaction,
      getReactionSummary,
    );
  }

  VoteController createVoteController() {
    return VoteController(submitVote);
  }

  PollResultController createPollResultController() {
    return PollResultController(getPollResults);
  }

  CreatePollController createCreatePollController() {
    return CreatePollController(
      createPollUseCase: createPoll,
      geoScopeController: geoScopeController,
    );
  }

  // ==========================================================
  // CONTROLLERS - NEWS
  // ==========================================================

  NewsController createNewsController() {
    return NewsController(
      getNewsFeed,
      toggleReaction,
      getReactionSummary,
    );
  }

  // ==========================================================
  // CONTROLLERS - SOCIAL
  // ==========================================================

  FeedController createFeedController() {
    return FeedController(
      getFeed: getFeed,
      geoScopeController: geoScopeController,
      toggleReaction: toggleReaction,
      getReactionSummary: getReactionSummary,
    );
  }

  // ==========================================================
  // CONTROLLERS - DISCUSSION
  // ==========================================================

  DiscussionController createDiscussionController(TargetRef target) {
    return DiscussionController(
      target: target,
      addComment: addComment,
      getCommentsForTarget: getCommentsForTarget,
    );
  }
}