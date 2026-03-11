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

  SessionRepositoryImpl() {
    _currentSession = null;
    _sessionController.add(_currentSession);
    _currentUserIdController.add(_currentSession?.userId);
  }

  @override
  Future<AuthSession?> getCurrentSession() async {
    return _currentSession;
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    _currentSession = session;
    _sessionController.add(_currentSession);
    _currentUserIdController.add(_currentSession?.userId);
  }

  @override
  Future<String?> getCurrentUserId() async {
    return _currentSession?.userId;
  }

  @override
  Future<void> saveCurrentUserId(String userId) async {
    _currentSession = AuthSession(
      userId: userId,
      accessToken: '',
    );
    _sessionController.add(_currentSession);
    _currentUserIdController.add(_currentSession?.userId);
  }

  @override
  Future<void> clearSession() async {
    _currentSession = null;
    _sessionController.add(_currentSession);
    _currentUserIdController.add(_currentSession?.userId);
  }

  @override
  Stream<AuthSession?> watchSession() {
    return _sessionController.stream;
  }

  @override
  Stream<String?> watchCurrentUserId() {
    return _currentUserIdController.stream;
  }
}