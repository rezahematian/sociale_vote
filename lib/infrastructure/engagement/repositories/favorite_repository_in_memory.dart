import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/engagement/entities/favorite.dart';
import 'package:sociale_vote/domain/engagement/repositories/favorite_repository.dart';

/// Implementazione in-memory dei preferiti.
///
/// v1: niente persistenza tra restart.
/// v2: potrà essere sostituita da repo HTTP.
class FavoriteRepositoryInMemory implements FavoriteRepository {
  final List<Favorite> _favorites = [];

  @override
  Future<bool> isFavorite({
    required String userId,
    required TargetRef target,
  }) async {
    return _favorites.any(
      (f) => f.userId == userId && f.target == target,
    );
  }

  @override
  Future<void> addFavorite(Favorite favorite) async {
    // Evita duplicati
    final exists = _favorites.any(
      (f) =>
          f.userId == favorite.userId &&
          f.target == favorite.target,
    );
    if (!exists) {
      _favorites.add(favorite);
    }
  }

  @override
  Future<void> removeFavorite({
    required String userId,
    required TargetRef target,
  }) async {
    _favorites.removeWhere(
      (f) => f.userId == userId && f.target == target,
    );
  }

  @override
  Future<List<Favorite>> getFavoritesForUser(String userId) async {
    return _favorites.where((f) => f.userId == userId).toList();
  }
}