import 'package:flutter/foundation.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/discovery/usecases/get_for_you_feed.dart';
import 'package:sociale_vote/domain/discussion/usecases/get_comment_count_for_target.dart';
import 'package:sociale_vote/domain/engagement/entities/reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/usecases/get_reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/usecases/toggle_reaction.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';

class ForYouFeedController extends ChangeNotifier {
  final GetForYouFeed _getForYouFeed;
  final GeoScopeController _geoScopeController;
  final ToggleReaction _toggleReaction;
  final GetReactionSummary _getReactionSummary;
  final GetCommentCountForTarget _getCommentCountForTarget;

  ForYouFeedController({
    required GetForYouFeed getForYouFeed,
    required GeoScopeController geoScopeController,
    required ToggleReaction toggleReaction,
    required GetReactionSummary getReactionSummary,
    required GetCommentCountForTarget getCommentCountForTarget,
  })  : _getForYouFeed = getForYouFeed,
        _geoScopeController = geoScopeController,
        _toggleReaction = toggleReaction,
        _getReactionSummary = getReactionSummary,
        _getCommentCountForTarget = getCommentCountForTarget;

  List<Post> _posts = [];
  List<Post> get posts => List.unmodifiable(_posts);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null && _errorMessage!.isNotEmpty;

  final Map<String, ReactionSummary> _reactionSummaries =
      <String, ReactionSummary>{};

  final Map<String, int> _commentCounts = <String, int>{};

  String? _lastKnownUserId;
  bool _isDisposed = false;
  int _requestId = 0;

  ReactionSummary? summaryForPost(Post post) {
    return _reactionSummaries[_postId(post)];
  }

  int likeCountForPost(Post post) {
    return summaryForPost(post)?.likeCount ?? 0;
  }

  int dislikeCountForPost(Post post) {
    return summaryForPost(post)?.dislikeCount ?? 0;
  }

  int commentCountForPost(Post post) {
    return _commentCounts[_postId(post)] ?? post.commentCount;
  }

  ReactionType? userReactionForPost(Post post) {
    return summaryForPost(post)?.userReaction;
  }

  String _postId(Post post) => post.id.value;

  TargetRef _targetForPost(Post post) {
    return TargetRef.post(_postId(post));
  }

  bool _containsPost(Post post) {
    final postId = _postId(post);
    return _posts.any((item) => item.id.value == postId);
  }

  Future<void> load({
    required String? userId,
    int limit = 10,
  }) async {
    final int requestId = ++_requestId;
    final GeoScope scope = _geoScopeController.scope;

    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    _lastKnownUserId = userId ?? _lastKnownUserId;
    _reactionSummaries.clear();
    _commentCounts.clear();

    try {
      final result = await _getForYouFeed(
        userId: userId,
        currentScope: scope,
        limit: limit,
      );

      if (!_isRequestStillValid(requestId)) {
        return;
      }

      _posts = result;

      await _loadReactionSummariesForPosts(
        result,
        userId: _lastKnownUserId,
        requestId: requestId,
      );

      if (!_isRequestStillValid(requestId)) {
        return;
      }

      await _loadCommentCountsForPosts(
        result,
        requestId: requestId,
      );
    } catch (e) {
      if (!_isRequestStillValid(requestId)) {
        return;
      }

      _errorMessage = e.toString();
      _posts = [];
      _reactionSummaries.clear();
      _commentCounts.clear();
    } finally {
      if (!_isRequestStillValid(requestId)) {
        return;
      }

      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> _loadReactionSummariesForPosts(
    List<Post> posts, {
    required String? userId,
    required int requestId,
  }) async {
    if (posts.isEmpty) {
      return;
    }

    final targets = posts.map(_targetForPost).toList();

    final summaries = await _getReactionSummary(
      targets,
      userId: userId,
    );

    if (!_isRequestStillValid(requestId)) {
      return;
    }

    for (final summary in summaries) {
      _reactionSummaries[summary.target.id] = summary;
    }
  }

  Future<void> _loadCommentCountsForPosts(
    List<Post> posts, {
    required int requestId,
  }) async {
    if (posts.isEmpty) {
      return;
    }

    for (final post in posts) {
      final count = await _getCommentCountForTarget(_targetForPost(post));

      if (!_isRequestStillValid(requestId)) {
        return;
      }

      _commentCounts[_postId(post)] = count;
    }
  }

  Future<void> refreshCommentCountForPost(Post post) async {
    if (!_containsPost(post)) {
      return;
    }

    try {
      final count = await _getCommentCountForTarget(_targetForPost(post));
      if (_isDisposed || !_containsPost(post)) return;

      _commentCounts[_postId(post)] = count;
      _safeNotifyListeners();
    } catch (_) {}
  }

  Future<void> refreshReactionSummaryForPost(Post post) async {
    if (!_containsPost(post)) {
      return;
    }

    try {
      final summaries = await _getReactionSummary(
        [_targetForPost(post)],
        userId: _lastKnownUserId,
      );

      if (_isDisposed || !_containsPost(post)) return;

      if (summaries.isNotEmpty) {
        _reactionSummaries[_postId(post)] = summaries.first;
        _safeNotifyListeners();
      }
    } catch (_) {}
  }

  Future<void> refreshEngagementForPost(Post post) async {
    if (!_containsPost(post)) {
      return;
    }

    try {
      final results = await Future.wait([
        _getReactionSummary(
          [_targetForPost(post)],
          userId: _lastKnownUserId,
        ),
        _getCommentCountForTarget(_targetForPost(post)),
      ]);

      if (_isDisposed || !_containsPost(post)) return;

      final summaries = results[0] as List<ReactionSummary>;
      final commentCount = results[1] as int;

      if (summaries.isNotEmpty) {
        _reactionSummaries[_postId(post)] = summaries.first;
      }
      _commentCounts[_postId(post)] = commentCount;

      _safeNotifyListeners();
    } catch (_) {}
  }

  Future<void> toggleFireForPost({
    required String userId,
    required Post post,
  }) async {
    assert(userId.isNotEmpty, 'toggleFireForPost richiede userId valido.');

    final target = _targetForPost(post);

    final summary = await _toggleReaction(
      userId: userId,
      target: target,
      type: ReactionType.like,
    );

    if (_isDisposed || !_containsPost(post)) return;

    _reactionSummaries[_postId(post)] = summary;
    _lastKnownUserId = userId;
    _safeNotifyListeners();
  }

  Future<void> toggleIceForPost({
    required String userId,
    required Post post,
  }) async {
    assert(userId.isNotEmpty, 'toggleIceForPost richiede userId valido.');

    final target = _targetForPost(post);

    final summary = await _toggleReaction(
      userId: userId,
      target: target,
      type: ReactionType.dislike,
    );

    if (_isDisposed || !_containsPost(post)) return;

    _reactionSummaries[_postId(post)] = summary;
    _lastKnownUserId = userId;
    _safeNotifyListeners();
  }

  void clear() {
    _posts = [];
    _isLoading = false;
    _errorMessage = null;
    _reactionSummaries.clear();
    _commentCounts.clear();
    _safeNotifyListeners();
  }

  bool _isRequestStillValid(int requestId) {
    return !_isDisposed && requestId == _requestId;
  }

  void _safeNotifyListeners() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}