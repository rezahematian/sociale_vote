import 'package:flutter/foundation.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/content/social/usecases/get_feed.dart';
import 'package:sociale_vote/domain/engagement/entities/reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/usecases/get_reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/usecases/toggle_reaction.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';

/// Controller applicativo per il social feed.
///
/// Responsabilità:
/// - leggere lo scope corrente da [GeoScopeController]
/// - chiamare il use case [GetFeed]
/// - gestire reazioni (🔥 / ❄) tramite [ToggleReaction]
/// - esporre summary delle reazioni per ogni post
/// - esporre stato semplice per la UI (loading / error / lista post)
class FeedController extends ChangeNotifier {
  final GetFeed _getFeed;
  final GeoScopeController _geoScopeController;
  final ToggleReaction _toggleReaction;
  final GetReactionSummary _getReactionSummary;

  FeedController({
    required GetFeed getFeed,
    required GeoScopeController geoScopeController,
    required ToggleReaction toggleReaction,
    required GetReactionSummary getReactionSummary,
  })  : _getFeed = getFeed,
        _geoScopeController = geoScopeController,
        _toggleReaction = toggleReaction,
        _getReactionSummary = getReactionSummary;

  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  List<Post> _posts = const [];

  /// Reaction summary per postId (post.id.value).
  Map<String, ReactionSummary> _reactionSummaries =
      const <String, ReactionSummary>{};

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  List<Post> get posts => _posts;

  /// Ritorna il summary per un post, se presente.
  ReactionSummary? summaryForPost(Post post) {
    final postId = _postId(post);
    return _reactionSummaries[postId];
  }

  /// Conteggio like (🔥) per un post.
  int likeCountForPost(Post post) {
    return summaryForPost(post)?.likeCount ?? 0;
  }

  /// Conteggio dislike (❄) per un post.
  int dislikeCountForPost(Post post) {
    return summaryForPost(post)?.dislikeCount ?? 0;
  }

  String _postId(Post post) {
    // Adatta qui se il tuo modello Post è diverso.
    // Se post.id è già una String, puoi fare semplicemente:
    // return post.id;
    return post.id.value;
  }

  TargetRef _targetForPost(Post post) {
    return TargetRef.post(_postId(post));
  }

  /// Carica il feed in base allo scope geografico corrente.
  ///
  /// Usato tipicamente in initState della pagina:
  ///   controller.loadFeed();
  Future<void> loadFeed() async {
    _setLoading(true);

    try {
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
      );

      _posts = result;
      _hasError = false;
      _errorMessage = null;

      // Dopo aver caricato i post, carichiamo i summary delle reazioni.
      await _loadReactionSummariesForPosts(result);
    } catch (e) {
      // v1: gestione errore minimale, niente Failure/Result globale.
      _hasError = true;
      _errorMessage = 'Impossibile caricare il feed.';
      _reactionSummaries = const {};
    } finally {
      _setLoading(false);
    }
  }

  /// Forza un reload (utile per pull-to-refresh).
  Future<void> refresh() async {
    await loadFeed();
  }

  /// Toggle 🔥 per un post (like).
  ///
  /// Richiede userId NON vuoto (solo utenti registrati).
  Future<void> toggleFireForPost({
    required String userId,
    required Post post,
  }) async {
    if (userId.isEmpty) {
      // v1: la UI dovrebbe intercettare e mandare al login, qui non facciamo nulla.
      return;
    }

    final target = _targetForPost(post);

    final summary = await _toggleReaction(
      userId: userId,
      target: target,
      type: ReactionType.like,
    );

    _reactionSummaries[_postId(post)] = summary;
    notifyListeners();
  }

  /// Toggle ❄ per un post (dislike).
  ///
  /// Richiede userId NON vuoto (solo utenti registrati).
  Future<void> toggleIceForPost({
    required String userId,
    required Post post,
  }) async {
    if (userId.isEmpty) {
      // v1: la UI dovrebbe intercettare e mandare al login, qui non facciamo nulla.
      return;
    }

    final target = _targetForPost(post);

    final summary = await _toggleReaction(
      userId: userId,
      target: target,
      type: ReactionType.dislike,
    );

    _reactionSummaries[_postId(post)] = summary;
    notifyListeners();
  }

  Future<void> _loadReactionSummariesForPosts(List<Post> posts) async {
    if (posts.isEmpty) {
      _reactionSummaries = const {};
      return;
    }

    final targets = posts.map(_targetForPost).toList();
    final summaries = await _getReactionSummary(targets);

    final map = <String, ReactionSummary>{};
    for (final summary in summaries) {
      // summary.target.id contiene l’id del post (post.id.value)
      map[summary.target.id] = summary;
    }

    _reactionSummaries = map;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}