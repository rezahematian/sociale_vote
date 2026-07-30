import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/institution_level.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_status.dart';

class UserProfile {
  final String id;
  final String? displayName;
  final String? username;
  final String? avatarUrl;
  final String? bio;
  final String? country;
  final String? city;

  /// Asse civico principale dell'utente.
  final ActorType actorType;

  /// Livello di verifica Persona raggiunto.
  ///
  /// Per Funzionario, Istituzione e Organizzazione resta [VerificationLevel.none].
  final VerificationLevel verificationLevel;

  /// Livello istituzionale, applicabile solo alle istituzioni pubbliche.
  final InstitutionLevel? institutionLevel;

  /// Stato della richiesta di verifica.
  final VerificationStatus verificationStatus;

  /// Quando l'utente ha richiesto la verifica.
  final DateTime? verificationRequestedAt;

  /// Quando la verifica è stata approvata.
  final DateTime? verifiedAt;

  /// Titolo pubblico opzionale per i funzionari pubblici.
  final String? officialTitle;

  /// Nome dell'istituzione pubblica.
  final String? institutionName;

  /// Nome dell'organizzazione verificata.
  final String? organizationName;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Compatibilità legacy:
  /// - accountType viene convertito in actorType
  /// - isVerified viene convertito in verificationLevel
  UserProfile({
    required this.id,
    this.displayName,
    this.username,
    this.avatarUrl,
    this.bio,
    this.country,
    this.city,
    ActorType? actorType,
    VerificationLevel? verificationLevel,
    this.institutionLevel,
    VerificationStatus? verificationStatus,
    this.verificationRequestedAt,
    this.verifiedAt,
    this.officialTitle,
    this.institutionName,
    this.organizationName,
    String? accountType,
    bool? isVerified,
    required this.createdAt,
    required this.updatedAt,
  })  : actorType = actorType ?? _actorTypeFromLegacy(accountType),
        verificationLevel =
            verificationLevel ?? _verificationLevelFromLegacy(isVerified),
        verificationStatus = verificationStatus ?? VerificationStatus.none;

  /// Getter legacy mantenuto per non rompere subito UI e codice esistente.
  String get accountType => actorType.storageKey;

  /// Getter legacy mantenuto per compatibilità temporanea.
  bool get isVerified => hasElevatedIdentity;

  /// Identity semantic helpers
  bool get isCitizen => actorType == ActorType.citizen;

  bool get isVerifiedCitizen =>
      actorType == ActorType.citizen &&
      verificationLevel != VerificationLevel.none;

  bool get isPublicOfficial => actorType == ActorType.publicOfficial;

  bool get isInstitutionActor =>
      actorType == ActorType.institution && institutionLevel != null;

  bool get isOrganizationActor => actorType == ActorType.organization;

  bool get isRepresentativeActor =>
      isPublicOfficial || isInstitutionActor || isOrganizationActor;

  bool get hasElevatedIdentity => isVerifiedCitizen || isRepresentativeActor;

  /// Label legacy mantenute temporaneamente.
  ///
  /// La UI deve usare AppLocalizations per i testi visibili.
  String get actorTypeLabel => _actorTypeLabel(actorType);

  String get verificationLevelLabel =>
      _verificationLevelLabel(verificationLevel);

  String? get institutionLevelLabel =>
      _formatInstitutionLevelLabel(institutionLevel);

  /// Badge legacy derivato dall'identità.
  ///
  /// La UI deve sostituire queste stringhe con chiavi localizzate.
  String? get primaryIdentityBadgeLabel {
    if (isPublicOfficial) {
      return 'Public Official';
    }

    if (isInstitutionActor) {
      return 'Public Institution';
    }

    if (isOrganizationActor) {
      return 'Verified Organization';
    }

    switch (verificationLevel) {
      case VerificationLevel.none:
        return null;
      case VerificationLevel.level1:
        return 'Verified Identity';
      case VerificationLevel.level2:
        return 'Advanced Verified Identity';
    }
  }

