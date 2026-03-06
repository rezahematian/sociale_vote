import '../entities/poll.dart';
import '../repositories/poll_repository.dart';
import '../value_objects/poll_id.dart';

class GetPollDetail {
  final PollRepository repository;

  GetPollDetail(this.repository);

  Future<Poll?> call(PollId pollId) {
    return repository.getPollDetail(pollId);
  }
}