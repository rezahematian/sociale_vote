import 'package:flutter/material.dart';
import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/engagement/entities/reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/usecases/get_reaction_summary.dart';
import 'package:sociale_vote/domain/engagement/usecases/toggle_reaction.dart';
import 'package:sociale_vote/domain/engagement/value_objects/reaction_type.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
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
  final GeoScopeController geoScopeController;
  final ToggleReaction toggleReaction;
  final GetReactionSummary getReactionSummary;

  late final VoidCallback _geoScopeListener;

  String? _lastKnownUserId;
  bool _isDisposed = false;

  // ===== Filtri / ordinamento =====
  PollSortMode _sortMode = PollSortMode.latest;
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

  PollListController({
    required this.getPollsUseCase,
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
    _currentOffset = 0;
    _hasMoreFromSource = true;

    await _loadNextPage();
    if (_isDisposed) return;

    _isLoading = false;
    _safeNotifyListeners();
  }

  Future<void> loadMorePolls() async {
    if (_isDisposed) return;
    if (_isLoading) return;
    if (!_hasMoreFromSource) return;

    _isLoading = true;
    _safeNotifyListeners();

    await _loadNextPage();
    if (_isDisposed) return;

    _isLoading = false;
    _safeNotifyListeners();
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
    _allPolls.addAll(result);

    await _loadReactionSummariesForPolls(result);
    if (_isDisposed) return;

    _recomputeVisiblePolls();
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

  // ===== Reaction helpers =====

  ReactionSummary? _summaryForPoll(Poll poll) {
    return _reactionSummaries[poll.id.value];
  }

  int likeCountForPoll(Poll poll) => _summaryForPoll(poll)?.likeCount ?? 0;

  int dislikeCountForPoll(Poll poll) =>
      _summaryForPoll(poll)?.dislikeCount ?? 0;

  ReactionType? userReactionForPoll(Poll poll) =>
      _summaryForPoll(poll)?.userReaction;

  double _heatForPoll(Poll poll) {
    final summary = _summaryForPoll(poll);
    if (summary == null) return 0;
    return (summary.likeCount - summary.dislikeCount).toDouble();
  }

  // ===== Filtri + ordinamento =====

  void _recomputeVisiblePolls() {
    // Partiamo sempre da tutti i poll dello scope corrente.
    var tmp = List<Poll>.from(_allPolls);

    // 1) Filtro di scope logico (V1: currentScope → nessun cambio).
    tmp = _applyScopeFilter(tmp);

    // 2) Filtro di stato (open/closed/all).
    tmp = _applyStatusFilter(tmp);

    // 3) Ordinamento Latest / Hottest.
    _sortPolls(tmp);

    _visiblePolls
      ..clear()
      ..addAll(tmp);
  }

  List<Poll> _applyScopeFilter(List<Poll> input) {
    switch (_scopeFilter) {
      case PollScopeFilter.currentScope:
        // V1: i poll sono già filtrati per scope lato use case (GeoScopeController),
        // quindi non modifichiamo la lista.
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
        // V1: manteniamo l'ordine di arrivo dal repository
        // (considerato già "latest" lato sorgente).
        break;
      case PollSortMode.hottest:
        list.sort(
          (a, b) => _heatForPoll(b).compareTo(_heatForPoll(a)),
        );
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