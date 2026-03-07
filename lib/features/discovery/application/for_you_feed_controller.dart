import 'package:flutter/foundation.dart';

import 'package:sociale_vote/domain/content/social/entities/post.dart';
import 'package:sociale_vote/domain/discovery/usecases/get_for_you_feed.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';

/// Controller applicativo per il feed "For You".
///
/// Responsabilità:
/// - leggere lo scope corrente da [GeoScopeController]
/// - chiamare il use case [GetForYouFeed]
/// - esporre lo stato (lista post + loading + eventuale errore)
class ForYouFeedController extends ChangeNotifier {
  final GetForYouFeed _getForYouFeed;
  final GeoScopeController _geoScopeController;

  ForYouFeedController({
    required GetForYouFeed getForYouFeed,
    required GeoScopeController geoScopeController,
  })  : _getForYouFeed = getForYouFeed,
        _geoScopeController = geoScopeController;

  /// Lista dei post nel feed "For You".
  List<Post> _posts = [];
  List<Post> get posts => List.unmodifiable(_posts);

  /// Stato di caricamento.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Eventuale messaggio di errore (solo per debug/logging UI).
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Comodo per la UI: true se c'è un errore significativo.
  bool get hasError => _errorMessage != null && _errorMessage!.isNotEmpty;

  /// Carica il feed "For You" per l'utente corrente.
  ///
  /// - [userId]: può essere null (guest)
  /// - usa sempre lo [GeoScope] corrente letto dal [GeoScopeController]
  /// - [limit]: massimo numero di post da restituire
  Future<void> load({
    required String? userId,
    int limit = 10,
  }) async {
    // Scope corrente: world / country / city
    final GeoScope scope = _geoScopeController.scope;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _getForYouFeed(
        userId: userId,
        currentScope: scope,
        limit: limit,
      );

      _posts = result;
    } catch (e, _) {
      // In v1 logghiamo solo un messaggio semplice.
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Svuota lo stato corrente (utile in caso di logout o reset esplicito).
  void clear() {
    _posts = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}