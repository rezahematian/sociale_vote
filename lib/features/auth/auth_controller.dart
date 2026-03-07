import 'package:flutter/foundation.dart';

import '../../core/auth/auth_service.dart';
import '../../core/auth/auth_session.dart';
import '../../core/session_manager.dart';

class AuthController extends ChangeNotifier {
  final AuthService authService;
  final SessionManager sessionManager;

  AuthSession? _session;
  AuthSession? get session => _session;

  bool get isAuthenticated => _session != null;

  AuthController({
    required this.authService,
    required this.sessionManager,
  });

  Future<void> login(String email, String password) async {
    final session = await authService.login(
      email: email,
      password: password,
    );

    _session = session;
    sessionManager.startSession(session.user);
    notifyListeners();
  }

  Future<void> logout() async {
    await authService.logout();
    _session = null;
    sessionManager.endSession();
    notifyListeners();
  }

  Future<void> restore() async {
    final restored = await authService.restoreSession();
    if (restored != null && restored.isValid) {
      _session = restored;
      sessionManager.startSession(restored.user);
      notifyListeners();
    }
  }
}
