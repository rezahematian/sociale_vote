import 'package:flutter/material.dart';

import '../core/session_manager.dart';
import '../features/auth/login_screen.dart';

import '../features/news/news_screen.dart';
import '../features/news/news_controller.dart';
import '../features/news/news_item.dart'; // NewsScope
import '../core/bootstrap/app_bootstrap.dart';

/// CityNavigationGate
///
/// Punto centrale e DEFINITIVO di decisione
/// per la navigazione geografica.
///
/// 🔒 REGOLE FERREE:
/// - NON contiene UI
/// - NON conosce widget chiamanti (Home, Map, Search, ecc.)
/// - Decide SOLO in base a:
///   - stato sessione
///   - locationId
///
/// 🔁 FLUSSO:
/// - Guest  → Login → ritorno automatico → destinazione corretta
/// - Logged → destinazione corretta
///
/// Questo file è il "cervello geografico" dell'app.
/// Una volta chiuso, NON si riapre.
class CityNavigationGate {
  CityNavigationGate._();

  /// Sessione globale (singleton)
  static final SessionManager _session = SessionManager();

  /// Cache temporanea della location richiesta (guest flow)
  static String? _pendingLocationId;

  /// Entry point unico per la navigazione geografica
  static Future<void> openCity(
    BuildContext context, {
    required String locationId,
  }) async {
    if (!_session.isAuthenticated) {
      _pendingLocationId = locationId;
      await _goToLogin(context);
    } else {
      await _routeByLocation(context, locationId);
    }
  }

  // =========================
  // LOGIN FLOW
  // =========================

  static Future<void> _goToLogin(BuildContext context) async {
    debugPrint('🔐 Guest → login (location=$_pendingLocationId)');

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );

    if (result == true && _pendingLocationId != null) {
      final locationId = _pendingLocationId!;
      _pendingLocationId = null;

      debugPrint('↩️ Login completato → ritorno a: $locationId');
      await _routeByLocation(context, locationId);
    }
  }

  // =========================
  // ROUTING LOGIC (CORE)
  // =========================

  static Future<void> _routeByLocation(
    BuildContext context,
    String locationId,
  ) async {
    final NewsController newsController = AppBootstrap.newsController;

    // 🌍 MONDO
    if (locationId == 'world') {
      debugPrint('🌍 News globali');

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NewsScreen(
            controller: newsController,
            languageCode: 'it',
            countryCode: 'WW', // placeholder semantico per global
            scope: NewsScope.global,
          ),
        ),
      );
      return;
    }

    // 🇮🇹 / 🇺🇸 / 🇫🇷 PAESE (ISO-2)
    if (_isCountryCode(locationId)) {
      final countryCode = locationId.toUpperCase();

      debugPrint('🏳️ News paese: $countryCode');

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NewsScreen(
            controller: newsController,
            languageCode: 'it',
            countryCode: countryCode,
            scope: NewsScope.country,
          ),
        ),
      );
      return;
    }

    // 🏙️ CITTÀ
    assert(
      locationId.isNotEmpty,
      'CityNavigationGate: locationId città non valido',
    );

    debugPrint('🏙️ News città: $locationId');

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewsScreen(
          controller: newsController,
          languageCode: 'it',
          countryCode: 'IT', // TODO: derivare dal cityId
          scope: NewsScope.city,
          locationId: locationId,
        ),
      ),
    );
  }

  // =========================
  // HELPERS
  // =========================

  static bool _isCountryCode(String value) {
    return value.length == 2 &&
        RegExp(r'^[a-zA-Z]{2}$').hasMatch(value);
  }
}
