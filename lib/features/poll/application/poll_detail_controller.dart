import 'package:flutter/material.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/engagement/entities/reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/usecases/get_reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/usecases/toggle_reaction.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/usecases/delete_poll.dart';
import 'package:sociale_vote/domain/poll/usecases/get_poll_detail.dart';
import 'package:sociale_vote/domain/poll/usecases/update_poll_text.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';

import 'poll_state.dart';

class PollDetailController extends ChangeNotifier {
  final GetPollDetail _getPollDetail;
  final UpdatePollText _updatePollText;
  final DeletePoll _deletePoll;
  final ToggleReaction _toggleReaction;
  final GetReactionSummary _getReactionSummary;

  PollDetailState _state = const PollDetailInitial();
  PollDetailState get state => _state;

  ReactionSummary? _reactionSummary;
  ReactionSummary? get reactionSummary => _reactionSummary;

  PollId? _currentPollId;
  String? _lastUserId;

  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

  bool _isDisposed = false;
  int _loadRequestId = 0;

  PollDetailController(
    this._getPollDetail,
    this._updatePollText,
    this._deletePoll,
    this._toggleReaction,
    this._getReactionSummary,
  );

  Future<void> loadPoll(
    PollId pollId, {
    String? userId,
  }) async {
    if (_isDisposed) {
      return;
    }

    final requestId = ++_loadRequestId;

    _currentPollId = pollId;
    _lastUserId = userId ?? _lastUserId;

    _state = const PollDetailLoading();
    _reactionSummary = null;
    _safeNotifyListeners();

    try {
      final poll = await _getPollDetail(pollId);

      if (!_isLoadRequestCurrent(requestId)) {
        return;
      }

      if (poll == null) {
        _state = const PollDetailError('Poll not found');
      } else {
        _state = PollDetailLoaded(poll);

        try {
          final target = TargetRef.poll(poll.id.value);
          final summaries = await _getReactionSummary(
            [target],
            userId: _lastUserId,
          );

          if (!_isLoadRequestCurrent(requestId)) {
            return;
          }

          _reactionSummary = summaries.isNotEmpty ? summaries.first : null;
        } catch (_) {
          if (!_isLoadRequestCurrent(requestId)) {
            return;
          }

          _reactionSummary = null;
        }
      }
    } catch (_) {
      if (!_isLoadRequestCurrent(requestId)) {
        return;
      }

      _state = const PollDetailError('Failed to load poll');
    }

    if (_isLoadRequestCurrent(requestId)) {
      _safeNotifyListeners();
    }
  }

  Future<void> refresh() async {
    final pollId = _currentPollId;
    if (pollId == null || _isDisposed) {
      return;
    }

    await loadPoll(pollId, userId: _lastUserId);
  }

  int likeCount() {
    return _reactionSummary?.likeCount ?? 0;
  }

  int dislikeCount() {
    return _reactionSummary?.dislikeCount ?? 0;
  }

  ReactionType? get userReaction => _reactionSummary?.userReaction;

  bool canDelete({required String userId}) {
    final currentState = _state;
    if (currentState is! PollDetailLoaded) {
      return false;
    }

    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      return false;
    }

    final ownerId = currentState.poll.createdByUserId?.trim();
    if (ownerId == null || ownerId.isEmpty) {
      return false;
    }

    return ownerId == normalizedUserId;
  }

  bool canEdit({required String userId}) {
    final currentState = _state;
    if (currentState is! PollDetailLoaded) {
      return false;
    }

    if (!canDelete(userId: userId)) {
      return false;
    }

    return currentState.poll.voteCount == 0;
  }

  Future<Poll> updateCurrentPollText({
    required String userId,
    required String title,
    String? description,
  }) async {
    final currentState = _state;
    if (currentState is! PollDetailLoaded) {
      throw Exception('Poll non caricato.');
    }

    if (_isUpdating) {
      throw Exception('Aggiornamento già in corso.');
    }

    if (!canEdit(userId: userId)) {
      throw Exception(
        'Puoi modificare solo i tuoi sondaggi senza voti.',
      );
    }

    _isUpdating = true;
    _safeNotifyListeners();

    try {
      final updatedPoll = await _updatePollText(
        pollId: currentState.poll.id.value,
        title: title,
        description: description,
      );

      if (!_isDisposed && _currentPollId?.value == updatedPoll.id.value) {
        _state = PollDetailLoaded(updatedPoll);
      }

      return updatedPoll;
    } finally {
      if (!_isDisposed) {
        _isUpdating = false;
        _safeNotifyListeners();
      }
    }
  }

  Future<bool> deleteCurrentPoll({required String userId}) async {
    final currentState = _state;
    if (currentState is! PollDetailLoaded) {
      return false;
    }

    if (_isDeleting || _isDisposed) {
      return false;
    }

    if (!canDelete(userId: userId)) {
      return false;
    }

    _isDeleting = true;
    _safeNotifyListeners();

    try {
      await _deletePoll(currentState.poll.id.value);
      return true;
    } catch (_) {
      return false;
    } finally {
      if (!_isDisposed) {
        _isDeleting = false;
        _safeNotifyListeners();
      }
    }
  }

  Future<void> toggleFire({required String userId}) async {
    await _toggleCurrentReaction(
      userId: userId,
      type: ReactionType.like,
    );
  }

  Future<void> toggleIce({required String userId}) async {
    await _toggleCurrentReaction(
      userId: userId,
      type: ReactionType.dislike,
    );
  }

  Future<void> _toggleCurrentReaction({
    required String userId,
    required ReactionType type,
  }) async {
    final currentState = _state;
    if (currentState is! PollDetailLoaded || userId.isEmpty || _isDisposed) {
      return;
    }

    final pollId = currentState.poll.id.value;
    final target = TargetRef.poll(pollId);

    final summary = await _toggleReaction(
      userId: userId,
      target: target,
      type: type,
    );

    if (_isDisposed || _currentPollId?.value != pollId) {
      return;
    }

    _reactionSummary = summary;
    _lastUserId = userId;
    _safeNotifyListeners();
  }

  bool _isLoadRequestCurrent(int requestId) {
    return !_isDisposed && requestId == _loadRequestId;
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
    _loadRequestId++;
    super.dispose();
  }
}
