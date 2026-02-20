import '../entities/poll_entity.dart';
import '../repositories/i_poll_repository.dart';
import '../exceptions/poll_exceptions.dart';
import '../events/poll_closed_event.dart';

class ClosePollUseCase {
  final IPollRepository pollRepository;

  ClosePollUseCase({
    required this.pollRepository,
  });

  Future<(PollEntity, PollClosedEvent)> execute(
    PollEntity poll,
  ) async {
    if (poll.isClosed) {
      throw PollClosedException();
    }

    final updated = poll.copyWith(isClosed: true);

    await pollRepository.save(updated);

    return (updated, PollClosedEvent(updated));
  }
}
