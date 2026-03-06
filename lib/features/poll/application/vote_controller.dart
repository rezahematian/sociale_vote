import 'package:flutter/material.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/entities/vote.dart';
import 'package:sociale_vote/domain/poll/errors/poll_closed_exception.dart';
import 'package:sociale_vote/domain/poll/errors/unauthorized_vote_exception.dart';
import 'package:sociale_vote/domain/poll/usecases/submit_vote.dart';

/// Tipologia di errore di voto (UI-agnostica).
enum VoteErrorType {
  none,
  noSelection,
  unauthorized,
  closed,
  generic,
}

class VoteController extends ChangeNotifier {
  final SubmitVote _submitVote;

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
    } on UnauthorizedVoteException {
      _errorType = VoteErrorType.unauthorized;
      _errorMessage = null;
      _submittedSuccessfully = false;
    } on PollClosedException {
      _errorType = VoteErrorType.closed;
      _errorMessage = null;
      _submittedSuccessfully = false;
    } catch (_) {
      _errorType = VoteErrorType.generic;
      _errorMessage = null;
      _submittedSuccessfully = false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}