import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sociale_vote/core/supabase/supabase_client.dart';
import 'package:sociale_vote/domain/admin/entities/admin_entities.dart';
import 'package:sociale_vote/domain/admin/repositories/admin_repository.dart';
import 'package:sociale_vote/domain/identity/value_objects/actor_type.dart';
import 'package:sociale_vote/domain/identity/value_objects/role.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_level.dart';
import 'package:sociale_vote/domain/identity/value_objects/verification_status.dart';

class AdminRepositoryException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final bool retryable;

  const AdminRepositoryException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.retryable = false,
  });

  @override
  String toString() {
    final details = <String>[
      if (statusCode != null) 'status: $statusCode',
      if (errorCode != null) 'code: $errorCode',
    ];

    return details.isEmpty
        ? 'AdminRepositoryException: $message'
        : 'AdminRepositoryException(${details.join(', ')}): $message';
  }
}

class AdminRepositoryImpl implements AdminRepository {
  static const String _adminUsersFunction = 'admin-users';
  static const String _adminReadFunction = 'admin-read';
  static const String _adminReportActionsFunction = 'admin-report-actions';
  static const String _setSystemRoleFunction = 'set-system-role';
  static const String _adminAccountActionsFunction = 'admin-account-actions';
  static const String _adminDeleteAccountFunction = 'admin-delete-account';

  final SupabaseClient _client;

  AdminRepositoryImpl({
    SupabaseClient? client,
  }) : _client = client ?? AppSupabase.client;

  @override
  Future<AdminDashboardSummary> getDashboardSummary() async {
    final data = await _invoke(
      _adminReadFunction,
      const <String, Object?>{
        'operation': 'dashboard',
      },
    );
    _requireSuccess(data);

    final summary = _readRequiredObject(
      data,
      'summary',
    );

    return AdminDashboardSummary(
      pendingVerificationRequests: _readRequiredNonNegativeInt(
        summary,
        'pendingVerificationRequests',
      ),
      openReports: _readRequiredNonNegativeInt(
        summary,
        'openReports',
      ),
      suspendedAccounts: _readRequiredNonNegativeInt(
        summary,
        'suspendedAccounts',
      ),
      totalUsers: _readRequiredNonNegativeInt(
        summary,
        'totalUsers',
      ),
      staffUsers: _readRequiredNonNegativeInt(
        summary,
        'staffUsers',
      ),
      newUsers24h: _readRequiredNonNegativeInt(
        summary,
        'newUsers24h',
      ),
      newUsers7d: _readRequiredNonNegativeInt(
        summary,
        'newUsers7d',
      ),
      recentSignIns24h: _readRequiredNonNegativeInt(
        summary,
        'recentSignIns24h',
      ),
      recentSignIns7d: _readRequiredNonNegativeInt(
        summary,
        'recentSignIns7d',
      ),
      pollsCreated24h: _readRequiredNonNegativeInt(
        summary,
        'pollsCreated24h',
      ),
      pollsCreated7d: _readRequiredNonNegativeInt(
        summary,
        'pollsCreated7d',
      ),
      postsCreated24h: _readRequiredNonNegativeInt(
        summary,
        'postsCreated24h',
      ),
      postsCreated7d: _readRequiredNonNegativeInt(
        summary,
        'postsCreated7d',
      ),
      adminActions24h: _readRequiredNonNegativeInt(
        summary,
        'adminActions24h',
      ),
      adminActions7d: _readRequiredNonNegativeInt(
        summary,
        'adminActions7d',
      ),
      generatedAt: _readRequiredDateTime(
        summary,
        'generatedAt',
      ),
    );
  }

  @override
  Future<AdminUserSearchPage> searchUsers({
    String? query,
    int page = 1,
    int perPage = 25,
  }) async {
    final data = await _invoke(
      _adminUsersFunction,
      <String, Object?>{
        'query': query,
        'page': page,
        'perPage': perPage,
      },
    );
    _requireSuccess(data);

    final userRows = _readRequiredObjectList(
      data,
      'users',
    );
    final pagination = _readRequiredObject(
      data,
      'pagination',
    );

    return AdminUserSearchPage(
      users: userRows.map(_mapUserSummary).toList(growable: false),
      page: _readRequiredPositiveInt(
        pagination,
        'page',
      ),
      perPage: _readRequiredPositiveInt(
        pagination,
        'perPage',
      ),
      totalCount: _readRequiredNonNegativeInt(
        pagination,
        'totalCount',
      ),
      totalPages: _readRequiredNonNegativeInt(
        pagination,
        'totalPages',
      ),
    );
  }

