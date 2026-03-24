import 'package:flutter/foundation.dart';
import 'package:sociale_vote/domain/notifications/usecases/create_poll_result_notification.dart';
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/entities/vote.dart';
import 'package:sociale_vote/domain/poll/usecases/submit_vote.dart';

class SubmitVoteAndNotify {
  final SubmitVote _submitVote;
  final CreatePollResultNotification _createPollResultNotification;

  SubmitVoteAndNotify(
    this._submitVote,
    this._createPollResultNotification,
  );

  Future<void> call(
    Vote vote, {
    required Poll poll,
    required String? userId,
    required String? userCountryCode,
  }) async {
    await _submitVote(
      vote,
      poll: poll,
      userId: userId,
      userCountryCode: userCountryCode,
    );

    try {
      final notification = await _createPollResultNotification(
        poll: poll,
        actorUserId: userId,
      );

      debugPrint(
        'SubmitVoteAndNotify poll notification result: '
        '${notification == null ? 'null' : notification.id}',
      );
    } catch (e, st) {
      debugPrint('SubmitVoteAndNotify poll notification error: $e');
      debugPrint('$st');
    }
  }
}