  /// Badge secondario opzionale per il livello istituzionale.
  String? get secondaryIdentityBadgeLabel {
    if (!isInstitutionActor) {
      return null;
    }

    return institutionLevelLabel;
  }

  /// Dettaglio identity mostrabile vicino al nome profilo.
  ///
  /// - funzionario pubblico -> titolo pubblico
  /// - istituzione pubblica -> nome dell'ente
  /// - organizzazione verificata -> nome dell'organizzazione
  String? get identityDetailLabel {
    switch (actorType) {
      case ActorType.citizen:
        return null;
      case ActorType.publicOfficial:
        return _normalizeNullableText(officialTitle);
      case ActorType.institution:
        return _normalizeNullableText(institutionName);
      case ActorType.organization:
        return _normalizeNullableText(organizationName);
    }
  }

  /// Stato account legacy già derivato centralmente.
  ///
  /// La UI deve comporlo usando AppLocalizations.
  String get accountStatusLabel {
    final parts = <String>[actorTypeLabel];

    if (isInstitutionActor && institutionLevelLabel != null) {
      parts.add(institutionLevelLabel!);
    }

    if (isCitizen) {
      parts.add(verificationLevelLabel);
    }
    return parts.join(' · ');
  }

  UserProfile copyWith({
    String? displayName,
    String? username,
    String? avatarUrl,
    String? bio,
    String? country,
    String? city,
    ActorType? actorType,
    VerificationLevel? verificationLevel,
    InstitutionLevel? institutionLevel,
    VerificationStatus? verificationStatus,
    DateTime? verificationRequestedAt,
    DateTime? verifiedAt,
    String? officialTitle,
    String? institutionName,
    String? organizationName,
    String? accountType,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      country: country ?? this.country,
      city: city ?? this.city,
      actorType: actorType ??
          (accountType != null
              ? _actorTypeFromLegacy(accountType)
              : this.actorType),
      verificationLevel: verificationLevel ??
          (isVerified != null
              ? _verificationLevelFromLegacy(isVerified)
              : this.verificationLevel),
      institutionLevel: institutionLevel ?? this.institutionLevel,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationRequestedAt:
          verificationRequestedAt ?? this.verificationRequestedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      officialTitle: officialTitle ?? this.officialTitle,
      institutionName: institutionName ?? this.institutionName,
      organizationName: organizationName ?? this.organizationName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static ActorType _actorTypeFromLegacy(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'public_official':
        return ActorType.publicOfficial;
      case 'institution':
        return ActorType.institution;
      case 'organization':
      case 'verified_organization':
        return ActorType.organization;
      case 'citizen':
      case 'person':
      default:
        return ActorType.citizen;
    }
  }

  static VerificationLevel _verificationLevelFromLegacy(bool? value) {
    if (value == true) {
      return VerificationLevel.level1;
    }
    return VerificationLevel.none;
  }

  static String _actorTypeLabel(ActorType value) {
    switch (value) {
      case ActorType.citizen:
        return 'Person';
      case ActorType.publicOfficial:
        return 'Public Official';
      case ActorType.institution:
        return 'Public Institution';
      case ActorType.organization:
        return 'Verified Organization';
    }
  }

  static String _verificationLevelLabel(VerificationLevel value) {
    switch (value) {
      case VerificationLevel.none:
        return 'Not Verified';
      case VerificationLevel.level1:
        return 'Verified Identity';
      case VerificationLevel.level2:
        return 'Advanced Verified Identity';
    }
  }

  static String? _formatInstitutionLevelLabel(InstitutionLevel? value) {
    switch (value) {
      case InstitutionLevel.municipality:
        return 'Municipal';
      case InstitutionLevel.province:
        return 'Provincial';
      case InstitutionLevel.region:
        return 'Regional';
      case InstitutionLevel.ministry:
        return 'Ministry';
      case InstitutionLevel.government:
        return 'Government';
      case InstitutionLevel.publicAgency:
        return 'Public Agency';
      case InstitutionLevel.otherPublicBody:
        return 'Other Public Body';
      case null:
        return null;
    }
  }

  static String? _normalizeNullableText(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}
