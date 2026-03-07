import 'package:flutter/foundation.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/content/social/usecases/get_post_detail.dart';
import 'package:sociale_vote/domain/engagement/entities/reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/usecases/get_reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/usecases/toggle_reaction.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';

/// Controller applicativo per la pagina di dettaglio di un post.
///
/// Responsabilità:
/// - caricare il post tramite [GetPostDetail]
/// - gestire le reazioni (🔥 / ❄) tramite [ToggleReaction]
/// - caricare e mantenere il [ReactionSummary] del post
/// - esporre uno stato semplice per la UI (loading / error / post + summary)
class PostDetailController extends ChangeNotifier {
  final String _postId;
  final GetPostDetail _getPostDetail;
  final ToggleReaction _toggleReaction;
  final GetReactionSummary _getReactionSummary;

  PostDetailController({
    required String postId,
    required GetPostDetail getPostDetail,
    required ToggleReaction toggleReaction,
    required GetReactionSummary getReactionSummary,
  })  : _postId = postId,
        _getPostDetail = getPostDetail,
        _toggleReaction = toggleReaction,
        _getReactionSummary = getReactionSummary;

  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  Post? _post;
  ReactionSummary? _reactionSummary;

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  Post? get post => _post;
  ReactionSummary? get reactionSummary => _reactionSummary;

  /// Conteggio like (🔥) per il post corrente.
  int get likeCount => _reactionSummary?.likeCount ?? 0;

  /// Conteggio dislike (❄) per il post corrente.
  int get dislikeCount => _reactionSummary?.dislikeCount ?? 0;

  /// Reazione corrente dell'utente (se presente).
  ReactionType? get userReaction => _reactionSummary?.userReaction;

  String get postId => _postId;

  String _postIdFromPost(Post post) {
    // Coerente con FeedController: usiamo post.id.value.
    return post.id.value;
  }

  TargetRef _targetForPost(Post post) {
    return TargetRef.post(_postIdFromPost(post));
  }

  /// Carica il dettaglio del post + il relativo summary delle reazioni.
  ///
  /// Tipicamente chiamato da initState della PostDetailPage:
  ///   controller.load();
  Future<void> load() async {
    _setLoading(true);

    try {
      final result = await _getPostDetail(_postId);

      if (result == null) {
        _hasError = true;
        _errorMessage = 'Post non trovato.';
        _post = null;
        _reactionSummary = null;
        return;
      }

      _post = result;
      _hasError = false;
      _errorMessage = null;

      await _loadReactionSummaryForPost(result);
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Impossibile caricare il post.';
      _post = null;
      _reactionSummary = null;
    } finally {
      _setLoading(false);
    }
  }

  /// Forza il ricaricamento del dettaglio (es. pull-to-refresh).
  Future<void> refresh() async {
    await load();
  }

  /// Toggle 🔥 (like) per il post corrente.
  ///
  /// Richiede [userId] NON vuoto (solo utenti registrati).
  Future<void> toggleFire({
    required String userId,
  }) async {
    if (userId.isEmpty) {
      // v1: la UI dovrebbe intercettare e mandare al login, qui non facciamo nulla.
      return;
    }

    final currentPost = _post;
    if (currentPost == null) {
      // Se per qualche motivo il post non è caricato, non facciamo nulla.
      return;
    }

    final target = _targetForPost(currentPost);

    final summary = await _toggleReaction(
      userId: userId,
      target: target,
      type: ReactionType.like,
    );

    _reactionSummary = summary;
    notifyListeners();
  }

  /// Toggle ❄ (dislike) per il post corrente.
  ///
  /// Richiede [userId] NON vuoto (solo utenti registrati).
  Future<void> toggleIce({
    required String userId,
  }) async {
    if (userId.isEmpty) {
      // v1: la UI dovrebbe intercettare e mandare al login, qui non facciamo nulla.
      return;
    }

    final currentPost = _post;
    if (currentPost == null) {
      // Se per qualche motivo il post non è caricato, non facciamo nulla.
      return;
    }

    final target = _targetForPost(currentPost);

    final summary = await _toggleReaction(
      userId: userId,
      target: target,
      type: ReactionType.dislike,
    );

    _reactionSummary = summary;
    notifyListeners();
  }

  Future<void> _loadReactionSummaryForPost(Post post) async {
    // Riutilizziamo lo stesso use case usato nel feed,
    // passando una lista con un solo target.
    final target = _targetForPost(post);
    final summaries = await _getReactionSummary(<TargetRef>[target]);

    if (summaries.isEmpty) {
      _reactionSummary = null;
      return;
    }

    // Cerchiamo il summary che corrisponde esattamente a questo post.
    final postId = _postIdFromPost(post);
    _reactionSummary = summaries.firstWhere(
      (s) => s.target.id == postId,
      orElse: () => summaries.first,
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}