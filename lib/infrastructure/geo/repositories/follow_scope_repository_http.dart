import 'package:sociale_vote/core/http/api_client.dart';
import 'package:sociale_vote/domain/geo/entities/follow_scope.dart';
import 'package:sociale_vote/domain/geo/repositories/follow_scope_repository.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';

/// Implementazione HTTP-ready del FollowScopeRepository.
///
/// ⚠️ V1:
/// - Solo wiring, nessuna vera chiamata al backend.
/// - Tutti i metodi lanciano UnimplementedError finché
///   non vengono collegati agli endpoint reali.
class FollowScopeRepositoryHttp implements FollowScopeRepository {
  // ignore: unused_field
  final ApiClient _client;

  FollowScopeRepositoryHttp(this._client);

  @override
  Future<bool> isFollowing({
    required String userId,
    required GeoScope scope,
  }) async {
    // TODO: implementare chiamata REST al backend reale.
    throw UnimplementedError(
      'FollowScopeRepositoryHttp.isFollowing non è ancora implementato.',
    );
  }

  @override
  Future<void> addFollow(FollowScope follow) async {
    // TODO: implementare chiamata REST al backend reale.
    throw UnimplementedError(
      'FollowScopeRepositoryHttp.addFollow non è ancora implementato.',
    );
  }

  @override
  Future<void> removeFollow({
    required String userId,
    required GeoScope scope,
  }) async {
    // TODO: implementare chiamata REST al backend reale.
    throw UnimplementedError(
      'FollowScopeRepositoryHttp.removeFollow non è ancora implementato.',
    );
  }

  @override
  Future<List<FollowScope>> getFollowedScopesForUser(
    String userId,
  ) async {
    // TODO: implementare chiamata REST al backend reale.
    throw UnimplementedError(
      'FollowScopeRepositoryHttp.getFollowedScopesForUser non è ancora implementato.',
    );
  }
}
