import 'package:sociale_vote/domain/geo/entities/follow_scope.dart';
import 'package:sociale_vote/domain/geo/repositories/follow_scope_repository.dart';

/// Use case per ottenere tutti gli scope geografici
/// seguiti da un determinato utente.
///
/// Non contiene logica complessa: delega al repository.
/// Serve come punto di estensione futura (es. caching,
/// filtro, sorting, policy).
class GetFollowedScopesForUser {
  final FollowScopeRepository _repository;

  const GetFollowedScopesForUser(this._repository);

  Future<List<FollowScope>> call(String userId) {
    return _repository.getFollowedScopesForUser(userId);
  }
}