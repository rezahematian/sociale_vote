import 'package:sociale_vote/domain/identity/repositories/session_repository.dart';
import 'package:sociale_vote/domain/identity/repositories/user_repository.dart';

/// Use case per autenticare un utente.
///
/// V2:
/// - chiama [UserRepository.login]
/// - riceve una [AuthSession]
/// - salva la sessione tramite [SessionRepository]
class LoginUser {
  final UserRepository _userRepository;
  final SessionRepository _sessionRepository;

  LoginUser(
    this._userRepository,
    this._sessionRepository,
  );

  Future<void> call({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      throw Exception('Invalid credentials.');
    }

    final session = await _userRepository.login(
      email: trimmedEmail,
      password: trimmedPassword,
    );

    await _sessionRepository.saveSession(session);
  }
}