import '../entities/poll.dart';
import '../repositories/i_poll_repository.dart';
import '../exceptions/poll_exceptions.dart';
import '../events/poll_closed_event.dart';
import '../value_objects/poll_status.dart';

class ClosePollUseCase {
  final IPollRepository pollRepository;

  ClosePollUseCase({
    required this.pollRepository,
  });

  Future<(Poll, PollClosedEvent)> execute(
    Poll poll,
  ) async {
    if (poll.isClosed) {
      throw PollClosedException();
    }

    final updated = poll.copyWith(
      status: PollStatus.closed,
    );

    await pollRepository.save(updated);

    return (updated, PollClosedEvent(updated));
  }
}