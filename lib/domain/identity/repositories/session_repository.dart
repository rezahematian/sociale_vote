import 'dart:async';

import 'package:sociale_vote/domain/identity/value_objects/role.dart';

/// Sessione autenticata minima dell'utente.
///
/// V1 reale minima:
/// - userId
/// - accessToken
/// - refreshToken opzionale
/// - email opzionale
/// - displayName opzionale
/// - role tecnico opzionale con default user
class AuthSession {
  final String userId;
  final String accessToken;
  final String? refreshToken;
  final String? email;
  final String? displayName;
  final Role role;

  const AuthSession({
    required this.userId,
    required this.accessToken,
    this.refreshToken,
    this.email,
    this.displayName,
    this.role = Role.user,
  });

  AuthSession copyWith({
    String? userId,
    String? accessToken,
    String? refreshToken,
    String? email,
    String? displayName,
    Role? role,
  }) {
    return AuthSession(
      userId: userId ?? this.userId,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
    );
  }
}

/// Repository per la sessione utente.
///
/// Evoluzione:
/// - da semplice userId in-memory
/// - a sessione reale minima con token + dati base utente
///
/// Nota:
/// I metodi legacy su `userId` sono mantenuti temporaneamente
/// per compatibilità col codice esistente, così non dobbiamo
/// riscrivere subito più file insieme.
abstract class SessionRepository {
  /// Restituisce la sessione corrente completa, oppure `null`
  /// se l'utente non è autenticato.
  Future<AuthSession?> getCurrentSession();

  /// Salva la sessione corrente completa.
  Future<void> saveSession(AuthSession session);

  /// Cancella la sessione corrente (logout).
  Future<void> clearSession();

  /// Stream che emette la sessione corrente ogni volta che cambia.
  ///
  /// Può emettere `null` se non c'è nessuna sessione.
  Stream<AuthSession?> watchSession();

  // ==========================================================
  // LEGACY COMPATIBILITY
  // ==========================================================

  /// Restituisce l'ID utente corrente se esiste una sessione,
  /// altrimenti `null`.
  Future<String?> getCurrentUserId();

  /// Salva una sessione minima a partire da un solo userId.
  ///
  /// Metodo legacy temporaneo per compatibilità con il codice attuale.
  Future<void> saveCurrentUserId(String userId);

  /// Stream che emette l'ID utente corrente ogni volta che cambia.
  ///
  /// Metodo legacy temporaneo per compatibilità con il codice attuale.
  Stream<String?> watchCurrentUserId();
}