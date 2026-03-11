import 'package:sociale_vote/domain/identity/repositories/session_repository.dart';

/// Repository dominio per le operazioni di identità utente.
///
/// V1 reale minima:
/// - login
/// - register
/// - eventuale recupero profilo/sessione utente corrente
///
/// Nota:
/// il repository restituisce direttamente una [AuthSession]
/// così il layer application può salvare subito la sessione
/// tramite [SessionRepository].
abstract class UserRepository {
  /// Esegue login con credenziali utente.
  ///
  /// Restituisce la sessione autenticata completa se il login ha successo.
  Future<AuthSession> login({
    required String email,
    required String password,
  });

  /// Registra un nuovo utente.
  ///
  /// Restituisce la sessione autenticata completa del nuovo utente.
  Future<AuthSession> register({
    required String email,
    required String password,
    required String displayName,
  });

  /// Recupera i dati aggiornati dell'utente autenticato corrente
  /// a partire da un access token valido.
  ///
  /// In questa fase può restare non implementato lato infrastructure,
  /// ma fissiamo già il contratto per evitare di cambiare di nuovo il file.
  Future<AuthSession> getCurrentUser({
    required String accessToken,
  });
}