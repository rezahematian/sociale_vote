import 'package:sociale_vote/domain/identity/entities/verification_request.dart';
import 'package:sociale_vote/domain/identity/repositories/user_profile_repository.dart';
import 'package:sociale_vote/domain/identity/repositories/verification_request_repository.dart';
import 'package:sociale_vote/domain/identity/usecases/review_verification_request.dart';
import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_status.dart';

class ReviewVerificationRequestAndUpdateProfile {
  final VerificationRequestRepository _verificationRequestRepository;
  final UserProfileRepository _userProfileRepository;
  final ReviewVerificationRequest _reviewVerificationRequest;

  ReviewVerificationRequestAndUpdateProfile({
    required VerificationRequestRepository verificationRequestRepository,
    required UserProfileRepository userProfileRepository,
    required ReviewVerificationRequest reviewVerificationRequest,
  })  : _verificationRequestRepository = verificationRequestRepository,
        _userProfileRepository = userProfileRepository,
        _reviewVerificationRequest = reviewVerificationRequest;

  Future<VerificationRequest> call({
    required String requestId,
    required VerificationRequestStatus status,
    required String reviewedBy,
    String? reviewNote,
  }) async {
    final normalizedRequestId = requestId.trim();
    final normalizedReviewedBy = reviewedBy.trim();

    if (normalizedRequestId.isEmpty) {
      throw ArgumentError('Request id non valido.');
    }

    if (normalizedReviewedBy.isEmpty) {
      throw ArgumentError('Reviewed by non valido.');
    }

    final existingRequest =
        await _verificationRequestRepository.getById(normalizedRequestId);

    if (existingRequest == null) {
      throw Exception('Richiesta verifica non trovata.');
    }

    if (existingRequest.status != VerificationRequestStatus.pending) {
      throw Exception('La richiesta non è più pending.');
    }

    final currentProfile =
        await _userProfileRepository.getUserProfile(existingRequest.userId);

    if (currentProfile == null) {
      throw Exception('Profilo utente non trovato.');
    }

    final reviewedRequest = await _reviewVerificationRequest.call(
      requestId: normalizedRequestId,
      status: status,
      reviewedBy: normalizedReviewedBy,
      reviewNote: reviewNote,
    );

    if (status == VerificationRequestStatus.approved) {
      await _userProfileRepository.updateIdentityState(
        userId: reviewedRequest.userId,
        actorType: reviewedRequest.targetActorType,
        verificationLevel: reviewedRequest.targetVerificationLevel,
        verificationStatus: VerificationStatus.none,
        institutionLevel:
            reviewedRequest.targetActorType == ActorType.institution
                ? reviewedRequest.targetInstitutionLevel
                : null,
        officialTitle:
            reviewedRequest.targetActorType == ActorType.publicOfficial
                ? reviewedRequest.officialTitle
                : null,
        institutionName:
            reviewedRequest.targetActorType == ActorType.institution
                ? reviewedRequest.institutionName
                : null,
        verificationRequestedAt: reviewedRequest.submittedAt,
        verifiedAt: reviewedRequest.reviewedAt ?? DateTime.now(),
      );

      return reviewedRequest;
    }

    if (status == VerificationRequestStatus.rejected) {
      await _userProfileRepository.updateIdentityState(
        userId: reviewedRequest.userId,
        actorType: currentProfile.actorType,
        verificationLevel: currentProfile.verificationLevel,
        verificationStatus: VerificationStatus.rejected,
        institutionLevel: currentProfile.institutionLevel,
        officialTitle: currentProfile.officialTitle,
        institutionName: currentProfile.institutionName,
        verificationRequestedAt: reviewedRequest.submittedAt,
        verifiedAt: currentProfile.verifiedAt,
      );

      return reviewedRequest;
    }

    throw ArgumentError('Lo stato review deve essere approved o rejected.');
  }
}