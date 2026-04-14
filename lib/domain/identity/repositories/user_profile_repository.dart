import 'package:sociale_vote/domain/identity/entities/user_profile.dart';
import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/institution_level.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_status.dart';

abstract class UserProfileRepository {
  Future<UserProfile?> getUserProfile(String userId);

  Future<UserProfile?> getUserProfileByUsername(String username);

  Future<UserProfile> createUserProfile({
    required String userId,
    String? displayName,
    String? username,
    String? avatarUrl,
    String? bio,
    String? country,
    String? city,
  });

  Future<UserProfile> updateUserProfile({
    required String userId,
    String? displayName,
    String? username,
    String? avatarUrl,
    String? bio,
    String? country,
    String? city,
  });

  Future<UserProfile> updateIdentityState({
    required String userId,
    required ActorType actorType,
    required VerificationLevel verificationLevel,
    required VerificationStatus verificationStatus,
    InstitutionLevel? institutionLevel,
    String? officialTitle,
    String? institutionName,
    DateTime? verificationRequestedAt,
    DateTime? verifiedAt,
  });
}