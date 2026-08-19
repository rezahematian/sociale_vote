import 'package:sociale_vote/domain/identity/entities/verification_request.dart';
import 'package:sociale_vote/domain/identity/repositories/verification_request_repository.dart';
import 'package:sociale_vote/domain/identity/usecases/review_verification_request.dart';
import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';

class ReviewVerificationRequestAndUpdateProfile {
  final VerificationRequestRepository _verificationRequestRepository;
  final ReviewVerificationRequest _reviewVerificationRequest;

  ReviewVerificationRequestAndUpdateProfile({
    required VerificationRequestRepository verificationRequestRepository,
    required ReviewVerificationRequest reviewVerificationRequest,
  })  : _verificationRequestRepository = verificationRequestRepository,
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

    if (status == VerificationRequestStatus.approved) {
      _validateApprovedRequest(existingRequest);
    }

    return _reviewVerificationRequest.call(
      requestId: normalizedRequestId,
      status: status,
      reviewedBy: normalizedReviewedBy,
      reviewNote: normalizedReviewNote,
    );
  }

  void _validateApprovedRequest(VerificationRequest request) {
    if ((request.targetActorType == ActorType.citizen ||
            request.targetActorType == ActorType.publicOfficial) &&
        _normalizeCountryCode(request.votingCountryCode) == null) {
      throw Exception(
        'Per approvare questa verifica serve un paese di voto valido.',
      );
    }

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
        if (request.targetVerificationLevel != VerificationLevel.none) {
          throw Exception(
            'Un public official non deve avere un livello Persona.',
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
        if (request.targetVerificationLevel != VerificationLevel.none) {
          throw Exception(
            'Una institution non deve avere un livello Persona.',
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

      case VerificationRequestType.organization:
        if (request.targetActorType != ActorType.organization) {
          throw Exception(
            'Una richiesta organization deve portare a actorType organization.',
          );
        }
        if (request.targetVerificationLevel != VerificationLevel.none) {
          throw Exception(
            'Una organization non deve avere un livello Persona.',
          );
        }
        if (_normalizeNullableText(request.organizationName) == null) {
          throw Exception(
            'Per approvare una organization serve organizationName.',
          );
        }
        break;
    }
  }

  String? _normalizeCountryCode(String? value) {
    final normalized = value?.trim().toUpperCase();
    if (normalized == null ||
        normalized.isEmpty ||
        !RegExp(r'^[A-Z]{2}$').hasMatch(normalized)) {
      return null;
    }
    return normalized;
  }

  String? _normalizeNullableText(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}
