class UserIdentity {
  /// Identificativo univoco utente
  final String id;

  /// Username pubblico (opzionale)
  final String? username;

  /// Stato verifica account
  final bool isVerified;

  /// Codice paese (es. IT)
  final String? countryCode;

  /// Codice città (es. MI)
  final String? cityCode;

  const UserIdentity({
    /// Supporto named parameter moderno
    String? userId,

    /// Supporto legacy / dominio
    String? id,

    this.username,
    this.isVerified = false,
    this.countryCode,
    this.cityCode,
  }) : id = id ?? userId ?? '';

  /// Compatibilità legacy
  String get userId => id;
}
