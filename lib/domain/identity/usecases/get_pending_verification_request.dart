import 'package:sociale_vote/domain/identity/entities/verification_request.dart';
import 'package:sociale_vote/domain/identity/repositories/verification_request_repository.dart';

class GetPendingVerificationRequest {
  final VerificationRequestRepository _repository;

  GetPendingVerificationRequest(this._repository);

  Future<VerificationRequest?> call(String userId) {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      throw ArgumentError('User id non valido.');
    }

    return _repository.getPendingRequestForUser(normalizedUserId);
  }
}