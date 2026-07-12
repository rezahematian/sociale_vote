import 'package:sociale_vote/core/http/api_client.dart';
import 'package:sociale_vote/domain/geo/entities/follow_scope.dart';
import 'package:sociale_vote/domain/geo/repositories/follow_scope_repository.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';

/// Stub HTTP del [FollowScopeRepository].
///
/// La configurazione R1 usa [FollowScopeRepositoryInMemory] tramite AppDI.
/// Questo adapter resta intenzionalmente non collegato finché non saranno
/// definiti endpoint REST reali per i follow geografici.
class FollowScopeRepositoryHttp implements FollowScopeRepository {
  // ignore: unused_field
  final ApiClient _client;

  FollowScopeRepositoryHttp(this._client);

  @override
  Future<bool> isFollowing({
    required String userId,
    required GeoScope scope,
  }) async {
    // Adapter non attivo in R1: nessun endpoint REST disponibile.
    throw UnimplementedError(
      'FollowScopeRepositoryHttp.isFollowing non è ancora implementato.',
    );
  }

  @override
  Future<void> addFollow(FollowScope follow) async {
    // Adapter non attivo in R1: nessun endpoint REST disponibile.
    throw UnimplementedError(
      'FollowScopeRepositoryHttp.addFollow non è ancora implementato.',
    );
  }

  @override
  Future<void> removeFollow({
    required String userId,
    required GeoScope scope,
  }) async {
    // Adapter non attivo in R1: nessun endpoint REST disponibile.
    throw UnimplementedError(
      'FollowScopeRepositoryHttp.removeFollow non è ancora implementato.',
    );
  }

  @override
  Future<List<FollowScope>> getFollowedScopesForUser(
    String userId,
  ) async {
    // Adapter non attivo in R1: nessun endpoint REST disponibile.
    throw UnimplementedError(
      'FollowScopeRepositoryHttp.getFollowedScopesForUser non è ancora implementato.',
    );
  }
}
