enum VerificationStatus {
  none,
  pending,
  rejected,
}

extension VerificationStatusX on VerificationStatus {
  String get storageKey {
    switch (this) {
      case VerificationStatus.none:
        return 'none';
      case VerificationStatus.pending:
        return 'pending';
      case VerificationStatus.rejected:
        return 'rejected';
    }
  }

  bool get isPending => this == VerificationStatus.pending;

  static VerificationStatus fromStorageKey(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'pending':
        return VerificationStatus.pending;
      case 'rejected':
        return VerificationStatus.rejected;
      case 'none':
      default:
        return VerificationStatus.none;
    }
  }
}