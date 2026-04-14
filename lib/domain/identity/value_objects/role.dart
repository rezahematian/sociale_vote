enum Role {
  user,
  moderator,
  admin,
}

extension RoleX on Role {
  String get storageKey {
    switch (this) {
      case Role.user:
        return 'user';
      case Role.moderator:
        return 'moderator';
      case Role.admin:
        return 'admin';
    }
  }

  bool get isStaff {
    switch (this) {
      case Role.user:
        return false;
      case Role.moderator:
      case Role.admin:
        return true;
    }
  }

  static Role fromStorageKey(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'moderator':
        return Role.moderator;
      case 'admin':
        return Role.admin;
      case 'user':
      default:
        return Role.user;
    }
  }
}