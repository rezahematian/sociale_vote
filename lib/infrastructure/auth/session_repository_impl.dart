import 'dart:async';

import 'package:sociale_vote/domain/identity/repositories/session_repository.dart';

/// Implementazione in-memory di [SessionRepository].
///
/// V3:
/// - mantiene una [AuthSession] completa in memoria
/// - espone stream sia della sessione che del solo userId
/// - parte SENZA utente autenticato (sessione = null)
/// - mantiene compatibilità con i metodi legacy basati su userId
class SessionRepositoryImpl implements SessionRepository {
  AuthSession? _currentSession;

  final StreamController<AuthSession?> _sessionController =
      StreamController<AuthSession?>.broadcast();

  final StreamController<String?> _currentUserIdController =
      StreamController<String?>.broadcast();

  @override
  Future<AuthSession?> getCurrentSession() async {
    return _currentSession;
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    _setCurrentSession(session);
  }

  @override
  Future<String?> getCurrentUserId() async {
    return _currentSession?.userId;
  }

  @override
  Future<void> saveCurrentUserId(String userId) async {
    final currentSession = _currentSession;
    if (currentSession?.userId == userId) {
      return;
    }

    _setCurrentSession(
      AuthSession(
        userId: userId,
        accessToken: '',
      ),
    );
  }

  @override
  Future<void> clearSession() async {
    _setCurrentSession(null);
  }

  @override
  Stream<AuthSession?> watchSession() {
    return _watchWithCurrentValue<AuthSession?>(
      currentValue: () => _currentSession,
      changes: _sessionController.stream,
    );
  }

  @override
  Stream<String?> watchCurrentUserId() {
    return _watchWithCurrentValue<String?>(
      currentValue: () => _currentSession?.userId,
      changes: _currentUserIdController.stream,
    );
  }

  void _setCurrentSession(AuthSession? session) {
    final previousSession = _currentSession;
    final sessionChanged = !_areSessionsEqual(previousSession, session);
    if (!sessionChanged) {
      return;
    }

    final previousUserId = previousSession?.userId;
    final nextUserId = session?.userId;

    _currentSession = session;
    _sessionController.add(session);

    if (previousUserId != nextUserId) {
      _currentUserIdController.add(nextUserId);
    }
  }

  bool _areSessionsEqual(AuthSession? first, AuthSession? second) {
    if (identical(first, second)) {
      return true;
    }

    if (first == null || second == null) {
      return false;
    }

    return first.userId == second.userId &&
        first.accessToken == second.accessToken &&
        first.refreshToken == second.refreshToken &&
        first.email == second.email &&
        first.displayName == second.displayName &&
        first.role == second.role;
  }

  Stream<T> _watchWithCurrentValue<T>({
    required T Function() currentValue,
    required Stream<T> changes,
  }) {
    late final StreamController<T> controller;
    StreamSubscription<T>? subscription;

    controller = StreamController<T>(
      sync: true,
      onListen: () {
        subscription = changes.listen(
          controller.add,
          onError: controller.addError,
          onDone: controller.close,
        );
        controller.add(currentValue());
      },
      onPause: () {
        subscription?.pause();
      },
      onResume: () {
        subscription?.resume();
      },
      onCancel: () {
        return subscription?.cancel();
      },
    );

    return controller.stream;
  }
}
