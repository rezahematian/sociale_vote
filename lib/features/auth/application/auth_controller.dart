import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
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
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  AuthStatus _status = AuthStatus.unknown;
  String? _errorMessage;
  String? _currentUserId;

  StreamSubscription<String?>? _currentUserIdSubscription;
  bool _isDisposed = false;

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
    _currentUserIdSubscription?.cancel();
    _currentUserIdSubscription =
        _sessionRepository.watchCurrentUserId().listen((userId) {
      _currentUserId = userId;
      _status = _statusFromCurrentUser();
      _safeNotifyListeners();
    });
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (_status == AuthStatus.loading) {
      return;
    }

    _status = AuthStatus.loading;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      await _loginUser(
        email: email,
        password: password,
      );

      await _trackAuthEvent(
        name: 'login',
        parameters: <String, Object>{
          'method': 'email',
        },
      );
    } catch (e) {
      if (_isDisposed) return;
      _status = AuthStatus.error;
      _errorMessage = _mapAuthError(
        e,
        isRegisterFlow: false,
        isPasswordResetFlow: false,
        isUpdatePasswordFlow: false,
      );
      _safeNotifyListeners();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (_status == AuthStatus.loading) {
      return;
    }

    _status = AuthStatus.loading;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      await _registerUser(
        email: email,
        password: password,
        displayName: displayName,
      );

      await _trackAuthEvent(
        name: 'sign_up',
        parameters: <String, Object>{
          'method': 'email',
        },
      );
    } catch (e) {
      if (_isDisposed) return;
      _status = AuthStatus.error;
      _errorMessage = _mapAuthError(
        e,
        isRegisterFlow: true,
        isPasswordResetFlow: false,
        isUpdatePasswordFlow: false,
      );
      _safeNotifyListeners();
    }
  }

  Future<bool> forgotPassword({
    required String email,
  }) async {
    if (_status == AuthStatus.loading) {
      return false;
    }

    _status = AuthStatus.loading;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      await _authApi.sendPasswordResetEmail(email: email);
      _status = _statusFromCurrentUser();
      _safeNotifyListeners();
      return true;
    } catch (e) {
      if (_isDisposed) return false;
      _status = AuthStatus.error;
      _errorMessage = _mapAuthError(
        e,
        isRegisterFlow: false,
        isPasswordResetFlow: true,
        isUpdatePasswordFlow: false,
      );
      _safeNotifyListeners();
      return false;
    }
  }

  Future<bool> updatePassword({
    required String newPassword,
  }) async {
    if (_status == AuthStatus.loading) {
      return false;
    }

    _status = AuthStatus.loading;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      await _authApi.updatePassword(newPassword: newPassword);
      _status = _statusFromCurrentUser();
      _safeNotifyListeners();
      return true;
    } catch (e) {
      if (_isDisposed) return false;
      _status = AuthStatus.error;
      _errorMessage = _mapAuthError(
        e,
        isRegisterFlow: false,
        isPasswordResetFlow: false,
        isUpdatePasswordFlow: true,
      );
      _safeNotifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authApi.logout();
    await _sessionRepository.clearSession();

    await _trackAuthEvent(
      name: 'logout',
      parameters: const <String, Object>{
        'method': 'manual',
      },
    );
  }

  void clearError() {
    _errorMessage = null;
    _safeNotifyListeners();
  }

  AuthStatus _statusFromCurrentUser() {
    return _currentUserId == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
  }

  Future<void> _trackAuthEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (_) {}
  }

  String _mapAuthError(
    Object error, {
    required bool isRegisterFlow,
    required bool isPasswordResetFlow,
    required bool isUpdatePasswordFlow,
  }) {
    final raw = error.toString().trim();
    final normalized = raw.toLowerCase();

    if (normalized.contains('invalid login credentials') ||
        normalized.contains('invalid credentials')) {
      return 'Email or password not valid.';
    }

    if (normalized.contains('user already registered') ||
        normalized.contains('already been registered') ||
        normalized.contains('already exists')) {
      return 'This email is already registered.';
    }

    if (normalized.contains('invalid email')) {
      return 'Enter a valid email address.';
    }

    if (normalized.contains('password should be at least') ||
        normalized.contains('password must be at least') ||
        normalized.contains('weak password')) {
      return isUpdatePasswordFlow
          ? 'New password is too weak.'
          : 'Password is too weak.';
    }

    if (normalized.contains('network') ||
        normalized.contains('socket') ||
        normalized.contains('timeout') ||
        normalized.contains('timed out') ||
        normalized.contains('failed host lookup')) {
      return 'Network error. Check your connection and try again.';
    }

    if (normalized.contains('too many requests') ||
        normalized.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }

    if (normalized.contains('email not confirmed')) {
      return isRegisterFlow
          ? 'Registration failed. Check your details and try again.'
          : 'Email or password not valid.';
    }

    if (isPasswordResetFlow) {
      return raw.isNotEmpty
          ? 'Password reset failed: $raw'
          : 'Password reset failed. Please try again.';
    }

    if (isUpdatePasswordFlow) {
      return raw.isNotEmpty
          ? 'Password update failed: $raw'
          : 'Password update failed. Please try again.';
    }

    if (isRegisterFlow) {
      return raw.isNotEmpty
          ? 'Registration failed: $raw'
          : 'Registration failed. Please try again.';
    }

    return raw.isNotEmpty
        ? 'Login failed: $raw'
        : 'Login failed. Please try again.';
  }

  void _safeNotifyListeners() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _currentUserIdSubscription?.cancel();
    _currentUserIdSubscription = null;
    super.dispose();
  }
}