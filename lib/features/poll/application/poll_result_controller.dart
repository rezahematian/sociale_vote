import 'package:flutter/material.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/entities/poll_result.dart';
import 'package:sociale_vote/domain/poll/usecases/get_poll_results.dart';

/// Controller application-layer per ottenere e gestire
/// lo stato dei risultati di un poll.
class PollResultController extends ChangeNotifier {
  final GetPollResults _getPollResults;

  PollResultController(this._getPollResults);

  bool _isLoading = false;
  PollResult? _result;
  String? _error;

  bool get isLoading => _isLoading;
  PollResult? get result => _result;
  String? get error => _error;

  Future<void> loadResults(Poll poll) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _getPollResults(poll);
      _result = result;
    } catch (e) {
      _error = 'Failed to load results';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _result = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}