import 'package:sociale_vote/domain/geo/entities/follow_scope.dart';
import 'package:sociale_vote/domain/geo/repositories/follow_scope_repository.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';

/// Use case applicativo per togglare il follow di uno scope geografico.
///
/// - Se l'utente sta già seguendo [scope], viene rimosso il follow e
///   il metodo ritorna `false`.
/// - Se l'utente non sta seguendo [scope], viene aggiunto il follow e
///   il metodo ritorna `true`.
class ToggleFollowScope {
  final FollowScopeRepository _repository;

  const ToggleFollowScope(this._repository);

  /// Esegue il toggle del follow:
  /// - true  → dopo la chiamata l'utente STA seguendo lo scope
  /// - false → dopo la chiamata l'utente NON STA seguendo lo scope
  Future<bool> call({
    required String userId,
    required GeoScope scope,
  }) async {
    final alreadyFollowing = await _repository.isFollowing(
      userId: userId,
      scope: scope,
    );

    if (alreadyFollowing) {
      await _repository.removeFollow(
        userId: userId,
        scope: scope,
      );
      return false;
    } else {
      final follow = FollowScope(
        userId: userId,
        scope: scope,
        followedAt: DateTime.now().toUtc(),
      );

      await _repository.addFollow(follow);
      return true;
    }
  }
}