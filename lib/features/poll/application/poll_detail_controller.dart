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

  PollDetailController(
    this._getPollDetail,
    this._toggleReaction,
    this._getReactionSummary,
  );

  Future<void> loadPoll(PollId pollId) async {
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
          final summaries = await _getReactionSummary([target]);
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

  int likeCount() {
    return _reactionSummary?.likeCount ?? 0;
  }

  int dislikeCount() {
    return _reactionSummary?.dislikeCount ?? 0;
  }

  /// Toggle 🔥 per il poll corrente.
  Future<void> toggleFire({required String userId}) async {
    final currentState = _state;
    if (currentState is! PollDetailLoaded) return;

    final poll = currentState.poll;
    final target = TargetRef.poll(poll.id.value);

    final summary = await _toggleReaction(
      userId: userId,
      target: target,
      type: ReactionType.like,
    );

    _reactionSummary = summary;
    notifyListeners();
  }

  /// Toggle ❄ per il poll corrente.
  Future<void> toggleIce({required String userId}) async {
    final currentState = _state;
    if (currentState is! PollDetailLoaded) return;

    final poll = currentState.poll;
    final target = TargetRef.poll(poll.id.value);

    final summary = await _toggleReaction(
      userId: userId,
      target: target,
      type: ReactionType.dislike,
    );

    _reactionSummary = summary;
    notifyListeners();
  }
}