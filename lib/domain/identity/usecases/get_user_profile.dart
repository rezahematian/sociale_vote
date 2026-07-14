import 'package:sociale_vote/domain/identity/entities/user_profile.dart';
import 'package:sociale_vote/domain/identity/repositories/session_repository.dart';
import 'package:sociale_vote/domain/identity/repositories/user_profile_repository.dart';

class GetUserProfile {
  final UserProfileRepository _repository;
  final SessionRepository _sessionRepository;

  GetUserProfile(
    this._repository,
    this._sessionRepository,
  );

  Future<UserProfile> call(String userId) async {
    final existing = await _repository.getUserProfile(userId);
    final existingDisplayName = _normalizeNullable(existing?.displayName);

    if (existing != null && existingDisplayName != null) {
      return existing;
    }

    final session = await _sessionRepository.getCurrentSession();
    final bootstrapDisplayName = session?.userId == userId
        ? _normalizeNullable(session?.displayName)
        : null;

    if (existing != null) {
      if (bootstrapDisplayName == null) {
        return existing;
      }

      return _repository.updateUserProfile(
        userId: userId,
        displayName: bootstrapDisplayName,
      );
    }

    return _repository.createUserProfile(
      userId: userId,
      displayName: bootstrapDisplayName,
    );
  }

  String? _normalizeNullable(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}
