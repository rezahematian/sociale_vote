import 'moderation_policy.dart';
import 'moderation_decision.dart';

class ModerationService {
  ModerationDecision moderateText(String text) {
    return ModerationPolicy.evaluateText(text);
  }
}
