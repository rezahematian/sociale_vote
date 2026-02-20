import '../../core/auth/auth_guard.dart';
import '../../core/rate_limit/rate_limit_guard.dart';
import '../../core/audit/vote_audit_service.dart';
import '../../domain/poll/vote_request.dart';
import 'vote_api_service.dart';

class VoteAbuseUseCase {
  final AuthGuard authGuard;
  final RateLimitGuard rateLimitGuard;
  final VoteApiService apiService;
  final VoteAuditService auditService;

  VoteAbuseUseCase({
    required this.authGuard,
    required this.rateLimitGuard,
    required this.apiService,
    required this.auditService,
  });

  void execute({
    required String pollId,
    required VoteRequest request,
  }) {
    final user = authGuard.enforceVerifiedUser();

    rateLimitGuard.checkVote(user.id);

    apiService.vote(
      pollId: pollId,
      request: request,
      user: user,
    );

    auditService.record(
      pollId: pollId,
      userId: user.id,
      optionId: request.optionId,
    );
  }
}
