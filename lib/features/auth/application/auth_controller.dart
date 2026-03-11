import 'package:flutter/foundation.dart';

import 'package:sociale_vote/domain/identity/repositories/session_repository.dart';
import 'package:sociale_vote/domain/identity/usecases/login_user.dart';
import 'package:sociale_vote/domain/identity/usecases/register_user.dart';
import 'package:sociale_vote/infrastructure/persistence/remote/rest/auth_api.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
  loading,
  error,
}

class AuthController extends ChangeNotifier {
  final SessionRepository _sessionRepository;
  final LoginUser _loginUser;
  final RegisterUser _registerUser;
  final AuthApi _authApi;

  AuthStatus _status = AuthStatus.unknown;
  String? _errorMessage;
  String? _currentUserId;

  AuthController({
    required SessionRepository sessionRepository,
    required LoginUser loginUser,
    required RegisterUser registerUser,
    required AuthApi authApi,
  })  : _sessionRepository = sessionRepository,
        _loginUser = loginUser,
        _registerUser = registerUser,
        _authApi = authApi {
    _initialize();
  }

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get currentUserId => _currentUserId;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  void _initialize() {
    _sessionRepository.watchCurrentUserId().listen((userId) {
      _currentUserId = userId;
      _status = userId == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated;
      notifyListeners();
    });
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loginUser(
        email: email,
        password: password,
      );
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _registerUser(
        email: email,
        password: password,
        displayName: displayName,
      );
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authApi.logout();
    await _sessionRepository.clearSession();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}