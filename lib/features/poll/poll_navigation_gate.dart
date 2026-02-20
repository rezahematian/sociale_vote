import 'package:flutter/material.dart';

import '../../core/session_manager.dart';
import '../../core/security/vote_guard.dart';
import '../../core/audit/vote_audit_service.dart';

import '../../domain/poll/voting_policy.dart';
import '../../domain/user/user_identity.dart';

import '../comment/comment_controller.dart';
import '../comment/comment_service.dart';

import 'poll_controller.dart';
import 'poll_repository.dart';
import 'poll_service.dart';
import 'vote_repository.dart';
import 'vote_service.dart';
import 'poll_detail_screen.dart';

/// Scope geografico del Poll
enum PollScope {
  global,
  country,
  city,
}

/// PollNavigationGate
///
/// Punto centrale di accesso al dettaglio di un sondaggio.
///
/// Responsabilità:
/// - Verificare autenticazione
/// - Gestire contesto geografico del poll
/// - Preparare le dipendenze
/// - Caricare il poll
/// - Navigare verso PollDetailScreen
///
/// NON fa:
/// - UI
/// - Logica di voto
/// - Fetch diretto nel widget
class PollNavigationGate {
  PollNavigationGate._();

  static final SessionManager _session = SessionManager();

  /// Entry point unico
  static Future<void> openPoll(
    BuildContext context, {
    required String pollId,
    required PollScope scope,
    String? locationId,
  }) async {
    if (!_session.isAuthenticated) {
      _showAuthRequired(context);
      return;
    }

    // Guardia di coerenza
    if (scope == PollScope.city && locationId == null) {
      throw ArgumentError(
        'PollScope.city richiede un locationId',
      );
    }

    await _goToPollDetail(
      context,
      pollId: pollId,
      scope: scope,
      locationId: locationId,
    );
  }

  // =========================
  // PRIVATE
  // =========================

  static Future<void> _goToPollDetail(
    BuildContext context, {
    required String pollId,
    required PollScope scope,
    String? locationId,
  }) async {
    debugPrint(
      '🗳️ Apertura poll: $pollId | scope=$scope | location=$locationId',
    );

    // =========================
    // DEPENDENCIES
    // =========================

    // Poll
    final pollRepository = PollRepository();
    final pollService = PollService(pollRepository);

    // Vote
    final voteService = VoteService();
    final voteRepository = VoteRepository(
      voteService: voteService,
    );

    // Core
    final votingPolicy = VotingPolicy();
    final auditService = VoteAuditService();
    final voteGuard = VoteGuard();
    final sessionManager = _session;

    final pollController = PollController(
      pollService: pollService,
      voteRepository: voteRepository,
      votingPolicy: votingPolicy,
      auditService: auditService,
      sessionManager: sessionManager,
      voteGuard: voteGuard,
    );

    // Commenti
    final commentService = CommentService();
    final commentController = CommentController(commentService);

    final UserIdentity currentUser =
        sessionManager.currentUser as UserIdentity;

    // =========================
    // LOAD POLL BEFORE NAV
    // =========================
    await pollController.loadPoll(pollId);

    // =========================
    // NAVIGATION
    // =========================
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PollDetailScreen(
          pollId: pollId,
          pollController: pollController,
          commentController: commentController,
          currentUser: currentUser,
        ),
      ),
    );
  }

  static void _showAuthRequired(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Devi essere autenticato per partecipare al voto'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
