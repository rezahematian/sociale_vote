import 'package:flutter/material.dart';
import 'package:sociale_vote/domain/poll/entities/vote.dart';
import 'package:sociale_vote/domain/poll/usecases/submit_vote.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_id.dart';

class VoteController extends ChangeNotifier {
  final SubmitVote _submitVote;

  /// Id delle opzioni attualmente selezionate.
  final Set<String> _selectedOptionIds = {};

  bool _isSubmitting = false;
  String? _errorMessage;
  bool _submittedSuccessfully = false;

  VoteController(this._submitVote);

  Set<String> get selectedOptionIds => _selectedOptionIds;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  bool get submittedSuccessfully => _submittedSuccessfully;

  /// Seleziona/deseleziona un’opzione.
  ///
  /// [allowMultiple] indica se il poll permette più selezioni (es. multipleChoice).
  /// Per i poll single choice (o yes/no) se selezioni una nuova opzione
  /// viene automaticamente svuotata la selezione precedente.
  void toggleOption(String optionId, {required bool allowMultiple}) {
    _errorMessage = null;
    _submittedSuccessfully = false;

    if (!allowMultiple) {
      // Single choice: se clicchi di nuovo la stessa la deselezioni,
      // altrimenti selezione unica.
      if (_selectedOptionIds.contains(optionId)) {
        _selectedOptionIds.clear();
      } else {
        _selectedOptionIds
          ..clear()
          ..add(optionId);
      }
    } else {
      // Multiple choice: toggle libero.
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
    _submittedSuccessfully = false;
    notifyListeners();
  }

  /// Invia il voto per il poll indicato.
  ///
  /// Per ora validiamo solo che ci sia almeno una opzione selezionata.
  /// Le regole min/max più avanzate possono essere aggiunte in seguito
  /// usando PollConfiguration a livello di UI o application.
  Future<void> submitVote(PollId pollId) async {
    if (_selectedOptionIds.isEmpty) {
      _errorMessage = 'Please select at least one option.';
      _submittedSuccessfully = false;
      notifyListeners();
      return;
    }

    _isSubmitting = true;
    _errorMessage = null;
    _submittedSuccessfully = false;
    notifyListeners();

    try {
      final vote = Vote.now(
        pollId: pollId,
        optionIds: _selectedOptionIds.toList(),
      );

      await _submitVote(vote);

      _submittedSuccessfully = true;
    } catch (e) {
      _errorMessage = 'Failed to submit vote. Please try again.';
      _submittedSuccessfully = false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}