  @override
  Future<AdminUserDetail> getUserDetail({
    required String userId,
  }) async {
    final data = await _invoke(
      _adminReadFunction,
      <String, Object?>{
        'operation': 'user_detail',
        'targetUserId': userId,
      },
    );
    _requireSuccess(data);

    return _mapUserDetail(
      _readRequiredObject(
        data,
        'user',
      ),
    );
  }

  @override
  Future<AdminReportQueuePage> getReportQueue({
    AdminReportStatus? status,
    AdminReportTargetType? targetType,
    int limit = 25,
    int offset = 0,
  }) async {
    final data = await _invoke(
      _adminReadFunction,
      <String, Object?>{
        'operation': 'reports',
        'filters': <String, Object?>{
          'status': status?.storageKey,
          'targetType': targetType?.storageKey,
        },
        'limit': limit,
        'offset': offset,
      },
    );
    _requireSuccess(data);

    final reportRows = _readRequiredObjectList(
      data,
      'reports',
    );
    final pagination = _readRequiredObject(
      data,
      'pagination',
    );

    return AdminReportQueuePage(
      reports: reportRows.map(_mapReportEntry).toList(growable: false),
      limit: _readRequiredPositiveInt(
        pagination,
        'limit',
      ),
      offset: _readRequiredNonNegativeInt(
        pagination,
        'offset',
      ),
      returnedCount: _readRequiredNonNegativeInt(
        pagination,
        'returnedCount',
      ),
      totalCount: _readRequiredNonNegativeInt(
        pagination,
        'totalCount',
      ),
      hasMore: _readRequiredBool(
        pagination,
        'hasMore',
      ),
    );
  }

  @override
  Future<AdminReportQueuePage> getEscalatedReportQueue({
    int limit = 25,
    int offset = 0,
  }) async {
    final data = await _invoke(
      _adminReadFunction,
      <String, Object?>{
        'operation': 'escalated_reports',
        'limit': limit,
        'offset': offset,
      },
    );
    _requireSuccess(data);

    final reportRows = _readRequiredObjectList(
      data,
      'reports',
    );
    final pagination = _readRequiredObject(
      data,
      'pagination',
    );

    return AdminReportQueuePage(
      reports: reportRows.map(_mapReportEntry).toList(growable: false),
      limit: _readRequiredPositiveInt(
        pagination,
        'limit',
      ),
      offset: _readRequiredNonNegativeInt(
        pagination,
        'offset',
      ),
      returnedCount: _readRequiredNonNegativeInt(
        pagination,
        'returnedCount',
      ),
      totalCount: _readRequiredNonNegativeInt(
        pagination,
        'totalCount',
      ),
      hasMore: _readRequiredBool(
        pagination,
        'hasMore',
      ),
    );
  }

  @override
  Future<void> recordReportDecision({
    required String reportId,
    required AdminReportDecision decision,
    required String reviewNote,
  }) async {
    final data = await _invoke(
      _adminReportActionsFunction,
      <String, Object?>{
        'reportId': reportId,
        'decision': decision.storageKey,
        'reviewNote': reviewNote,
      },
    );
    _requireSuccess(data);
  }

  @override
  Future<void> resolveEscalatedReport({
    required String reportId,
    required AdminReportResolution resolution,
    required String resolutionNote,
  }) async {
    final data = await _invoke(
      _adminReportActionsFunction,
      <String, Object?>{
        'reportId': reportId,
        'adminResolution': resolution.storageKey,
        'adminResolutionNote': resolutionNote,
      },
    );
    _requireSuccess(data);
  }

  @override
  Future<void> setReportContentVisibility({
    required String reportId,
    required bool isHidden,
    required String reason,
  }) async {
    final data = await _invoke(
      _adminReportActionsFunction,
      <String, Object?>{
        'reportId': reportId,
        'contentAction': isHidden ? 'hide' : 'restore',
        'actionReason': reason,
      },
    );
    _requireSuccess(data);
  }

