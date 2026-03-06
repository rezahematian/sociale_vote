import '../entities/poll.dart';

abstract class IPollRepository {
  Future<void> save(Poll poll);
}