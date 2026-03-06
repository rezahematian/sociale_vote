import 'package:flutter/foundation.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/discussion/entities/comment.dart';
import 'package:sociale_vote/domain/discussion/usecases/add_comment.dart';
import 'package:sociale_vote/domain/discussion/usecases/get_comments_for_target.dart';

/// Controller applicativo generico per la discussione (commenti)
/// associata a un qualsiasi contenuto identificato da [TargetRef].
///
/// Utilizzi previsti:
/// - NewsDetailPage (TargetRef.news)
/// - PollDetailPage (TargetRef.poll)
/// - in futuro: PostDetailPage, VideoDetailPage, ecc.
class DiscussionController extends ChangeNotifier {
  final TargetRef target;
  final AddComment _addComment;
  final GetCommentsForTarget _getCommentsForTarget;

  DiscussionController({
    required this.target,
    required AddComment addComment,
    required GetCommentsForTarget getCommentsForTarget,
  })  : _addComment = addComment,
        _getCommentsForTarget = getCommentsForTarget;

  List<Comment> _comments = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<Comment> get comments => List.unmodifiable(_comments);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  bool get hasComments => _comments.isNotEmpty;

  /// Commenti root (depth == 0 oppure parentId == null).
  List<Comment> get rootComments {
    return _comments
        .where((c) => c.parentId == null || c.depth == 0)
        .toList()
      ..sort(
        (a, b) => a.createdAt.compareTo(b.createdAt),
      );
  }

  /// Reply per un commento root specifico.
  List<Comment> repliesFor(String parentId) {
    return _comments
        .where((c) => c.parentId == parentId)
        .toList()
      ..sort(
        (a, b) => a.createdAt.compareTo(b.createdAt),
      );
  }

  /// Carica tutti i commenti per il [target] configurato.
  Future<void> loadComments() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _getCommentsForTarget(target);
      _comments = List<Comment>.from(result)
        ..sort(
          (a, b) => a.createdAt.compareTo(b.createdAt),
        );
    } catch (e) {
      // Per ora messaggio generico; eventualmente log esterno.
      _errorMessage = 'Impossibile caricare i commenti.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Aggiunge un nuovo commento root (depth 0).
  Future<void> addRootComment({
    required String userId,
    required String content,
  }) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      return;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newComment = await _addComment(
        userId: userId,
        target: target,
        content: trimmed,
        parentId: null,
      );

      _comments = List<Comment>.from(_comments)..add(newComment);
      _comments.sort(
        (a, b) => a.createdAt.compareTo(b.createdAt),
      );
    } catch (e) {
      _errorMessage = 'Impossibile aggiungere il commento.';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Aggiunge una reply a un commento esistente.
  ///
  /// v1: supporto depth 0/1
  /// - se [parent] è root → reply (depth 1)
  /// - se [parent] è già reply → niente nesting ulteriore (opzione: blocco soft)
  Future<void> replyToComment({
    required String userId,
    required Comment parent,
    required String content,
  }) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      return;
    }

    // v1: niente nesting oltre depth 1
    if (parent.parentId != null && parent.depth >= 1) {
      // Possiamo semplicemente ignorare o impostare un errore soft.
      _errorMessage = 'Le risposte nidificate oltre un livello non sono supportate.';
      notifyListeners();
      return;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final reply = await _addComment(
        userId: userId,
        target: target,
        content: trimmed,
        parentId: parent.id,
      );

      _comments = List<Comment>.from(_comments)..add(reply);
      _comments.sort(
        (a, b) => a.createdAt.compareTo(b.createdAt),
      );
    } catch (e) {
      _errorMessage = 'Impossibile aggiungere la risposta.';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Elimina un commento (e le sue reply immediate) dalla discussione.
  ///
  /// v1:
  /// - operazione solo in-memory sul controller
  /// - niente chiamata a repository / backend
  /// - pensata per repo in-memory; in futuro potremo aggiungere un use case `DeleteComment`.
  Future<void> deleteComment(Comment comment) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final id = comment.id;

      // Rimuove il commento e le sue reply (depth 1).
      _comments = _comments
          .where((c) => c.id != id && c.parentId != id)
          .toList()
        ..sort(
          (a, b) => a.createdAt.compareTo(b.createdAt),
        );
    } catch (e) {
      _errorMessage = 'Impossibile eliminare il commento.';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Utility per resettare un eventuale messaggio di errore
  /// dopo che la UI l'ha mostrato.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}