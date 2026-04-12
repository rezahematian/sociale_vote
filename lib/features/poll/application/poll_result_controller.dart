import 'dart:async';

import 'package:flutter/material.dart';

import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/entities/poll_result.dart';
import 'package:sociale_vote/domain/poll/repositories/vote_repository.dart';
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
/// - voti pubblici nominativi (solo se consentiti)
class PollResultController extends ChangeNotifier {
  final GetPollResults _getPollResults;
  final VoteRepository _voteRepository;
  final PollQuorumEvaluator _quorumEvaluator;
  final PollOutcomeCalculator _outcomeCalculator;
  final PollResultsVisibilityResolver _visibilityResolver;

  static const Duration _realtimeReloadDebounce =
      Duration(milliseconds: 250);
  static const int _publicVotesPageSize = 50;

  StreamSubscription<void>? _votesSubscription;
  Timer? _reloadDebounceTimer;
  String? _subscribedPollId;

  bool _isDisposed = false;
  int _requestId = 0;
  bool _reloadQueued = false;

  int _publicVotesRequestId = 0;
  bool _publicVotesReloadQueued = false;

  PollResultController(
    this._getPollResults,
    this._voteRepository, {
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

  Poll? _lastPoll;
  bool? _lastUserHasVoted;

  bool _isPublicVotesLoading = false;
  List<PublicPollVoteEntry> _publicVotes = const [];
  String? _publicVotesError;
  bool _publicVotesHasMore = false;
  String _publicVotesQuery = '';
  bool _publicVotesInitialized = false;

  bool get isLoading => _isLoading;
  PollResult? get result => _result;
  String? get error => _error;

  QuorumStatus get quorumStatus => _quorumStatus;
  PollOutcome get outcome => _outcome;
  bool get canShowResults => _canShowResults;

  bool get isQuorumApplicable => _quorumStatus != QuorumStatus.notApplicable;
  bool get isQuorumReached => _quorumStatus == QuorumStatus.reached;
  bool get hasOutcome => _outcome != PollOutcome.notApplicable;

  bool get isPublicVotesLoading => _isPublicVotesLoading;
  List<PublicPollVoteEntry> get publicVotes =>
      List<PublicPollVoteEntry>.unmodifiable(_publicVotes);
  String? get publicVotesError => _publicVotesError;
  bool get publicVotesHasMore => _publicVotesHasMore;
  String get publicVotesQuery => _publicVotesQuery;
  bool get publicVotesInitialized => _publicVotesInitialized;

  bool get canShowPublicVotes {
    final poll = _lastPoll;
    if (poll == null) return false;
    if (!_canShowResults) return false;
    return _isPublicVoteEnabled(poll);
  }

  Future<void> loadResults({
    required Poll poll,
    required bool userHasVoted,
  }) async {
    if (_isDisposed) return;

    final previousPollId = _lastPoll?.id.value;
    final pollChanged = previousPollId != poll.id.value;

    if (pollChanged) {
      _resetPublicVotesState(notify: false);
    }

    await _ensureRealtimeSubscription(poll);
    if (_isDisposed) return;

    final requestId = ++_requestId;

    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      final repositoryUserHasVoted =
          await _resolveCurrentUserHasVoted(poll);

      if (!_isRequestStillValid(requestId)) return;

      final effectiveUserHasVoted = userHasVoted || repositoryUserHasVoted;

      _lastPoll = poll;
      _lastUserHasVoted = effectiveUserHasVoted;

      final result = await _getPollResults(poll);
      if (!_isRequestStillValid(requestId)) return;

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
        userHasVoted: effectiveUserHasVoted,
      );

      if (!canShowPublicVotes) {
        _resetPublicVotesState(notify: false);
      }
    } catch (_) {
      if (!_isRequestStillValid(requestId)) return;

      _error = 'Failed to load results';
      _quorumStatus = QuorumStatus.notApplicable;
      _outcome = PollOutcome.notApplicable;
      _canShowResults = false;
      _resetPublicVotesState(notify: false);
    } finally {
      if (!_isRequestStillValid(requestId)) return;

      _isLoading = false;
      _safeNotifyListeners();

      if (_reloadQueued) {
        _reloadQueued = false;
        unawaited(reload());
      }
    }
  }

