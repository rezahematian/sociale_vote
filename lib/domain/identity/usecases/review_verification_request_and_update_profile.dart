import 'package:sociale_vote/domain/identity/entities/verification_request.dart';
import 'package:sociale_vote/domain/identity/repositories/user_profile_repository.dart';
import 'package:sociale_vote/domain/identity/repositories/verification_request_repository.dart';
import 'package:sociale_vote/domain/identity/usecases/review_verification_request.dart';
import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';
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
    final normalizedReviewNote = _normalizeNullableText(reviewNote);

    if (normalizedRequestId.isEmpty) {
      throw ArgumentError('Request id non valido.');
    }

    if (normalizedReviewedBy.isEmpty) {
      throw ArgumentError('Reviewed by non valido.');
    }

    if (status != VerificationRequestStatus.approved &&
        status != VerificationRequestStatus.rejected) {
      throw ArgumentError('Lo stato review deve essere approved o rejected.');
    }

    if (status == VerificationRequestStatus.rejected &&
        normalizedReviewNote == null) {
      throw ArgumentError(
        'Review note obbligatoria per rifiutare la richiesta.',
      );
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

    if (status == VerificationRequestStatus.approved) {
      _validateApprovedRequest(existingRequest);
    }

    final reviewedRequest = await _reviewVerificationRequest.call(
      requestId: normalizedRequestId,
      status: status,
      reviewedBy: normalizedReviewedBy,
      reviewNote: normalizedReviewNote,
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
                ? _normalizeNullableText(reviewedRequest.officialTitle)
                : null,
        institutionName:
            reviewedRequest.targetActorType == ActorType.institution
                ? _normalizeNullableText(reviewedRequest.institutionName)
                : null,
        verificationRequestedAt: reviewedRequest.submittedAt,
        verifiedAt: reviewedRequest.reviewedAt ?? DateTime.now(),
      );

      return reviewedRequest;
    }

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

  void _validateApprovedRequest(VerificationRequest request) {
    switch (request.requestType) {
      case VerificationRequestType.citizenLevel1:
        if (request.targetActorType != ActorType.citizen) {
          throw Exception('Una richiesta citizen level1 deve restare citizen.');
        }
        if (request.targetVerificationLevel != VerificationLevel.level1) {
          throw Exception(
            'Una richiesta citizen level1 deve portare a verification level1.',
          );
        }
        break;

      case VerificationRequestType.citizenLevel2:
        if (request.targetActorType != ActorType.citizen) {
          throw Exception('Una richiesta citizen level2 deve restare citizen.');
        }
        if (request.targetVerificationLevel != VerificationLevel.level2) {
          throw Exception(
            'Una richiesta citizen level2 deve portare a verification level2.',
          );
        }
        break;

      case VerificationRequestType.publicOfficial:
        if (request.targetActorType != ActorType.publicOfficial) {
          throw Exception(
            'Una richiesta public official deve portare a actorType publicOfficial.',
          );
        }
        if (request.targetVerificationLevel != VerificationLevel.level2) {
          throw Exception(
            'Un public official approvato deve avere verification level2.',
          );
        }
        if (_normalizeNullableText(request.officialTitle) == null) {
          throw Exception(
            'Per approvare un public official serve officialTitle.',
          );
        }
        break;

      case VerificationRequestType.institution:
        if (request.targetActorType != ActorType.institution) {
          throw Exception(
            'Una richiesta institution deve portare a actorType institution.',
          );
        }
        if (request.targetVerificationLevel != VerificationLevel.level2) {
          throw Exception(
            'Una institution approvata deve avere verification level2.',
          );
        }
        if (request.targetInstitutionLevel == null) {
          throw Exception(
            'Per approvare una institution serve institutionLevel.',
          );
        }
        if (_normalizeNullableText(request.institutionName) == null) {
          throw Exception(
            'Per approvare una institution serve institutionName.',
          );
        }
        break;
    }
  }

  String? _normalizeNullableText(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}