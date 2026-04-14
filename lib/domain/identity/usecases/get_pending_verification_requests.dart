import 'package:sociale_vote/domain/identity/entities/verification_request.dart';
import 'package:sociale_vote/domain/identity/repositories/verification_request_repository.dart';

class GetPendingVerificationRequests {
  final VerificationRequestRepository _repository;

  GetPendingVerificationRequests(this._repository);

  Future<List<VerificationRequest>> call({
    int limit = 50,
    int offset = 0,
  }) {
    if (limit <= 0) {
      throw ArgumentError('Limit non valido.');
    }

    if (offset < 0) {
      throw ArgumentError('Offset non valido.');
    }

    return _repository.getPendingRequests(
      limit: limit,
      offset: offset,
    );
  }
}