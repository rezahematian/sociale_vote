import 'package:flutter/material.dart';

import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/entities/poll_result.dart';
import 'package:sociale_vote/domain/poll/usecases/get_poll_results.dart';
import 'package:sociale_vote/domain/poll/value_objects/quorum_status.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_outcome.dart';

import 'package:sociale_vote/domain/poll/services/poll_quorum_evaluator.dart';
import 'package:sociale_vote/domain/poll/services/poll_outcome_calculator.dart';
import 'package:sociale_vote/domain/poll/services/poll_results_visibility_resolver.dart';

/// Controller application-layer per:
/// - risultati
/// - quorum
/// - outcome
/// - visibilità risultati (governance completa)
class PollResultController extends ChangeNotifier {
  final GetPollResults _getPollResults;
  final PollQuorumEvaluator _quorumEvaluator;
  final PollOutcomeCalculator _outcomeCalculator;
  final PollResultsVisibilityResolver _visibilityResolver;

  PollResultController(
    this._getPollResults, {
    PollQuorumEvaluator? quorumEvaluator,
    PollOutcomeCalculator? outcomeCalculator,
    PollResultsVisibilityResolver? visibilityResolver,
  })  : _quorumEvaluator = quorumEvaluator ?? const PollQuorumEvaluator(),
        _outcomeCalculator = outcomeCalculator ?? const PollOutcomeCalculator(),
        _visibilityResolver =
            visibilityResolver ?? const PollResultsVisibilityResolver();

  bool _isLoading = false;
  PollResult? _result;
  String? _error;

  QuorumStatus _quorumStatus = QuorumStatus.notApplicable;
  PollOutcome _outcome = PollOutcome.notApplicable;
  bool _canShowResults = false;

  bool get isLoading => _isLoading;
  PollResult? get result => _result;
  String? get error => _error;

  QuorumStatus get quorumStatus => _quorumStatus;
  PollOutcome get outcome => _outcome;
  bool get canShowResults => _canShowResults;

  bool get isQuorumApplicable => _quorumStatus != QuorumStatus.notApplicable;
  bool get isQuorumReached => _quorumStatus == QuorumStatus.reached;
  bool get hasOutcome => _outcome != PollOutcome.notApplicable;

  Future<void> loadResults({
    required Poll poll,
    required bool userHasVoted,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _getPollResults(poll);
      _result = result;

      _quorumStatus = _quorumEvaluator.evaluate(
        poll: poll,
        result: result,
      );

      _outcome = _outcomeCalculator.calculate(
        poll: poll,
        result: result,
        quorumStatus: _quorumStatus,
      );

      _canShowResults = _visibilityResolver.canShowResults(
        poll: poll,
        userHasVoted: userHasVoted,
      );
    } catch (e) {
      _error = 'Failed to load results';
      _quorumStatus = QuorumStatus.notApplicable;
      _outcome = PollOutcome.notApplicable;
      _canShowResults = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _result = null;
    _error = null;
    _isLoading = false;
    _quorumStatus = QuorumStatus.notApplicable;
    _outcome = PollOutcome.notApplicable;
    _canShowResults = false;
    notifyListeners();
  }
}