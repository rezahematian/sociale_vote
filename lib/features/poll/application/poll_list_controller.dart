import 'package:flutter/foundation.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/engagement/entities/reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/usecases/get_reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/usecases/toggle_reaction.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/entities/poll_result.dart';
import 'package:sociale_vote/domain/poll/usecases/get_poll_results.dart';
import 'package:sociale_vote/domain/poll/usecases/get_polls.dart';
import 'package:sociale_vote/domain/poll/value_objects/poll_status.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';

enum PollSortMode {
  latest,
  hottest,
}

/// Filtro logico di scope per la lista poll.
/// V1: solo currentScope (lo stesso del GeoScopeController),
/// ma l'enum è pronto per estensioni future (es. followed, global, ecc.).
enum PollScopeFilter {
  currentScope,
}

/// Filtro di stato delle votazioni (aperta/chiusa).
enum PollStatusFilter {
  all,
  open,
  closed,
}

class PollListController extends ChangeNotifier {
  final GetPolls getPollsUseCase;
  final GetPollResults getPollResults;
  final GeoScopeController geoScopeController;
  final ToggleReaction toggleReaction;
  final GetReactionSummary getReactionSummary;

  late final VoidCallback _geoScopeListener;

  String? _lastKnownUserId;
  bool _isDisposed = false;

  // ===== Filtri / ordinamento =====
  PollSortMode _sortMode = PollSortMode.hottest;
  PollScopeFilter _scopeFilter = PollScopeFilter.currentScope;
  PollStatusFilter _statusFilter = PollStatusFilter.all;

  // ===== Stato =====
  bool _isLoading = false;
  bool _hasMoreFromSource = true;

  static const int _pageSize = 10;
  int _currentOffset = 0;

  /// Lista sorgente: tutti i poll ricevuti dal backend per lo scope corrente.
  final List<Poll> _allPolls = [];

  /// Lista visibile: applicazione di filtri + sorting su [_allPolls].
  final List<Poll> _visiblePolls = [];

  final Map<String, ReactionSummary> _reactionSummaries = {};
  final Map<String, PollResult> _pollResults = {};

  PollListController({
    required this.getPollsUseCase,
    required this.getPollResults,
    required this.geoScopeController,
    required this.toggleReaction,
    required this.getReactionSummary,
  }) {
    _geoScopeListener = () {
      loadPolls(userId: _lastKnownUserId);
    };
    geoScopeController.addListener(_geoScopeListener);
  }

  // ===== Getters di stato esposto alla UI =====

  bool get isLoading => _isLoading;
  bool get hasMoreFromSource => _hasMoreFromSource;

  /// Lista di poll già filtrata e ordinata secondo
  /// sortMode, scopeFilter e statusFilter.
  List<Poll> get polls => List.unmodifiable(_visiblePolls);

  PollSortMode get sortMode => _sortMode;
  PollScopeFilter get scopeFilter => _scopeFilter;
  PollStatusFilter get statusFilter => _statusFilter;

  PollResult? resultForPoll(Poll poll) => _pollResults[poll.id.value];

  void _safeNotifyListeners() {
    if (_isDisposed) return;
    notifyListeners();
  }

  // ===== Setter filtri / ordinamento =====

  void setSortMode(PollSortMode mode) {
    if (_sortMode == mode) return;
    _sortMode = mode;
    _recomputeVisiblePolls();
    _safeNotifyListeners();
  }

  void setScopeFilter(PollScopeFilter filter) {
    if (_scopeFilter == filter) return;
    _scopeFilter = filter;
    _recomputeVisiblePolls();
    _safeNotifyListeners();
  }

  void setStatusFilter(PollStatusFilter filter) {
    if (_statusFilter == filter) return;
    _statusFilter = filter;
    _recomputeVisiblePolls();
    _safeNotifyListeners();
  }

  // ===== Caricamento / paginazione =====

