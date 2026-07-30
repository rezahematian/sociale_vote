import 'package:sociale_vote/domain/admin/entities/admin_entities.dart';
import 'package:sociale_vote/domain/admin/repositories/admin_repository.dart';

class LoadAdminAudit {
  static const int maximumActionLength = 80;
  static const int maximumTargetIdLength = 320;
  static const int maximumLimit = 100;

  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  static final RegExp _actionPattern = RegExp(
    r'^[a-z0-9_]+$',
  );

  final AdminRepository _repository;

  const LoadAdminAudit(this._repository);

  Future<List<AdminAuditEntry>> call({
    String? actorUserId,
    String? action,
    String? targetId,
    AdminAuditResult? result,
    DateTime? from,
    DateTime? to,
    int limit = 50,
    int offset = 0,
  }) {
    if (limit < 1 || limit > maximumLimit) {
      throw RangeError.range(
        limit,
        1,
        maximumLimit,
        'limit',
      );
    }

    if (offset < 0) {
      throw RangeError.value(
        offset,
        'offset',
      );
    }

    final normalizedActorUserId = _normalizeOptionalUuid(
      actorUserId,
      name: 'actorUserId',
    );
    final normalizedAction = _normalizeAction(action);
    final normalizedTargetId = targetId?.trim();
    final normalizedFrom = from?.toUtc();
    final normalizedTo = to?.toUtc();

    if (normalizedTargetId != null &&
        normalizedTargetId.length > maximumTargetIdLength) {
      throw ArgumentError.value(
        targetId,
        'targetId',
      );
    }

    if (normalizedFrom != null &&
        normalizedTo != null &&
        normalizedFrom.isAfter(normalizedTo)) {
      throw ArgumentError.value(
        from,
        'from',
      );
    }

    return _repository.getAuditEntries(
      actorUserId: normalizedActorUserId,
      action: normalizedAction,
      targetId: normalizedTargetId == null || normalizedTargetId.isEmpty
          ? null
          : normalizedTargetId,
      result: result,
      from: normalizedFrom,
      to: normalizedTo,
      limit: limit,
      offset: offset,
    );
  }

  static String? _normalizeOptionalUuid(
    String? value, {
    required String name,
  }) {
    final normalized = value?.trim().toLowerCase();

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    if (!_uuidPattern.hasMatch(normalized)) {
      throw ArgumentError.value(
        value,
        name,
      );
    }

    return normalized;
  }

  static String? _normalizeAction(String? value) {
    final normalized = value?.trim().toLowerCase();

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    if (normalized.length > maximumActionLength ||
        !_actionPattern.hasMatch(normalized)) {
      throw ArgumentError.value(
        value,
        'action',
      );
    }

    return normalized;
  }
}
