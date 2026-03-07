import 'package:flutter/foundation.dart';

import '../../core/session_manager.dart';
import '../../core/audit/vote_audit_service.dart';

import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/entities/vote.dart';
import 'package:sociale_vote/domain/poll/usecases/submit_vote.dart';

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
  final SubmitVote submitVote;
  final VoteAuditService auditService;
  final SessionManager sessionManager;

  PollController({
    required this.pollService,
    required this.submitVote,
    required this.auditService,
    required this.sessionManager,
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
  List<Poll> _polls = [];
  List<Poll> get polls => List.unmodifiable(_polls);

  Future<void> loadPolls() async {
    if (isLoading) return;

    _setStatus(PollControllerStatus.loading);

    try {
      final polls = await pollService.getActivePolls();

      _polls = List<Poll>.from(polls);

      _errorMessage = null;
      _setStatus(PollControllerStatus.idle);
    } catch (e) {
      _fail(e.toString());
    }
  }

  // =========================
  // CURRENT POLL
  // =========================
  Poll? _currentPoll;
  Poll? get currentPoll => _currentPoll;

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

    // Il dominio "pulito" non tiene userHasVoted nel Poll.
    // La verifica "già votato" viene fatta nel SubmitVote via repository.
    return PollUserState.canVote;
  }

  bool get canVote => pollUserState == PollUserState.canVote;

  // Nel dominio pulito, visibilità risultati è gestita da PollResultController/VisibilityResolver.
  // Qui lasciamo solo un fallback conservativo.
  bool get resultsVisible => pollUserState == PollUserState.closed;

  // =========================
  // VOTE FLOW (CLEAN)
  // =========================
  Future<void> vote({
    required String pollId,
    required List<String> optionIds,
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

      final vote = Vote.now(
        pollId: poll.id,
        optionIds: optionIds,
      );

      await submitVote(
        vote,
        poll: poll,
        userId: user.id,
        userCountryCode: null,
      );

      await auditService.logVote(vote);

      // 🔄 Refresh poll dal backend
      final refreshed = await pollService.getPollById(pollId);
      _currentPoll = refreshed;

      // 🔄 Update lista locale
      _polls = _polls
          .map((p) => p.id.value == pollId ? refreshed : p)
          .toList(growable: false);

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