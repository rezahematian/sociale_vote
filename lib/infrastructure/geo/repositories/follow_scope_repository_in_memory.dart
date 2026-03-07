import 'package:sociale_vote/domain/geo/entities/follow_scope.dart';
import 'package:sociale_vote/domain/geo/repositories/follow_scope_repository.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';

/// Implementazione in-memory del FollowScopeRepository.
///
/// ⚠️ V1:
/// - Nessuna persistenza tra restart
/// - Lista locale in memoria
class FollowScopeRepositoryInMemory implements FollowScopeRepository {
  final List<FollowScope> _follows = [];

  @override
  Future<bool> isFollowing({
    required String userId,
    required GeoScope scope,
  }) async {
    return _follows.any(
      (f) => f.userId == userId && f.scope == scope,
    );
  }

  @override
  Future<void> addFollow(FollowScope follow) async {
    final exists = _follows.any(
      (f) => f.userId == follow.userId && f.scope == follow.scope,
    );

    if (!exists) {
      _follows.add(follow);
    }
  }

  @override
  Future<void> removeFollow({
    required String userId,
    required GeoScope scope,
  }) async {
    _follows.removeWhere(
      (f) => f.userId == userId && f.scope == scope,
    );
  }

  @override
  Future<List<FollowScope>> getFollowedScopesForUser(
    String userId,
  ) async {
    return _follows
        .where((f) => f.userId == userId)
        .toList(growable: false);
  }
}