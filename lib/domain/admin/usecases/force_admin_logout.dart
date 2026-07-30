import 'package:sociale_vote/domain/admin/repositories/admin_repository.dart';

class ForceAdminLogout {
  static const int maximumReasonLength = 1000;

  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  final AdminRepository _repository;

  const ForceAdminLogout(this._repository);

  Future<void> call({
    required String operationId,
    required String targetUserId,
    required String reason,
  }) {
    final normalizedReason = reason.trim();

    if (normalizedReason.isEmpty ||
        normalizedReason.length > maximumReasonLength) {
      throw ArgumentError.value(
        reason,
        'reason',
      );
    }

    return _repository.forceLogout(
      operationId: _normalizeUuid(
        operationId,
        name: 'operationId',
      ),
      targetUserId: _normalizeUuid(
        targetUserId,
        name: 'targetUserId',
      ),
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
