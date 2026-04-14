enum VerificationLevel {
  none,
  level1,
  level2,
}

extension VerificationLevelX on VerificationLevel {
  String get storageKey {
    switch (this) {
      case VerificationLevel.none:
        return 'none';
      case VerificationLevel.level1:
        return 'level1';
      case VerificationLevel.level2:
        return 'level2';
    }
  }

  bool get isVerified {
    switch (this) {
      case VerificationLevel.none:
        return false;
      case VerificationLevel.level1:
      case VerificationLevel.level2:
        return true;
    }
  }

  static VerificationLevel fromStorageKey(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'level1':
        return VerificationLevel.level1;
      case 'level2':
        return VerificationLevel.level2;
      case 'none':
      default:
        return VerificationLevel.none;
    }
  }
}