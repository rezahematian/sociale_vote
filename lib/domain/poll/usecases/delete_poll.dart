import 'package:sociale_vote/domain/poll/repositories/poll_repository.dart';

class DeletePoll {
  final PollRepository _repository;

  DeletePoll(this._repository);

  Future<void> call(String pollId) {
    return _repository.deletePoll(pollId);
  }
}