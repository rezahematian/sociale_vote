import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/domain/poll/repositories/poll_repository.dart';

class UpdatePollText {
  final PollRepository _repository;

  UpdatePollText(this._repository);

  Future<Poll> call({
    required String pollId,
    required String title,
    String? description,
  }) {
    return _repository.updatePollText(
      pollId: pollId,
      title: title,
      description: description,
    );
  }
}