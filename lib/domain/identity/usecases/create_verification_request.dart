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
    String? organizationName,
    String? organizationLegalName,
    String? organizationPublicName,
    String? organizationEntityType,
    String? organizationCountryCode,
    String? organizationCity,
    String? organizationWebsiteUrl,
    String? organizationRepresentativeRole,
    String? organizationRegistryId,
    String? organizationAuthorityNote,
    InstitutionLevel? targetInstitutionLevel,
  }) {
    final normalizedUserId = userId.trim();
    final normalizedOfficialTitle = _normalizeNullable(officialTitle);
    final normalizedInstitutionName = _normalizeNullable(institutionName);
    final normalizedOrganizationName = _normalizeNullable(organizationName);
    final normalizedOrganizationLegalName =
        _normalizeNullable(organizationLegalName);
    final normalizedOrganizationPublicName =
        _normalizeNullable(organizationPublicName);
    final normalizedOrganizationEntityType =
        _normalizeNullable(organizationEntityType);
    final normalizedOrganizationCountryCode =
        _normalizeNullable(organizationCountryCode)?.toUpperCase();
    final normalizedOrganizationCity = _normalizeNullable(organizationCity);
    final normalizedOrganizationWebsiteUrl =
        _normalizeNullable(organizationWebsiteUrl);
    final normalizedOrganizationRepresentativeRole =
        _normalizeNullable(organizationRepresentativeRole);
    final normalizedOrganizationRegistryId =
        _normalizeNullable(organizationRegistryId);
    final normalizedOrganizationAuthorityNote =
        _normalizeNullable(organizationAuthorityNote);

    if (normalizedUserId.isEmpty) {
      throw ArgumentError('User id non valido.');
    }

    switch (requestType) {
      case VerificationRequestType.citizenLevel1:
        return _repository.createRequest(
          userId: normalizedUserId,
          requestType: requestType,
          targetActorType: ActorType.citizen,
          targetVerificationLevel: VerificationLevel.level1,
        );

      case VerificationRequestType.citizenLevel2:
        return _repository.createRequest(
          userId: normalizedUserId,
          requestType: requestType,
          targetActorType: ActorType.citizen,
          targetVerificationLevel: VerificationLevel.level2,
        );

      case VerificationRequestType.publicOfficial:
        if (normalizedOfficialTitle == null) {
          throw ArgumentError('Official title obbligatorio.');
        }

        return _repository.createRequest(
          userId: normalizedUserId,
          requestType: requestType,
          targetActorType: ActorType.publicOfficial,
          targetVerificationLevel: VerificationLevel.none,
          officialTitle: normalizedOfficialTitle,
        );

      case VerificationRequestType.institution:
        if (normalizedInstitutionName == null) {
          throw ArgumentError('Institution name obbligatorio.');
        }

        if (targetInstitutionLevel == null) {
          throw ArgumentError('Institution level obbligatorio.');
        }

        return _repository.createRequest(
          userId: normalizedUserId,
          requestType: requestType,
          targetActorType: ActorType.institution,
          targetVerificationLevel: VerificationLevel.none,
          targetInstitutionLevel: targetInstitutionLevel,
          institutionName: normalizedInstitutionName,
        );

      case VerificationRequestType.organization:
        if (normalizedOrganizationName == null ||
            normalizedOrganizationLegalName == null ||
            normalizedOrganizationPublicName == null ||
            normalizedOrganizationEntityType == null ||
            normalizedOrganizationCountryCode == null ||
            normalizedOrganizationRepresentativeRole == null ||
            normalizedOrganizationAuthorityNote == null) {
          throw ArgumentError('Organization verification data incomplete.');
        }
        if (!RegExp(r'^[A-Z]{2}$')
            .hasMatch(normalizedOrganizationCountryCode)) {
          throw ArgumentError('Organization country code non valido.');
        }

        return _repository.createRequest(
          userId: normalizedUserId,
          requestType: requestType,
          targetActorType: ActorType.organization,
          targetVerificationLevel: VerificationLevel.none,
          organizationName: normalizedOrganizationName,
          organizationLegalName: normalizedOrganizationLegalName,
          organizationPublicName: normalizedOrganizationPublicName,
          organizationEntityType: normalizedOrganizationEntityType,
          organizationCountryCode: normalizedOrganizationCountryCode,
          organizationCity: normalizedOrganizationCity,
          organizationWebsiteUrl: normalizedOrganizationWebsiteUrl,
          organizationRepresentativeRole:
              normalizedOrganizationRepresentativeRole,
          organizationRegistryId: normalizedOrganizationRegistryId,
          organizationAuthorityNote: normalizedOrganizationAuthorityNote,
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
