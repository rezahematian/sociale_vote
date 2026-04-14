import 'package:sociale_vote/domain/identity/entities/verification_request.dart';
import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/institution_level.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';

abstract class VerificationRequestRepository {
  Future<VerificationRequest?> getById(String requestId);

  Future<VerificationRequest?> getPendingRequestForUser(String userId);

  Future<List<VerificationRequest>> getRequestsForUser(String userId);

  Future<List<VerificationRequest>> getPendingRequests({
    int limit = 50,
    int offset = 0,
  });

  Future<VerificationRequest> createRequest({
    required String userId,
    required VerificationRequestType requestType,
    required ActorType targetActorType,
    required VerificationLevel targetVerificationLevel,
    InstitutionLevel? targetInstitutionLevel,
    String? officialTitle,
    String? institutionName,
  });

  Future<VerificationRequest> reviewRequest({
    required String requestId,
    required VerificationRequestStatus status,
    required String reviewedBy,
    String? reviewNote,
  });

  Future<VerificationRequest> cancelRequest({
    required String requestId,
  });
}