  @override
  Future<void> changeSystemRole({
    required String operationId,
    required String targetUserId,
    required Role role,
    required String reason,
  }) async {
    final data = await _invoke(
      _setSystemRoleFunction,
      <String, Object?>{
        'operationId': operationId,
        'targetUserId': targetUserId,
        'role': role.storageKey,
        'reason': reason,
      },
    );
    _requireSuccess(data);
  }

  @override
  Future<void> setPublicIdentity({
    required String operationId,
    required String targetUserId,
    required ActorType actorType,
    required VerificationLevel verificationLevel,
    required String reason,
  }) async {
    final data = await _invoke(
      _adminAccountActionsFunction,
      <String, Object?>{
        'operationId': operationId,
        'targetUserId': targetUserId,
        'action': 'set_public_identity',
        'actorType': actorType.storageKey,
        'verificationLevel': verificationLevel.storageKey,
        'reason': reason,
      },
    );
    _requireSuccess(data);
  }

  @override
  Future<void> suspendAccount({
    required String operationId,
    required String targetUserId,
    required DateTime suspendedUntil,
    required String reason,
  }) {
    return _applyAccountAction(
      operationId: operationId,
      targetUserId: targetUserId,
      action: 'suspend',
      reason: reason,
      suspendedUntil: suspendedUntil,
    );
  }

  @override
  Future<void> reactivateAccount({
    required String operationId,
    required String targetUserId,
    required String reason,
  }) {
    return _applyAccountAction(
      operationId: operationId,
      targetUserId: targetUserId,
      action: 'reactivate',
      reason: reason,
    );
  }

  @override
  Future<void> forceLogout({
    required String operationId,
    required String targetUserId,
    required String reason,
  }) {
    return _applyAccountAction(
      operationId: operationId,
      targetUserId: targetUserId,
      action: 'force_logout',
      reason: reason,
    );
  }

  @override
  Future<void> deleteAccount({
    required String operationId,
    required String targetUserId,
    required String reason,
    required String confirmation,
    required String accountIdentifier,
  }) async {
    final data = await _invoke(
      _adminDeleteAccountFunction,
      <String, Object?>{
        'operationId': operationId,
        'targetUserId': targetUserId,
        'reason': reason,
        'confirmation': confirmation,
        'accountIdentifier': accountIdentifier,
      },
    );
    _requireSuccess(data);
  }

  @override
  Future<AdminWorkspaceEntitlement?> getWorkspaceEntitlement({
    required String targetUserId,
  }) async {
    final raw = await _client.rpc(
      'admin_get_workspace_entitlement',
      params: <String, dynamic>{'p_target_user_id': targetUserId.trim()},
    );
    if (raw == null) return null;
    final row = raw is Map<String, dynamic>
        ? raw
        : raw is Map
            ? Map<String, dynamic>.from(raw)
            : const <String, dynamic>{};
    if (row.isEmpty) return null;
    return _workspaceEntitlementFromRow(row);
  }

  @override
  Future<AdminWorkspaceEntitlement> setWorkspaceEntitlement({
    required String targetUserId,
    required AdminWorkspaceEntitlementStatus entitlementStatus,
    DateTime? expiresAt,
    required String reason,
  }) async {
    final raw = await _client.rpc(
      'admin_set_workspace_entitlement',
      params: <String, dynamic>{
        'p_target_user_id': targetUserId.trim(),
        'p_entitlement_status': entitlementStatus.storageKey,
        'p_expires_at': expiresAt?.toUtc().toIso8601String(),
        'p_reason': reason.trim(),
      },
    );
    final row = raw is Map<String, dynamic>
        ? raw
        : raw is Map
            ? Map<String, dynamic>.from(raw)
            : const <String, dynamic>{};
    if (row.isEmpty) {
      throw const AdminRepositoryException(
        message: 'Workspace entitlement response is empty.',
      );
    }
    return _workspaceEntitlementFromRow(row);
  }

