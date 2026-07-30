enum ActorType {
  citizen,
  publicOfficial,
  institution,
  organization,
}

extension ActorTypeX on ActorType {
  String get storageKey {
    switch (this) {
      case ActorType.citizen:
        return 'citizen';
      case ActorType.publicOfficial:
        return 'public_official';
      case ActorType.institution:
        return 'institution';
      case ActorType.organization:
        return 'organization';
    }
  }

  static ActorType fromStorageKey(String? value) {
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
}
