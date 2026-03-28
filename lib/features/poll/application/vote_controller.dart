import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/entities/vote.dart';
import 'package:sociale_vote/domain/poll/errors/poll_closed_exception.dart';
import 'package:sociale_vote/domain/poll/errors/unauthorized_vote_exception.dart';
import 'package:sociale_vote/domain/poll/usecases/submit_vote_and_notify.dart';

/// Tipologia di errore di voto (UI-agnostica).
enum VoteErrorType {
  none,
  noSelection,
  unauthorized,
  closed,
  alreadyVoted,
  generic,
}

class VoteController extends ChangeNotifier {
  final SubmitVoteAndNotify _submitVote;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Id delle opzioni attualmente selezionate.
  final Set<String> _selectedOptionIds = {};

  bool _isSubmitting = false;

  /// Messaggio testuale legacy (non localizzato).
  /// Non usarlo in UI: usa [errorType] e mappa in pagina.
  String? _errorMessage;

  bool _submittedSuccessfully = false;

  VoteErrorType _errorType = VoteErrorType.none;

  VoteController(this._submitVote);

  Set<String> get selectedOptionIds => _selectedOptionIds;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  bool get submittedSuccessfully => _submittedSuccessfully;
  VoteErrorType get errorType => _errorType;

  /// Seleziona/deseleziona un’opzione.
  void toggleOption(String optionId, {required bool allowMultiple}) {
    if (_isSubmitting) return;

    _errorMessage = null;
    _errorType = VoteErrorType.none;
    _submittedSuccessfully = false;

    if (!allowMultiple) {
      if (_selectedOptionIds.contains(optionId)) {
        _selectedOptionIds.clear();
      } else {
        _selectedOptionIds
          ..clear()
          ..add(optionId);
      }
    } else {
      if (_selectedOptionIds.contains(optionId)) {
        _selectedOptionIds.remove(optionId);
      } else {
        _selectedOptionIds.add(optionId);
      }
    }

    notifyListeners();
  }

  /// Reset completo dello stato di selezione e invio.
  void reset() {
    _selectedOptionIds.clear();
    _isSubmitting = false;
    _errorMessage = null;
    _errorType = VoteErrorType.none;
    _submittedSuccessfully = false;
    notifyListeners();
  }

  /// Invia il voto per il [poll] indicato.
  Future<void> submitVote({
    required Poll poll,
    required String? userId,
    String? userCountryCode,
  }) async {
    if (_isSubmitting) return;

    if (_selectedOptionIds.isEmpty) {
      _errorType = VoteErrorType.noSelection;
      _errorMessage = null;
      _submittedSuccessfully = false;
      notifyListeners();
      return;
    }

    _isSubmitting = true;
    _errorMessage = null;
    _errorType = VoteErrorType.none;
    _submittedSuccessfully = false;
    notifyListeners();

    try {
      final selectedCount = _selectedOptionIds.length;

      final vote = Vote.now(
        pollId: poll.id,
        optionIds: _selectedOptionIds.toList(),
      );

      await _submitVote(
        vote,
        poll: poll,
        userId: userId,
        userCountryCode: userCountryCode,
      );

      _submittedSuccessfully = true;

      await _trackVoteSubmitted(
        poll: poll,
        selectedCount: selectedCount,
      );
    } on UnauthorizedVoteException {
      _errorType = VoteErrorType.unauthorized;
      _errorMessage = null;
      _submittedSuccessfully = false;
    } on PollClosedException {
      _errorType = VoteErrorType.closed;
      _errorMessage = null;
      _submittedSuccessfully = false;
    } catch (e) {
      final message = e.toString().toLowerCase();

      if (message.contains('duplicate') ||
          message.contains('unique') ||
          message.contains('already voted') ||
          message.contains('unique_vote') ||
          message.contains('unique_vote_per_poll_user')) {
        _errorType = VoteErrorType.alreadyVoted;
      } else {
        _errorType = VoteErrorType.generic;
      }

      _errorMessage = null;
      _submittedSuccessfully = false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> _trackVoteSubmitted({
    required Poll poll,
    required int selectedCount,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'submit_vote',
        parameters: <String, Object>{
          'poll_id': poll.id.value,
          'selected_option_count': selectedCount,
        },
      );
    } catch (_) {
      // Best effort: analytics must never break vote flow.
    }
  }
}