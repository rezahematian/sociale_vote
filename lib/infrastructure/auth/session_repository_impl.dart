import 'dart:async';

import 'package:sociale_vote/domain/identity/entities/user.dart';
import 'package:sociale_vote/domain/identity/repositories/session_repository.dart';
import 'package:sociale_vote/domain/identity/value_objects/user_id.dart';

/// Implementazione in-memory di [SessionRepository].
///
/// V1: nessuna persistenza su disco, nessun token reale.
/// Serve per:
/// - avere un currentUser coerente in tutta l'app
/// - centralizzare la logica di sessione
/// - preparare il terreno per una futura versione con storage sicuro + backend.
///
/// In futuro potrai:
/// - leggere/scrivere da secure storage
/// - agganciare token di accesso/refresh
/// - fare bootstrap iniziale da storage all'avvio dell'app.
class SessionRepositoryImpl implements SessionRepository {
  User? _currentUser;

  /// StreamController broadcast per permettere a più listener
  /// (UI, controller, servizi) di reagire ai cambi di sessione.
  final StreamController<User?> _currentUserController =
      StreamController<User?>.broadcast();

  SessionRepositoryImpl();

  @override
  Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<UserId?> getCurrentUserId() async {
    return _currentUser?.id;
  }

  @override
  Future<void> saveSession(User user) async {
    _currentUser = user;
    _currentUserController.add(_currentUser);
  }

  @override
  Future<void> clearSession() async {
    _currentUser = null;
    _currentUserController.add(_currentUser);
  }

  @override
  Stream<User?> watchCurrentUser() {
    // Per comodità, emettiamo subito lo stato corrente al nuovo listener.
    // In Dart puro sarebbe tipico usare uno Stream "seeded", ma qui facciamo
    // una piccola utility che emette subito il valore corrente e poi si
    // sottoscrive al broadcast.
    final controller = StreamController<User?>();

    // Emette lo stato corrente
    controller.add(_currentUser);

    // Si sottoscrive agli aggiornamenti futuri
    final sub = _currentUserController.stream.listen(
      controller.add,
      onError: controller.addError,
      onDone: controller.close,
    );

    // Quando il listener si cancella, chiudiamo anche il nostro controller
    // e rimuoviamo la sottoscrizione al broadcast interno.
    controller.onCancel = () {
      sub.cancel();
    };

    return controller.stream;
  }

  /// Da chiamare quando l'app viene chiusa definitivamente,
  /// se vuoi evitare warning di controller non chiusi.
  void dispose() {
    _currentUserController.close();
  }
}