import 'package:sociale_vote/domain/identity/repositories/session_repository.dart';

/// Use case per registrare un nuovo utente.
///
/// V1:
/// - Validazione minima
/// - Nessun backend reale
/// - Auto-login dopo registrazione
/// - Salva sessione tramite [SessionRepository]
class RegisterUser {
  final SessionRepository _sessionRepository;

  RegisterUser(this._sessionRepository);

  Future<void> call({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      throw Exception('Invalid registration data.');
    }

    // V1: generiamo userId semplice coerente con login
    final userId = _generateUserIdFromEmail(trimmedEmail);

    await _sessionRepository.saveCurrentUserId(userId);
  }

  String _generateUserIdFromEmail(String email) {
    return email.toLowerCase();
  }
}