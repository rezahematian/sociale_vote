import 'package:flutter/material.dart';

import '../core/session_manager.dart';
import '../features/auth/login_screen.dart';

/// CityNavigationGate
///
/// Punto UNICO di decisione per l’accesso alle sezioni città.
///
/// Responsabilità:
/// - Verifica stato autenticazione
/// - Decide se:
///   → mandare a Login
///   → aprire sezione città
///
/// NON FA:
/// - UI
/// - Logica di dominio
/// - Rendering
class CityNavigationGate {
  static void openCity({
    required BuildContext context,
    required String locationId,
  }) {
    final session = SessionManager();

    // =========================
    // NOT AUTHENTICATED → LOGIN
    // =========================
    if (!session.isAuthenticated) {
      debugPrint('🔒 Accesso negato → Login richiesto ($locationId)');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
      return;
    }

    // =========================
    // AUTHENTICATED → CITY FEED
    // =========================
    debugPrint('➡️ Apri sezione città: $locationId');

    // STEP SUCCESSIVO (quando esisterà):
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => CityFeedScreen(locationId: locationId),
    //   ),
    // );
  }
}
