import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/institution_level.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';

enum VerificationRequestType {
  citizenLevel1,
  citizenLevel2,
  publicOfficial,
  institution,
  organization,
}

extension VerificationRequestTypeX on VerificationRequestType {
  String get storageKey {
    switch (this) {
      case VerificationRequestType.citizenLevel1:
        return 'citizen_level1';
      case VerificationRequestType.citizenLevel2:
        return 'citizen_level2';
      case VerificationRequestType.publicOfficial:
        return 'public_official';
      case VerificationRequestType.institution:
        return 'institution';
      case VerificationRequestType.organization:
        return 'organization';
    }
  }

  static VerificationRequestType fromStorageKey(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'citizen_level1':
        return VerificationRequestType.citizenLevel1;
      case 'citizen_level2':
        return VerificationRequestType.citizenLevel2;
      case 'public_official':
        return VerificationRequestType.publicOfficial;
      case 'institution':
        return VerificationRequestType.institution;
      case 'organization':
      case 'verified_organization':
        return VerificationRequestType.organization;
      default:
        return VerificationRequestType.citizenLevel1;
    }
  }
}

enum VerificationRequestStatus {
  pending,
  approved,
  rejected,
  cancelled,
}

extension VerificationRequestStatusX on VerificationRequestStatus {
  String get storageKey {
    switch (this) {
      case VerificationRequestStatus.pending:
        return 'pending';
      case VerificationRequestStatus.approved:
        return 'approved';
      case VerificationRequestStatus.rejected:
        return 'rejected';
      case VerificationRequestStatus.cancelled:
        return 'cancelled';
    }
  }

  bool get isFinal {
    switch (this) {
      case VerificationRequestStatus.pending:
        return false;
      case VerificationRequestStatus.approved:
      case VerificationRequestStatus.rejected:
      case VerificationRequestStatus.cancelled:
        return true;
    }
  }

  static VerificationRequestStatus fromStorageKey(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'approved':
        return VerificationRequestStatus.approved;
      case 'rejected':
        return VerificationRequestStatus.rejected;
      case 'cancelled':
        return VerificationRequestStatus.cancelled;
      case 'pending':
      default:
        return VerificationRequestStatus.pending;
    }
  }
}

class VerificationRequest {
  static const Object _unset = Object();

  final String id;
  final String userId;

  final VerificationRequestType requestType;
  final ActorType targetActorType;
  final VerificationLevel targetVerificationLevel;
  final InstitutionLevel? targetInstitutionLevel;

  /// Paese candidato a diventare il paese di voto verificato quando la
  /// richiesta viene approvata.
  ///
  /// È separato dal normale `profile.country`, che resta modificabile.
  /// Questo valore è uno snapshot della richiesta di verifica e non deve
  /// essere usato come autorizzazione finché la richiesta non è approvata.
  final String? votingCountryCode;

  final String? officialTitle;
  final String? institutionName;
  final String? organizationName;

  final VerificationRequestStatus status;

  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? reviewNote;

  final DateTime createdAt;
  final DateTime updatedAt;

  const VerificationRequest({
    required this.id,
    required this.userId,
    required this.requestType,
    required this.targetActorType,
    required this.targetVerificationLevel,
    this.targetInstitutionLevel,
    this.votingCountryCode,
    this.officialTitle,
    this.institutionName,
    this.organizationName,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.reviewNote,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status == VerificationRequestStatus.pending;
  bool get isApproved => status == VerificationRequestStatus.approved;
  bool get isRejected => status == VerificationRequestStatus.rejected;
  bool get isCancelled => status == VerificationRequestStatus.cancelled;

  bool get isReviewable => isPending;
  bool get isCancellable => isPending;

  bool get requiresOfficialTitle =>
      requestType == VerificationRequestType.publicOfficial;

  bool get requiresInstitutionData =>
      requestType == VerificationRequestType.institution;

  bool get requiresOrganizationData =>
      requestType == VerificationRequestType.organization;

  VerificationRequest copyWith({
    String? id,
    String? userId,
    VerificationRequestType? requestType,
    ActorType? targetActorType,
    VerificationLevel? targetVerificationLevel,
    Object? targetInstitutionLevel = _unset,
    Object? votingCountryCode = _unset,
    Object? officialTitle = _unset,
    Object? institutionName = _unset,
    Object? organizationName = _unset,
    VerificationRequestStatus? status,
    DateTime? submittedAt,
    Object? reviewedAt = _unset,
    Object? reviewedBy = _unset,
    Object? reviewNote = _unset,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VerificationRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      requestType: requestType ?? this.requestType,
      targetActorType: targetActorType ?? this.targetActorType,
      targetVerificationLevel:
          targetVerificationLevel ?? this.targetVerificationLevel,
      targetInstitutionLevel: identical(targetInstitutionLevel, _unset)
          ? this.targetInstitutionLevel
          : targetInstitutionLevel as InstitutionLevel?,
      votingCountryCode: identical(votingCountryCode, _unset)
          ? this.votingCountryCode
          : votingCountryCode as String?,
      officialTitle: identical(officialTitle, _unset)
          ? this.officialTitle
          : officialTitle as String?,
      institutionName: identical(institutionName, _unset)
          ? this.institutionName
          : institutionName as String?,
      organizationName: identical(organizationName, _unset)
          ? this.organizationName
          : organizationName as String?,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: identical(reviewedAt, _unset)
          ? this.reviewedAt
          : reviewedAt as DateTime?,
      reviewedBy: identical(reviewedBy, _unset)
          ? this.reviewedBy
          : reviewedBy as String?,
      reviewNote: identical(reviewNote, _unset)
          ? this.reviewNote
          : reviewNote as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
