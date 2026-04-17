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

  /// Livello di verifica raggiunto.
  final VerificationLevel verificationLevel;

  /// Livello istituzionale, applicabile solo a soggetti institution
  /// (o eventualmente official in casi futuri).
  final InstitutionLevel? institutionLevel;

  /// Stato della richiesta di verifica.
  final VerificationStatus verificationStatus;

  /// Quando l'utente ha richiesto la verifica.
  final DateTime? verificationRequestedAt;

  /// Quando la verifica è stata approvata.
  final DateTime? verifiedAt;

  /// Titolo pubblico opzionale per soggetti official.
  /// Esempi futuri: sindaco, ministro, assessore.
  final String? officialTitle;

  /// Nome istituzionale opzionale.
  /// Esempi futuri: Comune di Milano, Ministero della Salute.
  final String? institutionName;

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
    String? accountType,
    bool? isVerified,
    required this.createdAt,
    required this.updatedAt,
  })  : actorType = actorType ?? _actorTypeFromLegacy(accountType),
        verificationLevel =
            verificationLevel ?? _verificationLevelFromLegacy(isVerified),
        verificationStatus =
            verificationStatus ?? VerificationStatus.none;

  /// Getter legacy mantenuto per non rompere subito UI e codice esistente.
  String get accountType => actorType.storageKey;

  /// Getter legacy mantenuto per compatibilità temporanea.
  bool get isVerified => verificationLevel.isVerified;

  /// Identity semantic helpers
  bool get isCitizen => actorType == ActorType.citizen;

  bool get isVerifiedCitizen =>
      actorType == ActorType.citizen &&
      verificationLevel != VerificationLevel.none;

  bool get isPublicOfficial =>
      actorType == ActorType.publicOfficial &&
      verificationLevel == VerificationLevel.level2;

  bool get isInstitutionActor =>
      actorType == ActorType.institution &&
      verificationLevel == VerificationLevel.level2 &&
      institutionLevel != null;

  bool get hasElevatedIdentity =>
      isVerifiedCitizen || isPublicOfficial || isInstitutionActor;

  /// Label principali centralizzate per evitare derivazioni sparse nei widget.
  String get actorTypeLabel => _actorTypeLabel(actorType);

  String get verificationLevelLabel =>
      _verificationLevelLabel(verificationLevel);

  String? get institutionLevelLabel =>
      _formatInstitutionLevelLabel(institutionLevel);

  /// Badge principale derivato dall'identità prodotto.
  ///
  /// Regola:
  /// - citizen standard -> nessun badge principale
  /// - citizen verificato -> badge verified
  /// - public official -> badge public official
  /// - institution -> badge institution
  String? get primaryIdentityBadgeLabel {
    if (isPublicOfficial) {
      return 'Public Official';
    }

    if (isInstitutionActor) {
      return 'Institution';
    }

    switch (verificationLevel) {
      case VerificationLevel.none:
        return null;
      case VerificationLevel.level1:
        return 'Verified Lv1';
      case VerificationLevel.level2:
        return 'Verified Lv2';
    }
  }

  /// Badge secondario opzionale per l'identity.
  ///
  /// In F12.6 serve soprattutto per institution level.
  String? get secondaryIdentityBadgeLabel {
    if (!isInstitutionActor) {
      return null;
    }

    return institutionLevelLabel;
  }

  /// Dettaglio identity mostrabile vicino al nome profilo.
  ///
  /// - official -> titolo pubblico
  /// - institution -> nome ente
  String? get identityDetailLabel {
    if (isPublicOfficial) {
      return _normalizeNullableText(officialTitle);
    }

    if (actorType == ActorType.institution) {
      return _normalizeNullableText(institutionName);
    }

    return null;
  }

  /// Stato account leggibile già derivato centralmente.
  String get accountStatusLabel {
    final parts = <String>[
      actorTypeLabel,
    ];

    if (institutionLevelLabel != null) {
      parts.add(institutionLevelLabel!);
    }

    parts.add(verificationLevelLabel);
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
      case 'citizen':
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
        return 'Citizen';
      case ActorType.publicOfficial:
        return 'Public Official';
      case ActorType.institution:
        return 'Institution';
    }
  }

  static String _verificationLevelLabel(VerificationLevel value) {
    switch (value) {
      case VerificationLevel.none:
        return 'Standard';
      case VerificationLevel.level1:
        return 'Verified Lv1';
      case VerificationLevel.level2:
        return 'Verified Lv2';
    }
  }

  static String? _formatInstitutionLevelLabel(InstitutionLevel? value) {
    switch (value) {
      case InstitutionLevel.municipality:
        return 'Municipality';
      case InstitutionLevel.province:
        return 'Province';
      case InstitutionLevel.region:
        return 'Region';
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