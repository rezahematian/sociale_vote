import '../entities/poll.dart';
import '../repositories/poll_repository.dart';

class GetPolls {
  final PollRepository repository;

  GetPolls(this.repository);

  Future<List<Poll>> call({
    String? countryCode,
    String? cityId,
  }) {
    return repository.getPolls(
      countryCode: countryCode,
      cityId: cityId,
    );
  }
}