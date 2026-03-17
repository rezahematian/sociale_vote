import 'package:flutter/material.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';

/// Controller application-layer per lo scope geografico globale.
///
/// Viene pensato come sorgente unica di verità per:
/// - livello corrente (world / country / city)
/// - eventuale countryCode / cityId
///
/// In futuro può essere usato da:
/// - mappa civica
/// - lista poll
/// - news feed
/// - social feed
class GeoScopeController extends ChangeNotifier {
  GeoScope _scope = GeoScope.world();

  GeoScope get scope => _scope;

  /// Alias più esplicito per i consumer che leggono lo scope globale corrente.
  GeoScope get currentScope => _scope;

  /// Setter generico: utile quando lo scope viene risolto da altri moduli
  /// (es. geo-search: query -> GeoScope).
  void setScope(GeoScope scope) {
    _updateScope(scope);
  }

  /// Imposta lo scope globale (mondo intero).
  void setWorld() {
    _updateScope(GeoScope.world());
  }

  /// Imposta lo scope su un paese specifico.
  void setCountry(String countryCode) {
    _updateScope(GeoScope.country(countryCode));
  }

  /// Imposta lo scope su una città specifica.
  void setCity({
    required String countryCode,
    required String cityId,
  }) {
    _updateScope(
      GeoScope.city(
        countryCode: countryCode,
        cityId: cityId,
      ),
    );
  }

  void _updateScope(GeoScope newScope) {
    if (_isSameScope(_scope, newScope)) {
      return;
    }

    _scope = newScope;
    notifyListeners();
  }

  bool _isSameScope(GeoScope a, GeoScope b) {
    if (identical(a, b)) return true;
    if (a == b) return true;
    return _scopeKey(a) == _scopeKey(b);
  }

  String _scopeKey(GeoScope scope) {
    final dynamic dynamicScope = scope;

    Object? readSafely(Object? Function() reader) {
      try {
        return reader();
      } catch (_) {
        return null;
      }
    }

    String normalizeText(Object? value) {
      return (value ?? '').toString().trim().toLowerCase();
    }

    String normalizeNum(Object? value) {
      if (value is num) {
        return value.toStringAsFixed(6);
      }
      return '';
    }

    return <String>[
      normalizeText(readSafely(() => dynamicScope.level) ?? scope.level),
      normalizeText(readSafely(() => dynamicScope.id)),
      normalizeText(readSafely(() => dynamicScope.code)),
      normalizeText(readSafely(() => dynamicScope.slug)),
      normalizeText(readSafely(() => dynamicScope.name)),
      normalizeText(readSafely(() => dynamicScope.countryCode)),
      normalizeText(readSafely(() => dynamicScope.countryName)),
      normalizeText(readSafely(() => dynamicScope.cityId)),
      normalizeText(readSafely(() => dynamicScope.cityName)),
      normalizeNum(readSafely(() => dynamicScope.centerLat) ?? scope.centerLat),
      normalizeNum(readSafely(() => dynamicScope.centerLng) ?? scope.centerLng),
      normalizeNum(readSafely(() => dynamicScope.radiusKm)),
    ].join('|');
  }
}