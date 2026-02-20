import 'package:flutter/foundation.dart';

import '../../core/session_manager.dart';
import '../data/vote_repository.dart';

import '../domain/entities/poll_entity.dart';
import '../domain/entities/vote_entity.dart';
import '../domain/entities/vote_request.dart';
import '../domain/services/vote_guard.dart';
import '../domain/value_objects/voting_policy.dart';

import '../../core/audit/vote_audit_service.dart';
import '../poll_service.dart';

enum PollControllerStatus {
  idle,
  loading,
  voting,
  success,
  error,
}

enum PollUserState {
  canVote,
  voted,
  closed,
}

class PollController extends ChangeNotifier {
  // =========================
  // DEPENDENCIES
  // =========================
  final PollService pollService;
  final VoteRepository voteRepository;
  final VotingPolicy votingPolicy;
  final VoteAuditService auditService;
  final SessionManager sessionManager;
  final VoteGuard voteGuard;

  PollController({
    required this.pollService,
    required this.voteRepository,
    required this.votingPolicy,
    required this.auditService,
    required this.sessionManager,
    required this.voteGuard,
  });

  // =========================
  // STATE
  // =========================
  PollControllerStatus _status = PollControllerStatus.idle;
  PollControllerStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isLoading =>
      _status == PollControllerStatus.loading ||
      _status == PollControllerStatus.voting;

  // =========================
  // POLLS LIST
  // =========================
  List<PollEntity> _polls = [];
  List<PollEntity> get polls => List.unmodifiable(_polls);

  /// Ranking principale (Home Map / Feed)
  List<PollEntity> get rankedPolls {
    final sorted = [..._polls];
    sorted.sort(
      (a, b) => b.trendingScore.compareTo(a.trendingScore),
    );
    return sorted;
  }

  /// 🔥 Solo hot
  List<PollEntity> get hotPolls =>
      rankedPolls.where((p) => p.isHot).toList();

  /// 🚀 Trending
  List<PollEntity> get trendingPolls =>
      rankedPolls.where((p) => p.isTrending).toList();

  /// ⚖️ Controversial
  List<PollEntity> get controversialPolls =>
      rankedPolls.where((p) => p.isControversial).toList();

  Future<void> loadPolls() async {
    if (isLoading) return;

    _setStatus(PollControllerStatus.loading);

    try {
      final polls = await pollService.getActivePolls();

      _polls = [...polls]
        ..sort(
          (a, b) =>
              b.trendingScore.compareTo(a.trendingScore),
        );

      _errorMessage = null;
      _setStatus(PollControllerStatus.idle);
    } catch (e) {
      _fail(e.toString());
    }
  }

  // =========================
  // CURRENT POLL
  // =========================
  PollEntity? _currentPoll;
  PollEntity? get currentPoll => _currentPoll;

  Future<void> loadPoll(String pollId) async {
    if (isLoading) return;

    _setStatus(PollControllerStatus.loading);

    try {
      _currentPoll = await pollService.getPollById(pollId);
      _errorMessage = null;
      _setStatus(PollControllerStatus.idle);
    } catch (e) {
      _fail(e.toString());
    }
  }

  // =========================
  // USER STATE
  // =========================
  PollUserState get pollUserState {
    final poll = _currentPoll;

    if (poll == null) return PollUserState.closed;
    if (!poll.isOpen) return PollUserState.closed;
    if (poll.userHasVoted) return PollUserState.voted;

    return PollUserState.canVote;
  }

  bool get canVote => pollUserState == PollUserState.canVote;
  bool get hasVoted => pollUserState == PollUserState.voted;

  bool get resultsVisible =>
      pollUserState == PollUserState.voted ||
      pollUserState == PollUserState.closed;

  // =========================
  // VOTE FLOW
  // =========================
  Future<void> vote({
    required String pollId,
    required List<VoteSelection> selections,
  }) async {
    if (_status == PollControllerStatus.voting) return;

    final user = sessionManager.currentUser;

    if (user == null) {
      _fail('Utente non autenticato');
      return;
    }

    _setStatus(PollControllerStatus.voting);

    try {
      final poll = await pollService.getPollById(pollId);

      final request = VoteRequest(
        pollId: poll.id,
        userId: user.id,
        timestamp: DateTime.now(),
        selections: selections,
      );

      voteGuard.ensureCanVote(
        userId: user.id,
        poll: poll,
        request: request,
      );

      final VoteEntity vote =
          await voteRepository.submitVote(request);

      await auditService.logVote(vote);

      // 🔄 Refresh poll dal backend
      final refreshed =
          await pollService.getPollById(pollId);

      _currentPoll = refreshed;

      // 🔄 Update lista locale senza ricaricare tutto
      _polls = _polls
          .map((p) => p.id == pollId ? refreshed : p)
          .toList()
        ..sort(
          (a, b) =>
              b.trendingScore.compareTo(a.trendingScore),
        );

      _errorMessage = null;
      _setStatus(PollControllerStatus.success);

      Future.microtask(() {
        _status = PollControllerStatus.idle;
        notifyListeners();
      });
    } catch (e) {
      _fail(e.toString());
    }
  }

  // =========================
  // INTERNAL
  // =========================
  void _setStatus(PollControllerStatus status) {
    _status = status;
    notifyListeners();
  }

  void _fail(String message) {
    _errorMessage = message;
    _status = PollControllerStatus.error;
    notifyListeners();
  }

  void reset() {
    _status = PollControllerStatus.idle;
    _currentPoll = null;
    _polls = [];
    _errorMessage = null;
    notifyListeners();
  }
}
