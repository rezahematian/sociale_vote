import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/role.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_status.dart';

enum AdminWorkspaceEntitlementStatus {
  none,
  pilot,
  active,
  suspended,
  expired,
}

extension AdminWorkspaceEntitlementStatusX on AdminWorkspaceEntitlementStatus {
  String get storageKey => switch (this) {
        AdminWorkspaceEntitlementStatus.none => 'none',
        AdminWorkspaceEntitlementStatus.pilot => 'pilot',
        AdminWorkspaceEntitlementStatus.active => 'active',
        AdminWorkspaceEntitlementStatus.suspended => 'suspended',
        AdminWorkspaceEntitlementStatus.expired => 'expired',
      };

  static AdminWorkspaceEntitlementStatus fromStorageKey(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'pilot' => AdminWorkspaceEntitlementStatus.pilot,
      'active' => AdminWorkspaceEntitlementStatus.active,
      'suspended' => AdminWorkspaceEntitlementStatus.suspended,
      'expired' => AdminWorkspaceEntitlementStatus.expired,
      _ => AdminWorkspaceEntitlementStatus.none,
    };
  }
}

class AdminWorkspaceEntitlement {
  final String organizationId;
  final String organizationName;
  final String verificationStatus;
  final String workspaceId;
  final AdminWorkspaceEntitlementStatus entitlementStatus;
  final String workspaceStatus;
  final String planKey;
  final String commercialMode;
  final bool billingEnabled;
  final DateTime? entitlementStartedAt;
  final DateTime? entitlementExpiresAt;

  const AdminWorkspaceEntitlement({
    required this.organizationId,
    required this.organizationName,
    required this.verificationStatus,
    required this.workspaceId,
    required this.entitlementStatus,
    required this.workspaceStatus,
    required this.planKey,
    required this.commercialMode,
    required this.billingEnabled,
    required this.entitlementStartedAt,
    required this.entitlementExpiresAt,
  });
}

enum AdminFinanceDirection { income, expense }

extension AdminFinanceDirectionX on AdminFinanceDirection {
  String get storageKey => switch (this) {
        AdminFinanceDirection.income => 'income',
        AdminFinanceDirection.expense => 'expense',
      };

  static AdminFinanceDirection fromStorageKey(String? value) {
    return value?.trim().toLowerCase() == 'income'
        ? AdminFinanceDirection.income
        : AdminFinanceDirection.expense;
  }
}

class AdminFinanceEntry {
  final String id;
  final DateTime occurredOn;
  final AdminFinanceDirection direction;
  final int amountCents;
  final String currency;
  final String category;
  final String? counterparty;
  final String? note;
  final DateTime createdAt;

  const AdminFinanceEntry({
    required this.id,
    required this.occurredOn,
    required this.direction,
    required this.amountCents,
    required this.currency,
    required this.category,
    required this.counterparty,
    required this.note,
    required this.createdAt,
  });
}

class AdminFinanceSnapshot {
  final String currency;
  final DateTime monthStart;
  final int monthIncomeCents;
  final int monthExpenseCents;
  final int monthBalanceCents;
  final int totalIncomeCents;
  final int totalExpenseCents;
  final int totalBalanceCents;
  final List<AdminFinanceEntry> entries;
  final DateTime generatedAt;

  AdminFinanceSnapshot({
    required this.currency,
    required this.monthStart,
    required this.monthIncomeCents,
    required this.monthExpenseCents,
    required this.monthBalanceCents,
    required this.totalIncomeCents,
    required this.totalExpenseCents,
    required this.totalBalanceCents,
    required List<AdminFinanceEntry> entries,
    required this.generatedAt,
  }) : entries = List<AdminFinanceEntry>.unmodifiable(entries);
}

class AdminRadioMondoTrack {
  final String id;
  final String title;
  final String audioUrl;
  final int sortOrder;
  final bool isEnabled;
  final String attribution;
  final String? licenseUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AdminRadioMondoTrack({
    required this.id,
    required this.title,
    required this.audioUrl,
    required this.sortOrder,
    required this.isEnabled,
    required this.attribution,
    required this.licenseUrl,
    required this.createdAt,
    required this.updatedAt,
  });
}

enum AdminAccountStatus {
  active,
  suspended,
  deleted,
  unknown,
}

extension AdminAccountStatusX on AdminAccountStatus {
  String get storageKey {
    switch (this) {
      case AdminAccountStatus.active:
        return 'active';
      case AdminAccountStatus.suspended:
        return 'suspended';
      case AdminAccountStatus.deleted:
        return 'deleted';
      case AdminAccountStatus.unknown:
        return 'unknown';
    }
  }

  bool get canReceiveAdminActions {
    switch (this) {
      case AdminAccountStatus.active:
      case AdminAccountStatus.suspended:
        return true;
      case AdminAccountStatus.deleted:
      case AdminAccountStatus.unknown:
        return false;
    }
  }

