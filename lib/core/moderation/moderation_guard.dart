import 'moderation_service.dart';
import 'moderation_decision.dart';
import 'moderation_action.dart';

class ModerationGuard {
  final ModerationService service;

  ModerationGuard(this.service);

  void enforceAllowed(String text) {
    final decision = service.moderateText(text);

    if (decision.action == ModerationAction.banUser ||
        decision.action == ModerationAction.remove) {
      throw Exception(decision.reason);
    }
  }

  ModerationDecision preview(String text) {
    return service.moderateText(text);
  }
}
