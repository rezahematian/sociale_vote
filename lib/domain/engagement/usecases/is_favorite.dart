import 'package:sociale_vote/domain/common/value_objects/target_ref.dart';
import 'package:sociale_vote/domain/engagement/repositories/favorite_repository.dart';

/// Use case per leggere lo stato "è nei preferiti?" per un singolo target.
class IsFavorite {
  final FavoriteRepository _repository;

  IsFavorite(this._repository);

  Future<bool> call({
    required String userId,
    required TargetRef target,
  }) {
    return _repository.isFavorite(userId: userId, target: target);
  }
}