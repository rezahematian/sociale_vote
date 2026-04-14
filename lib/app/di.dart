import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sociale_vote/core/http/api_client.dart';
import 'package:sociale_vote/core/storage/key_value_storage.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';

import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/content/news/repositories/news_repository.dart';
import 'package:sociale_vote/domain/content/news/usecases/get_news_detail.dart';
import 'package:sociale_vote/domain/content/news/usecases/get_news_feed.dart';

import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/content/social/repositories/post_repository.dart';
import 'package:sociale_vote/domain/content/social/usecases/create_post.dart';
import 'package:sociale_vote/domain/content/social/usecases/delete_post.dart';
import 'package:sociale_vote/domain/content/social/usecases/get_feed.dart';
import 'package:sociale_vote/domain/content/social/usecases/get_post_detail.dart';
import 'package:sociale_vote/domain/content/social/usecases/update_post.dart';

import 'package:sociale_vote/domain/discovery/usecases/get_for_you_feed.dart';
import 'package:sociale_vote/domain/discovery/usecases/get_trending_content.dart';

import 'package:sociale_vote/domain/discussion/repositories/comment_repository.dart';
import 'package:sociale_vote/domain/discussion/usecases/add_comment.dart';
import 'package:sociale_vote/domain/discussion/usecases/add_comment_and_notify.dart';
import 'package:sociale_vote/domain/discussion/usecases/get_comment_count_for_target.dart';
import 'package:sociale_vote/domain/discussion/usecases/get_comments_for_target.dart';
import 'package:sociale_vote/domain/discussion/usecases/update_comment.dart';

import 'package:sociale_vote/domain/engagement/repositories/favorite_repository.dart';
import 'package:sociale_vote/domain/engagement/repositories/reaction_repository.dart';
import 'package:sociale_vote/domain/engagement/usecases/get_reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/usecases/is_favorite.dart';
import 'package:sociale_vote/domain/engagement/usecases/toggle_favorite.dart';
import 'package:sociale_vote/domain/engagement/usecases/toggle_reaction.dart';

import 'package:sociale_vote/domain/geo/repositories/device_location_repository.dart';
import 'package:sociale_vote/domain/geo/repositories/follow_scope_repository.dart';
import 'package:sociale_vote/domain/geo/repositories/geocoding_repository.dart';
import 'package:sociale_vote/domain/geo/repositories/geo_resolver.dart';
import 'package:sociale_vote/domain/geo/usecases/get_followed_scopes_for_user.dart';
import 'package:sociale_vote/domain/geo/usecases/resolve_scope_from_point.dart';
import 'package:sociale_vote/domain/geo/usecases/toggle_follow_scope.dart';
import 'package:sociale_vote/domain/geo/value_objects/content_location.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';

import 'package:sociale_vote/domain/identity/repositories/session_repository.dart';
import 'package:sociale_vote/domain/identity/repositories/user_profile_repository.dart';
import 'package:sociale_vote/domain/identity/repositories/user_repository.dart';
import 'package:sociale_vote/domain/identity/repositories/verification_request_repository.dart';
import 'package:sociale_vote/domain/identity/usecases/cancel_verification_request.dart';
import 'package:sociale_vote/domain/identity/usecases/create_verification_request.dart';
import 'package:sociale_vote/domain/identity/usecases/get_pending_verification_request.dart';
import 'package:sociale_vote/domain/identity/usecases/get_pending_verification_requests.dart';
import 'package:sociale_vote/domain/identity/usecases/get_user_profile.dart';
import 'package:sociale_vote/domain/identity/usecases/get_verification_requests_for_user.dart';
import 'package:sociale_vote/domain/identity/usecases/login_user.dart';
import 'package:sociale_vote/domain/identity/usecases/register_user.dart';
import 'package:sociale_vote/domain/identity/usecases/review_verification_request.dart';
import 'package:sociale_vote/domain/identity/usecases/review_verification_request_and_update_profile.dart';
import 'package:sociale_vote/domain/identity/usecases/update_user_profile.dart';

import 'package:sociale_vote/domain/moderation/repositories/moderation_repository.dart';
import 'package:sociale_vote/domain/moderation/usecases/report_content.dart';

import 'package:sociale_vote/domain/notifications/repositories/notification_repository.dart';
import 'package:sociale_vote/domain/notifications/usecases/create_comment_mention_notifications.dart';
import 'package:sociale_vote/domain/notifications/usecases/create_comment_reply_notification.dart';
import 'package:sociale_vote/domain/notifications/usecases/create_poll_result_notification.dart';
import 'package:sociale_vote/domain/notifications/usecases/get_notifications_for_user.dart';
import 'package:sociale_vote/domain/notifications/usecases/get_unread_notifications_count.dart';
import 'package:sociale_vote/domain/notifications/usecases/mark_all_notifications_as_read.dart';
import 'package:sociale_vote/domain/notifications/usecases/mark_notification_as_read.dart';

import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/repositories/poll_repository.dart';
import 'package:sociale_vote/domain/poll/repositories/vote_repository.dart';
import 'package:sociale_vote/domain/poll/services/vote_aggregator.dart';
import 'package:sociale_vote/domain/poll/usecases/create_poll.dart';
import 'package:sociale_vote/domain/poll/usecases/delete_poll.dart';
import 'package:sociale_vote/domain/poll/usecases/get_poll_detail.dart';
import 'package:sociale_vote/domain/poll/usecases/get_poll_results.dart';
import 'package:sociale_vote/domain/poll/usecases/get_polls.dart';
import 'package:sociale_vote/domain/poll/usecases/submit_vote.dart';
import 'package:sociale_vote/domain/poll/usecases/submit_vote_and_notify.dart';
import 'package:sociale_vote/domain/poll/usecases/update_poll_text.dart';

import 'package:sociale_vote/domain/search/repositories/search_repository.dart';
import 'package:sociale_vote/domain/search/usecases/search_content.dart';

import 'package:sociale_vote/features/auth/application/auth_controller.dart';
import 'package:sociale_vote/features/discovery/application/for_you_feed_controller.dart';
import 'package:sociale_vote/features/discovery/application/trending_controller.dart';
import 'package:sociale_vote/features/discussion/application/discussion_controller.dart';
import 'package:sociale_vote/features/geo/application/follow_scope_controller.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';
import 'package:sociale_vote/features/home/application/civic_feed_controller.dart';
import 'package:sociale_vote/features/map/application/civic_map_controller.dart';
import 'package:sociale_vote/features/news/application/news_controller.dart';
import 'package:sociale_vote/features/notifications/application/notifications_controller.dart';
import 'package:sociale_vote/features/poll/application/create_poll_controller.dart';
import 'package:sociale_vote/features/poll/application/poll_detail_controller.dart';
import 'package:sociale_vote/features/poll/application/poll_list_controller.dart';
import 'package:sociale_vote/features/poll/application/poll_result_controller.dart';
import 'package:sociale_vote/features/poll/application/vote_controller.dart';
import 'package:sociale_vote/features/profile/application/verification_requests_controller.dart';
import 'package:sociale_vote/features/profile/application/verification_review_controller.dart';
import 'package:sociale_vote/features/search/application/search_controller.dart';
import 'package:sociale_vote/features/social/application/feed_controller.dart';
import 'package:sociale_vote/features/social/application/post_detail_controller.dart';

