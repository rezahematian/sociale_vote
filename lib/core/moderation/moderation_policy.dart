import 'moderation_decision.dart';
import 'moderation_action.dart';

class ModerationPolicy {
  static ModerationDecision evaluateText(String text) {
    final normalized = text.toLowerCase();

    if (normalized.contains('spam')) {
      return const ModerationDecision(
        action: ModerationAction.remove,
        reason: 'Spam detected',
      );
    }

    if (normalized.contains('hate')) {
      return const ModerationDecision(
        action: ModerationAction.banUser,
        reason: 'Hate speech',
      );
    }

    if (normalized.length < 3) {
      return const ModerationDecision(
        action: ModerationAction.hide,
        reason: 'Low quality content',
      );
    }

    return ModerationDecision.none;
  }
}
