import 'package:sociale_vote/domain/identity/repositories/session_repository.dart';
import 'package:sociale_vote/domain/identity/repositories/user_repository.dart';

/// Use case per registrare un nuovo utente.
///
/// V2:
/// - chiama [UserRepository.register]
/// - riceve una [AuthSession]
/// - salva la sessione tramite [SessionRepository]
/// - l'utente risulta automaticamente loggato
class RegisterUser {
  final UserRepository _userRepository;
  final SessionRepository _sessionRepository;

  RegisterUser(
    this._userRepository,
    this._sessionRepository,
  );

  Future<void> call({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();
    final trimmedDisplayName = displayName.trim();

    if (trimmedEmail.isEmpty ||
        trimmedPassword.isEmpty ||
        trimmedDisplayName.isEmpty) {
      throw Exception('Invalid registration data.');
    }

    final session = await _userRepository.register(
      email: trimmedEmail,
      password: trimmedPassword,
      displayName: trimmedDisplayName,
    );

    await _sessionRepository.saveSession(session);
  }
}