  AdminWorkspaceEntitlement _workspaceEntitlementFromRow(
    Map<String, dynamic> row,
  ) {
    DateTime? readDate(String key) {
      final value = row[key]?.toString().trim();
      if (value == null || value.isEmpty) return null;
      return DateTime.tryParse(value)?.toLocal();
    }

    return AdminWorkspaceEntitlement(
      organizationId: row['organization_id']?.toString().trim() ?? '',
      organizationName: row['organization_name']?.toString().trim() ?? '',
      verificationStatus:
          row['verification_status']?.toString().trim() ?? 'unknown',
      workspaceId: row['workspace_id']?.toString().trim() ?? '',
      entitlementStatus: AdminWorkspaceEntitlementStatusX.fromStorageKey(
        row['entitlement_status']?.toString(),
      ),
      workspaceStatus: row['workspace_status']?.toString().trim() ?? 'unknown',
      planKey: row['plan_key']?.toString().trim() ?? '',
      commercialMode: row['commercial_mode']?.toString().trim() ?? '',
      billingEnabled: row['billing_enabled'] == true,
      entitlementStartedAt: readDate('entitlement_started_at'),
      entitlementExpiresAt: readDate('entitlement_expires_at'),
    );
  }

  @override
  Future<AdminFinanceSnapshot> getFinanceSnapshot() async {
    final raw = await _client.rpc('admin_finance_snapshot');
    final row = _asObject(raw, context: 'admin_finance_snapshot');
    final entries = _readRequiredObjectList(row, 'entries')
        .map(_mapFinanceEntry)
        .toList(growable: false);

    return AdminFinanceSnapshot(
      currency: _readRequiredString(row, 'currency'),
      monthStart: _readRequiredDateTime(row, 'month_start'),
      monthIncomeCents: _readRequiredNonNegativeInt(row, 'month_income_cents'),
      monthExpenseCents:
          _readRequiredNonNegativeInt(row, 'month_expense_cents'),
      monthBalanceCents: _readRequiredSignedInt(row, 'month_balance_cents'),
      totalIncomeCents: _readRequiredNonNegativeInt(row, 'total_income_cents'),
      totalExpenseCents:
          _readRequiredNonNegativeInt(row, 'total_expense_cents'),
      totalBalanceCents: _readRequiredSignedInt(row, 'total_balance_cents'),
      entries: entries,
      generatedAt: _readRequiredDateTime(row, 'generated_at'),
    );
  }

  @override
  Future<void> addFinanceEntry({
    required DateTime occurredOn,
    required AdminFinanceDirection direction,
    required int amountCents,
    required String category,
    String? counterparty,
    String? note,
    required String reason,
  }) async {
    await _client.rpc(
      'admin_finance_add_entry',
      params: <String, dynamic>{
        'p_occurred_on': _dateOnly(occurredOn),
        'p_direction': direction.storageKey,
        'p_amount_cents': amountCents,
        'p_category': category.trim(),
        'p_counterparty': _nullableString(counterparty),
        'p_note': _nullableString(note),
        'p_reason': reason.trim(),
      },
    );
  }

  @override
  Future<void> voidFinanceEntry({
    required String entryId,
    required String reason,
  }) async {
    await _client.rpc(
      'admin_finance_void_entry',
      params: <String, dynamic>{
        'p_entry_id': entryId.trim(),
        'p_reason': reason.trim(),
      },
    );
  }

  @override
  Future<List<AdminRadioMondoTrack>> getRadioMondoTracks() async {
    final raw = await _client.rpc('admin_radio_mondo_list');
    if (raw is! List) {
      throw _invalidResponse('admin_radio_mondo_list');
    }
    return raw
        .map((item) => _mapRadioMondoTrack(
              _asObject(item, context: 'admin_radio_mondo_list'),
            ))
        .toList(growable: false);
  }

