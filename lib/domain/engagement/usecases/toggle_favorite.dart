import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/engagement/entities/favorite.dart';
import 'package:sociale_vote/domain/engagement/repositories/favorite_repository.dart';

/// Use case per togglare lo stato di "preferito" (⭐) su un contenuto.
///
/// Se il contenuto è già tra i preferiti → lo rimuove.
/// Se non è tra i preferiti → lo aggiunge.
class ToggleFavorite {
  final FavoriteRepository _repository;

  ToggleFavorite(this._repository);

  Future<bool> call({
    required String userId,
    required TargetRef target,
  }) async {
    final alreadyFavorite = await _repository.isFavorite(
      userId: userId,
      target: target,
    );

    if (alreadyFavorite) {
      await _repository.removeFavorite(userId: userId, target: target);
      return false; // ora NON è più preferito
    } else {
      final favorite = Favorite(
        userId: userId,
        target: target,
        createdAt: DateTime.now().toUtc(),
      );
      await _repository.addFavorite(favorite);
      return true; // ora è preferito
    }
  }
}