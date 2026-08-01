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
