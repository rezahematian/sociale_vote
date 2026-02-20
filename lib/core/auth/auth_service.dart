import '../../domain/user/user_identity.dart';
import 'auth_session.dart';
import 'auth_storage.dart';
import 'auth_token.dart';

class AuthService {
  final AuthStorage storage;

  AuthService(this.storage);

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    // MOCK – replace with backend
    await Future.delayed(const Duration(milliseconds: 400));

    final user = UserIdentity(
      id: 'user_${email.hashCode}',
      email: email,
      verified: true,
    );

    final token = AuthToken(
      value: 'token_${DateTime.now().millisecondsSinceEpoch}',
      expiresAt: DateTime.now().add(const Duration(hours: 12)),
    );

    final session = AuthSession(user: user, token: token);
    await storage.save(session);

    return session;
  }

  Future<void> logout() async {
    await storage.clear();
  }

  Future<AuthSession?> restoreSession() {
    return storage.load();
  }
}
