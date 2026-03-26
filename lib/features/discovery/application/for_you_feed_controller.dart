import 'package:flutter/foundation.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/discovery/usecases/get_for_you_feed.dart';
import 'package:sociale_vote/domain/engagement/entities/reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/usecases/get_reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/usecases/toggle_reaction.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';
import 'package:sociale_vote/features/home/application/feed_item.dart';
import 'package:sociale_vote/domain/discussion/usecases/get_comment_count_for_target.dart';

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

  List<FeedItem> _items = [];
  List<FeedItem> get items => List.unmodifiable(_items);

  List<Post> get posts => _items
      .where((item) => item.post != null)
      .map((item) => item.post!)
      .toList(growable: false);

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
    return _reactionSummaries[_targetForPost(post).key];
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

    return _items.any(
      (item) => item.post?.id.value == postId,
    );
  }

  Future<void> load({
    required String? userId,
    int limit = 10,
  }) async {
    final int requestId = ++_requestId;
    final scope = _geoScopeController.scope;

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

      _items = result;
      _primeCommentCountsFromItems(result);

      await _loadReactionSummariesForPostItems(
        result,
        userId: _lastKnownUserId,
        requestId: requestId,
      );
    } catch (e) {
      if (!_isRequestStillValid(requestId)) {
        return;
      }

      _errorMessage = e.toString();
      _items = [];
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

  void _primeCommentCountsFromItems(List<FeedItem> items) {
    for (final item in items) {
      final post = item.post;
      if (post == null) {
        continue;
      }

      _commentCounts[_postId(post)] = item.commentCount;
    }
  }

  Future<void> _loadReactionSummariesForPostItems(
    List<FeedItem> items, {
    required String? userId,
    required int requestId,
  }) async {
    final postItems = items
        .where((item) => item.isPost && item.post != null)
        .toList(growable: false);

    if (postItems.isEmpty) {
      return;
    }

    final targets = postItems.map((item) => item.targetRef).toList(growable: false);

    final summaries = await _getReactionSummary(
      targets,
      userId: userId,
    );

    if (!_isRequestStillValid(requestId)) {
      return;
    }

    for (final summary in summaries) {
      _reactionSummaries[summary.target.key] = summary;
    }
  }

  Future<void> refreshCommentCountForPost(Post post) async {
    if (!_containsPost(post)) {
      return;
    }

    try {
      final count = await _getCommentCountForTarget(_targetForPost(post));
      if (_isDisposed || !_containsPost(post)) {
        return;
      }

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

      if (_isDisposed || !_containsPost(post)) {
        return;
      }

      if (summaries.isNotEmpty) {
        _reactionSummaries[_targetForPost(post).key] = summaries.first;
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

      if (_isDisposed || !_containsPost(post)) {
        return;
      }

      final summaries = results[0] as List<ReactionSummary>;
      final commentCount = results[1] as int;

      if (summaries.isNotEmpty) {
        _reactionSummaries[_targetForPost(post).key] = summaries.first;
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

    if (_isDisposed || !_containsPost(post)) {
      return;
    }

    _reactionSummaries[target.key] = summary;
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

    if (_isDisposed || !_containsPost(post)) {
      return;
    }

    _reactionSummaries[target.key] = summary;
    _lastKnownUserId = userId;
    _safeNotifyListeners();
  }

  void clear() {
    _items = [];
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
    if (_isDisposed) {
      return;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}