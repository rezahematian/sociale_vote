import 'auth_session.dart';

class AuthStorage {
  AuthSession? _session;

  Future<void> save(AuthSession session) async {
    _session = session;
  }

  Future<AuthSession?> load() async {
    return _session;
  }

  Future<void> clear() async {
    _session = null;
  }
}
