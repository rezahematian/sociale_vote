import 'auth_session.dart';

class AuthGuard {
  void ensureAuthenticated(AuthSession? session) {
    if (session == null || !session.isValid) {
      throw Exception('Authentication required');
    }
  }
}
