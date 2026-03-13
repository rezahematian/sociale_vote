import 'package:sociale_vote/domain/identity/entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<UserProfile?> getUserProfile(String userId);

  Future<UserProfile> updateUserProfile({
    required String userId,
    String? displayName,
    String? avatarUrl,
    String? bio,
    String? country,
    String? city,
  });
}