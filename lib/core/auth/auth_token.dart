class AuthToken {
  final String value;
  final DateTime expiresAt;

  AuthToken({
    required this.value,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
