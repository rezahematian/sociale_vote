import 'package:sociale_vote/domain/identity/entities/user_profile.dart';
import 'package:sociale_vote/domain/identity/repositories/user_profile_repository.dart';

class UpdateUserProfile {
  final UserProfileRepository _repository;

  UpdateUserProfile(this._repository);

  Future<UserProfile> call({
    required String userId,
    String? displayName,
    String? username,
    String? avatarUrl,
    String? bio,
    String? country,
    String? city,
  }) async {
    final existing = await _repository.getUserProfile(userId);

    if (existing == null) {
      return _repository.createUserProfile(
        userId: userId,
        displayName: displayName,
        username: username,
        avatarUrl: avatarUrl,
        bio: bio,
        country: country,
        city: city,
      );
    }

    return _repository.updateUserProfile(
      userId: userId,
      displayName: displayName,
      username: username,
      avatarUrl: avatarUrl,
      bio: bio,
      country: country,
      city: city,
    );
  }
}