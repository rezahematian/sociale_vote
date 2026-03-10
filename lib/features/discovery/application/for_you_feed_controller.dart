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

/// Controller applicativo per il feed "For You".
///
/// Responsabilità:
/// - leggere lo scope corrente da [GeoScopeController]
/// - chiamare il use case [GetForYouFeed]
/// - esporre lo stato (lista post + loading + eventuale errore)
/// - gestire reaction summary per i post
/// - gestire conteggio commenti per i post
/// - gestire toggle reazioni 🔥 / ❄
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

  /// Lista dei post nel feed "For You".
  List<Post> _posts = [];
  List<Post> get posts => List.unmodifiable(_posts);

  /// Stato di caricamento.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Eventuale messaggio di errore (solo per debug/logging UI).
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Comodo per la UI: true se c'è un errore significativo.
  bool get hasError => _errorMessage != null && _errorMessage!.isNotEmpty;

  /// Reaction summary per postId.
  final Map<String, ReactionSummary> _reactionSummaries =
      <String, ReactionSummary>{};

  /// Comment count per postId.
  final Map<String, int> _commentCounts = <String, int>{};

  /// Ultimo userId usato per caricare i ReactionSummary.
  String? _lastKnownUserId;

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

  /// Carica il feed "For You" per l'utente corrente.
  ///
  /// - [userId]: può essere null (guest)
  /// - usa sempre lo [GeoScope] corrente letto dal [GeoScopeController]
  /// - [limit]: massimo numero di post da restituire
  Future<void> load({
    required String? userId,
    int limit = 10,
  }) async {
    final GeoScope scope = _geoScopeController.scope;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _lastKnownUserId = userId ?? _lastKnownUserId;
    _reactionSummaries.clear();
    _commentCounts.clear();

    try {
      final result = await _getForYouFeed(
        userId: userId,
        currentScope: scope,
        limit: limit,
      );

      _posts = result;

      await _loadReactionSummariesForPosts(
        result,
        userId: _lastKnownUserId,
      );

      await _loadCommentCountsForPosts(result);
    } catch (e, _) {
      _errorMessage = e.toString();
      _posts = [];
      _reactionSummaries.clear();
      _commentCounts.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadReactionSummariesForPosts(
    List<Post> posts, {
    String? userId,
  }) async {
    if (posts.isEmpty) {
      return;
    }

    final targets = posts.map(_targetForPost).toList();

    final summaries = await _getReactionSummary(
      targets,
      userId: userId,
    );

    for (final summary in summaries) {
      _reactionSummaries[summary.target.id] = summary;
    }
  }

  Future<void> _loadCommentCountsForPosts(List<Post> posts) async {
    if (posts.isEmpty) {
      return;
    }

    for (final post in posts) {
      final count = await _getCommentCountForTarget(_targetForPost(post));
      _commentCounts[_postId(post)] = count;
    }
  }

  Future<void> toggleFireForPost({
    required String userId,
    required Post post,
  }) async {
    assert(userId.isNotEmpty,
        'toggleFireForPost richiede userId valido.');

    final target = _targetForPost(post);

    final summary = await _toggleReaction(
      userId: userId,
      target: target,
      type: ReactionType.like,
    );

    _reactionSummaries[_postId(post)] = summary;
    notifyListeners();
  }

  Future<void> toggleIceForPost({
    required String userId,
    required Post post,
  }) async {
    assert(userId.isNotEmpty,
        'toggleIceForPost richiede userId valido.');

    final target = _targetForPost(post);

    final summary = await _toggleReaction(
      userId: userId,
      target: target,
      type: ReactionType.dislike,
    );

    _reactionSummaries[_postId(post)] = summary;
    notifyListeners();
  }

  /// Svuota lo stato corrente (utile in caso di logout o reset esplicito).
  void clear() {
    _posts = [];
    _isLoading = false;
    _errorMessage = null;
    _reactionSummaries.clear();
    _commentCounts.clear();
    notifyListeners();
  }
}