import 'package:flutter/material.dart';

import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/engagement/entities/reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/usecases/get_reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/usecases/toggle_reaction.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';
import 'package:sociale_vote/domain/poll/usecases/get_poll_detail.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';

import 'poll_state.dart';

class PollDetailController extends ChangeNotifier {
  final GetPollDetail _getPollDetail;
  final ToggleReaction _toggleReaction;
  final GetReactionSummary _getReactionSummary;

  PollDetailState _state = const PollDetailInitial();
  PollDetailState get state => _state;

  /// Reaction summary per il poll corrente (se caricato).
  ReactionSummary? _reactionSummary;
  ReactionSummary? get reactionSummary => _reactionSummary;

  /// Per supportare eventuale refresh: ricordiamo l'ultimo pollId e userId.
  PollId? _currentPollId;
  String? _lastUserId;

  PollDetailController(
    this._getPollDetail,
    this._toggleReaction,
    this._getReactionSummary,
  );

  /// Carica il poll + reaction summary.
  ///
  /// [userId] è opzionale:
  /// - se valorizzato, viene usato per ottenere anche userReaction
  /// - viene memorizzato in [_lastUserId] per futuri reload/refresh
  Future<void> loadPoll(
    PollId pollId, {
    String? userId,
  }) async {
    _currentPollId = pollId;
    _lastUserId = userId ?? _lastUserId;

    _state = const PollDetailLoading();
    _reactionSummary = null;
    notifyListeners();

    try {
      final poll = await _getPollDetail(pollId);

      if (poll == null) {
        _state = const PollDetailError('Poll not found');
      } else {
        _state = PollDetailLoaded(poll);

        // Dopo aver caricato il poll, carichiamo anche il reaction summary.
        try {
          final target = TargetRef.poll(poll.id.value);
          final summaries = await _getReactionSummary(
            [target],
            userId: _lastUserId,
          );
          _reactionSummary =
              summaries.isNotEmpty ? summaries.first : null;
        } catch (_) {
          // In caso di errore sulle reazioni non blocchiamo il dettaglio poll.
          _reactionSummary = null;
        }
      }
    } catch (e) {
      // Qui possiamo in futuro migliorare con error handler centralizzato
      _state = const PollDetailError('Failed to load poll');
    }

    notifyListeners();
  }

  /// Comodo per pull-to-refresh, se hai già chiamato loadPoll una volta.
  Future<void> refresh() async {
    if (_currentPollId == null) return;
    await loadPoll(_currentPollId!, userId: _lastUserId);
  }

  int likeCount() {
    return _reactionSummary?.likeCount ?? 0;
  }

  int dislikeCount() {
    return _reactionSummary?.dislikeCount ?? 0;
  }

  /// Reazione corrente dell'utente sul poll (se presente).
  ReactionType? get userReaction => _reactionSummary?.userReaction;

  /// Toggle 🔥 per il poll corrente.
  Future<void> toggleFire({required String userId}) async {
    final currentState = _state;
    if (currentState is! PollDetailLoaded) return;

    if (userId.isEmpty) {
      // v1: la UI / AuthGuard dovrebbe già bloccare i guest.
      return;
    }

    final poll = currentState.poll;
    final target = TargetRef.poll(poll.id.value);

    final summary = await _toggleReaction(
      userId: userId,
      target: target,
      type: ReactionType.like,
    );

    _reactionSummary = summary;
    _lastUserId = userId;
    notifyListeners();
  }

  /// Toggle ❄ per il poll corrente.
  Future<void> toggleIce({required String userId}) async {
    final currentState = _state;
    if (currentState is! PollDetailLoaded) return;

    if (userId.isEmpty) {
      return;
    }

    final poll = currentState.poll;
    final target = TargetRef.poll(poll.id.value);

    final summary = await _toggleReaction(
      userId: userId,
      target: target,
      type: ReactionType.dislike,
    );

    _reactionSummary = summary;
    _lastUserId = userId;
    notifyListeners();
  }
}