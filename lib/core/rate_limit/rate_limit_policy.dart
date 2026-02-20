import 'rate_limit_rule.dart';

class RateLimitPolicy {
  static const RateLimitRule postRule =
      RateLimitRule(maxActions: 10, window: Duration(minutes: 5));

  static const RateLimitRule commentRule =
      RateLimitRule(maxActions: 20, window: Duration(minutes: 5));

  static const RateLimitRule voteRule =
      RateLimitRule(maxActions: 1, window: Duration(hours: 24));
}
