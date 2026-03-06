import 'package:sociale_vote/domain/identity/repositories/session_repository.dart';

/// Use case per autenticare un utente.
///
/// V1:
/// - Validazione minimale
/// - Nessun backend reale
/// - Genera userId semplice basato sull'email
/// - Salva la sessione tramite [SessionRepository]
class LoginUser {
  final SessionRepository _sessionRepository;

  LoginUser(this._sessionRepository);

  Future<void> call({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      throw Exception('Invalid credentials.');
    }

    // V1: generiamo un userId semplice e coerente
    final userId = _generateUserIdFromEmail(trimmedEmail);

    await _sessionRepository.saveCurrentUserId(userId);
  }

  String _generateUserIdFromEmail(String email) {
    // Versione semplice: lowercase e rimuove spazi
    return email.toLowerCase();
  }
}