import 'trust_profile.dart';
import 'trust_policy.dart';

class TrustService {
  final Map<String, TrustProfile> _profiles = {};

  TrustProfile getProfile(String userId) {
    return _profiles[userId] ??
        TrustProfile(
          userId: userId,
          score: 0,
          level: TrustPolicy.levelFromScore(0),
        );
  }

  TrustProfile adjustScore(String userId, int delta) {
    final current = getProfile(userId);
    final newScore = current.score + delta;
    final newLevel = TrustPolicy.levelFromScore(newScore);

    final updated = current.copyWith(
      score: newScore,
      level: newLevel,
    );

    _profiles[userId] = updated;
    return updated;
  }
}
