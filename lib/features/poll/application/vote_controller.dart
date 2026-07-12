import 'package:flutter/material.dart';
import 'package:sociale_vote/core/analytics/analytics_service.dart';
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

  /// Id delle opzioni attualmente selezionate.
  final Set<String> _selectedOptionIds = {};

  bool _isSubmitting = false;

  /// Messaggio testuale legacy (non localizzato).
  /// Non usarlo in UI: usa [errorType] e mappa in pagina.
  String? _errorMessage;

  bool _submittedSuccessfully = false;

  VoteErrorType _errorType = VoteErrorType.none;

  bool _isDisposed = false;
  int _submitOperationId = 0;

  VoteController(this._submitVote);

  Set<String> get selectedOptionIds => _selectedOptionIds;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  bool get submittedSuccessfully => _submittedSuccessfully;
  VoteErrorType get errorType => _errorType;

  /// Seleziona/deseleziona un’opzione.
  void toggleOption(String optionId, {required bool allowMultiple}) {
    if (_isSubmitting || _isDisposed) return;

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

    _safeNotifyListeners();
  }

  /// Reset completo dello stato di selezione e invio.
  void reset() {
    if (_isDisposed) return;

    _submitOperationId++;
    _selectedOptionIds.clear();
    _isSubmitting = false;
    _errorMessage = null;
    _errorType = VoteErrorType.none;
    _submittedSuccessfully = false;
    _safeNotifyListeners();
  }

  /// Invia il voto per il [poll] indicato.
  Future<void> submitVote({
    required Poll poll,
    required String? userId,
    String? userCountryCode,
  }) async {
    if (_isSubmitting || _isDisposed) return;

    if (_selectedOptionIds.isEmpty) {
      _errorType = VoteErrorType.noSelection;
      _errorMessage = null;
      _submittedSuccessfully = false;
      _safeNotifyListeners();
      return;
    }

    final operationId = ++_submitOperationId;

    _isSubmitting = true;
    _errorMessage = null;
    _errorType = VoteErrorType.none;
    _submittedSuccessfully = false;
    _safeNotifyListeners();

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

      if (!_isOperationCurrent(operationId)) {
        return;
      }

      _submittedSuccessfully = true;

      await _trackVoteSubmitted(
        poll: poll,
        selectedCount: selectedCount,
      );
    } on UnauthorizedVoteException {
      if (_isOperationCurrent(operationId)) {
        _errorType = VoteErrorType.unauthorized;
        _errorMessage = null;
        _submittedSuccessfully = false;
      }
    } on PollClosedException {
      if (_isOperationCurrent(operationId)) {
        _errorType = VoteErrorType.closed;
        _errorMessage = null;
        _submittedSuccessfully = false;
      }
    } catch (e) {
      if (_isOperationCurrent(operationId)) {
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
      }
    } finally {
      if (_isOperationCurrent(operationId)) {
        _isSubmitting = false;
        _safeNotifyListeners();
      }
    }
  }

  bool _isOperationCurrent(int operationId) {
    return !_isDisposed && operationId == _submitOperationId;
  }

  void _safeNotifyListeners() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _submitOperationId++;
    super.dispose();
  }

  Future<void> _trackVoteSubmitted({
    required Poll poll,
    required int selectedCount,
  }) async {
    await AnalyticsService.instance.logEvent(
      'vote_submitted',
      parameters: <String, Object?>{
        'poll_id': poll.id.value,
        'selected_option_count': selectedCount,
      },
    );
  }
}
