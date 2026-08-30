import 'package:sociale_vote/domain/admin/entities/admin_entities.dart';
import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/role.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';

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

  Future<AdminReportQueuePage> getReportQueue({
    AdminReportStatus? status,
    AdminReportTargetType? targetType,
    int limit = 25,
    int offset = 0,
  });

  Future<AdminReportQueuePage> getEscalatedReportQueue({
    int limit = 25,
    int offset = 0,
  });

  Future<void> recordReportDecision({
    required String reportId,
    required AdminReportDecision decision,
    required String reviewNote,
  });

  Future<void> resolveEscalatedReport({
    required String reportId,
    required AdminReportResolution resolution,
    required String resolutionNote,
  });

  Future<void> setReportContentVisibility({
    required String reportId,
    required bool isHidden,
    required String reason,
  });

  Future<void> changeSystemRole({
    required String operationId,
    required String targetUserId,
    required Role role,
    required String reason,
  });

  Future<void> setPublicIdentity({
    required String operationId,
    required String targetUserId,
    required ActorType actorType,
    required VerificationLevel verificationLevel,
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

  Future<AdminWorkspaceEntitlement?> getWorkspaceEntitlement({
    required String targetUserId,
  });

  Future<AdminWorkspaceEntitlement> setWorkspaceEntitlement({
    required String targetUserId,
    required AdminWorkspaceEntitlementStatus entitlementStatus,
    DateTime? expiresAt,
    required String reason,
  });

  Future<AdminFinanceSnapshot> getFinanceSnapshot();

  Future<void> addFinanceEntry({
    required DateTime occurredOn,
    required AdminFinanceDirection direction,
    required int amountCents,
    required String category,
    String? counterparty,
    String? note,
    required String reason,
  });

  Future<void> voidFinanceEntry({
    required String entryId,
    required String reason,
  });

  Future<List<AdminRadioMondoTrack>> getRadioMondoTracks();

  Future<AdminRadioMondoTrack> upsertRadioMondoTrack({
    String? trackId,
    required String title,
    required String audioUrl,
    required int sortOrder,
    required bool isEnabled,
    required String attribution,
    String? licenseUrl,
    required bool rightsConfirmed,
    required String reason,
  });

  Future<void> setRadioMondoTrackEnabled({
    required String trackId,
    required bool isEnabled,
    required String reason,
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
