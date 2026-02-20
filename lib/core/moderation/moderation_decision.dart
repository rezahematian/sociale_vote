import 'moderation_action.dart';

class ModerationDecision {
  final ModerationAction action;
  final String reason;

  const ModerationDecision({
    required this.action,
    required this.reason,
  });

  static const none =
      ModerationDecision(action: ModerationAction.none, reason: '');
}