  static AdminAccountStatus fromStorageKey(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'active':
        return AdminAccountStatus.active;
      case 'suspended':
        return AdminAccountStatus.suspended;
      case 'deleted':
        return AdminAccountStatus.deleted;
      default:
        return AdminAccountStatus.unknown;
    }
  }
}

enum AdminAuditResult {
  success,
  failure,
  denied,
  noop,
  unknown,
}

extension AdminAuditResultX on AdminAuditResult {
  String get storageKey {
    switch (this) {
      case AdminAuditResult.success:
        return 'success';
      case AdminAuditResult.failure:
        return 'failure';
      case AdminAuditResult.denied:
        return 'denied';
      case AdminAuditResult.noop:
        return 'noop';
      case AdminAuditResult.unknown:
        return 'unknown';
    }
  }

  bool get isSuccessful =>
      this == AdminAuditResult.success || this == AdminAuditResult.noop;

  static AdminAuditResult fromStorageKey(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'success':
        return AdminAuditResult.success;
      case 'failure':
        return AdminAuditResult.failure;
      case 'denied':
        return AdminAuditResult.denied;
      case 'noop':
        return AdminAuditResult.noop;
      default:
        return AdminAuditResult.unknown;
    }
  }
}

class AdminDashboardSummary {
  final int pendingVerificationRequests;
  final int openReports;
  final int suspendedAccounts;
  final int totalUsers;
  final int staffUsers;

  final int newUsers24h;
  final int newUsers7d;
  final int recentSignIns24h;
  final int recentSignIns7d;

  final int pollsCreated24h;
  final int pollsCreated7d;
  final int postsCreated24h;
  final int postsCreated7d;

  final int adminActions24h;
  final int adminActions7d;

  final DateTime generatedAt;

  const AdminDashboardSummary({
    required this.pendingVerificationRequests,
    required this.openReports,
    required this.suspendedAccounts,
    required this.totalUsers,
    required this.staffUsers,
    required this.newUsers24h,
    required this.newUsers7d,
    required this.recentSignIns24h,
    required this.recentSignIns7d,
    required this.pollsCreated24h,
    required this.pollsCreated7d,
    required this.postsCreated24h,
    required this.postsCreated7d,
    required this.adminActions24h,
    required this.adminActions7d,
    required this.generatedAt,
  })  : assert(pendingVerificationRequests >= 0),
        assert(openReports >= 0),
        assert(suspendedAccounts >= 0),
        assert(totalUsers >= 0),
        assert(staffUsers >= 0),
        assert(staffUsers <= totalUsers),
        assert(newUsers24h >= 0),
        assert(newUsers7d >= 0),
        assert(recentSignIns24h >= 0),
        assert(recentSignIns7d >= 0),
        assert(pollsCreated24h >= 0),
        assert(pollsCreated7d >= 0),
        assert(postsCreated24h >= 0),
        assert(postsCreated7d >= 0),
        assert(adminActions24h >= 0),
        assert(adminActions7d >= 0);

  int get pendingWork => pendingVerificationRequests + openReports;

  int get regularUsers => totalUsers - staffUsers;
}

enum AdminReportStatus {
  open,
  inReview,
  resolved,
  dismissed,
  unknown,
}

extension AdminReportStatusX on AdminReportStatus {
  String get storageKey {
    switch (this) {
      case AdminReportStatus.open:
        return 'open';
      case AdminReportStatus.inReview:
        return 'in_review';
      case AdminReportStatus.resolved:
        return 'resolved';
      case AdminReportStatus.dismissed:
        return 'dismissed';
      case AdminReportStatus.unknown:
        return 'unknown';
    }
  }

  bool get isPending {
    return this == AdminReportStatus.open || this == AdminReportStatus.inReview;
  }

  static AdminReportStatus fromStorageKey(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'open':
        return AdminReportStatus.open;
      case 'in_review':
        return AdminReportStatus.inReview;
      case 'resolved':
        return AdminReportStatus.resolved;
      case 'dismissed':
        return AdminReportStatus.dismissed;
      default:
        return AdminReportStatus.unknown;
    }
  }
}

enum AdminReportTargetType {
  poll,
  post,
  news,
  unknown,
}

extension AdminReportTargetTypeX on AdminReportTargetType {
  String get storageKey {
    switch (this) {
      case AdminReportTargetType.poll:
        return 'poll';
      case AdminReportTargetType.post:
        return 'post';
      case AdminReportTargetType.news:
        return 'news';
      case AdminReportTargetType.unknown:
        return 'unknown';
    }
  }

