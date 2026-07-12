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

  AuthStatus _status = AuthStatus.unknown;
  String? _errorMessage;
  String? _currentUserId;

  StreamSubscription<String?>? _currentUserIdSubscription;
  bool _isDisposed = false;
  bool _operationInProgress = false;
  int _operationId = 0;
  int _sessionEventId = 0;

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
    final previousSubscription = _currentUserIdSubscription;
    if (previousSubscription != null) {
      unawaited(previousSubscription.cancel());
    }

    _currentUserIdSubscription = _sessionRepository.watchCurrentUserId().listen(
          _handleCurrentUserIdChanged,
          onError: _handleSessionStreamError,
        );

    final operationId = _operationId;
    final sessionEventId = _sessionEventId;
    unawaited(
      _restoreCurrentUserId(
        operationId: operationId,
        sessionEventId: sessionEventId,
      ),
    );
  }

  Future<void> _restoreCurrentUserId({
    required int operationId,
    required int sessionEventId,
  }) async {
    try {
      final userId = await _sessionRepository.getCurrentUserId();

      if (_isDisposed ||
          operationId != _operationId ||
          sessionEventId != _sessionEventId) {
        return;
      }

      _applyCurrentUserId(userId);
    } catch (_) {
      if (_isDisposed ||
          operationId != _operationId ||
          sessionEventId != _sessionEventId) {
        return;
      }

      _status = AuthStatus.error;
      _errorMessage = 'Unable to restore the current session.';
      _safeNotifyListeners();
    }
  }

  void _handleCurrentUserIdChanged(String? userId) {
    if (_isDisposed) {
      return;
    }

    _sessionEventId++;
    _currentUserId = _normalizeUserId(userId);

    if (!_operationInProgress) {
      _status = _statusFromCurrentUser();
      _errorMessage = null;
    }

    _safeNotifyListeners();
  }

  void _handleSessionStreamError(Object _, StackTrace __) {
    if (_isDisposed || _operationInProgress) {
      return;
    }

    _status = AuthStatus.error;
    _errorMessage = 'Unable to update the current session.';
    _safeNotifyListeners();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final operationId = _beginOperation();
    if (operationId == null) {
      return;
    }

    try {
      await _loginUser(
        email: email,
        password: password,
      );

      final userId = await _sessionRepository.getCurrentUserId();
      if (!_isOperationStillValid(operationId)) {
        return;
      }

      if (_normalizeUserId(userId) == null) {
        _finishOperationWithError(
          operationId,
          'Login completed but the user session is not available.',
        );
        return;
      }

      _currentUserId = _normalizeUserId(userId);
      _finishOperation(
        operationId,
        status: AuthStatus.authenticated,
      );

      unawaited(
        _trackAuthEvent(
          name: 'login',
          parameters: <String, Object>{
            'method': 'email',
          },
        ),
      );
    } catch (e) {
      _finishOperationWithError(
        operationId,
        _mapAuthError(
          e,
          isRegisterFlow: false,
          isPasswordResetFlow: false,
          isUpdatePasswordFlow: false,
        ),
      );
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final operationId = _beginOperation();
    if (operationId == null) {
      return;
    }

    try {
      await _registerUser(
        email: email,
        password: password,
        displayName: displayName,
      );

      final userId = await _sessionRepository.getCurrentUserId();
      if (!_isOperationStillValid(operationId)) {
        return;
      }

      if (_normalizeUserId(userId) == null) {
        _finishOperationWithError(
          operationId,
          'Registration completed but the user session is not available.',
        );
        return;
      }

      _currentUserId = _normalizeUserId(userId);
      _finishOperation(
        operationId,
        status: AuthStatus.authenticated,
      );

      unawaited(
        _trackAuthEvent(
          name: 'sign_up',
          parameters: <String, Object>{
            'method': 'email',
          },
        ),
      );
    } catch (e) {
      _finishOperationWithError(
        operationId,
        _mapAuthError(
          e,
          isRegisterFlow: true,
          isPasswordResetFlow: false,
          isUpdatePasswordFlow: false,
        ),
      );
    }
  }

  Future<bool> forgotPassword({
    required String email,
    required String redirectTo,
  }) async {
    final operationId = _beginOperation();
    if (operationId == null) {
      return false;
    }

    try {
      await _authApi.sendPasswordResetEmail(
        email: email,
        redirectTo: redirectTo,
      );

      if (!_isOperationStillValid(operationId)) {
        return false;
      }

      _finishOperation(
        operationId,
        status: _statusFromCurrentUser(),
      );
      return true;
    } catch (e) {
      _finishOperationWithError(
        operationId,
        _mapAuthError(
          e,
          isRegisterFlow: false,
          isPasswordResetFlow: true,
          isUpdatePasswordFlow: false,
        ),
      );
      return false;
    }
  }

  Future<bool> updatePassword({
    required String newPassword,
  }) async {
    final operationId = _beginOperation();
    if (operationId == null) {
      return false;
    }

    try {
      await _authApi.updatePassword(newPassword: newPassword);

      if (!_isOperationStillValid(operationId)) {
        return false;
      }

      _finishOperation(
        operationId,
        status: _statusFromCurrentUser(),
      );
      return true;
    } catch (e) {
      _finishOperationWithError(
        operationId,
        _mapAuthError(
          e,
          isRegisterFlow: false,
          isPasswordResetFlow: false,
          isUpdatePasswordFlow: true,
        ),
      );
      return false;
    }
  }

  Future<void> logout() async {
    final operationId = _beginOperation();
    if (operationId == null) {
      return;
    }

    Object? logoutError;

    try {
      await _authApi.logout();
    } catch (e) {
      logoutError = e;
    }

    try {
      await _sessionRepository.clearSession();
    } catch (e) {
      logoutError ??= e;
    }

    if (!_isOperationStillValid(operationId)) {
      return;
    }

    _currentUserId = null;

    if (logoutError != null) {
      _finishOperationWithError(
        operationId,
        _mapLogoutError(logoutError),
      );
      return;
    }

    _finishOperation(
      operationId,
      status: AuthStatus.unauthenticated,
    );

    unawaited(
      _trackAuthEvent(
        name: 'logout',
        parameters: const <String, Object>{
          'method': 'manual',
        },
      ),
    );
  }

  void clearError() {
    if (_isDisposed || _errorMessage == null) {
      return;
    }

    _errorMessage = null;
    _safeNotifyListeners();
  }

  int? _beginOperation() {
    if (_isDisposed || _operationInProgress) {
      return null;
    }

    _operationInProgress = true;
    final operationId = ++_operationId;
    _status = AuthStatus.loading;
    _errorMessage = null;
    _safeNotifyListeners();
    return operationId;
  }

  bool _isOperationStillValid(int operationId) {
    return !_isDisposed && _operationInProgress && operationId == _operationId;
  }

  void _finishOperation(
    int operationId, {
    required AuthStatus status,
  }) {
    if (!_isOperationStillValid(operationId)) {
      return;
    }

    _operationInProgress = false;
    _status = status;
    _errorMessage = null;
    _safeNotifyListeners();
  }

  void _finishOperationWithError(
    int operationId,
    String message,
  ) {
    if (!_isOperationStillValid(operationId)) {
      return;
    }

    _operationInProgress = false;
    _status = AuthStatus.error;
    _errorMessage = message;
    _safeNotifyListeners();
  }

  void _applyCurrentUserId(String? userId) {
    if (_isDisposed) {
      return;
    }

    _currentUserId = _normalizeUserId(userId);
    _status = _statusFromCurrentUser();
    _errorMessage = null;
    _safeNotifyListeners();
  }

  String? _normalizeUserId(String? userId) {
    final normalized = userId?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  AuthStatus _statusFromCurrentUser() {
    return _currentUserId == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
  }

  bool get _supportsFirebaseAnalytics {
    if (kIsWeb) {
      return true;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return false;
    }
  }

  Future<void> _trackAuthEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (!_supportsFirebaseAnalytics) {
      return;
    }

    try {
      await FirebaseAnalytics.instance.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (_) {}
  }

  String _mapLogoutError(Object error) {
    final normalized = error.toString().trim().toLowerCase();

    if (normalized.contains('network') ||
        normalized.contains('socket') ||
        normalized.contains('timeout') ||
        normalized.contains('timed out') ||
        normalized.contains('failed host lookup')) {
      return 'Logout could not be completed. Check your connection and try again.';
    }

    return 'Logout could not be completed. Please try again.';
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
    if (_isDisposed) {
      return;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _operationInProgress = false;
    _operationId++;
    _sessionEventId++;

    final subscription = _currentUserIdSubscription;
    _currentUserIdSubscription = null;
    if (subscription != null) {
      unawaited(subscription.cancel());
    }

    super.dispose();
  }
}
