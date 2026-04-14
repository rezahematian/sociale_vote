import 'package:sociale_vote/domain/identity/entities/verification_request.dart';
import 'package:sociale_vote/domain/identity/repositories/verification_request_repository.dart';

class ReviewVerificationRequest {
  final VerificationRequestRepository _repository;

  ReviewVerificationRequest(this._repository);

  Future<VerificationRequest> call({
    required String requestId,
    required VerificationRequestStatus status,
    required String reviewedBy,
    String? reviewNote,
  }) {
    final normalizedRequestId = requestId.trim();
    final normalizedReviewedBy = reviewedBy.trim();

    if (normalizedRequestId.isEmpty) {
      throw ArgumentError('Request id non valido.');
    }

    if (normalizedReviewedBy.isEmpty) {
      throw ArgumentError('Reviewed by non valido.');
    }

    if (status == VerificationRequestStatus.pending ||
        status == VerificationRequestStatus.cancelled) {
      throw ArgumentError('Lo stato review deve essere approved o rejected.');
    }

    return _repository.reviewRequest(
      requestId: normalizedRequestId,
      status: status,
      reviewedBy: normalizedReviewedBy,
      reviewNote: reviewNote?.trim(),
    );
  }
}