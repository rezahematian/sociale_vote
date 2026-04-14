import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/institution_level.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';

enum VerificationRequestType {
  citizenLevel1,
  citizenLevel2,
  publicOfficial,
  institution,
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
  final String id;
  final String userId;

  final VerificationRequestType requestType;
  final ActorType targetActorType;
  final VerificationLevel targetVerificationLevel;
  final InstitutionLevel? targetInstitutionLevel;

  final String? officialTitle;
  final String? institutionName;

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
    this.officialTitle,
    this.institutionName,
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

  bool get requiresOfficialTitle =>
      requestType == VerificationRequestType.publicOfficial;

  bool get requiresInstitutionData =>
      requestType == VerificationRequestType.institution;

  VerificationRequest copyWith({
    String? id,
    String? userId,
    VerificationRequestType? requestType,
    ActorType? targetActorType,
    VerificationLevel? targetVerificationLevel,
    InstitutionLevel? targetInstitutionLevel,
    String? officialTitle,
    String? institutionName,
    VerificationRequestStatus? status,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? reviewNote,
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
      targetInstitutionLevel:
          targetInstitutionLevel ?? this.targetInstitutionLevel,
      officialTitle: officialTitle ?? this.officialTitle,
      institutionName: institutionName ?? this.institutionName,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewNote: reviewNote ?? this.reviewNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}