import 'package:sociale_vote/infrastructure/auth/session_repository_impl.dart';
import 'package:sociale_vote/infrastructure/discussion/repositories/comment_repository_impl.dart';
import 'package:sociale_vote/infrastructure/engagement/repositories/favorite_repository_supabase.dart';
import 'package:sociale_vote/infrastructure/engagement/repositories/reaction_repository_impl.dart';
import 'package:sociale_vote/infrastructure/geo/geo_resolver_impl.dart';
import 'package:sociale_vote/infrastructure/geo/repositories/device_location_repository_impl.dart';
import 'package:sociale_vote/infrastructure/geo/repositories/follow_scope_repository_in_memory.dart';
import 'package:sociale_vote/infrastructure/geo/repositories/geocoding_repository_impl.dart';
import 'package:sociale_vote/infrastructure/identity/repositories/user_profile_repository_impl.dart';
import 'package:sociale_vote/infrastructure/identity/repositories/verification_request_repository_impl.dart';
import 'package:sociale_vote/infrastructure/moderation/repositories/moderation_repository_impl.dart';
import 'package:sociale_vote/infrastructure/news/aggregator/gnews_provider.dart';
import 'package:sociale_vote/infrastructure/news/aggregator/guardian_provider.dart';
import 'package:sociale_vote/infrastructure/news/aggregator/news_aggregator.dart';
import 'package:sociale_vote/infrastructure/news/aggregator/news_api_org_provider.dart';
import 'package:sociale_vote/infrastructure/news/aggregator/news_provider.dart';
import 'package:sociale_vote/infrastructure/news/aggregator/web_news_proxy_provider.dart';
import 'package:sociale_vote/infrastructure/news/mappers/news_mapper.dart';
import 'package:sociale_vote/infrastructure/news/repositories/news_repository_impl.dart';
import 'package:sociale_vote/infrastructure/notifications/repositories/notification_repository_impl.dart';
import 'package:sociale_vote/infrastructure/persistence/remote/rest/auth_api.dart';
import 'package:sociale_vote/infrastructure/persistence/remote/rest/guardian_api.dart';
import 'package:sociale_vote/infrastructure/persistence/remote/rest/news_api.dart';
import 'package:sociale_vote/infrastructure/persistence/remote/rest/news_api_org_api.dart';
import 'package:sociale_vote/infrastructure/poll/repositories/poll_repository_supabase.dart';
import 'package:sociale_vote/infrastructure/poll/repositories/vote_repository_impl.dart';
import 'package:sociale_vote/infrastructure/search/repositories/search_repository_in_memory.dart';
import 'package:sociale_vote/infrastructure/social/repositories/post_repository_impl.dart';
import 'package:sociale_vote/shared/services/storage_service.dart';

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

class _TargetEngagementSnapshot {
  final int heat;
  final int commentCount;

  const _TargetEngagementSnapshot({
    required this.heat,
    required this.commentCount,
  });
}

class _CachedTargetEngagementSnapshot {
  final _TargetEngagementSnapshot snapshot;
  final DateTime cachedAt;

  const _CachedTargetEngagementSnapshot({
    required this.snapshot,
    required this.cachedAt,
  });
}

class AppDI {
  AppDI._internal() {
    _sessionRepository.watchCurrentUserId().listen((userId) {
      _currentUserId = userId;
    });
  }

  static final AppDI instance = AppDI._internal();

  static const int _pollMapBatchSize = 120;
  static const int _postMapBatchSize = 120;
  static const int _newsMapBatchSize = 80;
  static const Duration _mapEngagementCacheTtl = Duration(seconds: 20);

  final GeoScopeController _geoScopeController = GeoScopeController();

  FollowScopeController? _followScopeController;
  String? _followScopeControllerUserId;

  final Map<String, _CachedTargetEngagementSnapshot>
      _mapEngagementSnapshotCache =
      <String, _CachedTargetEngagementSnapshot>{};

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

  final ApiClient _guardianClient = ApiClient(
    baseUrl: 'https://content.guardianapis.com',
  );

  final ApiClient _newsApiOrgClient = ApiClient(
    baseUrl: 'https://newsapi.org/v2',
  );

  final ApiClient _gnewsClient = ApiClient(
    baseUrl: 'https://gnews.io/api/v4',
  );

  late final GuardianApi _guardianApi = GuardianApi(_guardianClient);
  late final NewsApiOrgApi _newsApiOrgApi = NewsApiOrgApi(_newsApiOrgClient);
  late final NewsApi _newsApi = NewsApi(_gnewsClient);

  late final NewsMapper _newsMapper = NewsMapper();

  late final NewsProvider _guardianProvider = GuardianProvider(_guardianApi);
  late final NewsProvider _newsApiOrgProvider =
      NewsApiOrgProvider(_newsApiOrgApi);
  late final NewsProvider _gnewsProvider = GNewsProvider(_newsApi);
  late final NewsProvider _webNewsProxyProvider = WebNewsProxyProvider();

  late final NewsAggregator _newsAggregator = NewsAggregator(
    providers: kIsWeb
        ? <NewsProvider>[
            _webNewsProxyProvider,
          ]
        : <NewsProvider>[
            _guardianProvider,
            _newsApiOrgProvider,
            _gnewsProvider,
          ],
    systemLanguageResolver: _readSystemContentLanguageApiValue,
  );

  late final AuthApi _authApi = const AuthApi();

  late final SessionRepository _sessionRepository = SessionRepositoryImpl();
  late final UserRepository _userRepository = UserRepositoryImpl(_authApi);
  late final UserProfileRepository _userProfileRepository =
      UserProfileRepositoryImpl();
  late final VerificationRequestRepository _verificationRequestRepository =
      VerificationRequestRepositoryImpl();
  late final GeoResolver _geoResolver = GeoResolverImpl();
  late final DeviceLocationRepository _deviceLocationRepository =
      const DeviceLocationRepositoryImpl();
  late final GeocodingRepository _geocodingRepository =
      const GeocodingRepositoryImpl();
  late final FollowScopeRepository _followScopeRepository =
      FollowScopeRepositoryInMemory();
  late final PollRepository _pollRepository = PollRepositorySupabase();
  late final VoteRepository _voteRepository =
      VoteRepositoryImpl(Supabase.instance.client);
  late final NewsRepositoryImpl _newsRepositoryImpl =
      NewsRepositoryImpl(_newsAggregator, _newsMapper, _geocodingRepository);
  late final NewsRepository _newsRepository = _newsRepositoryImpl;
  final PostRepository _postRepository = PostRepositoryImpl();
  final FavoriteRepository _favoriteRepository = FavoriteRepositorySupabase();
  final ReactionRepository _reactionRepository = ReactionRepositoryImpl();
  final CommentRepository _commentRepository = CommentRepositoryImpl();
  final NotificationRepository _notificationRepository =
      NotificationRepositoryImpl();
  late final ModerationRepository _moderationRepository =
      ModerationRepositoryImpl(Supabase.instance.client);
  late final SearchRepository _searchRepository = SearchRepositoryInMemory(
    pollRepository: pollRepository,
    newsRepository: newsRepository,
    postRepository: postRepository,
  );
  late final StorageService _storageService = StorageService(
    const SharedPreferencesKeyValueStorage(),
  );

  String? _currentUserId;

  SessionRepository get sessionRepository => _sessionRepository;
  UserRepository get userRepository => _userRepository;
  UserProfileRepository get userProfileRepository => _userProfileRepository;
  VerificationRequestRepository get verificationRequestRepository =>
      _verificationRequestRepository;
  PollRepository get pollRepository => _pollRepository;
  VoteRepository get voteRepository => _voteRepository;
  NewsRepository get newsRepository => _newsRepository;
  PostRepository get postRepository => _postRepository;
  FavoriteRepository get favoriteRepository => _favoriteRepository;
  ReactionRepository get reactionRepository => _reactionRepository;
  CommentRepository get commentRepository => _commentRepository;
  NotificationRepository get notificationRepository => _notificationRepository;
  ModerationRepository get moderationRepository => _moderationRepository;
  DeviceLocationRepository get deviceLocationRepository =>
      _deviceLocationRepository;
  GeocodingRepository get geocodingRepository => _geocodingRepository;
  FollowScopeRepository get followScopeRepository => _followScopeRepository;
  SearchRepository get searchRepository => _searchRepository;
  StorageService get storageService => _storageService;

