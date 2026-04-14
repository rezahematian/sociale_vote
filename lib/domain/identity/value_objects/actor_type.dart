enum ActorType {
  citizen,
  publicOfficial,
  institution,
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
    }
  }

  static ActorType fromStorageKey(String? value) {
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
}