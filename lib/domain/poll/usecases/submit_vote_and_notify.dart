import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';
import 'package:sociale_vote/domain/notifications/usecases/create_poll_result_notification.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/entities/vote.dart';
import 'package:sociale_vote/domain/poll/usecases/submit_vote.dart';

class SubmitVoteAndNotify {
  final SubmitVote _submitVote;

  /// The legacy notification dependency is intentionally kept in the
  /// constructor for source compatibility with the current DI wiring.
  /// Poll-result notifications are no longer created per submitted vote.
  SubmitVoteAndNotify(
    this._submitVote,
    CreatePollResultNotification _,
  );

  Future<void> call(
    Vote vote, {
    required Poll poll,
    required String? userId,
    required String? userCountryCode,
    ActorType actorType = ActorType.citizen,
    VerificationLevel verificationLevel = VerificationLevel.none,
  }) async {
    await _submitVote(
      vote,
      poll: poll,
      userId: userId,
      userCountryCode: userCountryCode,
      actorType: actorType,
      verificationLevel: verificationLevel,
    );
  }
}