  static AdminReportTargetType fromStorageKey(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'poll':
        return AdminReportTargetType.poll;
      case 'post':
        return AdminReportTargetType.post;
      case 'news':
        return AdminReportTargetType.news;
      default:
        return AdminReportTargetType.unknown;
    }
  }
}

enum AdminReportDecision {
  noViolation,
  violationConfirmed,
  escalateToAdmin,
  unknown,
}

extension AdminReportDecisionX on AdminReportDecision {
  String get storageKey {
    switch (this) {
      case AdminReportDecision.noViolation:
        return 'no_violation';
      case AdminReportDecision.violationConfirmed:
        return 'violation_confirmed';
      case AdminReportDecision.escalateToAdmin:
        return 'escalate_to_admin';
      case AdminReportDecision.unknown:
        return 'unknown';
    }
  }

  static AdminReportDecision fromStorageKey(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'no_violation':
        return AdminReportDecision.noViolation;
      case 'violation_confirmed':
        return AdminReportDecision.violationConfirmed;
      case 'escalate_to_admin':
        return AdminReportDecision.escalateToAdmin;
      default:
        return AdminReportDecision.unknown;
    }
  }
}

enum AdminReportResolution {
  noAccountAction,
  accountSuspended,
  logoutForced,
  accountDeleted,
  unknown,
}

extension AdminReportResolutionX on AdminReportResolution {
  String get storageKey {
    switch (this) {
      case AdminReportResolution.noAccountAction:
        return 'no_account_action';
      case AdminReportResolution.accountSuspended:
        return 'account_suspended';
      case AdminReportResolution.logoutForced:
        return 'logout_forced';
      case AdminReportResolution.accountDeleted:
        return 'account_deleted';
      case AdminReportResolution.unknown:
        return 'unknown';
    }
  }

  static AdminReportResolution fromStorageKey(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'no_account_action':
        return AdminReportResolution.noAccountAction;
      case 'account_suspended':
        return AdminReportResolution.accountSuspended;
      case 'logout_forced':
        return AdminReportResolution.logoutForced;
      case 'account_deleted':
        return AdminReportResolution.accountDeleted;
      default:
        return AdminReportResolution.unknown;
    }
  }
}

class AdminReportEntry {
  final String id;
  final AdminReportTargetType targetType;
  final String targetId;
  final String reporterUserId;
  final String? reportedUserId;
  final String? reportedDisplayName;
  final String? reportedUsername;
  final String? reportedAvatarUrl;
  final ActorType? reportedActorType;
  final VerificationLevel? reportedVerificationLevel;
  final String? targetTitle;
  final String reason;
  final AdminReportStatus status;
  final AdminReportDecision? moderationDecision;
  final String? reviewNote;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final bool contentIsHidden;
  final DateTime? contentVisibilityUpdatedAt;
  final int? contentVisibilityVersion;
  final DateTime createdAt;

  const AdminReportEntry({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.reporterUserId,
    this.reportedUserId,
    this.reportedDisplayName,
    this.reportedUsername,
    this.reportedAvatarUrl,
    this.reportedActorType,
    this.reportedVerificationLevel,
    this.targetTitle,
    required this.reason,
    required this.status,
    this.moderationDecision,
    this.reviewNote,
    this.reviewedBy,
    this.reviewedAt,
    this.contentIsHidden = false,
    this.contentVisibilityUpdatedAt,
    this.contentVisibilityVersion,
    required this.createdAt,
  });

  bool get hasReportedUser =>
      reportedUserId != null && reportedUserId!.trim().isNotEmpty;

  bool get hasOriginalTarget => targetId.trim().isNotEmpty;

  bool get hasModerationDecision => moderationDecision != null;

  bool get canRecordModerationDecision =>
      status.isPending && moderationDecision == null;

  bool get isAwaitingAdminDecision =>
      status == AdminReportStatus.inReview &&
      moderationDecision == AdminReportDecision.escalateToAdmin;

  bool get canResolveAdminEscalation => isAwaitingAdminDecision;

  bool get canChangeContentVisibility =>
      moderationDecision == AdminReportDecision.violationConfirmed &&
      targetType != AdminReportTargetType.unknown &&
      hasOriginalTarget;
}

class AdminReportQueuePage {
  final List<AdminReportEntry> reports;
  final int limit;
  final int offset;
  final int returnedCount;
  final int totalCount;
  final bool hasMore;

  AdminReportQueuePage({
    required List<AdminReportEntry> reports,
    required this.limit,
    required this.offset,
    required this.returnedCount,
    required this.totalCount,
    required this.hasMore,
  })  : assert(limit > 0),
        assert(offset >= 0),
        assert(returnedCount >= 0),
        assert(totalCount >= 0),
        reports = List<AdminReportEntry>.unmodifiable(reports);

  bool get hasPrevious => offset > 0;
}

