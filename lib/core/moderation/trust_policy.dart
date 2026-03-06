import 'trust_level.dart';

class TrustPolicy {
  static TrustLevel levelFromScore(int score) {
    if (score < -50) return TrustLevel.banned;
    if (score < 0) return TrustLevel.low;
    if (score < 100) return TrustLevel.normal;
    return TrustLevel.high;
  }
}
