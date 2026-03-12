import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sociale_vote/core/http/api_client.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';

import 'package:sociale_vote/domain/content/news/repositories/news_repository.dart';
import 'package:sociale_vote/domain/content/news/usecases/get_news_detail.dart';
import 'package:sociale_vote/domain/content/news/usecases/get_news_feed.dart';

import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/content/social/repositories/post_repository.dart';
import 'package:sociale_vote/domain/content/social/usecases/create_post.dart';
import 'package:sociale_vote/domain/content/social/usecases/get_feed.dart';
import 'package:sociale_vote/domain/content/social/usecases/get_post_detail.dart';

import 'package:sociale_vote/domain/discovery/usecases/get_for_you_feed.dart';
import 'package:sociale_vote/domain/discovery/usecases/get_trending_content.dart';

import 'package:sociale_vote/domain/discussion/repositories/comment_repository.dart';
import 'package:sociale_vote/domain/discussion/usecases/add_comment.dart';
import 'package:sociale_vote/domain/discussion/usecases/get_comment_count_for_target.dart';
import 'package:sociale_vote/domain/discussion/usecases/get_comments_for_target.dart';

import 'package:sociale_vote/domain/engagement/repositories/favorite_repository.dart';
import 'package:sociale_vote/domain/engagement/repositories/reaction_repository.dart';
import 'package:sociale_vote/domain/engagement/usecases/get_reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/usecases/is_favorite.dart';
import 'package:sociale_vote/domain/engagement/usecases/toggle_favorite.dart';
import 'package:sociale_vote/domain/engagement/usecases/toggle_reaction.dart';

import 'package:sociale_vote/domain/geo/repositories/follow_scope_repository.dart';
import 'package:sociale_vote/domain/geo/repositories/geo_resolver.dart';
import 'package:sociale_vote/domain/geo/usecases/get_followed_scopes_for_user.dart';
import 'package:sociale_vote/domain/geo/usecases/resolve_scope_from_point.dart';
import 'package:sociale_vote/domain/geo/usecases/toggle_follow_scope.dart';

import 'package:sociale_vote/domain/identity/repositories/session_repository.dart';
import 'package:sociale_vote/domain/identity/repositories/user_repository.dart';
import 'package:sociale_vote/domain/identity/usecases/login_user.dart';
import 'package:sociale_vote/domain/identity/usecases/register_user.dart';

import 'package:sociale_vote/domain/poll/repositories/poll_repository.dart';
import 'package:sociale_vote/domain/poll/repositories/vote_repository.dart';
import 'package:sociale_vote/domain/poll/services/vote_aggregator.dart';
import 'package:sociale_vote/domain/poll/usecases/create_poll.dart';
import 'package:sociale_vote/domain/poll/usecases/get_poll_detail.dart';
import 'package:sociale_vote/domain/poll/usecases/get_poll_results.dart';
import 'package:sociale_vote/domain/poll/usecases/get_polls.dart';
import 'package:sociale_vote/domain/poll/usecases/submit_vote.dart';

import 'package:sociale_vote/domain/search/repositories/search_repository.dart';
import 'package:sociale_vote/domain/search/usecases/search_content.dart';

import 'package:sociale_vote/features/auth/application/auth_controller.dart';
import 'package:sociale_vote/features/discovery/application/for_you_feed_controller.dart';
import 'package:sociale_vote/features/discovery/application/trending_controller.dart';
import 'package:sociale_vote/features/discussion/application/discussion_controller.dart';
import 'package:sociale_vote/features/geo/application/follow_scope_controller.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';
import 'package:sociale_vote/features/news/application/news_controller.dart';
import 'package:sociale_vote/features/poll/application/create_poll_controller.dart';
import 'package:sociale_vote/features/poll/application/poll_detail_controller.dart';
import 'package:sociale_vote/features/poll/application/poll_list_controller.dart';
import 'package:sociale_vote/features/poll/application/poll_result_controller.dart';
import 'package:sociale_vote/features/poll/application/vote_controller.dart';
import 'package:sociale_vote/features/search/application/search_controller.dart';
import 'package:sociale_vote/features/social/application/feed_controller.dart';
import 'package:sociale_vote/features/social/application/post_detail_controller.dart';

