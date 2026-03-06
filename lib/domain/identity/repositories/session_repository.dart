import 'package:sociale_vote/domain/identity/entities/user.dart';
import 'package:sociale_vote/domain/identity/value_objects/user_id.dart';

/// Repository di dominio per la gestione della sessione utente.
///
/// Responsabilità:
/// - sapere qual è l'utente attualmente loggato (se esiste)
/// - salvare/aggiornare la sessione corrente
/// - cancellare la sessione (logout)
/// - esporre uno stream per reagire ai cambiamenti di sessione
///
/// Nota: questa è solo l'interfaccia di dominio.
/// L'implementazione concreta sta in `infrastructure/auth/session_repository_impl.dart`.
abstract class SessionRepository {
  /// Restituisce l'utente attualmente loggato, se presente.
  Future<User?> getCurrentUser();

  /// Restituisce solo l'ID dell'utente loggato, se presente.
  ///
  /// Comodo per casi d'uso che non hanno bisogno di tutto l'oggetto [User].
  Future<UserId?> getCurrentUserId();

  /// Salva/aggiorna la sessione corrente per l'utente dato.
  ///
  /// In implementazioni future potrà:
  /// - persistere su storage locale sicuro
  /// - aggiornare token di accesso/refresh
  Future<void> saveSession(User user);

  /// Cancella la sessione corrente (logout).
  ///
  /// Dopo questa chiamata:
  /// - [getCurrentUser] e [getCurrentUserId] dovrebbero restituire `null`
  /// - lo stream [watchCurrentUser] dovrebbe emettere `null`
  Future<void> clearSession();

  /// Stream reattivo dei cambiamenti di utente corrente.
  ///
  /// Utile per:
  /// - UI che devono reagire al login/logout
  /// - controller che vogliono tenersi allineati allo stato di sessione
  Stream<User?> watchCurrentUser();
}