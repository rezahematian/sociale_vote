import 'package:sociale_vote/domain/admin/repositories/admin_repository.dart';
import 'package:sociale_vote/domain/identity/value_objects/role.dart';

class ChangeSystemRole {
  static const int maximumReasonLength = 1000;

  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  final AdminRepository _repository;

  const ChangeSystemRole(this._repository);

  Future<void> call({
    required String operationId,
    required String targetUserId,
    required Role role,
    required String reason,
  }) {
    final normalizedOperationId = _normalizeUuid(
      operationId,
      name: 'operationId',
    );
    final normalizedTargetUserId = _normalizeUuid(
      targetUserId,
      name: 'targetUserId',
    );
    final normalizedReason = reason.trim();

    if (normalizedReason.isEmpty ||
        normalizedReason.length > maximumReasonLength) {
      throw ArgumentError.value(
        reason,
        'reason',
      );
    }

    return _repository.changeSystemRole(
      operationId: normalizedOperationId,
      targetUserId: normalizedTargetUserId,
      role: role,
      reason: normalizedReason,
    );
  }

  static String _normalizeUuid(
    String value, {
    required String name,
  }) {
    final normalized = value.trim().toLowerCase();

    if (!_uuidPattern.hasMatch(normalized)) {
      throw ArgumentError.value(
        value,
        name,
      );
    }

    return normalized;
  }
}