  @override
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
  }) async {
    final raw = await _client.rpc(
      'admin_radio_mondo_upsert',
      params: <String, dynamic>{
        'p_track_id': _nullableString(trackId),
        'p_title': title.trim(),
        'p_audio_url': audioUrl.trim(),
        'p_sort_order': sortOrder,
        'p_is_enabled': isEnabled,
        'p_attribution': attribution.trim(),
        'p_license_url': _nullableString(licenseUrl),
        'p_rights_confirmed': rightsConfirmed,
        'p_reason': reason.trim(),
      },
    );
    return _mapRadioMondoTrack(
      _asObject(raw, context: 'admin_radio_mondo_upsert'),
    );
  }

  @override
  Future<void> setRadioMondoTrackEnabled({
    required String trackId,
    required bool isEnabled,
    required String reason,
  }) async {
    await _client.rpc(
      'admin_radio_mondo_set_enabled',
      params: <String, dynamic>{
        'p_track_id': trackId.trim(),
        'p_is_enabled': isEnabled,
        'p_reason': reason.trim(),
      },
    );
  }

  AdminFinanceEntry _mapFinanceEntry(Map<String, Object?> row) {
    return AdminFinanceEntry(
      id: _readRequiredString(row, 'id'),
      occurredOn: _readRequiredDateTime(row, 'occurred_on'),
      direction: AdminFinanceDirectionX.fromStorageKey(
        _readOptionalString(row, 'direction'),
      ),
      amountCents: _readRequiredNonNegativeInt(row, 'amount_cents'),
      currency: _readRequiredString(row, 'currency'),
      category: _readRequiredString(row, 'category'),
      counterparty: _readOptionalString(row, 'counterparty'),
      note: _readOptionalString(row, 'note'),
      createdAt: _readRequiredDateTime(row, 'created_at'),
    );
  }

  AdminRadioMondoTrack _mapRadioMondoTrack(Map<String, Object?> row) {
    return AdminRadioMondoTrack(
      id: _readRequiredString(row, 'id'),
      title: _readRequiredString(row, 'title'),
      audioUrl: _readRequiredString(row, 'audio_url'),
      sortOrder: _readRequiredNonNegativeInt(row, 'sort_order'),
      isEnabled: _readRequiredBool(row, 'is_enabled'),
      attribution: _readRequiredString(row, 'attribution'),
      licenseUrl: _readOptionalString(row, 'license_url'),
      createdAt: _readRequiredDateTime(row, 'created_at'),
      updatedAt: _readRequiredDateTime(row, 'updated_at'),
    );
  }

  String _dateOnly(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  String? _nullableString(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  @override
  Future<List<AdminAuditEntry>> getAuditEntries({
    String? actorUserId,
    String? action,
    String? targetId,
    AdminAuditResult? result,
    DateTime? from,
    DateTime? to,
    int limit = 50,
    int offset = 0,
  }) async {
    final data = await _invoke(
      _adminReadFunction,
      <String, Object?>{
        'operation': 'audit',
        'filters': <String, Object?>{
          'actorUserId': actorUserId,
          'action': action,
          'targetId': targetId,
          'result': result?.storageKey,
          'from': from?.toUtc().toIso8601String(),
          'to': to?.toUtc().toIso8601String(),
        },
        'limit': limit,
        'offset': offset,
      },
    );
    _requireSuccess(data);

    return _readRequiredObjectList(
      data,
      'entries',
    ).map(_mapAuditEntry).toList(growable: false);
  }

  Future<void> _applyAccountAction({
    required String operationId,
    required String targetUserId,
    required String action,
    required String reason,
    DateTime? suspendedUntil,
  }) async {
    final data = await _invoke(
      _adminAccountActionsFunction,
      <String, Object?>{
        'operationId': operationId,
        'targetUserId': targetUserId,
        'action': action,
        'reason': reason,
        if (suspendedUntil != null)
          'suspendedUntil': suspendedUntil.toUtc().toIso8601String(),
      },
    );
    _requireSuccess(data);
  }

  Future<Map<String, Object?>> _invoke(
    String functionName,
    Map<String, Object?> body,
  ) async {
    final session = _client.auth.currentSession;

    if (session == null) {
      throw const AdminRepositoryException(
        message: 'An authenticated session is required.',
        statusCode: 401,
        errorCode: 'session_required',
      );
    }

    try {
      final response = await _client.functions.invoke(
        functionName,
        body: body,
        headers: <String, String>{
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      return _asObject(
        response.data,
        context: functionName,
      );
    } on FunctionException catch (error) {
      throw _mapFunctionException(error);
    }
  }

  void _requireSuccess(Map<String, Object?> data) {
    if (data['success'] == true) {
      return;
    }

    throw _mapResponseFailure(data);
  }

  AdminUserSummary _mapUserSummary(
    Map<String, Object?> row,
  ) {
    return AdminUserSummary(
      id: _readRequiredString(row, 'userId'),
      displayName: _readOptionalString(row, 'displayName'),
      username: _readOptionalString(row, 'username'),
      avatarUrl: _readOptionalString(row, 'avatarUrl'),
      systemRole: RoleX.fromStorageKey(
        _readOptionalString(row, 'systemRole'),
      ),
      mirrorRole: RoleX.fromStorageKey(
        _readOptionalString(row, 'mirrorRole'),
      ),
      roleSynchronized: _readRequiredBool(
        row,
        'roleSynchronized',
      ),
      actorType: ActorTypeX.fromStorageKey(
        _readOptionalString(row, 'actorType'),
      ),
      verificationLevel: VerificationLevelX.fromStorageKey(
        _readOptionalString(row, 'verificationLevel'),
      ),
      verificationStatus: VerificationStatusX.fromStorageKey(
        _readOptionalString(row, 'verificationStatus'),
      ),
      accountStatus: AdminAccountStatusX.fromStorageKey(
        _readOptionalString(row, 'accountStatus'),
      ),
      suspendedUntil: _readOptionalDateTime(
        row,
        'suspendedUntil',
      ),
      createdAt: _readRequiredDateTime(
        row,
        'createdAt',
      ),
    );
  }

  AdminUserDetail _mapUserDetail(
    Map<String, Object?> row,
  ) {
    return AdminUserDetail(
      id: _readRequiredString(row, 'userId'),
      email: _readOptionalString(row, 'email'),
      emailConfirmedAt: _readOptionalDateTime(
        row,
        'emailConfirmedAt',
      ),
      lastSignInAt: _readOptionalDateTime(
        row,
        'lastSignInAt',
      ),
      displayName: _readOptionalString(row, 'displayName'),
      username: _readOptionalString(row, 'username'),
      avatarUrl: _readOptionalString(row, 'avatarUrl'),
      systemRole: RoleX.fromStorageKey(
        _readOptionalString(row, 'systemRole'),
      ),
      mirrorRole: RoleX.fromStorageKey(
        _readOptionalString(row, 'mirrorRole'),
      ),
      roleSynchronized: _readRequiredBool(
        row,
        'roleSynchronized',
      ),
      actorType: ActorTypeX.fromStorageKey(
        _readOptionalString(row, 'actorType'),
      ),
      verificationLevel: VerificationLevelX.fromStorageKey(
        _readOptionalString(row, 'verificationLevel'),
      ),
      verificationStatus: VerificationStatusX.fromStorageKey(
        _readOptionalString(row, 'verificationStatus'),
      ),
      accountStatus: AdminAccountStatusX.fromStorageKey(
        _readOptionalString(row, 'accountStatus'),
      ),
      suspendedUntil: _readOptionalDateTime(
        row,
        'suspendedUntil',
      ),
      createdAt: _readRequiredDateTime(
        row,
        'createdAt',
      ),
      reportsReceivedTotal: _readOptionalNonNegativeInt(
        row,
        'reportsReceivedTotal',
      ),
      reportsReceivedPending: _readOptionalNonNegativeInt(
        row,
        'reportsReceivedPending',
      ),
      confirmedViolationsTotal: _readOptionalNonNegativeInt(
        row,
        'confirmedViolationsTotal',
      ),
      reportsFiledTotal: _readOptionalNonNegativeInt(
        row,
        'reportsFiledTotal',
      ),
      pollsCreatedTotal: _readOptionalNonNegativeInt(
        row,
        'pollsCreatedTotal',
      ),
      postsCreatedTotal: _readOptionalNonNegativeInt(
        row,
        'postsCreatedTotal',
      ),
      commentsCreatedTotal: _readOptionalNonNegativeInt(
        row,
        'commentsCreatedTotal',
      ),
      adminActionsTotal: _readOptionalNonNegativeInt(
        row,
        'adminActionsTotal',
      ),
      lastReportReceivedAt: _readOptionalDateTime(
        row,
        'lastReportReceivedAt',
      ),
    );
  }

  AdminReportEntry _mapReportEntry(
    Map<String, Object?> row,
  ) {
    final reportedActorType = _readOptionalString(
      row,
      'reportedActorType',
    );
    final reportedVerificationLevel = _readOptionalString(
      row,
      'reportedVerificationLevel',
    );

    return AdminReportEntry(
      id: _readRequiredString(row, 'reportId'),
      targetType: AdminReportTargetTypeX.fromStorageKey(
        _readOptionalString(row, 'targetType'),
      ),
      targetId: _readRequiredString(row, 'targetId'),
      reporterUserId: _readRequiredString(row, 'reporterUserId'),
      reportedUserId: _readOptionalString(row, 'reportedUserId'),
      reportedDisplayName: _readOptionalString(
        row,
        'reportedDisplayName',
      ),
      reportedUsername: _readOptionalString(row, 'reportedUsername'),
      reportedAvatarUrl: _readOptionalString(row, 'reportedAvatarUrl'),
      reportedActorType: reportedActorType == null
          ? null
          : ActorTypeX.fromStorageKey(reportedActorType),
      reportedVerificationLevel: reportedVerificationLevel == null
          ? null
          : VerificationLevelX.fromStorageKey(
              reportedVerificationLevel,
            ),
      targetTitle: _readOptionalString(row, 'targetTitle'),
      reason: _readRequiredString(row, 'reason'),
      status: AdminReportStatusX.fromStorageKey(
        _readOptionalString(row, 'status'),
      ),
      moderationDecision: _mapOptionalReportDecision(
        row,
        'moderationDecision',
      ),
      reviewNote: _readOptionalString(row, 'reviewNote'),
      reviewedBy: _readOptionalString(row, 'reviewedBy'),
      reviewedAt: _readOptionalDateTime(row, 'reviewedAt'),
      contentIsHidden: _readRequiredBool(row, 'contentIsHidden'),
      contentVisibilityUpdatedAt: _readOptionalDateTime(
        row,
        'contentVisibilityUpdatedAt',
      ),
      contentVisibilityVersion: _readOptionalNonNegativeInt(
        row,
        'contentVisibilityVersion',
      ),
      createdAt: _readRequiredDateTime(
        row,
        'createdAt',
      ),
    );
  }

  AdminReportDecision? _mapOptionalReportDecision(
    Map<String, Object?> row,
    String key,
  ) {
    final value = _readOptionalString(row, key);
    if (value == null) {
      return null;
    }

    final decision = AdminReportDecisionX.fromStorageKey(value);
    return decision == AdminReportDecision.unknown ? null : decision;
  }

  AdminAuditEntry _mapAuditEntry(
    Map<String, Object?> row,
  ) {
    return AdminAuditEntry(
      id: _readRequiredString(row, 'id'),
      actorUserId: _readRequiredString(row, 'actorUserId'),
      actorRole: RoleX.fromStorageKey(
        _readOptionalString(row, 'actorRole'),
      ),
      action: _readRequiredString(row, 'action'),
      targetType: _readRequiredString(row, 'targetType'),
      targetId: _readOptionalString(row, 'targetId'),
      previousValue: _readOptionalObject(
        row,
        'previousValue',
      ),
      newValue: _readOptionalObject(
        row,
        'newValue',
      ),
      reason: _readRequiredString(row, 'reason'),
      result: AdminAuditResultX.fromStorageKey(
        _readOptionalString(row, 'result'),
      ),
      errorCode: _readOptionalString(row, 'errorCode'),
      createdAt: _readRequiredDateTime(
        row,
        'createdAt',
      ),
    );
  }

  AdminRepositoryException _mapFunctionException(
    FunctionException error,
  ) {
    final details = _tryAsObject(error.details);
    final statusCode = error.status;
    final errorCode = details == null
        ? _defaultErrorCode(statusCode)
        : _readFirstOptionalString(
              details,
              const <String>[
                'errorCode',
                'code',
              ],
            ) ??
            _defaultErrorCode(statusCode);
    final message = details == null
        ? _normalizeOptionalString(error.details?.toString()) ??
            _normalizeOptionalString(error.reasonPhrase) ??
            'Administrator service request failed.'
        : _readFirstOptionalString(
              details,
              const <String>[
                'error',
                'message',
              ],
            ) ??
            _normalizeOptionalString(error.reasonPhrase) ??
            'Administrator service request failed.';

    return AdminRepositoryException(
      message: message,
      statusCode: statusCode,
      errorCode: errorCode,
      retryable: details?['retryable'] == true || statusCode >= 500,
    );
  }

  AdminRepositoryException _mapResponseFailure(
    Map<String, Object?> data,
  ) {
    return AdminRepositoryException(
      message: _readFirstOptionalString(
            data,
            const <String>[
              'error',
              'message',
            ],
          ) ??
          'Administrator operation was rejected.',
      errorCode: _readFirstOptionalString(
        data,
        const <String>[
          'errorCode',
          'code',
        ],
      ),
      retryable: data['retryable'] == true,
    );
  }

  String _defaultErrorCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'invalid_request';
      case 401:
        return 'session_invalid';
      case 403:
        return 'access_denied';
      case 404:
        return 'not_found';
      case 409:
        return 'conflict';
      default:
        return statusCode >= 500 ? 'server_error' : 'request_failed';
    }
  }

  Map<String, Object?> _readRequiredObject(
    Map<String, Object?> source,
    String key,
  ) {
    return _asObject(
      source[key],
      context: key,
    );
  }

  Map<String, Object?> _readOptionalObject(
    Map<String, Object?> source,
    String key,
  ) {
    final value = source[key];
    if (value == null) {
      return const <String, Object?>{};
    }

    return _asObject(
      value,
      context: key,
    );
  }

  List<Map<String, Object?>> _readRequiredObjectList(
    Map<String, Object?> source,
    String key,
  ) {
    final value = source[key];

    if (value is! List) {
      throw _invalidResponse(key);
    }

    return value
        .map(
          (item) => _asObject(
            item,
            context: key,
          ),
        )
        .toList(growable: false);
  }

  Map<String, Object?> _asObject(
    Object? value, {
    required String context,
  }) {
    final object = _tryAsObject(value);
    if (object == null) {
      throw _invalidResponse(context);
    }

    return object;
  }

  Map<String, Object?>? _tryAsObject(Object? value) {
    if (value is! Map) {
      return null;
    }

    final result = <String, Object?>{};

    for (final entry in value.entries) {
      if (entry.key is! String) {
        return null;
      }
      result[entry.key as String] = entry.value;
    }

    return result;
  }

  String _readRequiredString(
    Map<String, Object?> source,
    String key,
  ) {
    final value = _readOptionalString(source, key);
    if (value == null) {
      throw _invalidResponse(key);
    }

    return value;
  }

  String? _readOptionalString(
    Map<String, Object?> source,
    String key,
  ) {
    return _normalizeOptionalString(source[key]);
  }

  String? _readFirstOptionalString(
    Map<String, Object?> source,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = _readOptionalString(source, key);
      if (value != null) {
        return value;
      }
    }

    return null;
  }

  String? _normalizeOptionalString(Object? value) {
    if (value is! String) {
      return null;
    }

    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  bool _readRequiredBool(
    Map<String, Object?> source,
    String key,
  ) {
    final value = source[key];
    if (value is! bool) {
      throw _invalidResponse(key);
    }

    return value;
  }

  int _readRequiredPositiveInt(
    Map<String, Object?> source,
    String key,
  ) {
    final value = _readRequiredNonNegativeInt(source, key);
    if (value == 0) {
      throw _invalidResponse(key);
    }

    return value;
  }

  int _readRequiredNonNegativeInt(
    Map<String, Object?> source,
    String key,
  ) {
    final value = source[key];
    final parsed = value is int
        ? value
        : value is String
            ? int.tryParse(value)
            : null;

    if (parsed == null || parsed < 0) {
      throw _invalidResponse(key);
    }

    return parsed;
  }

  int _readRequiredSignedInt(
    Map<String, Object?> source,
    String key,
  ) {
    final value = source[key];
    final parsed = value is int
        ? value
        : value is String
            ? int.tryParse(value)
            : null;

    if (parsed == null) {
      throw _invalidResponse(key);
    }

    return parsed;
  }

  int? _readOptionalNonNegativeInt(
    Map<String, Object?> source,
    String key,
  ) {
    final value = source[key];

    if (value == null) {
      return null;
    }

    final parsed = value is int
        ? value
        : value is String
            ? int.tryParse(value)
            : null;

    if (parsed == null || parsed < 0) {
      throw _invalidResponse(key);
    }

    return parsed;
  }

  DateTime _readRequiredDateTime(
    Map<String, Object?> source,
    String key,
  ) {
    final value = _readOptionalDateTime(source, key);
    if (value == null) {
      throw _invalidResponse(key);
    }

    return value;
  }

  DateTime? _readOptionalDateTime(
    Map<String, Object?> source,
    String key,
  ) {
    final value = source[key];

    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value.toLocal();
    }

    if (value is String) {
      return DateTime.tryParse(value)?.toLocal();
    }

    throw _invalidResponse(key);
  }

  AdminRepositoryException _invalidResponse(String context) {
    return AdminRepositoryException(
      message: 'Invalid administrator service response: $context.',
      errorCode: 'invalid_response',
    );
  }
}
