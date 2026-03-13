import 'package:sociale_vote/domain/identity/entities/user_profile.dart';
import 'package:sociale_vote/domain/identity/repositories/user_profile_repository.dart';

class GetUserProfile {
  final UserProfileRepository _repository;

  GetUserProfile(this._repository);

  Future<UserProfile?> call(String userId) {
    return _repository.getUserProfile(userId);
  }
}