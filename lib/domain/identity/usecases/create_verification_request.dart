import 'package:sociale_vote/domain/identity/entities/verification_request.dart';
import 'package:sociale_vote/domain/identity/repositories/verification_request_repository.dart';
import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/institution_level.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';

class CreateVerificationRequest {
  final VerificationRequestRepository _repository;

  CreateVerificationRequest(this._repository);

  Future<VerificationRequest> call({
    required String userId,
    required VerificationRequestType requestType,
    String? officialTitle,
    String? institutionName,
    InstitutionLevel? targetInstitutionLevel,
  }) {
    final normalizedOfficialTitle = _normalizeNullable(officialTitle);
    final normalizedInstitutionName = _normalizeNullable(institutionName);

    switch (requestType) {
      case VerificationRequestType.citizenLevel1:
        return _repository.createRequest(
          userId: userId,
          requestType: requestType,
          targetActorType: ActorType.citizen,
          targetVerificationLevel: VerificationLevel.level1,
        );

      case VerificationRequestType.citizenLevel2:
        return _repository.createRequest(
          userId: userId,
          requestType: requestType,
          targetActorType: ActorType.citizen,
          targetVerificationLevel: VerificationLevel.level2,
        );

      case VerificationRequestType.publicOfficial:
        if (normalizedOfficialTitle == null) {
          throw Exception('Official title obbligatorio.');
        }

        return _repository.createRequest(
          userId: userId,
          requestType: requestType,
          targetActorType: ActorType.publicOfficial,
          targetVerificationLevel: VerificationLevel.level2,
          officialTitle: normalizedOfficialTitle,
        );

      case VerificationRequestType.institution:
        if (normalizedInstitutionName == null) {
          throw Exception('Institution name obbligatorio.');
        }

        if (targetInstitutionLevel == null) {
          throw Exception('Institution level obbligatorio.');
        }

        return _repository.createRequest(
          userId: userId,
          requestType: requestType,
          targetActorType: ActorType.institution,
          targetVerificationLevel: VerificationLevel.level2,
          targetInstitutionLevel: targetInstitutionLevel,
          institutionName: normalizedInstitutionName,
        );
    }
  }

  String? _normalizeNullable(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}