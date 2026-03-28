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
      _status = userId == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated;
      _safeNotifyListeners();
    });
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
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
      _errorMessage = e.toString();
      _safeNotifyListeners();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
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
      _errorMessage = e.toString();
      _safeNotifyListeners();
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

  Future<void> _trackAuthEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (_) {
      // Best effort: analytics must never break auth flows.
    }
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