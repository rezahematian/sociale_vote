import 'dart:async';

import 'package:sociale_vote/domain/identity/repositories/session_repository.dart';

/// Implementazione in-memory di [SessionRepository].
///
/// V2:
/// - mantiene un singolo userId in memoria
/// - espone uno stream per i cambi di sessione
/// - parte SENZA utente autenticato (guest = null)
class SessionRepositoryImpl implements SessionRepository {
  String? _currentUserId;

  final StreamController<String?> _currentUserIdController =
      StreamController<String?>.broadcast();

  SessionRepositoryImpl() {
    // Nessun utente autenticato all'avvio.
    _currentUserId = null;
    _currentUserIdController.add(_currentUserId);
  }

  @override
  Future<String?> getCurrentUserId() async {
    return _currentUserId;
  }

  @override
  Future<void> saveCurrentUserId(String userId) async {
    _currentUserId = userId;
    _currentUserIdController.add(_currentUserId);
  }

  @override
  Future<void> clearSession() async {
    _currentUserId = null;
    _currentUserIdController.add(_currentUserId);
  }

  @override
  Stream<String?> watchCurrentUserId() {
    return _currentUserIdController.stream;
  }
}