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

    if (existing != null) {
      return existing;
    }

    final session = await _sessionRepository.getCurrentSession();
    final bootstrapDisplayName =
        session?.userId == userId ? _normalizeNullable(session?.displayName) : null;

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