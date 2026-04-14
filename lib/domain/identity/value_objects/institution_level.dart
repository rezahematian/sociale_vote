enum InstitutionLevel {
  municipality,
  province,
  region,
  ministry,
  government,
  publicAgency,
  otherPublicBody,
}

extension InstitutionLevelX on InstitutionLevel {
  String get storageKey {
    switch (this) {
      case InstitutionLevel.municipality:
        return 'municipality';
      case InstitutionLevel.province:
        return 'province';
      case InstitutionLevel.region:
        return 'region';
      case InstitutionLevel.ministry:
        return 'ministry';
      case InstitutionLevel.government:
        return 'government';
      case InstitutionLevel.publicAgency:
        return 'public_agency';
      case InstitutionLevel.otherPublicBody:
        return 'other_public_body';
    }
  }

  static InstitutionLevel fromStorageKey(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'municipality':
        return InstitutionLevel.municipality;
      case 'province':
        return InstitutionLevel.province;
      case 'region':
        return InstitutionLevel.region;
      case 'ministry':
        return InstitutionLevel.ministry;
      case 'government':
        return InstitutionLevel.government;
      case 'public_agency':
        return InstitutionLevel.publicAgency;
      case 'other_public_body':
        return InstitutionLevel.otherPublicBody;
      default:
        return InstitutionLevel.otherPublicBody;
    }
  }
}