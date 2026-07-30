import 'package:sociale_vote/domain/admin/entities/admin_entities.dart';
import 'package:sociale_vote/domain/identity/value_objects/role.dart';

class AdminUserSearchPage {
  final List<AdminUserSummary> users;
  final int page;
  final int perPage;
  final int totalCount;
  final int totalPages;

  AdminUserSearchPage({
    required List<AdminUserSummary> users,
    required this.page,
    required this.perPage,
    required this.totalCount,
    required this.totalPages,
  }) : users = List<AdminUserSummary>.unmodifiable(users);

  bool get hasPreviousPage => page > 1;
  bool get hasNextPage => page < totalPages;
}

abstract class AdminRepository {
  Future<AdminDashboardSummary> getDashboardSummary();

  Future<AdminUserSearchPage> searchUsers({
    String? query,
    int page = 1,
    int perPage = 25,
  });

  Future<AdminUserDetail> getUserDetail({
    required String userId,
  });

  Future<void> changeSystemRole({
    required String operationId,
    required String targetUserId,
    required Role role,
    required String reason,
  });

  Future<void> suspendAccount({
    required String operationId,
    required String targetUserId,
    required DateTime suspendedUntil,
    required String reason,
  });

  Future<void> reactivateAccount({
    required String operationId,
    required String targetUserId,
    required String reason,
  });

  Future<void> forceLogout({
    required String operationId,
    required String targetUserId,
    required String reason,
  });

  Future<void> deleteAccount({
    required String operationId,
    required String targetUserId,
    required String reason,
    required String confirmation,
    required String accountIdentifier,
  });

  Future<List<AdminAuditEntry>> getAuditEntries({
    String? actorUserId,
    String? action,
    String? targetId,
    AdminAuditResult? result,
    DateTime? from,
    DateTime? to,
    int limit = 50,
    int offset = 0,
  });
}
