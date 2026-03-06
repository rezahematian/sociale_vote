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

// NEWS infra nuovi
import 'package:sociale_vote/core/http/api_client.dart';
import 'package:sociale_vote/infrastructure/persistence/remote/rest/news_api.dart';
import 'package:sociale_vote/infrastructure/persistence/remote/rest/news_api_org_api.dart';
import 'package:sociale_vote/infrastructure/persistence/remote/rest/mediastack_api.dart';
import 'package:sociale_vote/infrastructure/news/mappers/news_mapper.dart';
import 'package:sociale_vote/infrastructure/news/aggregator/news_aggregator.dart';
import 'package:sociale_vote/infrastructure/news/aggregator/news_provider.dart';
import 'package:sociale_vote/infrastructure/news/aggregator/gnews_provider.dart';
import 'package:sociale_vote/infrastructure/news/aggregator/news_api_org_provider.dart';
import 'package:sociale_vote/infrastructure/news/aggregator/mediastack_provider.dart';

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
  // HTTP CLIENTS
  // ==========================================================

  final ApiClient _gnewsClient = ApiClient(
    baseUrl: 'https://gnews.io/api/v4',
  );

  final ApiClient _newsApiOrgClient = ApiClient(
    baseUrl: 'https://newsapi.org/v2',
  );

  final ApiClient _mediaStackClient = ApiClient(
    baseUrl: 'http://api.mediastack.com/v1',
  );

  // ==========================================================
  // NEWS INFRA
  // ==========================================================

  late final NewsApi _newsApi = NewsApi(_gnewsClient);
  late final NewsApiOrgApi _newsApiOrgApi = NewsApiOrgApi(_newsApiOrgClient);
  late final MediaStackApi _mediaStackApi = MediaStackApi(_mediaStackClient);

  late final NewsMapper _newsMapper = NewsMapper();

  late final NewsProvider _gnewsProvider = GNewsProvider(_newsApi);
  late final NewsProvider _newsApiOrgProvider =
      NewsApiOrgProvider(_newsApiOrgApi);
  late final NewsProvider _mediaStackProvider =
      MediaStackProvider(_mediaStackApi);

  late final NewsAggregator _newsAggregator = NewsAggregator(
    providers: <NewsProvider>[
      _gnewsProvider,
      _newsApiOrgProvider,
      _mediaStackProvider,
    ],
  );

  // ==========================================================
  // REPOSITORIES (singleton)
  // ==========================================================

  final PollRepository _pollRepository = PollRepositoryImpl();
  final VoteRepository _voteRepository = VoteRepositoryImpl();
  late final NewsRepository _newsRepository =
      NewsRepositoryImpl(_newsAggregator, _newsMapper);
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