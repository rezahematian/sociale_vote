import 'rate_limit_policy.dart';
import 'rate_limit_service.dart';

class RateLimitGuard {
  final RateLimitService service;

  RateLimitGuard(this.service);

  void checkPost(String userId) {
    service.enforce(
      key: 'post_$userId',
      rule: RateLimitPolicy.postRule,
    );
  }

  void checkComment(String userId) {
    service.enforce(
      key: 'comment_$userId',
      rule: RateLimitPolicy.commentRule,
    );
  }

  void checkVote(String userId) {
    service.enforce(
      key: 'vote_$userId',
      rule: RateLimitPolicy.voteRule,
    );
  }
}
