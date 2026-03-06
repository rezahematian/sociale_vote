import '../../domain/user/user_identity.dart';
import 'auth_token.dart';

class AuthSession {
  final UserIdentity user;
  final AuthToken token;

  AuthSession({
    required this.user,
    required this.token,
  });

  bool get isValid => !token.isExpired;
}