import 'package:sociale_vote/infrastructure/auth/session_repository_impl.dart';
import 'package:sociale_vote/infrastructure/discussion/repositories/comment_repository_impl.dart';
import 'package:sociale_vote/infrastructure/engagement/repositories/favorite_repository_in_memory.dart';
import 'package:sociale_vote/infrastructure/engagement/repositories/reaction_repository_impl.dart';
import 'package:sociale_vote/infrastructure/geo/geo_resolver_impl.dart';
import 'package:sociale_vote/infrastructure/geo/repositories/follow_scope_repository_in_memory.dart';
import 'package:sociale_vote/infrastructure/news/aggregator/gnews_provider.dart';
import 'package:sociale_vote/infrastructure/news/aggregator/mediastack_provider.dart';
import 'package:sociale_vote/infrastructure/news/aggregator/news_aggregator.dart';
import 'package:sociale_vote/infrastructure/news/aggregator/news_api_org_provider.dart';
import 'package:sociale_vote/infrastructure/news/aggregator/news_provider.dart';
import 'package:sociale_vote/infrastructure/news/mappers/news_mapper.dart';
import 'package:sociale_vote/infrastructure/news/repositories/news_repository_impl.dart';
import 'package:sociale_vote/infrastructure/persistence/remote/rest/auth_api.dart';
import 'package:sociale_vote/infrastructure/persistence/remote/rest/mediastack_api.dart';
import 'package:sociale_vote/infrastructure/persistence/remote/rest/news_api.dart';
import 'package:sociale_vote/infrastructure/persistence/remote/rest/news_api_org_api.dart';
import 'package:sociale_vote/infrastructure/poll/repositories/poll_repository_in_memory.dart';
import 'package:sociale_vote/infrastructure/poll/repositories/vote_repository_impl.dart';
import 'package:sociale_vote/infrastructure/search/repositories/search_repository_in_memory.dart';
import 'package:sociale_vote/infrastructure/social/repositories/post_repository_impl.dart';

/// Implementazione minima temporanea di [UserRepository].
///
/// In questa fase collega direttamente Supabase Auth tramite [AuthApi].
class UserRepositoryImpl implements UserRepository {
  final AuthApi _authApi;

