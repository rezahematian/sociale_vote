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
    if (newScope == _scope) {
      return;
    }
    _scope = newScope;
    notifyListeners();
  }
}