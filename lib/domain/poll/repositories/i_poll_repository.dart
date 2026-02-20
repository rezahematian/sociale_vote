import '../entities/poll_entity.dart';

abstract class IPollRepository {
  Future<void> save(PollEntity poll);
}