  String? get currentUserId => _currentUserId;

  Future<void> setContentLanguagePreference(String value) {
    return _storageService.writeContentLanguagePreference(value);
  }

  Future<String?> getContentLanguagePreference() {
    return _storageService.readContentLanguagePreference();
  }

  Future<void> clearContentLanguagePreference() {
    return _storageService.clearContentLanguagePreference();
  }

  Future<String?> _readStoredContentLanguageApiValue() async {
    try {
      final storedValue = await getContentLanguagePreference();
      if (storedValue == null) {
        return null;
      }

      final normalized = storedValue.trim().toLowerCase();
      switch (normalized) {
        case 'it':
        case 'en':
        case 'es':
        case 'fr':
        case 'de':
        case 'ar':
        case 'fa':
          return normalized;
        default:
          return null;
      }
    } catch (_) {
      return null;
    }
  }

  Future<String?> _readEffectiveContentLanguageApiValue() async {
    final stored = await _readStoredContentLanguageApiValue();
    if (stored != null && stored.trim().isNotEmpty) {
      return stored;
    }

    return _readSystemContentLanguageApiValue();
  }

  String? _readSystemContentLanguageApiValue() {
    try {
      final systemLanguage =
          ui.PlatformDispatcher.instance.locale.toLanguageTag();
      final normalized = systemLanguage
          .trim()
          .toLowerCase()
          .replaceAll('_', '-')
          .split('-')
          .first;

      switch (normalized) {
        case 'it':
        case 'en':
        case 'es':
        case 'fr':
        case 'de':
        case 'ar':
        case 'fa':
          return normalized;
        default:
          return 'en';
      }
    } catch (_) {
      return 'en';
    }
  }

  Future<int> refreshNewsFeedCache({
    String? countryCode,
    String? cityId,
    String? topic,
    String? language,
    int? providerLimit,
  }) async {
    final effectiveLanguage =
        language ?? await _readEffectiveContentLanguageApiValue();

    return _newsRepositoryImpl.refreshNewsFeedCache(
      countryCode: countryCode,
      cityId: cityId,
      topic: topic,
      language: effectiveLanguage,
      providerLimit: providerLimit,
    );
  }

  Future<void> logoutCurrentUser() async {
    await _authApi.logout();
    await _sessionRepository.clearSession();
  }

  VoteAggregator get voteAggregator => VoteAggregator();

  LoginUser get loginUser => LoginUser(
        userRepository,
        sessionRepository,
      );

  RegisterUser get registerUser => RegisterUser(
        userRepository,
        sessionRepository,
      );

  GetUserProfile get getUserProfile =>
      GetUserProfile(userProfileRepository, sessionRepository);

  UpdateUserProfile get updateUserProfile =>
      UpdateUserProfile(userProfileRepository);

  CreateVerificationRequest get createVerificationRequest =>
      CreateVerificationRequest(verificationRequestRepository);

  GetPendingVerificationRequest get getPendingVerificationRequest =>
      GetPendingVerificationRequest(verificationRequestRepository);

  GetPendingVerificationRequests get getPendingVerificationRequests =>
      GetPendingVerificationRequests(verificationRequestRepository);

  GetVerificationRequestsForUser get getVerificationRequestsForUser =>
      GetVerificationRequestsForUser(verificationRequestRepository);

  CancelVerificationRequest get cancelVerificationRequest =>
      CancelVerificationRequest(verificationRequestRepository);

  ReviewVerificationRequest get reviewVerificationRequest =>
      ReviewVerificationRequest(verificationRequestRepository);

  ReviewVerificationRequestAndUpdateProfile
      get reviewVerificationRequestAndUpdateProfile =>
          ReviewVerificationRequestAndUpdateProfile(
            verificationRequestRepository: verificationRequestRepository,
            userProfileRepository: userProfileRepository,
            reviewVerificationRequest: reviewVerificationRequest,
          );

  GetPolls get getPolls => GetPolls(pollRepository);

  GetPollDetail get getPollDetail => GetPollDetail(pollRepository);

  SubmitVote get submitVote => SubmitVote(voteRepository);

  SubmitVoteAndNotify get submitVoteAndNotify => SubmitVoteAndNotify(
        submitVote,
        createPollResultNotification,
      );

  GetPollResults get getPollResults =>
      GetPollResults(voteRepository, voteAggregator);

  CreatePoll get createPoll => CreatePoll(pollRepository);

  DeletePoll get deletePoll => DeletePoll(pollRepository);

  UpdatePollText get updatePollText => UpdatePollText(pollRepository);

  GetNewsFeed get getNewsFeed => GetNewsFeed(newsRepository);

  GetNewsDetail get getNewsDetail => GetNewsDetail(newsRepository);

  GetFeed get getFeed => GetFeed(postRepository);

  GetPostDetail get getPostDetail => GetPostDetail(postRepository);

  CreatePost get createPostUseCase => CreatePost(postRepository);

  UpdatePost get updatePost => UpdatePost(postRepository);

  DeletePost get deletePost => DeletePost(postRepository);

  Future<Post> createPost({
    required String authorId,
    required String authorName,
    required String title,
    required String content,
    String? countryCode,
    String? cityId,
    ContentLocation? contentLocation,
  }) {
    return createPostUseCase(
      authorId: authorId,
      authorName: authorName,
      title: title,
      content: content,
      countryCode: countryCode,
      cityId: cityId,
      contentLocation: contentLocation,
    );
  }

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

  ReportContent get reportContent => ReportContent(moderationRepository);

  ResolveScopeFromPoint get resolveScopeFromPoint =>
      ResolveScopeFromPoint(_geoResolver);

  GetFollowedScopesForUser get getFollowedScopesForUser =>
      GetFollowedScopesForUser(followScopeRepository);

  ToggleFollowScope get toggleFollowScope =>
      ToggleFollowScope(followScopeRepository);

  GetTrendingContent get getTrendingContent => GetTrendingContent(
        postRepository: postRepository,
        newsRepository: newsRepository,
        pollRepository: pollRepository,
        voteRepository: voteRepository,
        commentRepository: commentRepository,
        getReactionSummary: getReactionSummary,
        getCommentsForTarget: getCommentsForTarget,
        followScopeRepository: followScopeRepository,
      );

  GetForYouFeed get getForYouFeed => GetForYouFeed(
        postRepository: postRepository,
        newsRepository: newsRepository,
        pollRepository: pollRepository,
        commentRepository: commentRepository,
        getReactionSummary: getReactionSummary,
        followScopeRepository: followScopeRepository,
      );

  SearchContent get searchContent => SearchContent(searchRepository);

  AddComment get addComment => AddComment(commentRepository);

  CreateCommentReplyNotification get createCommentReplyNotification =>
      CreateCommentReplyNotification(
        commentRepository,
        notificationRepository,
      );

  CreateCommentMentionNotifications get createCommentMentionNotifications =>
      CreateCommentMentionNotifications(
        userProfileRepository,
        notificationRepository,
      );

  CreatePollResultNotification get createPollResultNotification =>
      CreatePollResultNotification(notificationRepository);

  AddCommentAndNotify get addCommentAndNotify => AddCommentAndNotify(
        addComment,
        createCommentReplyNotification,
        createCommentMentionNotifications,
      );

