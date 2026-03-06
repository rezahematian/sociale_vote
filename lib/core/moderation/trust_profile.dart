import 'trust_level.dart';

class TrustProfile {
  final String userId;
  final int score;
  final TrustLevel level;

  const TrustProfile({
    required this.userId,
    required this.score,
    required this.level,
  });

  TrustProfile copyWith({
    int? score,
    TrustLevel? level,
  }) {
    return TrustProfile(
      userId: userId,
      score: score ?? this.score,
      level: level ?? this.level,
    );
  }
}