  UserRepositoryImpl(this._authApi);

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) {
    return _authApi.login(
      email: email,
      password: password,
    );
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _authApi.register(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  @override
  Future<AuthSession> getCurrentUser({
    required String accessToken,
  }) async {
    final session = await _authApi.getCurrentSession();
    if (session == null) {
      throw Exception('Nessuna sessione utente disponibile.');
    }
    return session;
  }
}

/// Contenitore molto semplice per la Dependency Injection
/// dell'applicazione.
class AppDI {
  AppDI._internal() {
    _sessionRepository.watchCurrentUserId().listen((userId) {
      _currentUserId = userId;
    });
  }

  static final AppDI instance = AppDI._internal();

  // ==========================================================
  // CONTROLLERS GLOBALI
  // ==========================================================

  final GeoScopeController _geoScopeController = GeoScopeController();

  FollowScopeController? _followScopeController;
  String? _followScopeControllerUserId;

  GeoScopeController get geoScopeController => _geoScopeController;

  FollowScopeController get followScopeController {
    if (_followScopeController == null ||
        _followScopeControllerUserId != currentUserId) {
      _followScopeController?.dispose();
      _followScopeControllerUserId = currentUserId;
      _followScopeController = FollowScopeController(
        geoScopeController: geoScopeController,
        toggleFollowScope: toggleFollowScope,
        getFollowedScopesForUser: getFollowedScopesForUser,
        userId: currentUserId,
      );
    }
    return _followScopeController!;
  }

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
  // AUTH INFRA
  // ==========================================================

  late final AuthApi _authApi = const AuthApi();

  // ==========================================================
  // REPOSITORIES (singleton)
  // ==========================================================

  late final SessionRepository _sessionRepository = SessionRepositoryImpl();
  late final UserRepository _userRepository = UserRepositoryImpl(_authApi);
  late final GeoResolver _geoResolver = GeoResolverImpl();
  late final FollowScopeRepository _followScopeRepository =
      FollowScopeRepositoryInMemory();
  late final PollRepository _pollRepository = PollRepositorySupabase();
  late final VoteRepository _voteRepository =
      VoteRepositoryImpl(Supabase.instance.client);
  late final NewsRepository _newsRepository =
      NewsRepositoryImpl(_newsAggregator, _newsMapper);
  final PostRepository _postRepository = PostRepositoryImpl();
  final FavoriteRepository _favoriteRepository = FavoriteRepositoryInMemory();
  final ReactionRepository _reactionRepository = ReactionRepositoryImpl();
  final CommentRepository _commentRepository = CommentRepositoryImpl();
  late final SearchRepository _searchRepository = SearchRepositoryInMemory(
    pollRepository: pollRepository,
    newsRepository: newsRepository,
    postRepository: postRepository,
  );

  String? _currentUserId;

  SessionRepository get sessionRepository => _sessionRepository;
  UserRepository get userRepository => _userRepository;
  PollRepository get pollRepository => _pollRepository;
  VoteRepository get voteRepository => _voteRepository;
  NewsRepository get newsRepository => _newsRepository;
  PostRepository get postRepository => _postRepository;
  FavoriteRepository get favoriteRepository => _favoriteRepository;
  ReactionRepository get reactionRepository => _reactionRepository;
  CommentRepository get commentRepository => _commentRepository;
  FollowScopeRepository get followScopeRepository => _followScopeRepository;
  SearchRepository get searchRepository => _searchRepository;

  // ==========================================================
  // IDENTITY / SESSION
  // ==========================================================

  String? get currentUserId => _currentUserId;

  Future<void> logoutCurrentUser() async {
    await _authApi.logout();
    await _sessionRepository.clearSession();
  }

  // ==========================================================
  // SERVICES
  // ==========================================================

  VoteAggregator get voteAggregator => VoteAggregator();

  // ==========================================================
  // USE CASES - AUTH
  // ==========================================================

  LoginUser get loginUser => LoginUser(
        userRepository,
        sessionRepository,
      );

  RegisterUser get registerUser => RegisterUser(
        userRepository,
        sessionRepository,
      );

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

  GetPostDetail get getPostDetail => GetPostDetail(postRepository);

  CreatePost get createPostUseCase => CreatePost(postRepository);

  Future<Post> createPost({
    required String authorId,
    required String authorName,
    required String title,
    required String content,
    String? countryCode,
    String? cityId,
  }) {
    return createPostUseCase(
      authorId: authorId,
      authorName: authorName,
      title: title,
      content: content,
      countryCode: countryCode,
      cityId: cityId,
    );
  }

  // ==========================================================
  // USE CASES - ENGAGEMENT
  // ==========================================================

  IsFavorite get isFavoriteUseCase => IsFavorite(favoriteRepository);

  ToggleFavorite get toggleFavoriteUseCase =>
      ToggleFavorite(favoriteRepository);

  ToggleReaction get toggleReaction => ToggleReaction(reactionRepository);

  GetReactionSummary get getReactionSummary =>
      GetReactionSummary(reactionRepository);

  Future<bool> isFavorite({
    required String userId,
    required TargetRef target,
  }) {
    return isFavoriteUseCase(
      userId: userId,
      target: target,
    );
  }

  Future<bool> toggleFavorite({
    required String userId,
    required TargetRef target,
  }) {
    return toggleFavoriteUseCase(
      userId: userId,
      target: target,
    );
  }

  // ==========================================================
  // USE CASES - GEO
  // ==========================================================

  ResolveScopeFromPoint get resolveScopeFromPoint =>
      ResolveScopeFromPoint(_geoResolver);

  GetFollowedScopesForUser get getFollowedScopesForUser =>
      GetFollowedScopesForUser(followScopeRepository);

  ToggleFollowScope get toggleFollowScope =>
      ToggleFollowScope(followScopeRepository);

  // ==========================================================
  // USE CASES - DISCOVERY
  // ==========================================================

  GetTrendingContent get getTrendingContent => GetTrendingContent(
        postRepository: postRepository,
        getReactionSummary: getReactionSummary,
        getCommentsForTarget: getCommentsForTarget,
        followScopeRepository: followScopeRepository,
      );

  GetForYouFeed get getForYouFeed => GetForYouFeed(
        postRepository: postRepository,
        getReactionSummary: getReactionSummary,
        followScopeRepository: followScopeRepository,
      );

  // ==========================================================
  // USE CASES - SEARCH
  // ==========================================================

  SearchContent get searchContent => SearchContent(searchRepository);

  // ==========================================================
  // USE CASES - DISCUSSION (commenti)
  // ==========================================================

  AddComment get addComment => AddComment(commentRepository);

  GetCommentsForTarget get getCommentsForTarget =>
      GetCommentsForTarget(commentRepository);

  GetCommentCountForTarget get getCommentCountForTarget =>
      GetCommentCountForTarget(commentRepository);

  // ==========================================================
  // CONTROLLERS - AUTH
  // ==========================================================

  AuthController createAuthController() {
    return AuthController(
      sessionRepository: sessionRepository,
      loginUser: loginUser,
      registerUser: registerUser,
      authApi: _authApi,
    );
  }

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
    return PollResultController(getPollResults, voteRepository);
  }

  CreatePollController createCreatePollController() {
    return CreatePollController(
      createPollUseCase: createPoll,
      geoScopeController: geoScopeController,
      createdByUserId: currentUserId ?? 'guest',
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
      getCommentCountForTarget: getCommentCountForTarget,
    );
  }

  PostDetailController createPostDetailController(String postId) {
    return PostDetailController(
      postId: postId,
      getPostDetail: getPostDetail,
      toggleReaction: toggleReaction,
      getReactionSummary: getReactionSummary,
    );
  }

  // ==========================================================
  // CONTROLLERS - DISCOVERY
  // ==========================================================

  TrendingController createTrendingController() {
    return TrendingController(
      getTrendingContent: getTrendingContent,
      geoScopeController: geoScopeController,
      userId: currentUserId,
    );
  }

  ForYouFeedController createForYouFeedController() {
    return ForYouFeedController(
      getForYouFeed: getForYouFeed,
      geoScopeController: geoScopeController,
      toggleReaction: toggleReaction,
      getReactionSummary: getReactionSummary,
      getCommentCountForTarget: getCommentCountForTarget,
    );
  }

  // ==========================================================
  // CONTROLLERS - SEARCH
  // ==========================================================

  SearchController createSearchController() {
    return SearchController(
      searchContent: searchContent,
      geoScopeController: geoScopeController,
    );
  }

  // ==========================================================
  // CONTROLLERS - DISCUSSION
  // ==========================================================

  DiscussionController createDiscussionController(
    TargetRef target, {
    VoidCallback? onCommentsChanged,
  }) {
    return DiscussionController(
      target: target,
      addComment: addComment,
      getCommentsForTarget: getCommentsForTarget,
      onCommentsChanged: onCommentsChanged,
    );
  }
}