  GetCommentsForTarget get getCommentsForTarget =>
      GetCommentsForTarget(commentRepository);

  GetCommentCountForTarget get getCommentCountForTarget =>
      GetCommentCountForTarget(commentRepository);

  UpdateComment get updateComment => UpdateComment(commentRepository);

  GetNotificationsForUser get getNotificationsForUser =>
      GetNotificationsForUser(notificationRepository);

  GetUnreadNotificationsCount get getUnreadNotificationsCount =>
      GetUnreadNotificationsCount(notificationRepository);

  MarkNotificationAsRead get markNotificationAsRead =>
      MarkNotificationAsRead(notificationRepository);

  MarkAllNotificationsAsRead get markAllNotificationsAsRead =>
      MarkAllNotificationsAsRead(notificationRepository);

  AuthController createAuthController() {
    return AuthController(
      sessionRepository: sessionRepository,
      loginUser: loginUser,
      registerUser: registerUser,
      authApi: _authApi,
    );
  }

  VerificationRequestsController createVerificationRequestsController() {
    return VerificationRequestsController(
      createVerificationRequest: createVerificationRequest,
      getPendingVerificationRequest: getPendingVerificationRequest,
      getVerificationRequestsForUser: getVerificationRequestsForUser,
      cancelVerificationRequest: cancelVerificationRequest,
    );
  }

  VerificationReviewController createVerificationReviewController() {
    return VerificationReviewController(
      getPendingVerificationRequests: getPendingVerificationRequests,
      reviewVerificationRequestAndUpdateProfile:
          reviewVerificationRequestAndUpdateProfile,
    );
  }

  PollListController createPollListController() {
    return PollListController(
      getPollsUseCase: getPolls,
      getPollResults: getPollResults,
      geoScopeController: geoScopeController,
      toggleReaction: toggleReaction,
      getReactionSummary: getReactionSummary,
    );
  }

  PollDetailController createPollDetailController() {
    return PollDetailController(
      getPollDetail,
      updatePollText,
      deletePoll,
      toggleReaction,
      getReactionSummary,
    );
  }

  VoteController createVoteController() {
    return VoteController(submitVoteAndNotify);
  }

  PollResultController createPollResultController() {
    return PollResultController(getPollResults, voteRepository);
  }

  CreatePollController createCreatePollController() {
    return CreatePollController(
      createPollUseCase: createPoll,
      geoScopeController: geoScopeController,
      createdByUserId: currentUserId ?? 'guest',
      deviceLocationRepository: deviceLocationRepository,
      geocodingRepository: geocodingRepository,
    );
  }