  Future<void> loadPublicVotes({
    String query = '',
    bool loadMore = false,
  }) async {
    if (_isDisposed) return;

    final poll = _lastPoll;
    if (poll == null || !canShowPublicVotes) {
      _resetPublicVotesState();
      return;
    }

    if (_isPublicVotesLoading) {
      return;
    }

    final normalizedQuery = query.trim();
    final queryChanged = normalizedQuery != _publicVotesQuery;

    if (!loadMore || queryChanged) {
      _publicVotesQuery = normalizedQuery;
      _publicVotes = const [];
      _publicVotesHasMore = false;
      _publicVotesError = null;
    } else if (!_publicVotesHasMore) {
      return;
    }

    final offset = loadMore && !queryChanged ? _publicVotes.length : 0;
    final requestId = ++_publicVotesRequestId;

    _isPublicVotesLoading = true;
    _publicVotesError = null;
    _safeNotifyListeners();

    try {
      final page = await _voteRepository.getPublicVotesForPoll(
        poll.id,
        query: normalizedQuery.isEmpty ? null : normalizedQuery,
        limit: _publicVotesPageSize,
        offset: offset,
      );

      if (!_isPublicVotesRequestStillValid(requestId)) return;

      _publicVotes = offset == 0
          ? List<PublicPollVoteEntry>.from(page.items)
          : <PublicPollVoteEntry>[
              ..._publicVotes,
              ...page.items,
            ];

      _publicVotesHasMore = page.hasMore;
      _publicVotesInitialized = true;
    } catch (_) {
      if (!_isPublicVotesRequestStillValid(requestId)) return;
      _publicVotesError = 'Failed to load public votes';
    } finally {
      if (!_isPublicVotesRequestStillValid(requestId)) return;

      _isPublicVotesLoading = false;
      _safeNotifyListeners();

      if (_publicVotesReloadQueued && canShowPublicVotes) {
        _publicVotesReloadQueued = false;
        unawaited(
          loadPublicVotes(
            query: _publicVotesQuery,
          ),
        );
      }
    }
  }

  Future<bool> _resolveCurrentUserHasVoted(Poll poll) async {
    try {
      return await _voteRepository.hasCurrentUserVoted(poll.id);
    } catch (_) {
      return false;
    }
  }

  Future<void> _ensureRealtimeSubscription(Poll poll) async {
    final pollId = poll.id.value;

    if (_subscribedPollId == pollId) {
      return;
    }

    await _votesSubscription?.cancel();

    _votesSubscription = _voteRepository.watchVotesForPoll(poll.id).listen((_) {
      _scheduleRealtimeReload();
    });

    _subscribedPollId = pollId;
  }

  void _scheduleRealtimeReload() {
    if (_isDisposed) return;

    _reloadDebounceTimer?.cancel();
    _reloadDebounceTimer = Timer(_realtimeReloadDebounce, () {
      if (_isDisposed) return;

      if (_isLoading) {
        _reloadQueued = true;
        return;
      }

      if (_isPublicVotesLoading) {
        _publicVotesReloadQueued = true;
      }

      unawaited(reload());
    });
  }

  Future<void> reload() async {
    final poll = _lastPoll;
    final userHasVoted = _lastUserHasVoted;

    if (poll == null || userHasVoted == null) {
      return;
    }

    final shouldReloadPublicVotes = _publicVotesInitialized;

    await loadResults(
      poll: poll,
      userHasVoted: userHasVoted,
    );

    if (_isDisposed) return;

    if (shouldReloadPublicVotes && canShowPublicVotes) {
      await loadPublicVotes(query: _publicVotesQuery);
    }
  }

  void markUserHasVoted() {
    _lastUserHasVoted = true;
    _canShowResults = _lastPoll != null
        ? _visibilityResolver.canShowResults(
            poll: _lastPoll!,
            userHasVoted: true,
          )
        : _canShowResults;

    if (!canShowPublicVotes) {
      _resetPublicVotesState(notify: false);
    }

    _safeNotifyListeners();
  }

  bool _isPublicVoteEnabled(Poll poll) {
    try {
      final dynamic config = poll.configuration;
      final dynamic rules = config.anonymityRules;
      final dynamic level =
          rules?.level ??
          rules?.anonymityLevel ??
          config.anonymityLevel ??
          config.anonymityRules;

      final normalized = _normalizeRuleToken(level);

      return normalized.contains('public') ||
          normalized.contains('named') ||
          normalized.contains('nonanonymous') ||
          normalized.contains('notanonymous') ||
          normalized.contains('publicvote') ||
          normalized.contains('namedvote');
    } catch (_) {
      return false;
    }
  }

  String _normalizeRuleToken(dynamic value) {
    final raw = value?.toString().trim().toLowerCase() ?? '';
    return raw.replaceAll(RegExp(r'[^a-z]'), '');
  }

  bool _isRequestStillValid(int requestId) {
    return !_isDisposed && requestId == _requestId;
  }

  bool _isPublicVotesRequestStillValid(int requestId) {
    return !_isDisposed && requestId == _publicVotesRequestId;
  }

  void _resetPublicVotesState({
    bool notify = true,
  }) {
    _publicVotesRequestId += 1;
    _publicVotesReloadQueued = false;
    _publicVotes = const [];
    _publicVotesError = null;
    _isPublicVotesLoading = false;
    _publicVotesHasMore = false;
    _publicVotesQuery = '';
    _publicVotesInitialized = false;

    if (notify) {
      _safeNotifyListeners();
    }
  }

  void _safeNotifyListeners() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _reloadDebounceTimer?.cancel();
    _votesSubscription?.cancel();
    super.dispose();
  }

  void reset() {
    _requestId += 1;
    _reloadQueued = false;
    _reloadDebounceTimer?.cancel();
    _reloadDebounceTimer = null;
    _votesSubscription?.cancel();
    _votesSubscription = null;
    _subscribedPollId = null;
    _result = null;
    _error = null;
    _isLoading = false;
    _quorumStatus = QuorumStatus.notApplicable;
    _outcome = PollOutcome.notApplicable;
    _canShowResults = false;
    _lastPoll = null;
    _lastUserHasVoted = null;
    _resetPublicVotesState(notify: false);
    _safeNotifyListeners();
  }
}