class AdminUserSummary {
  final String id;
  final String? displayName;
  final String? username;
  final String? avatarUrl;
  final Role systemRole;
  final Role mirrorRole;
  final bool roleSynchronized;
  final ActorType actorType;
  final VerificationLevel verificationLevel;
  final VerificationStatus verificationStatus;
  final AdminAccountStatus accountStatus;
  final DateTime? suspendedUntil;
  final DateTime createdAt;

  const AdminUserSummary({
    required this.id,
    this.displayName,
    this.username,
    this.avatarUrl,
    required this.systemRole,
    required this.mirrorRole,
    required this.roleSynchronized,
    required this.actorType,
    required this.verificationLevel,
    required this.verificationStatus,
    required this.accountStatus,
    this.suspendedUntil,
    required this.createdAt,
  });

  bool get isStaff => systemRole.isStaff;
  bool get isAdmin => systemRole == Role.admin;
  bool get isSuspended => accountStatus == AdminAccountStatus.suspended;
  bool get isDeleted => accountStatus == AdminAccountStatus.deleted;

  bool get canReceiveAdminActions =>
      roleSynchronized && !isAdmin && accountStatus.canReceiveAdminActions;
}

class AdminUserDetail {
  final String id;
  final String? email;
  final DateTime? emailConfirmedAt;
  final DateTime? lastSignInAt;
  final String? displayName;
  final String? username;
  final String? avatarUrl;
  final Role systemRole;
  final Role mirrorRole;
  final bool roleSynchronized;
  final ActorType actorType;
  final VerificationLevel verificationLevel;
  final VerificationStatus verificationStatus;
  final AdminAccountStatus accountStatus;
  final DateTime? suspendedUntil;
  final DateTime createdAt;

  // Optional operational/moderation insight fields. They are nullable so the
  // Flutter client stays backward-compatible while the protected backend read
  // model is deployed.
  final int? reportsReceivedTotal;
  final int? reportsReceivedPending;
  final int? confirmedViolationsTotal;
  final int? reportsFiledTotal;
  final int? pollsCreatedTotal;
  final int? postsCreatedTotal;
  final int? commentsCreatedTotal;
  final int? adminActionsTotal;
  final DateTime? lastReportReceivedAt;

  const AdminUserDetail({
    required this.id,
    this.email,
    this.emailConfirmedAt,
    this.lastSignInAt,
    this.displayName,
    this.username,
    this.avatarUrl,
    required this.systemRole,
    required this.mirrorRole,
    required this.roleSynchronized,
    required this.actorType,
    required this.verificationLevel,
    required this.verificationStatus,
    required this.accountStatus,
    this.suspendedUntil,
    required this.createdAt,
    this.reportsReceivedTotal,
    this.reportsReceivedPending,
    this.confirmedViolationsTotal,
    this.reportsFiledTotal,
    this.pollsCreatedTotal,
    this.postsCreatedTotal,
    this.commentsCreatedTotal,
    this.adminActionsTotal,
    this.lastReportReceivedAt,
  });

  bool get isStaff => systemRole.isStaff;
  bool get isAdmin => systemRole == Role.admin;
  bool get isSuspended => accountStatus == AdminAccountStatus.suspended;
  bool get isDeleted => accountStatus == AdminAccountStatus.deleted;

  bool get canReceiveAdminActions =>
      roleSynchronized && !isAdmin && accountStatus.canReceiveAdminActions;

  AdminUserSummary toSummary() {
    return AdminUserSummary(
      id: id,
      displayName: displayName,
      username: username,
      avatarUrl: avatarUrl,
      systemRole: systemRole,
      mirrorRole: mirrorRole,
      roleSynchronized: roleSynchronized,
      actorType: actorType,
      verificationLevel: verificationLevel,
      verificationStatus: verificationStatus,
      accountStatus: accountStatus,
      suspendedUntil: suspendedUntil,
      createdAt: createdAt,
    );
  }
}

class AdminAuditEntry {
  final String id;
  final String actorUserId;
  final Role actorRole;
  final String action;
  final String targetType;
  final String? targetId;
  final Map<String, Object?> previousValue;
  final Map<String, Object?> newValue;
  final String reason;
  final AdminAuditResult result;
  final String? errorCode;
  final DateTime createdAt;

  AdminAuditEntry({
    required this.id,
    required this.actorUserId,
    required this.actorRole,
    required this.action,
    required this.targetType,
    this.targetId,
    Map<String, Object?> previousValue = const <String, Object?>{},
    Map<String, Object?> newValue = const <String, Object?>{},
    required this.reason,
    required this.result,
    this.errorCode,
    required this.createdAt,
  })  : previousValue = Map<String, Object?>.unmodifiable(previousValue),
        newValue = Map<String, Object?>.unmodifiable(newValue);

  bool get succeeded => result.isSuccessful;
}