  Future<void> loadPolls({String? userId}) async {
    if (_isDisposed) return;

    _lastKnownUserId = userId ?? _lastKnownUserId;

    _isLoading = true;
    _safeNotifyListeners();

    _allPolls.clear();
    _visiblePolls.clear();
    _reactionSummaries.clear();
    _pollResults.clear();
    _currentOffset = 0;
    _hasMoreFromSource = true;

    try {
      await _loadNextPage();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error loading polls: $e');
        debugPrint('$stackTrace');
      }

      _allPolls.clear();
      _visiblePolls.clear();
      _reactionSummaries.clear();
      _pollResults.clear();
      _currentOffset = 0;
      _hasMoreFromSource = false;
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  Future<void> loadMorePolls() async {
    if (_isDisposed) return;
    if (_isLoading) return;
    if (!_hasMoreFromSource) return;

    _isLoading = true;
    _safeNotifyListeners();

    try {
      await _loadNextPage();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error loading more polls: $e');
        debugPrint('$stackTrace');
      }
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  Future<void> _loadNextPage() async {
    if (_isDisposed) return;

    final scope = geoScopeController.scope;

    String? countryCode;
    String? cityId;

    switch (scope.level) {
      case GeoScopeLevel.world:
        break;
      case GeoScopeLevel.country:
        countryCode = scope.countryCode;
        break;
      case GeoScopeLevel.city:
        countryCode = scope.countryCode;
        cityId = scope.cityId;
        break;
    }

    final result = await getPollsUseCase(
      countryCode: countryCode,
      cityId: cityId,
      limit: _pageSize,
      offset: _currentOffset,
    );
    if (_isDisposed) return;

    if (result.length < _pageSize) {
      _hasMoreFromSource = false;
    }

    _currentOffset += result.length;

    final existingIds = _allPolls.map((p) => p.id.value).toSet();
    final uniqueNewPolls = <Poll>[];

    for (final poll in result) {
      final pollId = poll.id.value;
      if (existingIds.add(pollId)) {
        uniqueNewPolls.add(poll);
      }
    }

    if (result.isNotEmpty && uniqueNewPolls.isEmpty) {
      _hasMoreFromSource = false;
      return;
    }

    _allPolls.addAll(uniqueNewPolls);

    // Mostra subito i poll ricevuti dalla query principale.
    // Reazioni e risultati sono dati secondari e non devono bloccare
    // il primo render della Home o della Poll List.
    _recomputeVisiblePolls();
    _safeNotifyListeners();

    await Future.wait<void>([
      _loadReactionSummariesForPolls(uniqueNewPolls),
      _loadPollResultsForPolls(uniqueNewPolls),
    ]);
    if (_isDisposed) return;

    // Aggiorna le card quando arrivano i dati secondari.
    _recomputeVisiblePolls();
    _safeNotifyListeners();
  }

  Future<void> _loadReactionSummariesForPolls(List<Poll> newPolls) async {
    if (_isDisposed) return;
    if (newPolls.isEmpty) return;

    final targets = newPolls.map((p) => TargetRef.poll(p.id.value)).toList();

    final summaries = await getReactionSummary(
      targets,
      userId: _lastKnownUserId,
    );
    if (_isDisposed) return;

    for (final summary in summaries) {
      _reactionSummaries[summary.target.id] = summary;
    }
  }

  Future<void> _loadPollResultsForPolls(List<Poll> newPolls) async {
    if (_isDisposed) return;
    if (newPolls.isEmpty) return;

    await Future.wait<void>(
      newPolls.map((poll) async {
        if (_isDisposed) return;
        if (_pollResults.containsKey(poll.id.value)) return;

        try {
          final pollResult = await getPollResults(poll);
          if (_isDisposed) return;
          _pollResults[poll.id.value] = pollResult;
        } catch (_) {
          // Se un poll fallisce, non blocchiamo tutta la lista.
        }
      }),
    );
  }

  // ===== Reaction helpers =====

  ReactionSummary? _summaryForPoll(Poll poll) {
    return _reactionSummaries[poll.id.value];
  }

  int likeCountForPoll(Poll poll) => _summaryForPoll(poll)?.likeCount ?? 0;

  int dislikeCountForPoll(Poll poll) =>
      _summaryForPoll(poll)?.dislikeCount ?? 0;

  ReactionType? userReactionForPoll(Poll poll) =>
      _summaryForPoll(poll)?.userReaction;

  int _fireCountForPoll(Poll poll) {
    final summary = _summaryForPoll(poll);
    if (summary == null) return 0;
    return summary.likeCount;
  }

  int _sourceIndexForPoll(Poll poll) {
    final index = _allPolls.indexWhere((p) => p.id.value == poll.id.value);
    return index < 0 ? 1 << 30 : index;
  }

  int _comparePollPriority(Poll a, Poll b) {
    final voteCompare = b.voteCount.compareTo(a.voteCount);
    if (voteCompare != 0) {
      return voteCompare;
    }

    final fireCompare = _fireCountForPoll(b).compareTo(_fireCountForPoll(a));
    if (fireCompare != 0) {
      return fireCompare;
    }

    return _sourceIndexForPoll(a).compareTo(_sourceIndexForPoll(b));
  }

  // ===== Filtri + ordinamento =====

  void _recomputeVisiblePolls() {
    var tmp = List<Poll>.from(_allPolls);

    tmp = _applyScopeFilter(tmp);
    tmp = _applyStatusFilter(tmp);
    _sortPolls(tmp);

    _visiblePolls
      ..clear()
      ..addAll(tmp);
  }

  List<Poll> _applyScopeFilter(List<Poll> input) {
    switch (_scopeFilter) {
      case PollScopeFilter.currentScope:
        return input;
    }
  }

  List<Poll> _applyStatusFilter(List<Poll> input) {
    switch (_statusFilter) {
      case PollStatusFilter.all:
        return input;
      case PollStatusFilter.open:
        return input.where((p) => p.status == PollStatus.open).toList();
      case PollStatusFilter.closed:
        return input.where((p) => p.status == PollStatus.closed).toList();
    }
  }

  void _sortPolls(List<Poll> list) {
    switch (_sortMode) {
      case PollSortMode.latest:
        list.sort(
          (a, b) => _sourceIndexForPoll(a).compareTo(_sourceIndexForPoll(b)),
        );
        break;
      case PollSortMode.hottest:
        list.sort(_comparePollPriority);
        break;
    }
  }

  // ===== Toggle reazioni =====

  Future<void> toggleFireForPoll({
    required String userId,
    required Poll poll,
  }) async {
    if (_isDisposed) return;

    final summary = await toggleReaction(
      userId: userId,
      target: TargetRef.poll(poll.id.value),
      type: ReactionType.like,
    );
    if (_isDisposed) return;

    _reactionSummaries[poll.id.value] = summary;

    _recomputeVisiblePolls();
    _safeNotifyListeners();
  }

  Future<void> toggleIceForPoll({
    required String userId,
    required Poll poll,
  }) async {
    if (_isDisposed) return;

    final summary = await toggleReaction(
      userId: userId,
      target: TargetRef.poll(poll.id.value),
      type: ReactionType.dislike,
    );
    if (_isDisposed) return;

    _reactionSummaries[poll.id.value] = summary;

    _recomputeVisiblePolls();
    _safeNotifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    geoScopeController.removeListener(_geoScopeListener);
    super.dispose();
  }
}
