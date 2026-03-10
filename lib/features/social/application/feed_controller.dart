import 'package:flutter/foundation.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/content/social/usecases/get_feed.dart';
import 'package:sociale_vote/domain/discussion/usecases/get_comment_count_for_target.dart';
import 'package:sociale_vote/domain/engagement/entities/reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/usecases/get_reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/usecases/toggle_reaction.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';

/// Modalità di ordinamento per il social feed.
///
/// - [latest]  → usa l'ordine restituito da GetFeed (tipicamente per data)
/// - [hottest] → per "calore" (engagement / reazioni)
enum FeedSortMode {
  latest,
  hottest,
}

/// Controller applicativo per il social feed.
///
/// Responsabilità:
/// - leggere lo scope corrente da [GeoScopeController]
/// - chiamare il use case [GetFeed] con paginazione (limit/offset)
/// - gestire reazioni (🔥 / ❄) tramite [ToggleReaction]
/// - esporre summary delle reazioni per ogni post (conteggi + userReaction)
/// - esporre conteggio commenti per ogni post
/// - esporre stato semplice per la UI (loading / error / lista post)
/// - gestire paginazione reale (loadMorePosts)
///
/// NOTA IMPORTANTE:
/// Questo controller NON gestisce permessi.
/// Il controllo accessi deve avvenire PRIMA (es. tramite AuthGuard).
class FeedController extends ChangeNotifier {
  final GetFeed _getFeed;
  final GeoScopeController _geoScopeController;
  final ToggleReaction _toggleReaction;
  final GetReactionSummary _getReactionSummary;
  final GetCommentCountForTarget _getCommentCountForTarget;

  FeedController({
    required GetFeed getFeed,
    required GeoScopeController geoScopeController,
    required ToggleReaction toggleReaction,
    required GetReactionSummary getReactionSummary,
    required GetCommentCountForTarget getCommentCountForTarget,
  })  : _getFeed = getFeed,
        _geoScopeController = geoScopeController,
        _toggleReaction = toggleReaction,
        _getReactionSummary = getReactionSummary,
        _getCommentCountForTarget = getCommentCountForTarget;

  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  /// Post caricati finora (aggregato delle pagine).
  final List<Post> _posts = <Post>[];

  /// Reaction summary per postId.
  final Map<String, ReactionSummary> _reactionSummaries =
      <String, ReactionSummary>{};

  /// Comment count per postId.
  final Map<String, int> _commentCounts = <String, int>{};

  /// Paging reale (Fase 4.3).
  static const int _pageSize = 10;
  int _currentOffset = 0;
  bool _hasMoreFromSource = true;

  /// Ultimo userId usato per caricare i ReactionSummary.
  String? _lastKnownUserId;

  /// Modalità di ordinamento corrente per il feed.
  FeedSortMode _sortMode = FeedSortMode.latest;

  // ===== GETTER STATO PUBBLICO =====

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;

  /// Tutti i post caricati (già ordinati secondo [_sortMode]).
  List<Post> get posts => List<Post>.unmodifiable(_posts);

  /// True se il backend (o repo) ha ancora altre pagine da fornire.
  bool get hasMoreFromSource => _hasMoreFromSource;

  /// Modalità di ordinamento esposta alla UI.
  FeedSortMode get sortMode => _sortMode;

  // ===== ORDINAMENTO =====

  /// Cambia modalità di ordinamento e riordina la lista in memoria.
  void setSortMode(FeedSortMode mode) {
    if (_sortMode == mode) return;
    _sortMode = mode;
    _sortPosts();
    notifyListeners();
  }

  // ===== REACTION SUMMARY =====

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

  // ===== CARICAMENTO FEED (PAGINAZIONE REALE) =====

  /// Carica la **prima pagina** di feed per lo scope corrente.
  ///
  /// [userId] è opzionale:
  /// - se presente → GetReactionSummary può valorizzare anche userReaction
  /// - se nullo   → avremo solo i count globali (no stato utente)
  Future<void> loadFeed({String? userId}) async {
    _setLoading(true);
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    // Reset stato paging + lista corrente
    _posts.clear();
    _reactionSummaries.clear();
    _commentCounts.clear();
    _currentOffset = 0;
    _hasMoreFromSource = true;
    _lastKnownUserId = userId ?? _lastKnownUserId;

    try {
      await _loadNextPage();
    } catch (e, stackTrace) {
      _hasError = true;
      _errorMessage = 'Impossibile caricare il feed.';
      _posts.clear();
      _reactionSummaries.clear();
      _commentCounts.clear();
      _currentOffset = 0;
      _hasMoreFromSource = false;

      if (kDebugMode) {
        debugPrint('Error loading feed: $e');
        debugPrint('$stackTrace');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Ricarica il feed da zero (shortcut per pull-to-refresh).
  Future<void> refresh({String? userId}) async {
    await loadFeed(userId: userId);
  }

  /// Carica la **pagina successiva** del feed, se disponibile.
  Future<void> loadMorePosts() async {
    if (_isLoading) return;
    if (!_hasMoreFromSource) return;

    _setLoading(true);

    try {
      await _loadNextPage();
    } catch (e, stackTrace) {
      _hasError = true;
      _errorMessage ??= 'Impossibile caricare altri post.';
      _hasMoreFromSource = false;

      if (kDebugMode) {
        debugPrint('Error loading more posts: $e');
        debugPrint('$stackTrace');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadNextPage() async {
    final scope = _geoScopeController.scope;

    String? countryCode;
    String? cityId;

    switch (scope.level) {
      case GeoScopeLevel.world:
        countryCode = null;
        cityId = null;
        break;
      case GeoScopeLevel.country:
        countryCode = scope.countryCode;
        cityId = null;
        break;
      case GeoScopeLevel.city:
        countryCode = scope.countryCode;
        cityId = scope.cityId;
        break;
    }

    final result = await _getFeed(
      countryCode: countryCode,
      cityId: cityId,
      limit: _pageSize,
      offset: _currentOffset,
    );

    if (result.length < _pageSize) {
      _hasMoreFromSource = false;
    }

    _currentOffset += result.length;
    _posts.addAll(result);

    await _loadReactionSummariesForPosts(
      result,
      userId: _lastKnownUserId,
    );

    await _loadCommentCountsForPosts(result);

    _sortPosts();
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

  // ===== HEAT / SORTING =====

  /// Metrica di "calore" per un post, usata in modalità hottest.
  ///
  /// v1: differenza semplice like - dislike.
  /// In futuro qui puoi sostituire con un vero HeatScore (ReactionSummary.heat).
  double _heatForPost(Post post) {
    final summary = summaryForPost(post);
    if (summary == null) return 0;
    final likes = summary.likeCount;
    final dislikes = summary.dislikeCount;
    return (likes - dislikes).toDouble();
  }

  /// Ordina la lista interna _posts in base a [_sortMode].
  void _sortPosts() {
    if (_posts.isEmpty) return;

    switch (_sortMode) {
      case FeedSortMode.latest:
        // Assumiamo che il repository restituisca già i post in ordine
        // di recency (createdAt desc). Non forziamo sort extra.
        break;
      case FeedSortMode.hottest:
        _posts.sort(
          (a, b) => _heatForPost(b).compareTo(_heatForPost(a)),
        );
        break;
    }
  }

  // ===== REAZIONI 🔥 / ❄ =====

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

    if (_sortMode == FeedSortMode.hottest) {
      _sortPosts();
    }

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

    if (_sortMode == FeedSortMode.hottest) {
      _sortPosts();
    }

    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}