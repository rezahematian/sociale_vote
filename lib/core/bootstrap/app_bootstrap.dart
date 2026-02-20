import '../session_manager.dart';
import '../audit/vote_audit_service.dart';

import '../../domain/poll/voting_policy.dart';
import '../../domain/poll/vote_guard.dart';

import '../../features/poll/poll_controller.dart';
import '../../features/poll/poll_service.dart';
import '../../features/poll/poll_repository.dart';
import '../../features/poll/vote_service.dart';
import '../../features/poll/vote_repository.dart';

import '../../features/news/news_controller.dart';
import '../../features/news/news_service.dart';

class AppBootstrap {
  // =========================
  // CORE
  // =========================
  static late final SessionManager sessionManager;
  static late final VoteGuard voteGuard;
  static late final VoteAuditService voteAuditService;
  static late final VotingPolicy votingPolicy;

  // =========================
  // REPOSITORIES (DATASOURCE)
  // =========================
  static late final PollRepository pollRepository;
  static late final VoteRepository voteRepository;

  // =========================
  // SERVICES (DOMAIN)
  // =========================
  static late final PollService pollService;
  static late final VoteService voteService;
  static late final NewsService newsService;

  // =========================
  // CONTROLLERS
  // =========================
  static late final PollController pollController;
  static late final NewsController newsController;

  // =========================
  // INIT
  // =========================
  static void init() {
    // -------- CORE --------
    sessionManager = SessionManager();
    votingPolicy = const VotingPolicy();
    voteGuard = VoteGuard(
      votingPolicy: votingPolicy,
    );
    voteAuditService = VoteAuditService();

    // -------- REPOSITORIES --------
    pollRepository = PollRepository();
    voteService = VoteService();

    voteRepository = VoteRepository(
      voteService: voteService,
    );

    // -------- SERVICES --------
    pollService = PollService(pollRepository);
    newsService = NewsService();

    // -------- CONTROLLERS --------
    pollController = PollController(
      pollService: pollService,
      voteRepository: voteRepository,
      votingPolicy: votingPolicy,
      auditService: voteAuditService,
      sessionManager: sessionManager,
      voteGuard: voteGuard,
    );

    newsController = NewsController(newsService);
  }
}
