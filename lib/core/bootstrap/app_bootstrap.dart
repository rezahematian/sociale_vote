import 'package:sociale_vote/app/di.dart';

import '../session_manager.dart';
import '../audit/vote_audit_service.dart';

// Poll + News services usati dalla home "legacy"
import '../../features/poll/poll_service.dart';
import '../../features/poll/vote_service.dart';
import '../../features/news/application/news_controller.dart';

class AppBootstrap {
  // =========================
  // CORE
  // =========================
  static late final SessionManager sessionManager;
  static late final VoteAuditService voteAuditService;

  // =========================
  // SERVICES
  // =========================
  static late final PollService pollService;
  static late final VoteService voteService;

  // =========================
  // CONTROLLERS
  // =========================
  static late final NewsController newsController;

  // =========================
  // INIT
  // =========================
  static void init() {
    // -------- CORE --------
    sessionManager = SessionManager();
    voteAuditService = VoteAuditService();

    // -------- SERVICES (single source of truth = AppDI) --------
    //
    // AppDI deve fornire le dipendenze concrete (repository impl).
    // Se non esistono ancora questi getter/metodi, il prossimo step
    // è aggiungerli in lib/app/di.dart (non in questo file).
    pollService = AppDI.instance.pollService;
    voteService = AppDI.instance.voteService;

    // -------- CONTROLLERS --------
    newsController = AppDI.instance.createNewsController();
  }
}