import 'package:flutter/foundation.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/discussion/entities/comment.dart';
import 'package:sociale_vote/domain/discussion/usecases/get_comments_for_target.dart';
import 'package:sociale_vote/domain/discussion/usecases/update_comment.dart';

enum CommentSortOrder {
  oldestFirst,
  newestFirst,
}

typedef SubmitComment = Future<Comment> Function({
  required String userId,
  required TargetRef target,
  required String content,
  String? parentId,
});

class DiscussionController extends ChangeNotifier {
  final TargetRef target;
  final SubmitComment _addComment;
  final GetCommentsForTarget _getCommentsForTarget;
  final UpdateComment _updateComment;
  final VoidCallback? onCommentsChanged;

  DiscussionController({
    required this.target,
    required SubmitComment addComment,
    required GetCommentsForTarget getCommentsForTarget,
    required UpdateComment updateComment,
    this.onCommentsChanged,
  })  : _addComment = addComment,
        _getCommentsForTarget = getCommentsForTarget,
        _updateComment = updateComment;

  List<Comment> _comments = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  CommentSortOrder _sortOrder = CommentSortOrder.oldestFirst;

  static const int _defaultPageSize = 10;
  int _pageSize = _defaultPageSize;
  int _visibleRootCount = _defaultPageSize;

  List<Comment> get comments => List.unmodifiable(_comments);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  bool get hasComments => _comments.isNotEmpty;
  CommentSortOrder get sortOrder => _sortOrder;
  int get pageSize => _pageSize;

  bool get hasMoreRootComments {
    final totalRoots = _allRootCommentsCount();
    return _visibleRootCount < totalRoots;
  }

  void setSortOrder(CommentSortOrder order) {
    if (_sortOrder == order) return;
    _sortOrder = order;
    notifyListeners();
  }

  List<Comment> get rootComments {
    final roots = _allRootCommentsSorted();
    final visible = roots.take(_visibleRootCount).toList();
    return visible;
  }

  List<Comment> repliesFor(String parentId) {
    final replies = _comments.where((c) => c.parentId == parentId).toList()
      ..sort(_compareByCreatedAt);
    return replies;
  }

  int _compareByCreatedAt(Comment a, Comment b) {
    switch (_sortOrder) {
      case CommentSortOrder.oldestFirst:
        return a.createdAt.compareTo(b.createdAt);
      case CommentSortOrder.newestFirst:
        return b.createdAt.compareTo(a.createdAt);
    }
  }

  List<Comment> _allRootCommentsSorted() {
    return _comments.where((c) => c.parentId == null || c.depth == 0).toList()
      ..sort(_compareByCreatedAt);
  }

  int _allRootCommentsCount() {
    return _comments.where((c) => c.parentId == null || c.depth == 0).length;
  }

  void _notifyCommentsChanged() {
    onCommentsChanged?.call();
  }

  Future<void> loadComments() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _getCommentsForTarget(target);
      _comments = List<Comment>.from(result)..sort(_compareByCreatedAt);

      final totalRoots = _allRootCommentsCount();
      _visibleRootCount = totalRoots < _pageSize ? totalRoots : _pageSize;
    } catch (e) {
      _errorMessage = 'Impossibile caricare i commenti.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadMoreRootComments() {
    final totalRoots = _allRootCommentsCount();
    if (_visibleRootCount >= totalRoots) return;

    _visibleRootCount = (_visibleRootCount + _pageSize).clamp(0, totalRoots);
    notifyListeners();
  }

  Future<void> addRootComment({
    required String userId,
    required String content,
  }) async {
    if (_isSubmitting) return;

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
      _comments.sort(_compareByCreatedAt);

      final totalRoots = _allRootCommentsCount();
      if (_visibleRootCount < _pageSize) {
        _visibleRootCount = totalRoots < _pageSize ? totalRoots : _pageSize;
      } else {
        _visibleRootCount = _visibleRootCount.clamp(0, totalRoots);
      }

      _notifyCommentsChanged();
    } catch (e) {
      _errorMessage = 'Impossibile aggiungere il commento.';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> replyToComment({
    required String userId,
    required Comment parent,
    required String content,
  }) async {
    if (_isSubmitting) return;

    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      return;
    }

    if (parent.parentId != null && parent.depth >= 1) {
      _errorMessage =
          'Le risposte nidificate oltre un livello non sono supportate.';
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
      _comments.sort(_compareByCreatedAt);

      _notifyCommentsChanged();
    } catch (e) {
      _errorMessage = 'Impossibile aggiungere la risposta.';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> editComment({
    required Comment comment,
    required String content,
  }) async {
    if (_isSubmitting) return;

    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      return;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedComment = await _updateComment(
        commentId: comment.id,
        content: trimmed,
      );

      _comments = _comments
          .map((c) => c.id == updatedComment.id ? updatedComment : c)
          .toList()
        ..sort(_compareByCreatedAt);

      _notifyCommentsChanged();
    } catch (e) {
      _errorMessage = 'Impossibile modificare il commento.';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> deleteComment(Comment comment) async {
    if (_isSubmitting) return;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final id = comment.id;

      _comments = _comments.where((c) => c.id != id && c.parentId != id).toList()
        ..sort(_compareByCreatedAt);

      final totalRoots = _allRootCommentsCount();
      _visibleRootCount = _visibleRootCount.clamp(0, totalRoots);

      _notifyCommentsChanged();
    } catch (e) {
      _errorMessage = 'Impossibile eliminare il commento.';
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}