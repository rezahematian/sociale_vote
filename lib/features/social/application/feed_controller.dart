import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:sociale_vote/app/di.dart';
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
        _getCommentCountForTarget = getCommentCountForTarget {
    _geoScopeController.addListener(_handleScopeChanged);
  }

  bool _isLoading = false;
  bool _isPreparingHottest = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _isDisposed = false;

  /// Incrementato a ogni caricamento completo.
  /// I risultati appartenenti a richieste precedenti vengono ignorati.
  int _requestGeneration = 0;

  /// Post caricati finora (aggregato delle pagine).
  final List<Post> _posts = <Post>[];

  /// Ordine sorgente stabile, utile sia per latest sia come tie-break hottest.
  final Map<String, int> _sourceOrderByPostId = <String, int>{};
  int _nextSourceOrder = 0;

  /// Reaction summary per postId.
  final Map<String, ReactionSummary> _reactionSummaries =
      <String, ReactionSummary>{};

  /// Comment count per postId.
  final Map<String, int> _commentCounts = <String, int>{};

  /// Paging reale.
  static const int _pageSize = 10;
  int _currentOffset = 0;
  bool _hasMoreFromSource = true;

  /// Ultimo userId usato per caricare i ReactionSummary.
  String? _lastKnownUserId;

  /// Modalità di ordinamento corrente per il feed.
  FeedSortMode _sortMode = FeedSortMode.hottest;

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
    _notifyListeners();

    if (mode == FeedSortMode.hottest && _hasMoreFromSource) {
      unawaited(_loadAllRemainingPostsForHottest());
    }
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

  String _targetBatchKey(TargetRef target) {
    return '${target.type.name}|${target.id.trim()}';
  }

  bool _containsPost(Post post) {
    final postId = _postId(post);
    return _posts.any((item) => item.id.value == postId);
  }

  int _fireCountForPost(Post post) {
    final summary = summaryForPost(post);
    if (summary == null) return 0;
    return summary.likeCount;
  }

  int _sourceOrderForPost(Post post) {
    return _sourceOrderByPostId[_postId(post)] ?? (1 << 30);
  }

  int _comparePostPriority(Post a, Post b) {
    final fireCompare = _fireCountForPost(b).compareTo(_fireCountForPost(a));
    if (fireCompare != 0) {
      return fireCompare;
    }

    final commentCompare =
        commentCountForPost(b).compareTo(commentCountForPost(a));
    if (commentCompare != 0) {
      return commentCompare;
    }

    return _sourceOrderForPost(a).compareTo(_sourceOrderForPost(b));
  }

  // ===== CARICAMENTO FEED (PAGINAZIONE REALE) =====

  /// Carica la prima pagina di feed per lo scope corrente.
  ///
  /// [userId] è opzionale:
  /// - se presente → GetReactionSummary può valorizzare anche userReaction
  /// - se nullo   → avremo solo i count globali (no stato utente)
  Future<void> loadFeed({String? userId}) async {
    final generation = ++_requestGeneration;

    _isLoading = true;
    _hasError = false;
    _errorMessage = null;

    _posts.clear();
    _sourceOrderByPostId.clear();
    _nextSourceOrder = 0;
    _reactionSummaries.clear();
    _commentCounts.clear();
    _currentOffset = 0;
    _hasMoreFromSource = true;
    _lastKnownUserId = userId ?? _lastKnownUserId;

    _notifyListeners();

    try {
      _isPreparingHottest = _sortMode == FeedSortMode.hottest;

      await _loadNextPage(generation: generation);

      while (_isCurrentRequest(generation) &&
          _sortMode == FeedSortMode.hottest &&
          _hasMoreFromSource) {
        await _loadNextPage(generation: generation);
      }

      if (_isCurrentRequest(generation)) {
        _sortPosts();
      }
    } catch (e, stackTrace) {
      if (!_isCurrentRequest(generation)) {
        return;
      }

      _hasError = true;
      _errorMessage = 'Impossibile caricare il feed.';
      _posts.clear();
      _sourceOrderByPostId.clear();
      _reactionSummaries.clear();
      _commentCounts.clear();
      _currentOffset = 0;
      _hasMoreFromSource = false;

      if (kDebugMode) {
        debugPrint('Error loading feed: $e');
        debugPrint('$stackTrace');
      }
    } finally {
      _isPreparingHottest = false;
      if (_isCurrentRequest(generation)) {
        _setLoading(false);
      }
    }
  }

  /// Ricarica il feed da zero.
  Future<void> refresh({String? userId}) async {
    await loadFeed(userId: userId);
  }

  /// Carica la pagina successiva del feed, se disponibile.
  Future<void> loadMorePosts() async {
    if (_isDisposed || _isLoading || !_hasMoreFromSource) {
      return;
    }

    final generation = _requestGeneration;
    _setLoading(true);

    try {
      await _loadNextPage(generation: generation);
    } catch (e, stackTrace) {
      if (!_isCurrentRequest(generation)) {
        return;
      }

      // Un errore transitorio di paginazione non deve sostituire
      // i post già visibili con una schermata di errore globale.
      _hasError = _posts.isEmpty;
      _errorMessage = _posts.isEmpty
          ? 'Impossibile caricare il feed.'
          : 'Impossibile caricare altri post.';

      if (kDebugMode) {
        debugPrint('Error loading more posts: $e');
        debugPrint('$stackTrace');
      }

      _notifyListeners();
    } finally {
      if (_isCurrentRequest(generation)) {
        _setLoading(false);
      }
    }
  }

  Future<void> _loadAllRemainingPostsForHottest() async {
    if (_isDisposed || _isLoading || !_hasMoreFromSource) {
      return;
    }

    final generation = _requestGeneration;
    _isPreparingHottest = true;
    _setLoading(true);

    try {
      while (_isCurrentRequest(generation) &&
          _sortMode == FeedSortMode.hottest &&
          _hasMoreFromSource) {
        await _loadNextPage(generation: generation);
      }

      if (_isCurrentRequest(generation)) {
        _sortPosts();
      }
    } catch (e, stackTrace) {
      if (!_isCurrentRequest(generation)) {
        return;
      }

      _hasError = _posts.isEmpty;
      _errorMessage = _posts.isEmpty
          ? 'Impossibile caricare il feed.'
          : 'Impossibile completare l’ordinamento dei post più caldi.';

      if (kDebugMode) {
        debugPrint('Error loading remaining hottest posts: $e');
        debugPrint('$stackTrace');
      }
    } finally {
      _isPreparingHottest = false;
      if (_isCurrentRequest(generation)) {
        _setLoading(false);
      }
    }
  }

  Future<void> _loadNextPage({
    required int generation,
  }) async {
    if (!_isCurrentRequest(generation)) {
      return;
    }

    final scope = _geoScopeController.scope;
    final requestedOffset = _currentOffset;

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
      offset: requestedOffset,
    );

    if (!_isCurrentRequest(generation)) {
      return;
    }

    final existingIds = _posts.map(_postId).toSet();
    final pageIds = <String>{};
    final uniquePosts = <Post>[];

    for (final post in result) {
      final postId = _postId(post);
      if (postId.trim().isEmpty) {
        continue;
      }
      if (!existingIds.add(postId)) {
        continue;
      }
      if (!pageIds.add(postId)) {
        continue;
      }

      _sourceOrderByPostId.putIfAbsent(
        postId,
        () => _nextSourceOrder++,
      );
      uniquePosts.add(post);
    }

    _currentOffset = requestedOffset + result.length;

    if (result.length < _pageSize || uniquePosts.isEmpty) {
      _hasMoreFromSource = false;
    }

    _posts.addAll(uniquePosts);
    _hasError = false;
    _errorMessage = null;

    // In modalità latest manteniamo il caricamento progressivo.
    // In modalità hottest pubblichiamo la lista solo dopo avere caricato
    // tutte le pagine, così l'ordine non cambia durante lo scroll.
    _sortPosts();
    if (!_isPreparingHottest) {
      _notifyListeners();
    }

    if (uniquePosts.isEmpty) {
      return;
    }

    await Future.wait<void>([
      _loadReactionSummariesForPosts(
        uniquePosts,
        generation: generation,
        userId: _lastKnownUserId,
      ),
      _loadCommentCountsForPosts(
        uniquePosts,
        generation: generation,
      ),
    ]);

    if (!_isCurrentRequest(generation)) {
      return;
    }

    _sortPosts();
    if (!_isPreparingHottest) {
      _notifyListeners();
    }
  }

  Future<void> _loadReactionSummariesForPosts(
    List<Post> posts, {
    required int generation,
    String? userId,
  }) async {
    if (posts.isEmpty || !_isCurrentRequest(generation)) {
      return;
    }

    try {
      final targets = posts.map(_targetForPost).toList(growable: false);
      final summaries = await _getReactionSummary(
        targets,
        userId: userId,
      );

      if (!_isCurrentRequest(generation)) {
        return;
      }

      for (final summary in summaries) {
        _reactionSummaries[summary.target.id] = summary;
      }
    } catch (e, stackTrace) {
      // I dati di engagement sono secondari:
      // un loro errore non deve nascondere il feed principale.
      if (kDebugMode) {
        debugPrint('Error loading feed reaction summaries: $e');
        debugPrint('$stackTrace');
      }
    }
  }

  Future<void> _loadCommentCountsForPosts(
    List<Post> posts, {
    required int generation,
  }) async {
    if (posts.isEmpty || !_isCurrentRequest(generation)) {
      return;
    }

    try {
      final targets = posts.map(_targetForPost).toList(growable: false);
      final batchCounts =
          await AppDI.instance.commentRepository.countCommentsForTargets(
        targets,
      );

      if (!_isCurrentRequest(generation)) {
        return;
      }

      for (final post in posts) {
        final target = _targetForPost(post);
        final batchKey = _targetBatchKey(target);
        _commentCounts[_postId(post)] = batchCounts[batchKey] ?? 0;
      }
    } catch (e, stackTrace) {
      // Il conteggio commenti è secondario:
      // il feed resta utilizzabile anche se il batch fallisce.
      if (kDebugMode) {
        debugPrint('Error loading feed comment counts: $e');
        debugPrint('$stackTrace');
      }
    }
  }

  Future<void> refreshCommentCountForPost(Post post) async {
    if (_isDisposed || !_containsPost(post)) {
      return;
    }

    try {
      final count = await _getCommentCountForTarget(_targetForPost(post));

      if (_isDisposed || !_containsPost(post)) {
        return;
      }

      _commentCounts[_postId(post)] = count;

      if (_sortMode == FeedSortMode.hottest) {
        _sortPosts();
      }

      _notifyListeners();
    } catch (_) {
      // Refresh puntuale: manteniamo il valore corrente senza rompere il feed.
    }
  }

  Future<void> refreshReactionSummaryForPost(Post post) async {
    if (_isDisposed || !_containsPost(post)) {
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
        _reactionSummaries[_postId(post)] = summaries.first;

        if (_sortMode == FeedSortMode.hottest) {
          _sortPosts();
        }

        _notifyListeners();
      }
    } catch (_) {
      // Refresh puntuale: manteniamo lo stato corrente senza errori globali.
    }
  }

  Future<void> refreshEngagementForPost(Post post) async {
    if (_isDisposed || !_containsPost(post)) {
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
        _reactionSummaries[_postId(post)] = summaries.first;
      }
      _commentCounts[_postId(post)] = commentCount;

      if (_sortMode == FeedSortMode.hottest) {
        _sortPosts();
      }

      _notifyListeners();
    } catch (_) {
      // Nessun errore globale sul feed per refresh locale fallito.
    }
  }

  // ===== SORTING =====

  /// Ordina la lista interna in base a [_sortMode].
  void _sortPosts() {
    if (_posts.isEmpty) return;

    switch (_sortMode) {
      case FeedSortMode.latest:
        _posts.sort(
          (a, b) => _sourceOrderForPost(a).compareTo(
            _sourceOrderForPost(b),
          ),
        );
        break;
      case FeedSortMode.hottest:
        _posts.sort(_comparePostPriority);
        break;
    }
  }

  // ===== REAZIONI 🔥 / ❄ =====

  Future<void> toggleFireForPost({
    required String userId,
    required Post post,
  }) async {
    assert(userId.isNotEmpty, 'toggleFireForPost richiede userId valido.');

    final summary = await _toggleReaction(
      userId: userId,
      target: _targetForPost(post),
      type: ReactionType.like,
    );

    if (_isDisposed || !_containsPost(post)) {
      return;
    }

    _reactionSummaries[_postId(post)] = summary;
    _lastKnownUserId = userId;

    if (_sortMode == FeedSortMode.hottest) {
      _sortPosts();
    }

    _notifyListeners();
  }

  Future<void> toggleIceForPost({
    required String userId,
    required Post post,
  }) async {
    assert(userId.isNotEmpty, 'toggleIceForPost richiede userId valido.');

    final summary = await _toggleReaction(
      userId: userId,
      target: _targetForPost(post),
      type: ReactionType.dislike,
    );

    if (_isDisposed || !_containsPost(post)) {
      return;
    }

    _reactionSummaries[_postId(post)] = summary;
    _lastKnownUserId = userId;

    if (_sortMode == FeedSortMode.hottest) {
      _sortPosts();
    }

    _notifyListeners();
  }

  void _handleScopeChanged() {
    if (_isDisposed) {
      return;
    }

    unawaited(
      loadFeed(userId: _lastKnownUserId),
    );
  }

  bool _isCurrentRequest(int generation) {
    return !_isDisposed && generation == _requestGeneration;
  }

  void _setLoading(bool value) {
    if (_isDisposed || _isLoading == value) {
      return;
    }

    _isLoading = value;
    _notifyListeners();
  }

  void _notifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _requestGeneration++;
    _geoScopeController.removeListener(_handleScopeChanged);
    super.dispose();
  }
}
