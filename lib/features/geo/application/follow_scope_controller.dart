import 'package:flutter/foundation.dart';
import 'package:sociale_vote/domain/geo/entities/follow_scope.dart';
import 'package:sociale_vote/domain/geo/usecases/get_followed_scopes_for_user.dart';
import 'package:sociale_vote/domain/geo/usecases/toggle_follow_scope.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';

/// Controller applicativo per il "follow" degli scope geografici.
///
/// Responsabilità:
/// - sapere se l'utente corrente segue lo scope corrente
///   esposto da [GeoScopeController]
/// - permettere il toggle follow/unfollow
///
/// Nota: per semplicità, questo controller assume che l'utente
/// corrente venga passato al costruttore (snapshot di sessione).
class FollowScopeController extends ChangeNotifier {
  final GeoScopeController _geoScopeController;
  final ToggleFollowScope _toggleFollowScope;
  final GetFollowedScopesForUser _getFollowedScopesForUser;

  /// Id utente corrente (null se guest).
  final String? _userId;

  bool _isFollowingCurrentScope = false;
  bool _isLoading = false;

  bool _isDisposed = false;
  int _operationId = 0;

  FollowScopeController({
    required GeoScopeController geoScopeController,
    required ToggleFollowScope toggleFollowScope,
    required GetFollowedScopesForUser getFollowedScopesForUser,
    required String? userId,
  })  : _geoScopeController = geoScopeController,
        _toggleFollowScope = toggleFollowScope,
        _getFollowedScopesForUser = getFollowedScopesForUser,
        _userId = userId {
    _init();
  }

  bool get isFollowingCurrentScope => _isFollowingCurrentScope;

  bool get isLoading => _isLoading;

  bool get isGuest => _userId == null;

  /// Scope corrente esposto come comodità.
  GeoScopeController get geoScopeController => _geoScopeController;

  void _init() {
    // Carichiamo lo stato di follow per lo scope corrente se l'utente è loggato.
    if (_userId != null) {
      _loadFollowStateForCurrentScope();
    }

    // Sync automatico: quando cambia lo scope geografico,
    // ricarichiamo lo stato di follow.
    _geoScopeController.addListener(_onScopeChanged);
  }

  void _onScopeChanged() {
    if (_isDisposed) {
      return;
    }

    // Ogni volta che cambia lo scope (World / Country / City / Area),
    // ricalcoliamo se l'utente segue o meno lo scope corrente.
    if (_userId != null) {
      _loadFollowStateForCurrentScope();
    } else {
      // Se è guest non segue nulla.
      _isFollowingCurrentScope = false;
      _safeNotifyListeners();
    }
  }

  Future<void> _loadFollowStateForCurrentScope() async {
    if (_isDisposed) {
      return;
    }

    final userId = _userId;
    if (userId == null) {
      _isFollowingCurrentScope = false;
      _safeNotifyListeners();
      return;
    }

    final requestedScope = _geoScopeController.scope;
    final operationId = ++_operationId;

    _isLoading = true;
    _safeNotifyListeners();

    try {
      final follows = await _getFollowedScopesForUser(userId);

      if (!_isOperationCurrent(operationId)) {
        return;
      }

      _isFollowingCurrentScope = follows.any(
        (FollowScope follow) => follow.scope == requestedScope,
      );
    } finally {
      if (_isOperationCurrent(operationId)) {
        _isLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  /// API generica: ritorna se lo scope passato è seguito.
  ///
  /// Per v1 questo controller gestisce solo lo scope CORRENTE;
  /// se lo scope richiesto è diverso, ritorniamo `false`.
  bool isScopeFollowed(GeoScope scope) {
    final currentScope = _geoScopeController.scope;
    if (scope == currentScope) {
      return _isFollowingCurrentScope;
    }
    // V1: solo scope corrente gestito.
    return false;
  }

  /// Esegue il toggle di follow su uno scope specifico.
  ///
  /// Se lo scope coincide con quello corrente, aggiorna anche
  /// [_isFollowingCurrentScope] e notifica i listener.
  ///
  /// Se l'utente è guest, non fa nulla (la UI deve bloccare o mostrare login).
  Future<void> toggleFollowForScope(GeoScope scope) async {
    if (_isDisposed) {
      return;
    }

    final userId = _userId;
    if (userId == null) {
      // guest: niente follow
      return;
    }

    final operationId = ++_operationId;

    _isLoading = true;
    _safeNotifyListeners();

    try {
      final result = await _toggleFollowScope(
        userId: userId,
        scope: scope,
      );

      if (!_isOperationCurrent(operationId)) {
        return;
      }

      // result = true → dopo la chiamata STA seguendo quello scope
      if (scope == _geoScopeController.scope) {
        _isFollowingCurrentScope = result;
      }
    } finally {
      if (_isOperationCurrent(operationId)) {
        _isLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  /// Esegue il toggle di follow sull'attuale scope del GeoScopeController.
  ///
  /// Manteniamo questa API per retrocompatibilità:
  /// internamente delega a [toggleFollowForScope] con lo scope corrente.
  Future<void> toggleFollowForCurrentScope() async {
    final currentScope = _geoScopeController.scope;
    await toggleFollowForScope(currentScope);
  }

  /// Ricarica lo stato di follow quando cambia lo scope
  /// (chiamata esplicita, se serve; in più abbiamo il listener su GeoScopeController).
  Future<void> refreshForCurrentScope() async {
    await _loadFollowStateForCurrentScope();
  }

  bool _isOperationCurrent(int operationId) {
    return !_isDisposed && operationId == _operationId;
  }

  void _safeNotifyListeners() {
    if (_isDisposed) {
      return;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _operationId++;
    _geoScopeController.removeListener(_onScopeChanged);
    super.dispose();
  }
}
