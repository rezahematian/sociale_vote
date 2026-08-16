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

  /// Registra un nuovo utente con i dati minimi necessari
  /// per creare anche il profilo civico iniziale.
  ///
  /// [country] usa il codice paese ISO già adottato dal profilo
  /// e [city] contiene la città di residenza validata dal create flow.
  ///
  /// Restituisce la sessione autenticata completa del nuovo utente.
  Future<AuthSession> register({
    required String email,
    required String password,
    required String displayName,
    required String username,
    required String language,
    required String country,
    required String city,
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
