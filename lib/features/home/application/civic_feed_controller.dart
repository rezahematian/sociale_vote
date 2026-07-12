import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/news/entities/news_item.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';

import 'package:sociale_vote/features/home/application/feed_item.dart';

typedef PollLoader = Future<List<Poll>> Function(GeoScope? scope);
typedef NewsLoader = Future<List<NewsItem>> Function(GeoScope? scope);
typedef PostLoader = Future<List<Post>> Function(GeoScope? scope);

typedef PollIdReader = String Function(Poll poll);
typedef NewsIdReader = String Function(NewsItem news);
typedef PostIdReader = String Function(Post post);

typedef PollCreatedAtReader = DateTime Function(Poll poll);
typedef NewsCreatedAtReader = DateTime Function(NewsItem news);
typedef PostCreatedAtReader = DateTime Function(Post post);

typedef PollTargetRefReader = TargetRef Function(Poll poll);
typedef NewsTargetRefReader = TargetRef Function(NewsItem news);
typedef PostTargetRefReader = TargetRef Function(Post post);

typedef ReactionCountLoader = Future<int> Function(TargetRef targetRef);
typedef CommentCountLoader = Future<int> Function(TargetRef targetRef);

class CivicFeedController extends ChangeNotifier {
  final PollLoader _loadPolls;
  final NewsLoader _loadNews;
  final PostLoader _loadPosts;

  final PollIdReader _readPollId;
  final NewsIdReader _readNewsId;
  final PostIdReader _readPostId;

  final PollCreatedAtReader _readPollCreatedAt;
  final NewsCreatedAtReader _readNewsCreatedAt;
  final PostCreatedAtReader _readPostCreatedAt;

  final PollTargetRefReader _readPollTargetRef;
  final NewsTargetRefReader _readNewsTargetRef;
  final PostTargetRefReader _readPostTargetRef;

  final ReactionCountLoader? _loadReactionCount;
  final CommentCountLoader? _loadCommentCount;

  CivicFeedController({
    required PollLoader loadPolls,
    required NewsLoader loadNews,
    required PostLoader loadPosts,
    required PollIdReader readPollId,
    required NewsIdReader readNewsId,
    required PostIdReader readPostId,
    required PollCreatedAtReader readPollCreatedAt,
    required NewsCreatedAtReader readNewsCreatedAt,
    required PostCreatedAtReader readPostCreatedAt,
    required PollTargetRefReader readPollTargetRef,
    required NewsTargetRefReader readNewsTargetRef,
    required PostTargetRefReader readPostTargetRef,
    ReactionCountLoader? loadReactionCount,
    CommentCountLoader? loadCommentCount,
  })  : _loadPolls = loadPolls,
        _loadNews = loadNews,
        _loadPosts = loadPosts,
        _readPollId = readPollId,
        _readNewsId = readNewsId,
        _readPostId = readPostId,
        _readPollCreatedAt = readPollCreatedAt,
        _readNewsCreatedAt = readNewsCreatedAt,
        _readPostCreatedAt = readPostCreatedAt,
        _readPollTargetRef = readPollTargetRef,
        _readNewsTargetRef = readNewsTargetRef,
        _readPostTargetRef = readPostTargetRef,
        _loadReactionCount = loadReactionCount,
        _loadCommentCount = loadCommentCount;

  final List<FeedItem> _items = [];

  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  GeoScope? _currentScope;

  bool _isDisposed = false;
  int _feedOperationId = 0;

  List<FeedItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  GeoScope? get currentScope => _currentScope;
  bool get isEmpty => _items.isEmpty && !_isLoading;

