import 'package:sociale_vote/domain/geo/entities/follow_scope.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';

/// Repository astratto per la gestione dei follow sugli scope geografici.
///
/// Responsabilità:
/// - verificare se un utente segue uno scope
/// - aggiungere follow
/// - rimuovere follow
/// - ottenere lista scope seguiti da un utente
abstract class FollowScopeRepository {
  /// Ritorna true se l'utente segue già lo scope.
  Future<bool> isFollowing({
    required String userId,
    required GeoScope scope,
  });

  /// Aggiunge un follow.
  Future<void> addFollow(FollowScope follow);

  /// Rimuove un follow.
  Future<void> removeFollow({
    required String userId,
    required GeoScope scope,
  });

  /// Restituisce tutti gli scope seguiti dall'utente.
  Future<List<FollowScope>> getFollowedScopesForUser(String userId);
}