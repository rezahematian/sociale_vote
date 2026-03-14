import 'package:sociale_vote/domain/identity/entities/user_profile.dart';
import 'package:sociale_vote/domain/identity/repositories/user_profile_repository.dart';

class GetUserProfile {
  final UserProfileRepository _repository;

  GetUserProfile(this._repository);

  Future<UserProfile> call(String userId) async {
    final existing = await _repository.getUserProfile(userId);

    if (existing != null) {
      return existing;
    }

    // Se il profilo non esiste lo creiamo automaticamente
    return _repository.createUserProfile(userId: userId);
  }
}