  Future<void> load({GeoScope? scope}) async {
    if (_isDisposed) return;

    final operationId = ++_feedOperationId;

    _currentScope = scope;
    _isLoading = true;
    _isRefreshing = false;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final items = await _buildFeed(scope: scope);

      if (!_isOperationCurrent(operationId)) {
        return;
      }

      _items
        ..clear()
        ..addAll(items);
    } catch (error) {
      if (_isOperationCurrent(operationId)) {
        _errorMessage = error.toString();
        _items.clear();
      }
    } finally {
      if (_isOperationCurrent(operationId)) {
        _isLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  Future<void> refresh() async {
    if (_isDisposed) return;

    final operationId = ++_feedOperationId;
    final scope = _currentScope;

    _isLoading = false;
    _isRefreshing = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final items = await _buildFeed(scope: scope);

      if (!_isOperationCurrent(operationId)) {
        return;
      }

      _items
        ..clear()
        ..addAll(items);
    } catch (error) {
      if (_isOperationCurrent(operationId)) {
        _errorMessage = error.toString();
      }
    } finally {
      if (_isOperationCurrent(operationId)) {
        _isRefreshing = false;
        _safeNotifyListeners();
      }
    }
  }

  Future<void> reloadForScope(GeoScope? scope) async {
    await load(scope: scope);
  }

  bool _isOperationCurrent(int operationId) {
    return !_isDisposed && operationId == _feedOperationId;
  }

  void _safeNotifyListeners() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _feedOperationId++;
    super.dispose();
  }

  Future<List<FeedItem>> _buildFeed({GeoScope? scope}) async {
    final results = await Future.wait<dynamic>([
      _loadPolls(scope),
      _loadNews(scope),
      _loadPosts(scope),
    ]);

    final polls = (results[0] as List<Poll>);
    final newsList = (results[1] as List<NewsItem>);
    final posts = (results[2] as List<Post>);

    final feedItems = <FeedItem>[
      ...polls.map(_mapPollToFeedItem),
      ...newsList.map(_mapNewsToFeedItem),
      ...posts.map(_mapPostToFeedItem),
    ];

    final enriched = await _enrichMetrics(feedItems);
    enriched.sort((a, b) => b.rankingScore.compareTo(a.rankingScore));
    return enriched;
  }

  FeedItem _mapPollToFeedItem(Poll poll) {
    return FeedItem.poll(
      id: _readPollId(poll),
      targetRef: _readPollTargetRef(poll),
      createdAt: _readPollCreatedAt(poll),
      poll: poll,
    );
  }

  FeedItem _mapNewsToFeedItem(NewsItem news) {
    return FeedItem.news(
      id: _readNewsId(news),
      targetRef: _readNewsTargetRef(news),
      createdAt: _readNewsCreatedAt(news),
      news: news,
    );
  }

  FeedItem _mapPostToFeedItem(Post post) {
    return FeedItem.post(
      id: _readPostId(post),
      targetRef: _readPostTargetRef(post),
      createdAt: _readPostCreatedAt(post),
      post: post,
    );
  }

  Future<List<FeedItem>> _enrichMetrics(List<FeedItem> items) async {
    final enriched = <FeedItem>[];

    for (final item in items) {
      final reactionCount = await _safeLoadReactionCount(item.targetRef);
      final commentCount = await _safeLoadCommentCount(item.targetRef);
      final rankingScore = _computeRankingScore(
        reactionCount: reactionCount,
        commentCount: commentCount,
        createdAt: item.createdAt,
      );

      enriched.add(
        item.copyWith(
          reactionCount: reactionCount,
          commentCount: commentCount,
          rankingScore: rankingScore,
        ),
      );
    }

    return enriched;
  }

  Future<int> _safeLoadReactionCount(TargetRef targetRef) async {
    if (_loadReactionCount == null) {
      return 0;
    }

    try {
      return await _loadReactionCount(targetRef);
    } catch (_) {
      return 0;
    }
  }

  Future<int> _safeLoadCommentCount(TargetRef targetRef) async {
    if (_loadCommentCount == null) {
      return 0;
    }

    try {
      return await _loadCommentCount(targetRef);
    } catch (_) {
      return 0;
    }
  }

  double _computeRankingScore({
    required int reactionCount,
    required int commentCount,
    required DateTime createdAt,
  }) {
    final now = DateTime.now();
    final ageHours = math.max(
      0,
      now.difference(createdAt).inHours,
    );

    final recencyWeight = math
        .max(
          0,
          72 - ageHours,
        )
        .toDouble();

    return (reactionCount * 2) + commentCount + recencyWeight;
  }
}
