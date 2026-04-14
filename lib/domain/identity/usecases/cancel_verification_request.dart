import 'package:sociale_vote/domain/identity/entities/verification_request.dart';
import 'package:sociale_vote/domain/identity/repositories/verification_request_repository.dart';

class CancelVerificationRequest {
  final VerificationRequestRepository _repository;

  CancelVerificationRequest(this._repository);

  Future<VerificationRequest> call({
    required String requestId,
  }) {
    final normalizedRequestId = requestId.trim();
    if (normalizedRequestId.isEmpty) {
      throw ArgumentError('Request id non valido.');
    }

    return _repository.cancelRequest(
      requestId: normalizedRequestId,
    );
  }
}