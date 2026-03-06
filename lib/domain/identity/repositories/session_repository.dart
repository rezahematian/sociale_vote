import 'dart:async';

/// Repository per la sessione utente.
///
/// V1 semplificata:
/// - gestiamo solo uno userId (String)
/// - niente profilo utente completo
/// - storage solo in-memory
abstract class SessionRepository {
  /// Restituisce l'ID utente corrente se esiste una sessione,
  /// altrimenti `null`.
  Future<String?> getCurrentUserId();

  /// Salva l'ID dell'utente corrente (login).
  Future<void> saveCurrentUserId(String userId);

  /// Cancella la sessione corrente (logout).
  Future<void> clearSession();

  /// Stream che emette l'ID utente corrente ogni volta che cambia.
  ///
  /// Può emettere `null` se non c'è nessuna sessione.
  Stream<String?> watchCurrentUserId();
}