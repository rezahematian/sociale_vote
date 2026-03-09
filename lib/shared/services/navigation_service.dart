import 'package:flutter/material.dart';

/// Servizio centrale di navigazione.
///
/// Permette di navigare senza BuildContext usando una
/// GlobalKey collegata al MaterialApp.
///
/// Uso:
/// MaterialApp(
///   navigatorKey: NavigationService.navigatorKey,
/// )
///
/// Poi ovunque:
/// NavigationService.push(...)
class NavigationService {
  NavigationService._();

  /// Key globale del Navigator.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static NavigatorState? get _navigator => navigatorKey.currentState;

  /// Push semplice.
  static Future<T?> push<T>(Route<T> route) {
    return _navigator!.push(route);
  }

  /// Push con nome route.
  static Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return _navigator!.pushNamed<T>(routeName, arguments: arguments);
  }

  /// Replace route corrente.
  static Future<T?> pushReplacement<T, TO>(
    Route<T> route, {
    TO? result,
  }) {
    return _navigator!.pushReplacement(route, result: result);
  }

  /// Replace con route name.
  static Future<T?> pushReplacementNamed<T, TO>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return _navigator!.pushReplacementNamed(
      routeName,
      result: result,
      arguments: arguments,
    );
  }

  /// Pop route corrente.
  static void pop<T extends Object?>([T? result]) {
    if (_navigator!.canPop()) {
      _navigator!.pop(result);
    }
  }

  /// Torna alla root.
  static void popUntilRoot() {
    _navigator!.popUntil((route) => route.isFirst);
  }
}