  NewsController createNewsController() {
    return NewsController(
      getNewsFeed,
      toggleReaction,
      getReactionSummary,
    );
  }

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
      updatePost: updatePost,
      deletePost: deletePost,
      toggleReaction: toggleReaction,
      getReactionSummary: getReactionSummary,
    );
  }

  NotificationsController createNotificationsController() {
    return createNotificationsControllerForUser(currentUserId ?? '');
  }

  NotificationsController createNotificationsControllerForUser(String userId) {
    return NotificationsController(
      userId: userId,
      getNotificationsForUser: getNotificationsForUser,
      getUnreadNotificationsCount: getUnreadNotificationsCount,
      markNotificationAsRead: markNotificationAsRead,
      markAllNotificationsAsRead: markAllNotificationsAsRead,
    );
  }

  CivicFeedController createCivicFeedController() {
    return CivicFeedController(
      loadPolls: _loadPollsForScope,
      loadNews: _loadNewsForScope,
      loadPosts: _loadPostsForScope,
      readPollId: _readPollId,
      readNewsId: _readNewsId,
      readPostId: _readPostId,
      readPollCreatedAt: _readPollCreatedAt,
      readNewsCreatedAt: _readNewsCreatedAt,
      readPostCreatedAt: _readPostCreatedAt,
      readPollTargetRef: _readPollTargetRef,
      readNewsTargetRef: _readNewsTargetRef,
      readPostTargetRef: _readPostTargetRef,
      loadReactionCount: _loadReactionCountForTarget,
      loadCommentCount: _loadCommentCountForTarget,
    );
  }

  CivicMapController createCivicMapController() {
    return CivicMapController(
      loadPollItems: _loadPollMapItemsForScope,
      loadPostItems: _loadPostMapItemsForScope,
      loadNewsItems: _loadNewsMapItemsForScope,
      beforeRefresh: _refreshNewsCacheForMapScope,
    );
  }

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

  SearchController createSearchController() {
    return SearchController(
      searchContent: searchContent,
      geoScopeController: geoScopeController,
    );
  }

  DiscussionController createDiscussionController(
    TargetRef target, {
    VoidCallback? onCommentsChanged,
  }) {
    return DiscussionController(
      target: target,
      addComment: addCommentAndNotify.call,
      getCommentsForTarget: getCommentsForTarget,
      updateComment: updateComment,
      onCommentsChanged: onCommentsChanged,
    );
  }

  Future<List<Poll>> _loadPollsForScope(GeoScope? scope) async {
    final countryCode = _readScopeCountryCode(scope);
    final cityId = _readScopeCityId(scope);
    final dynamic useCase = getPolls;

    final scoped = await _tryLoadListOrEmpty<Poll>([
      () => useCase(countryCode: countryCode, cityId: cityId),
      () => useCase(countryCode: countryCode, cityId: cityId, limit: 20),
      () => useCase(
            countryCode: countryCode,
            cityId: cityId,
            limit: 20,
            offset: 0,
          ),
    ]);

    if (scoped.isNotEmpty) {
      return scoped;
    }

    return _tryLoadList<Poll>([
      () => useCase(),
      () => useCase(limit: 20),
      () => useCase(limit: 20, offset: 0),
    ]);
  }

  Future<List<NewsItem>> _loadNewsForScope(GeoScope? scope) async {
    final language = await _readEffectiveContentLanguageApiValue();
    final levelName = _readScopeLevelName(scope);
    final countryCode = _readScopeCountryCode(scope);
    final cityId = _readScopeCityId(scope);

    if (levelName == 'country') {
      if (!_hasText(countryCode)) {
        return <NewsItem>[];
      }

      return _loadNewsBatch(
        countryCode: countryCode,
        cityId: null,
        language: language,
        limit: 20,
      );
    }

    if (levelName == 'city') {
      if (!_hasText(countryCode) || !_hasText(cityId)) {
        return <NewsItem>[];
      }

      return _loadNewsBatch(
        countryCode: countryCode,
        cityId: cityId,
        language: language,
        limit: 20,
      );
    }

    return _loadNewsBatch(
      countryCode: null,
      cityId: null,
      language: language,
      limit: 20,
    );
  }

  Future<List<Post>> _loadPostsForScope(GeoScope? scope) async {
    final countryCode = _readScopeCountryCode(scope);
    final cityId = _readScopeCityId(scope);
    final dynamic useCase = getFeed;

    final scoped = await _tryLoadListOrEmpty<Post>([
      () => useCase(countryCode: countryCode, cityId: cityId),
      () => useCase(countryCode: countryCode, cityId: cityId, limit: 20),
      () => useCase(
            countryCode: countryCode,
            cityId: cityId,
            limit: 20,
            offset: 0,
          ),
    ]);

    if (scoped.isNotEmpty) {
      return scoped;
    }

    return _tryLoadList<Post>([
      () => useCase(),
      () => useCase(limit: 20),
      () => useCase(limit: 20, offset: 0),
    ]);
  }

  Future<List<Poll>> _loadPollsForMapScope(GeoScope scope) async {
    final polls = await _loadEntitiesForMapScope<Poll>(
      scope: scope,
      useCase: getPolls,
      batchSize: _pollMapBatchSize,
    );

    return _filterEntitiesForGeoScope(polls, scope);
  }

  Future<List<NewsItem>> _loadNewsForMapScope(GeoScope scope) async {
    final levelName = _readScopeLevelName(scope);
    final countryCode = _readScopeCountryCode(scope);
    final cityId = _readScopeCityId(scope);
    final language = await _readEffectiveContentLanguageApiValue();

    if (levelName == 'world') {
      final news = await _loadNewsBatch(
        countryCode: null,
        cityId: null,
        language: language,
        limit: _newsMapBatchSize,
      );
      return _filterEntitiesForGeoScope(news, scope);
    }

    if (levelName == 'country') {
      if (!_hasText(countryCode)) {
        return <NewsItem>[];
      }

      final news = await _loadNewsBatch(
        countryCode: countryCode,
        cityId: null,
        language: language,
        limit: _newsMapBatchSize,
      );

      return _filterEntitiesForGeoScope(news, scope);
    }

    if (levelName == 'city') {
      if (!_hasText(countryCode) || !_hasText(cityId)) {
        return <NewsItem>[];
      }

      final news = await _loadNewsBatch(
        countryCode: countryCode,
        cityId: cityId,
        language: language,
        limit: _newsMapBatchSize,
      );

      return _filterEntitiesForGeoScope(news, scope);
    }

    if (levelName == 'area') {
      if (_hasText(countryCode) && _hasText(cityId)) {
        final byCity = await _loadNewsBatch(
          countryCode: countryCode,
          cityId: cityId,
          language: language,
          limit: _newsMapBatchSize,
        );

        return _filterEntitiesForGeoScope(byCity, scope);
      }

      if (_hasText(countryCode)) {
        final byCountry = await _loadNewsBatch(
          countryCode: countryCode,
          cityId: null,
          language: language,
          limit: _newsMapBatchSize,
        );

        return _filterEntitiesForGeoScope(byCountry, scope);
      }

      final worldFallback = await _loadNewsBatch(
        countryCode: null,
        cityId: null,
        language: language,
        limit: _newsMapBatchSize,
      );

      return _filterEntitiesForGeoScope(worldFallback, scope);
    }

    final fallback = await _loadNewsBatch(
      countryCode: null,
      cityId: null,
      language: language,
      limit: _newsMapBatchSize,
    );

    return _filterEntitiesForGeoScope(fallback, scope);
  }

  Future<void> _refreshNewsCacheForMapScope(GeoScope scope) async {
    final levelName = _readScopeLevelName(scope);
    final countryCode = _readScopeCountryCode(scope);
    final cityId = _readScopeCityId(scope);
    final language = await _readEffectiveContentLanguageApiValue();

    if (levelName == 'city') {
      if (!_hasText(countryCode) || !_hasText(cityId)) {
        return;
      }

      await refreshNewsFeedCache(
        countryCode: countryCode,
        cityId: cityId,
        language: language,
        providerLimit: _newsMapBatchSize,
      );
      return;
    }

    if (levelName == 'country') {
      if (!_hasText(countryCode)) {
        return;
      }

      await refreshNewsFeedCache(
        countryCode: countryCode,
        cityId: null,
        language: language,
        providerLimit: _newsMapBatchSize,
      );
      return;
    }

    if (levelName == 'area') {
      if (_hasText(countryCode) && _hasText(cityId)) {
        await refreshNewsFeedCache(
          countryCode: countryCode,
          cityId: cityId,
          language: language,
          providerLimit: _newsMapBatchSize,
        );
        return;
      }

      if (_hasText(countryCode)) {
        await refreshNewsFeedCache(
          countryCode: countryCode,
          cityId: null,
          language: language,
          providerLimit: _newsMapBatchSize,
        );
        return;
      }
    }

    await refreshNewsFeedCache(
      countryCode: null,
      cityId: null,
      language: language,
      providerLimit: _newsMapBatchSize,
    );
  }

  Future<List<NewsItem>> _loadNewsBatch({
    required String? countryCode,
    required String? cityId,
    required String? language,
    required int limit,
  }) {
    final dynamic useCase = getNewsFeed;

    return _tryLoadListOrEmpty<NewsItem>([
      () => useCase(
            countryCode: countryCode,
            cityId: cityId,
            language: language,
            limit: limit,
            offset: 0,
          ),
    ]);
  }

  Future<List<Post>> _loadPostsForMapScope(GeoScope scope) async {
    final posts = await _loadEntitiesForMapScope<Post>(
      scope: scope,
      useCase: getFeed,
      batchSize: _postMapBatchSize,
    );

    return _filterEntitiesForGeoScope(posts, scope);
  }

  Future<List<T>> _loadEntitiesForMapScope<T>({
    required GeoScope scope,
    required dynamic useCase,
    required int batchSize,
  }) async {
    final levelName = _readScopeLevelName(scope);
    final countryCode = _readScopeCountryCode(scope);
    final cityId = _readScopeCityId(scope);

    if (levelName == 'world') {
      return _tryLoadList<T>([
        () => useCase(limit: batchSize),
        () => useCase(limit: batchSize, offset: 0),
        () => useCase(),
      ]);
    }

    if (levelName == 'country') {
      if (!_hasText(countryCode)) {
        return <T>[];
      }

      return _tryLoadListOrEmpty<T>([
        () => useCase(countryCode: countryCode, limit: batchSize),
        () => useCase(
              countryCode: countryCode,
              limit: batchSize,
              offset: 0,
            ),
        () => useCase(countryCode: countryCode),
      ]);
    }

    if (levelName == 'city') {
      if (!_hasText(countryCode) || !_hasText(cityId)) {
        return <T>[];
      }

      return _tryLoadListOrEmpty<T>([
        () => useCase(
              countryCode: countryCode,
              cityId: cityId,
              limit: batchSize,
            ),
        () => useCase(
              countryCode: countryCode,
              cityId: cityId,
              limit: batchSize,
              offset: 0,
            ),
        () => useCase(
              countryCode: countryCode,
              cityId: cityId,
            ),
      ]);
    }

    if (levelName == 'area') {
      if (_hasText(countryCode) && _hasText(cityId)) {
        final byCity = await _tryLoadListOrEmpty<T>([
          () => useCase(
                countryCode: countryCode,
                cityId: cityId,
                limit: batchSize,
              ),
          () => useCase(
                countryCode: countryCode,
                cityId: cityId,
                limit: batchSize,
                offset: 0,
              ),
          () => useCase(
                countryCode: countryCode,
                cityId: cityId,
              ),
        ]);

        if (byCity.isNotEmpty) {
          return byCity;
        }
      }

      if (_hasText(countryCode)) {
        final byCountry = await _tryLoadListOrEmpty<T>([
          () => useCase(countryCode: countryCode, limit: batchSize),
          () => useCase(
                countryCode: countryCode,
                limit: batchSize,
                offset: 0,
              ),
          () => useCase(countryCode: countryCode),
        ]);

        if (byCountry.isNotEmpty) {
          return byCountry;
        }
      }

      return _tryLoadListOrEmpty<T>([
        () => useCase(limit: batchSize),
        () => useCase(limit: batchSize, offset: 0),
        () => useCase(),
      ]);
    }

    return _tryLoadListOrEmpty<T>([
      () => useCase(limit: batchSize),
      () => useCase(limit: batchSize, offset: 0),
      () => useCase(),
    ]);
  }

  List<T> _filterEntitiesForGeoScope<T>(List<T> entities, GeoScope scope) {
    if (entities.isEmpty) {
      return <T>[];
    }

    final filtered = entities
        .where((entity) => _matchesEntityGeoScope(entity, scope))
        .toList(growable: false);

    return List<T>.unmodifiable(filtered);
  }

  bool _matchesEntityGeoScope(
    dynamic entity,
    GeoScope scope,
  ) {
    final levelName = _readScopeLevelName(scope);

    if (levelName == null || levelName == 'world') {
      return true;
    }

    final scopeCountryCode = _normalizeGeoValue(_readScopeCountryCode(scope));
    final scopeCityId = _normalizeGeoValue(_readScopeCityId(scope));

    final entityCountryCode = _normalizeGeoValue(_readEntityCountryCode(entity));
    final entityCityId = _normalizeGeoValue(_readEntityCityId(entity));

    if (levelName == 'country') {
      return scopeCountryCode != null && entityCountryCode == scopeCountryCode;
    }

    if (levelName == 'city') {
      return scopeCityId != null && entityCityId == scopeCityId;
    }

    if (levelName == 'area') {
      return _matchesAreaRadiusScope(
        entity,
        scope,
        scopeCountryCode: scopeCountryCode,
        scopeCityId: scopeCityId,
      );
    }

    return true;
  }

  bool _matchesAreaRadiusScope(
    dynamic entity,
    GeoScope scope, {
    required String? scopeCountryCode,
    required String? scopeCityId,
  }) {
    final scopePoint = _readScopeCenterPoint(scope);
    final radiusKm = _readScopeRadiusKm(scope);
    final entityPoint = _readEntityGeoFilterPoint(entity);

    if (scopePoint != null &&
        radiusKm != null &&
        radiusKm > 0 &&
        entityPoint != null) {
      final distanceKm = _distanceKm(
        scopePoint.$1,
        scopePoint.$2,
        entityPoint.$1,
        entityPoint.$2,
      );

      return distanceKm <= radiusKm;
    }

    if (scopeCityId != null) {
      final entityCityId = _normalizeGeoValue(_readEntityCityId(entity));
      if (entityCityId != null) {
        return entityCityId == scopeCityId;
      }
    }

    if (scopeCountryCode != null) {
      final entityCountryCode =
          _normalizeGeoValue(_readEntityCountryCode(entity));
      if (entityCountryCode != null) {
        return entityCountryCode == scopeCountryCode;
      }
    }

    return false;
  }

  (double, double)? _readScopeCenterPoint(GeoScope scope) {
    final lat = _readDoubleFromDynamicCandidates(scope, const [
      'centerLat',
      'latitude',
      'lat',
    ]);
    final lng = _readDoubleFromDynamicCandidates(scope, const [
      'centerLng',
      'longitude',
      'lng',
      'lon',
    ]);

    if (!_isValidLatLng(lat, lng)) {
      return null;
    }

    return (lat!, lng!);
  }

  double? _readScopeRadiusKm(GeoScope scope) {
    return _readDoubleFromDynamicCandidates(scope, const [
      'radiusKm',
      'radius',
    ]);
  }

  String? _readScopeLevelName(GeoScope? scope) {
    if (scope == null) {
      return null;
    }

    try {
      final dynamic level = (scope as dynamic).level;
      if (level == null) {
        return null;
      }

      final raw = level.toString().trim();
      if (raw.isEmpty) {
        return null;
      }

      final last = raw.split('.').last.trim().toLowerCase();
      return last.isEmpty ? null : last;
    } catch (_) {
      return null;
    }
  }

  bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  String? _normalizeGeoValue(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  Future<List<CivicMapItem>> _loadPollMapItemsForScope(GeoScope scope) async {
    final polls = await _loadPollsForMapScope(scope);
    return _buildMapItemsFromEntities<Poll>(
      entities: polls,
      scope: scope,
      type: CivicMapItemType.poll,
      readTargetRef: _readPollTargetRef,
    );
  }

  Future<List<CivicMapItem>> _loadPostMapItemsForScope(GeoScope scope) async {
    final posts = await _loadPostsForMapScope(scope);
    return _buildMapItemsFromEntities<Post>(
      entities: posts,
      scope: scope,
      type: CivicMapItemType.post,
      readTargetRef: _readPostTargetRef,
    );
  }

  Future<List<CivicMapItem>> _loadNewsMapItemsForScope(GeoScope scope) async {
    final news = await _loadNewsForMapScope(scope);
    return _buildMapItemsFromEntities<NewsItem>(
      entities: news,
      scope: scope,
      type: CivicMapItemType.news,
      readTargetRef: _readNewsTargetRef,
    );
  }

  Future<List<CivicMapItem>> _buildMapItemsFromEntities<T>({
    required List<T> entities,
    required GeoScope scope,
    required CivicMapItemType type,
    required TargetRef Function(T entity) readTargetRef,
  }) async {
    final targetRefs = entities.map(readTargetRef).toList(growable: false);

    final engagementByTargetKey =
        await _loadEngagementSnapshotsForTargets(targetRefs);

    final List<CivicMapItem> items = <CivicMapItem>[];

    for (var i = 0; i < entities.length; i++) {
      final entity = entities[i];
      final targetRef = targetRefs[i];
      final point = _readEntityMapPoint(
        entity,
        fallbackScope: scope,
        type: type,
      );

      if (point == null) {
        continue;
      }

      final engagement = engagementByTargetKey[_targetBatchKey(targetRef)] ??
          const _TargetEngagementSnapshot(
            heat: 0,
            commentCount: 0,
          );

      items.add(
        CivicMapItem(
          id: _readEntityId(entity),
          targetRef: targetRef,
          type: type,
          title: _readEntityTitle(entity),
          subtitle: _readEntitySubtitle(entity),
          geoScope: scope,
          contentLocation: _readEntityContentLocation(entity),
          latitude: point.$1,
          longitude: point.$2,
          heat: engagement.heat.toDouble(),
          commentCount: engagement.commentCount,
          createdAt: _readEntityCreatedAt(entity),
        ),
      );
    }

    return items;
  }

  ContentLocation? _readEntityContentLocation(dynamic entity) {
    try {
      final dynamic value = entity.contentLocation;
      return _tryReadContentLocation(value);
    } catch (_) {
      return null;
    }
  }

  String? _readEntityCountryCode(dynamic entity) {
    final contentLocation = _readEntityContentLocation(entity);
    final fromLocation = _normalizeGeoValue(contentLocation?.countryCode);
    if (fromLocation != null) {
      return fromLocation;
    }

    try {
      final dynamic value = entity.countryCode;
      if (value != null) {
        return _normalizeGeoValue(value.toString());
      }
    } catch (_) {}

    return null;
  }

  String? _readEntityCityId(dynamic entity) {
    final contentLocation = _readEntityContentLocation(entity);
    final fromLocation = _normalizeGeoValue(contentLocation?.cityId);
    if (fromLocation != null) {
      return fromLocation;
    }

    try {
      final dynamic value = entity.cityId;
      if (value != null) {
        return _normalizeGeoValue(value.toString());
      }
    } catch (_) {}

    return null;
  }

  ContentLocation? _tryReadContentLocation(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is ContentLocation) {
      return value;
    }
    if (value is Map<String, dynamic>) {
      return ContentLocation.fromJson(value);
    }
    if (value is Map) {
      return ContentLocation.fromJson(
        value.map(
          (key, val) => MapEntry(key.toString(), val),
        ),
      );
    }
    return null;
  }

  (double, double)? _readEntityMapPoint(
    dynamic entity, {
    required GeoScope fallbackScope,
    required CivicMapItemType type,
  }) {
    final direct = _tryReadLatLng(entity);
    if (direct != null) {
      return direct;
    }

    final contentLocationPoint = _tryReadContentLocationPoint(entity);
    if (contentLocationPoint != null) {
      return contentLocationPoint;
    }

    final nestedScope = _tryReadScopeLatLng(entity);
    if (nestedScope != null) {
      return nestedScope;
    }

    if (type == CivicMapItemType.news) {
      return null;
    }

    if (fallbackScope.centerLat != null &&
        fallbackScope.centerLng != null &&
        _isValidLatLng(fallbackScope.centerLat, fallbackScope.centerLng)) {
      return (fallbackScope.centerLat!, fallbackScope.centerLng!);
    }

    final levelName = _readScopeLevelName(fallbackScope);

    if (levelName == 'world') {
      return (20.0, 0.0);
    }

    if (levelName == 'country') {
      return (45.0, 10.0);
    }

    if (levelName == 'city') {
      return (45.4642, 9.1900);
    }

    if (levelName == 'area') {
      return null;
    }

    return null;
  }

  (double, double)? _readEntityGeoFilterPoint(dynamic entity) {
    final contentLocationPoint = _tryReadContentLocationPoint(entity);
    if (contentLocationPoint != null) {
      return contentLocationPoint;
    }

    final direct = _tryReadLatLng(entity);
    if (direct != null) {
      return direct;
    }

    final nestedScope = _tryReadScopeLatLng(entity);
    if (nestedScope != null) {
      return nestedScope;
    }

    return null;
  }

  (double, double)? _tryReadContentLocationPoint(dynamic entity) {
    final location = _readEntityContentLocation(entity);
    if (location == null) {
      return null;
    }

    if (_isValidLatLng(location.latitude, location.longitude)) {
      return (location.latitude!, location.longitude!);
    }

    if (_isValidLatLng(location.centerLat, location.centerLng)) {
      return (location.centerLat!, location.centerLng!);
    }

    return null;
  }

  (double, double)? _tryReadLatLng(dynamic entity) {
    final lat = _readDoubleFromDynamicCandidates(entity, const [
      'latitude',
      'lat',
      'centerLat',
    ]);

    final lng = _readDoubleFromDynamicCandidates(entity, const [
      'longitude',
      'lng',
      'lon',
      'centerLng',
    ]);

    if (!_isValidLatLng(lat, lng)) {
      return null;
    }

    return (lat!, lng!);
  }

  (double, double)? _tryReadScopeLatLng(dynamic entity) {
    try {
      final dynamic scope = entity.geoScope;
      if (scope == null) return null;

      final lat = _readDoubleFromDynamicCandidates(scope, const [
        'centerLat',
        'latitude',
        'lat',
      ]);
      final lng = _readDoubleFromDynamicCandidates(scope, const [
        'centerLng',
        'longitude',
        'lng',
        'lon',
      ]);

      if (!_isValidLatLng(lat, lng)) {
        return null;
      }

      return (lat!, lng!);
    } catch (_) {
      return null;
    }
  }

  double? _readDoubleFromDynamicCandidates(
    dynamic object,
    List<String> fields,
  ) {
    for (final field in fields) {
      try {
        final dynamic value = _readDynamicField(object, field);
        final parsed = _toDouble(value);
        if (parsed != null) {
          return parsed;
        }
      } catch (_) {}
    }
    return null;
  }

  dynamic _readDynamicField(dynamic object, String field) {
    switch (field) {
      case 'latitude':
        return object.latitude;
      case 'lat':
        return object.lat;
      case 'centerLat':
        return object.centerLat;
      case 'longitude':
        return object.longitude;
      case 'lng':
        return object.lng;
      case 'lon':
        return object.lon;
      case 'centerLng':
        return object.centerLng;
      case 'radiusKm':
        return object.radiusKm;
      case 'radius':
        return object.radius;
      default:
        throw StateError('Campo non supportato: $field');
    }
  }

  bool _isValidLatLng(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    if (!lat.isFinite || !lng.isFinite) return false;
    if (lat < -90 || lat > 90) return false;
    if (lng < -180 || lng > 180) return false;
    return true;
  }

  double _distanceKm(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _degreesToRadians(endLat - startLat);
    final dLng = _degreesToRadians(endLng - startLng);

    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_degreesToRadians(startLat)) *
            math.cos(_degreesToRadians(endLat)) *
            math.pow(math.sin(dLng / 2), 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  String _readEntityTitle(dynamic entity) {
    final title = _readStringCandidate(entity, const [
      'title',
      'question',
      'headline',
      'name',
    ]);
    if (title != null && title.trim().isNotEmpty) {
      return title.trim();
    }
    return entity.runtimeType.toString();
  }

  String? _readEntitySubtitle(dynamic entity) {
    final subtitle = _readStringCandidate(entity, const [
      'description',
      'summary',
      'content',
      'body',
      'sourceName',
      'authorName',
    ]);
    if (subtitle == null) {
      return null;
    }
    final normalized = subtitle.trim();
    if (normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  String? _readStringCandidate(dynamic object, List<String> fields) {
    for (final field in fields) {
      try {
        final dynamic value = _readStringField(object, field);
        if (value == null) {
          continue;
        }
        final text = value.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
      } catch (_) {}
    }
    return null;
  }

  dynamic _readStringField(dynamic object, String field) {
    switch (field) {
      case 'title':
        return object.title;
      case 'question':
        return object.question;
      case 'headline':
        return object.headline;
      case 'name':
        return object.name;
      case 'description':
        return object.description;
      case 'summary':
        return object.summary;
      case 'content':
        return object.content;
      case 'body':
        return object.body;
      case 'sourceName':
        return object.sourceName;
      case 'authorName':
        return object.authorName;
      default:
        throw StateError('Campo stringa non supportato: $field');
    }
  }

  Future<List<T>> _tryLoadList<T>(
    List<Future<dynamic> Function()> attempts,
  ) async {
    Object? lastError;

    for (final attempt in attempts) {
      try {
        final dynamic result = await attempt();

        if (result is List<T>) {
          return result;
        }
        if (result is List) {
          return result.cast<T>();
        }
        if (result is Iterable) {
          return result.cast<T>().toList();
        }
      } catch (error) {
        lastError = error;
      }
    }

    throw StateError(
      'Impossibile caricare la lista richiesta: ${lastError ?? 'errore sconosciuto'}',
    );
  }

  Future<List<T>> _tryLoadListOrEmpty<T>(
    List<Future<dynamic> Function()> attempts,
  ) async {
    for (final attempt in attempts) {
      try {
        final dynamic result = await attempt();

        if (result is List<T>) {
          return result;
        }
        if (result is List) {
          return result.cast<T>();
        }
        if (result is Iterable) {
          return result.cast<T>().toList();
        }
      } catch (_) {}
    }

    return <T>[];
  }

  String? _readScopeCountryCode(GeoScope? scope) {
    if (scope == null) {
      return null;
    }

    try {
      final dynamic value = (scope as dynamic).countryCode;
      if (value == null) {
        return null;
      }
      return value.toString();
    } catch (_) {
      return null;
    }
  }

  String? _readScopeCityId(GeoScope? scope) {
    if (scope == null) {
      return null;
    }

    try {
      final dynamic value = (scope as dynamic).cityId;
      if (value == null) {
        return null;
      }
      return value.toString();
    } catch (_) {
      return null;
    }
  }

  String _readPollId(Poll poll) => _readEntityId(poll);
  String _readNewsId(NewsItem news) => _readEntityId(news);
  String _readPostId(Post post) => _readEntityId(post);

  DateTime _readPollCreatedAt(Poll poll) => _readEntityCreatedAt(poll);
  DateTime _readNewsCreatedAt(NewsItem news) => _readEntityCreatedAt(news);
  DateTime _readPostCreatedAt(Post post) => _readEntityCreatedAt(post);

  TargetRef _readPollTargetRef(Poll poll) => TargetRef.poll(_readPollId(poll));
  TargetRef _readNewsTargetRef(NewsItem news) =>
      TargetRef.news(_readNewsId(news));
  TargetRef _readPostTargetRef(Post post) => TargetRef.post(_readPostId(post));

  String _readEntityId(dynamic entity) {
    try {
      final dynamic id = entity.id;
      return _stringFromUnknownId(id);
    } catch (_) {}

    try {
      final dynamic id = entity.pollId;
      return _stringFromUnknownId(id);
    } catch (_) {}

    try {
      final dynamic id = entity.newsId;
      return _stringFromUnknownId(id);
    } catch (_) {}

    try {
      final dynamic id = entity.postId;
      return _stringFromUnknownId(id);
    } catch (_) {}

    throw StateError('Impossibile leggere id da ${entity.runtimeType}');
  }

  String _stringFromUnknownId(dynamic id) {
    if (id == null) {
      throw StateError('Id nullo');
    }

    try {
      final dynamic value = id.value;
      if (value != null) {
        return value.toString();
      }
    } catch (_) {}

    return id.toString();
  }

  DateTime _readEntityCreatedAt(dynamic entity) {
    try {
      final dynamic value = entity.createdAt;
      final parsed = _parseDateTime(value);
      if (parsed != null) {
        return parsed;
      }
    } catch (_) {}

    try {
      final dynamic value = entity.publishedAt;
      final parsed = _parseDateTime(value);
      if (parsed != null) {
        return parsed;
      }
    } catch (_) {}

    try {
      final dynamic value = entity.updatedAt;
      final parsed = _parseDateTime(value);
      if (parsed != null) {
        return parsed;
      }
    } catch (_) {}

    try {
      final dynamic value = entity.date;
      final parsed = _parseDateTime(value);
      if (parsed != null) {
        return parsed;
      }
    } catch (_) {}

    return DateTime.now();
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.tryParse(value.toString());
  }

  Future<Map<String, _TargetEngagementSnapshot>>
      _loadEngagementSnapshotsForTargets(
    List<TargetRef> targets,
  ) async {
    if (targets.isEmpty) {
      return const <String, _TargetEngagementSnapshot>{};
    }

    final now = DateTime.now();
    _pruneExpiredMapEngagementSnapshotCache(now);

    final snapshots = <String, _TargetEngagementSnapshot>{};
    final missingTargetsByKey = <String, TargetRef>{};

    for (final target in targets) {
      final key = _targetBatchKey(target);
      final cached = _readCachedMapEngagementSnapshot(key, now);

      if (cached != null) {
        snapshots[key] = cached;
        continue;
      }

      missingTargetsByKey.putIfAbsent(key, () => target);
    }

    if (missingTargetsByKey.isEmpty) {
      return snapshots;
    }

    final missingTargets = missingTargetsByKey.values.toList(growable: false);

    final results = await Future.wait<dynamic>([
      _loadReactionCountsForTargets(missingTargets),
      _loadCommentCountsForTargets(missingTargets),
    ]);

    final reactionCounts = results[0] as Map<String, int>;
    final commentCounts = results[1] as Map<String, int>;

    for (final target in missingTargets) {
      final key = _targetBatchKey(target);
      final snapshot = _TargetEngagementSnapshot(
        heat: reactionCounts[key] ?? 0,
        commentCount: commentCounts[key] ?? 0,
      );

      snapshots[key] = snapshot;
      _writeCachedMapEngagementSnapshot(
        key,
        snapshot,
        now,
      );
    }

    return snapshots;
  }

  _TargetEngagementSnapshot? _readCachedMapEngagementSnapshot(
    String key,
    DateTime now,
  ) {
    final cached = _mapEngagementSnapshotCache[key];
    if (cached == null) {
      return null;
    }

    if (now.difference(cached.cachedAt) > _mapEngagementCacheTtl) {
      _mapEngagementSnapshotCache.remove(key);
      return null;
    }

    return cached.snapshot;
  }

  void _writeCachedMapEngagementSnapshot(
    String key,
    _TargetEngagementSnapshot snapshot,
    DateTime now,
  ) {
    _mapEngagementSnapshotCache[key] = _CachedTargetEngagementSnapshot(
      snapshot: snapshot,
      cachedAt: now,
    );
  }

  void _pruneExpiredMapEngagementSnapshotCache(DateTime now) {
    _mapEngagementSnapshotCache.removeWhere(
      (_, cached) => now.difference(cached.cachedAt) > _mapEngagementCacheTtl,
    );
  }

  Future<Map<String, int>> _loadReactionCountsForTargets(
    List<TargetRef> targets,
  ) async {
    final counts = <String, int>{};

    for (final target in targets) {
      counts[_targetBatchKey(target)] = 0;
    }

    try {
      final summaries = await reactionRepository.getSummariesForTargets(targets);

      for (var i = 0; i < targets.length; i++) {
        final summary = i < summaries.length ? summaries[i] : null;
        counts[_targetBatchKey(targets[i])] = _extractReactionTotal(summary);
      }
    } catch (_) {}

    return counts;
  }

  Future<Map<String, int>> _loadCommentCountsForTargets(
    List<TargetRef> targets,
  ) async {
    final counts = <String, int>{};

    for (final target in targets) {
      counts[_targetBatchKey(target)] = 0;
    }

    try {
      final batchCounts = await commentRepository.countCommentsForTargets(
        targets,
      );

      for (final entry in batchCounts.entries) {
        counts[entry.key] = entry.value;
      }
    } catch (_) {}

    return counts;
  }

  String _targetBatchKey(TargetRef target) {
    final type = switch (target.type) {
      TargetType.post => 'post',
      TargetType.news => 'news',
      TargetType.poll => 'poll',
      TargetType.video => 'video',
      _ => target.type.name,
    };

    return '$type|${target.id.trim()}';
  }

  Future<int> _loadReactionCountForTarget(TargetRef targetRef) async {
    try {
      final summaries = await getReactionSummary([targetRef]);

      if (summaries.isEmpty) {
        return 0;
      }

      return _extractReactionTotal(summaries.first);
    } catch (_) {
      return 0;
    }
  }

  int _extractReactionTotal(dynamic summary) {
    if (summary == null) {
      return 0;
    }

    num total = 0;
    bool hasBreakdown = false;

    void addIfNum(dynamic value) {
      if (value is num) {
        total += value;
        hasBreakdown = true;
      }
    }

    try {
      addIfNum(summary.likeCount);
    } catch (_) {}

    try {
      addIfNum(summary.dislikeCount);
    } catch (_) {}

    try {
      addIfNum(summary.fireCount);
    } catch (_) {}

    try {
      addIfNum(summary.iceCount);
    } catch (_) {}

    try {
      addIfNum(summary.upCount);
    } catch (_) {}

    try {
      addIfNum(summary.downCount);
    } catch (_) {}

    if (hasBreakdown) {
      return total.toInt();
    }

    try {
      final dynamic totalCount = summary.totalCount;
      if (totalCount is num) {
        return totalCount.toInt();
      }
    } catch (_) {}

    return 0;
  }

  Future<int> _loadCommentCountForTarget(TargetRef targetRef) async {
    try {
      final dynamic result = await getCommentCountForTarget(targetRef);

      if (result is int) {
        return result;
      }
      if (result is num) {
        return result.toInt();
      }

      return int.tryParse(result.toString()) ?? 0;
    } catch (_) {
      return 0;
    }
  }
}