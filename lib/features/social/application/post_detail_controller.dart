import 'package:flutter/foundation.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/content/social/usecases/delete_post.dart';
import 'package:sociale_vote/domain/content/social/usecases/get_post_detail.dart';
import 'package:sociale_vote/domain/content/social/usecases/update_post.dart';
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
  final UpdatePost? _updatePost;
  final DeletePost? _deletePost;
  final ToggleReaction _toggleReaction;
  final GetReactionSummary _getReactionSummary;

  PostDetailController({
    required String postId,
    required GetPostDetail getPostDetail,
    UpdatePost? updatePost,
    DeletePost? deletePost,
    required ToggleReaction toggleReaction,
    required GetReactionSummary getReactionSummary,
  })  : _postId = postId,
        _getPostDetail = getPostDetail,
        _updatePost = updatePost,
        _deletePost = deletePost,
        _toggleReaction = toggleReaction,
        _getReactionSummary = getReactionSummary;

  bool _isLoading = false;
  bool _hasError = false;
  bool _isDisposed = false;
  int _loadOperationId = 0;
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
    return post.id.value;
  }

  TargetRef _targetForPost(Post post) {
    return TargetRef.post(_postIdFromPost(post));
  }

  Future<void> load() async {
    if (_isDisposed) {
      return;
    }

    final operationId = ++_loadOperationId;
    _setLoading(true);

    try {
      final result = await _getPostDetail(_postId);

      if (!_isLoadOperationCurrent(operationId)) {
        return;
      }

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

      final summary = await _loadReactionSummaryForPost(result);

      if (!_isLoadOperationCurrent(operationId)) {
        return;
      }

      _reactionSummary = summary;
    } catch (e) {
      if (!_isLoadOperationCurrent(operationId)) {
        return;
      }

      _hasError = true;
      _errorMessage = 'Impossibile caricare il post.';
      _post = null;
      _reactionSummary = null;
    } finally {
      if (_isLoadOperationCurrent(operationId)) {
        _setLoading(false);
      }
    }
  }

  Future<void> refresh() async {
    await load();
  }

  /// Aggiorna il post corrente.
  ///
  /// In questa prima versione supportiamo solo title + content.
  Future<Post> update({
    required String title,
    required String content,
  }) async {
    final currentPost = _post;
    if (currentPost == null) {
      throw Exception('Post non trovato.');
    }

    final updatePost = _updatePost;
    if (updatePost == null) {
      throw Exception('Modifica post non disponibile.');
    }

    final updated = await updatePost(
      postId: currentPost.id.value,
      title: title,
      content: content,
    );

    if (_isDisposed) {
      return updated;
    }

    _post = updated;
    _safeNotifyListeners();
    return updated;
  }

  /// Elimina il post corrente.
  ///
  /// Il controllo owner-only resta lato UI + backend/RLS.
  /// Qui eseguiamo solo il percorso applicativo minimo.
  Future<void> delete() async {
    final currentPost = _post;
    if (currentPost == null) {
      throw Exception('Post non trovato.');
    }

    final deletePost = _deletePost;
    if (deletePost == null) {
      throw Exception('Eliminazione post non disponibile.');
    }

    await deletePost(currentPost.id.value);
  }

  Future<void> toggleFire({
    required String userId,
  }) async {
    if (userId.isEmpty) {
      return;
    }

    final currentPost = _post;
    if (currentPost == null) {
      return;
    }

    final target = _targetForPost(currentPost);

    final summary = await _toggleReaction(
      userId: userId,
      target: target,
      type: ReactionType.like,
    );

    if (_isDisposed) {
      return;
    }

    _reactionSummary = summary;
    _safeNotifyListeners();
  }

  Future<void> toggleIce({
    required String userId,
  }) async {
    if (userId.isEmpty) {
      return;
    }

    final currentPost = _post;
    if (currentPost == null) {
      return;
    }

    final target = _targetForPost(currentPost);

    final summary = await _toggleReaction(
      userId: userId,
      target: target,
      type: ReactionType.dislike,
    );

    if (_isDisposed) {
      return;
    }

    _reactionSummary = summary;
    _safeNotifyListeners();
  }

  Future<ReactionSummary?> _loadReactionSummaryForPost(Post post) async {
    final target = _targetForPost(post);
    final summaries = await _getReactionSummary(<TargetRef>[target]);

    if (summaries.isEmpty) {
      return null;
    }

    final postId = _postIdFromPost(post);
    return summaries.firstWhere(
      (summary) => summary.target.id == postId,
      orElse: () => summaries.first,
    );
  }

  bool _isLoadOperationCurrent(int operationId) {
    return !_isDisposed && operationId == _loadOperationId;
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
    _loadOperationId++;
    super.dispose();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _safeNotifyListeners();
  }
}
