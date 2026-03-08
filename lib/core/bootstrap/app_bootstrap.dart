import 'package:sociale_vote/app/di.dart';

import '../session_manager.dart';
import '../audit/vote_audit_service.dart';

import '../../features/news/application/news_controller.dart';

class AppBootstrap {
  // =========================
  // CORE
  // =========================
  static late final SessionManager sessionManager;
  static late final VoteAuditService voteAuditService;

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

    // -------- CONTROLLERS --------
    newsController = AppDI.instance.createNewsController();
  }
}