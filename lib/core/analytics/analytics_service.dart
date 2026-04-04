import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Wrapper locale e minimale per Firebase Analytics.
///
/// Obiettivo:
/// - evitare wiring in bootstrap/DI
/// - offrire un punto unico sicuro
/// - non rompere i flussi core se analytics fallisce
class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService([FirebaseAnalytics? analytics])
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  static final AnalyticsService instance = AnalyticsService();

  static bool _reportedUnavailable = false;

  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _safeCall(
      () => _analytics.logScreenView(
        screenName: _normalizeName(screenName),
        screenClass: _normalizeName(
          (screenClass != null && screenClass.trim().isNotEmpty)
              ? screenClass
              : screenName,
        ),
      ),
      'logScreenView',
    );
  }

  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) async {
    await _safeCall(
      () => _analytics.logEvent(
        name: _normalizeEventName(name),
        parameters: _sanitizeParameters(parameters),
      ),
      'logEvent:$name',
    );
  }

  Future<void> setUserId(String? userId) async {
    await _safeCall(
      () => _analytics.setUserId(id: userId),
      'setUserId',
    );
  }

  Future<void> setUserProperty({
    required String name,
    String? value,
  }) async {
    await _safeCall(
      () => _analytics.setUserProperty(
        name: _normalizeName(name),
        value: value,
      ),
      'setUserProperty:$name',
    );
  }

  Future<void> resetAnalyticsData() async {
    await _safeCall(
      _analytics.resetAnalyticsData,
      'resetAnalyticsData',
    );
  }

  Future<void> _safeCall(
    Future<void> Function() action,
    String context,
  ) async {
    try {
      await action();
    } on MissingPluginException catch (_) {
      _reportUnavailableOnce(context);
    } on PlatformException catch (error) {
      if (_isAnalyticsChannelUnavailable(error)) {
        _reportUnavailableOnce(context);
        return;
      }

      debugPrint('AnalyticsService [$context] error: $error');
    } catch (error) {
      debugPrint('AnalyticsService [$context] error: $error');
    }
  }

  bool _isAnalyticsChannelUnavailable(PlatformException error) {
    final code = error.code.trim().toLowerCase();
    final message = (error.message ?? '').trim().toLowerCase();

    if (code == 'channel-error') {
      return true;
    }

    if (message.contains('unable to establish connection on channel')) {
      return true;
    }

    if (message.contains('firebaseanalyticshostapi')) {
      return true;
    }

    return false;
  }

  void _reportUnavailableOnce(String context) {
    if (_reportedUnavailable) {
      return;
    }

    _reportedUnavailable = true;
    debugPrint(
      'AnalyticsService [$context]: Firebase Analytics non disponibile in questo runtime, tracking saltato.',
    );
  }

  Map<String, Object> _sanitizeParameters(Map<String, Object?> parameters) {
    final result = <String, Object>{};

    for (final entry in parameters.entries) {
      final key = _normalizeName(entry.key);
      final value = entry.value;

      if (value == null) {
        continue;
      }

      if (value is String || value is int || value is double || value is bool) {
        result[key] = value;
      } else {
        result[key] = value.toString();
      }
    }

    return result;
  }

  String _normalizeEventName(String value) {
    final normalized = _normalizeName(value).toLowerCase();
    return normalized.isEmpty ? 'app_event' : normalized;
  }

  String _normalizeName(String value) {
    final normalized = value
        .trim()
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');

    if (normalized.isEmpty) {
      return 'unknown';
    }

    return normalized.length <= 40
        ? normalized
        : normalized.substring(0, 40);
  }
}