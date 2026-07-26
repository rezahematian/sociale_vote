import 'package:sociale_vote/domain/identity/repositories/session_repository.dart';
import 'package:sociale_vote/domain/identity/repositories/user_repository.dart';

/// Use case per registrare un nuovo utente.
///
/// Responsabilità:
/// - normalizzare e validare i dati minimi di registrazione;
/// - chiamare [UserRepository.register];
/// - ricevere una [AuthSession];
/// - salvare la sessione tramite [SessionRepository].
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
    required String username,
    required String country,
    required String city,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();
    final trimmedDisplayName = displayName.trim();
    final normalizedUsername = _normalizeUsername(username);
    final trimmedCountry = country.trim();
    final trimmedCity = city.trim();

    if (trimmedEmail.isEmpty ||
        trimmedPassword.isEmpty ||
        trimmedDisplayName.isEmpty ||
        normalizedUsername.isEmpty ||
        trimmedCountry.isEmpty ||
        trimmedCity.isEmpty) {
      throw Exception('Invalid registration data.');
    }

    if (trimmedDisplayName.length < 2) {
      throw Exception('Invalid display name.');
    }

    if (trimmedPassword.length < 8) {
      throw Exception('Invalid password.');
    }

    final usernameRegex = RegExp(r'^[a-z0-9_]{3,20}$');
    if (!usernameRegex.hasMatch(normalizedUsername)) {
      throw Exception('Invalid username.');
    }

    final session = await _userRepository.register(
      email: trimmedEmail,
      password: trimmedPassword,
      displayName: trimmedDisplayName,
      username: normalizedUsername,
      country: trimmedCountry,
      city: trimmedCity,
    );

    await _sessionRepository.saveSession(session);
  }

  String _normalizeUsername(String value) {
    var normalized = value.trim().toLowerCase();

    if (normalized.startsWith('@')) {
      normalized = normalized.substring(1);
    }

    return normalized;
  }
}
