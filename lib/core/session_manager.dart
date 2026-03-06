import '../domain/user/user_identity.dart';

/// SessionManager
///
/// Gestisce lo stato di sessione dell’utente a livello globale.
///
/// CARATTERISTICHE:
/// - Singleton applicativo (unica istanza)
/// - Non dipende da UI
/// - Usato da:
///   - Login
///   - CityNavigationGate
///   - Router futuri
class SessionManager {
  // =========================
  // SINGLETON
  // =========================

  static final SessionManager _instance = SessionManager._internal();

  factory SessionManager() => _instance;

  SessionManager._internal();

  // =========================
  // STATE
  // =========================

  UserIdentity? _currentUser;

  // =========================
  // GETTERS
  // =========================

  UserIdentity? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  // =========================
  // SESSION CONTROL
  // =========================

  void startSession(UserIdentity user) {
    _currentUser = user;
  }

  void endSession() {
    _currentUser = null;
  }

  void ensureAuthenticated() {
    if (_currentUser == null) {
      throw Exception('User not authenticated');
    }
  }
}
